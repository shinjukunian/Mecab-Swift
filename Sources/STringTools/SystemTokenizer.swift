//
//  SystemTokenizer.swift
//  
//
//  Created by Morten Bertz on 2020/07/07.
//

import Foundation

public extension String{
    
    func furiganaReplacements()->[FuriganaAnnotation]{
        let japaneseLocale=Locale(identifier: "ja_JP")
        
        let nsRange=NSRange((self.startIndex..<self.endIndex), in: self)
        
        let tokenizer=CFStringTokenizerCreate(nil, self as CFString, CFRange(location: nsRange.location, length: nsRange.length), kCFStringTokenizerUnitWordBoundary, japaneseLocale as CFLocale)
        
        var annotations=[FuriganaAnnotation]()
        
        var result=CFStringTokenizerAdvanceToNextToken(tokenizer)
        
        while !result.isEmpty {
            
            defer {
                result=CFStringTokenizerAdvanceToNextToken(tokenizer)
            }
            
            let cfRange=CFStringTokenizerGetCurrentTokenRange(tokenizer)
            guard var range=Range<String.Index>.init(NSRange(location: cfRange.location, length: cfRange.length), in: self) else{continue}
            let subString=String(self[range])
            
            guard subString.containsKanjiCharacters else{continue}
            
            let subTokenizer=CFStringTokenizerCreate(nil, subString as CFString, CFRange(location: 0, length: subString.count), kCFStringTokenizerUnitWordBoundary, japaneseLocale as CFLocale)
            var subStringResult=CFStringTokenizerAdvanceToNextToken(subTokenizer)
            
            var subTransliterations=[String]()
            while !subStringResult.isEmpty {
                defer {
                    subStringResult=CFStringTokenizerAdvanceToNextToken(subTokenizer)
                }
                
                let cTypeRef=CFStringTokenizerCopyCurrentTokenAttribute(subTokenizer, kCFStringTokenizerAttributeLatinTranscription)
                guard let typeRef=cTypeRef, CFGetTypeID(typeRef) == CFStringGetTypeID() else{continue}
                let latinString=typeRef as! CFString
                subTransliterations.append(latinString as String)

            }
            
            guard var transliteration=subTransliterations.joined().applyingTransform(.latinToHiragana, reverse: false) else{continue}
            
            let hiraganaRanges=subString.hiraganaRanges
            for hiraganaRange in hiraganaRanges{
                switch hiraganaRange {
                case _ where hiraganaRange.upperBound == subString.endIndex:
                    let trailingDistance=subString.distance(from: subString.endIndex, to: hiraganaRange.lowerBound)
                    let newEndIndex=self.index(range.upperBound, offsetBy: trailingDistance)
                    range=range.lowerBound..<newEndIndex
                    let transliterationEnd=transliteration.index(transliteration.endIndex, offsetBy: trailingDistance)
                    let newTransliterationRange=transliteration.startIndex..<transliterationEnd
                    let t2=transliteration[newTransliterationRange]
                    transliteration=String(t2)
                case _ where hiraganaRange.lowerBound == subString.startIndex:
                    let leadingDistance=subString.distance(from: subString.startIndex, to: hiraganaRange.upperBound)
                    let newStartIndex=self.index(range.lowerBound, offsetBy: leadingDistance)
                    range=newStartIndex..<range.upperBound
                    let transliterationStart=transliteration.index(transliteration.startIndex, offsetBy: leadingDistance)
                    let newTransliterationRange=transliterationStart..<transliteration.endIndex
                    let t2=transliteration[newTransliterationRange]
                    transliteration=String(t2)
                default:
                    let detectedCenterHiragana=subString[hiraganaRange]
                    transliteration = transliteration.replacingOccurrences(of: detectedCenterHiragana, with: "　")
                    
                    
//                    let leadingDistance=subString.distance(from: subString.startIndex, to: hiraganaRange.lowerBound)
//                    let trailingDistance=subString.distance(from: subString.endIndex, to: hiraganaRange.upperBound)
//                    let transliterationStart=transliteration.index(transliteration.startIndex, offsetBy: leadingDistance)
//                    let transliterationEnd=transliteration.index(transliteration.endIndex, offsetBy: trailingDistance)
//                    let newTransliterationRange=transliterationStart..<transliterationEnd
//                    let length=subString.distance(from: hiraganaRange.lowerBound, to: hiraganaRange.upperBound)
//                    let replacementString=String(repeatElement("　", count: length))
//                    transliteration.replaceSubrange(newTransliterationRange, with: replacementString)
                }
            }
            
            
            if transliteration.isEmpty == false {
                let annotation=FuriganaAnnotation(reading: transliteration, range: range)
                annotations.append(annotation)
            }
            
        }
        
        return annotations
        
    }
    
    
    
}
