//
//  SystemTokenizer.swift
//  
//
//  Created by Morten Bertz on 2020/07/07.
//

import Foundation

public extension String{
    
    struct SystemTokenizerAnnotation: FuriganaAnnotating{
        public let base:String
        public let reading:String
        public let range:Range<String.Index>
    }
    
    func systemTokenizerFuriganaAnnotations()->[SystemTokenizerAnnotation]{
        let japaneseLocale=Locale(identifier: "ja_JP")
        
        let nsRange=NSRange((self.startIndex..<self.endIndex), in: self)
        
        let tokenizer=CFStringTokenizerCreate(nil, self as CFString, CFRange(location: nsRange.location, length: nsRange.length), kCFStringTokenizerUnitWordBoundary, japaneseLocale as CFLocale)
        
        var annotations=[SystemTokenizerAnnotation]()
        
        var result=CFStringTokenizerAdvanceToNextToken(tokenizer)
        
        while !result.isEmpty {
            
            defer {
                result=CFStringTokenizerAdvanceToNextToken(tokenizer)
            }
            
            let cfRange=CFStringTokenizerGetCurrentTokenRange(tokenizer)
            guard let range=Range<String.Index>.init(NSRange(location: cfRange.location, length: cfRange.length), in: self) else{continue}
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
            
            guard let result:String = subTransliterations.joined().applyingTransform(.latinToKatakana, reverse: false),
                  result.isEmpty == false else{
                continue
            }
            let annotation=SystemTokenizerAnnotation(base: subString, reading: result, range: range)
            annotations.append(annotation)
        }
        
        return annotations
    }
    
    
    
    @available(OSX 10.11, *)
    func furiganaReplacements()->[FuriganaAnnotation]{
        return self.systemTokenizerFuriganaAnnotations().compactMap {$0.furiganaAnnotation(for: self, kanjiOnly: true)}
    }
}
