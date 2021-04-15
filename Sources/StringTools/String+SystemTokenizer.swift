//
//  SystemTokenizer.swift
//  
//
//  Created by Morten Bertz on 2020/07/07.
//

import Foundation

public extension String{
    
    /**
     A convenience structure that encapsulates a token, with minimum information.
     - `base`: the original string as found in the text
     - `reading`: the transliterated string as katakana, following the format of `mecab`
     - `range`: the range of the base string in the underlying text
     */
    
    struct SystemTokenizerAnnotation: FuriganaAnnotating{
        public let base:String
        public let reading:String
        public let range:Range<String.Index>
    }
    /**A convenience function to use the system tokenizer to tokenize strings.
     */
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
    
    /**
     A convenience function to get system tokenizer furigana annotations with Hiragana
     */
    @available(OSX 10.11, *)
    func furiganaReplacements()->[FuriganaAnnotation]{
        return self.systemTokenizerFuriganaAnnotations().compactMap {annotation in
            let hiragana=SystemTokenizerAnnotation(base: annotation.base, reading: annotation.reading.hiraganaString, range: annotation.range)
            return hiragana.furiganaAnnotation(for: self, kanjiOnly: true)}
        
    }
}
