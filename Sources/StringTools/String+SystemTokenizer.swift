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
        /// The original string as found in the text
        public let base:String
        /// The transliterated string as katakana, following the format of `mecab`
        public let reading:String
        /// The range of the base string in the underlying text
        public let range:Range<String.Index>
    }
    
    /**A convenience function to use the system tokenizer to tokenize strings.
     */
    @available(macOS 10.11, *)
    func systemTokenizerFuriganaAnnotations(noSubstrings:Bool = true)->[SystemTokenizerAnnotation]{
        let japaneseLocale=Locale(identifier: "ja_JP")
        
        let nsRange=NSRange((self.startIndex..<self.endIndex), in: self)
        
        let tokenizer=CFStringTokenizerCreate(nil, self as CFString, CFRange(location: nsRange.location, length: nsRange.length), kCFStringTokenizerUnitWordBoundary, japaneseLocale as CFLocale)
        
        var annotations=[SystemTokenizerAnnotation]()
        
        var result=CFStringTokenizerAdvanceToNextToken(tokenizer)
        
        let kanjiCharacterSet=CharacterSet.kanji
        
        while !result.isEmpty {
            
            let annotation:SystemTokenizerAnnotation? = autoreleasepool{
                defer {
                    result=CFStringTokenizerAdvanceToNextToken(tokenizer)
                }
                
                let cfRange=CFStringTokenizerGetCurrentTokenRange(tokenizer)
                guard let range=Range<String.Index>.init(NSRange(location: cfRange.location, length: cfRange.length), in: self) else{return nil}
                let subString=String(self[range])
                
                let subStringSet=CharacterSet(charactersIn: subString)
                
                if kanjiCharacterSet.isDisjoint(with: subStringSet) == false{
                    
                    if noSubstrings{
                        let cTypeRef=CFStringTokenizerCopyCurrentTokenAttribute(tokenizer, kCFStringTokenizerAttributeLatinTranscription)
                        guard let typeRef=cTypeRef, CFGetTypeID(typeRef) == CFStringGetTypeID() else {return nil}
                        let latinString=typeRef as! CFString
                        guard let katakana=(latinString as String).applyingTransform(.latinToKatakana, reverse: false) else{return nil}
                        
                        return SystemTokenizerAnnotation(base: subString, reading: katakana, range: range)
                       
                    }
                    else{
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
                            return nil
                        }
                        return SystemTokenizerAnnotation(base: subString, reading: result, range: range)
                       
                    }
                   
                    
                }
                else{
                     return SystemTokenizerAnnotation(base: subString, reading: subString, range: range)
                }
            }

            
            guard let annotation = annotation else {
                continue
            }

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
