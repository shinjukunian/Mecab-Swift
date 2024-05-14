//
//  String+RubyTags.swift
//  
//
//  Created by Morten Bertz on 2021/09/22.
//

import Foundation

extension String{
    
    /**
     A minimal implementation of a `<ruby>` tagger for webextensions.
     
     Adds furigana in the form of `<ruby>_base_<rt>_furigana_of_base_</rt></ruby>`.  Designed to keep memory used to a minimum.
     
     - parameters:
        - useRomaji: Whether to use the latin alphabet or hiragana
        - kanjiOnly: whether to strip okurigana.
        - disallowedCharacters: A set of disallowed Kanji characters. Furigana will only be added to characters not in this set.
     - returns:
        A `<ruby>` annotated string suitable for display in a browser.
     */
    @available(macOS 10.11, *)
    public func rubyTaggedString(useRomaji:Bool = false, kanjiOnly:Bool = true, disallowedCharacters:Set<String> = Set<String>(), strict:Bool = false, transliterateAll:Bool = false)->String{
        
        var outString=""
        
        let japaneseLocale=Locale(identifier: "ja_JP")
        
        let nsRange=NSRange((self.startIndex..<self.endIndex), in: self)
        
        let tokenizer=CFStringTokenizerCreate(nil, self as CFString, CFRange(location: nsRange.location, length: nsRange.length), kCFStringTokenizerUnitWordBoundary, japaneseLocale as CFLocale)
        
        var result=CFStringTokenizerAdvanceToNextToken(tokenizer)
        
        while (result.contains(.normal)){
            
            defer {
                result=CFStringTokenizerAdvanceToNextToken(tokenizer)
            }
            
            
            let annotated=autoreleasepool(invoking: { () -> String in
                let cfRange=CFStringTokenizerGetCurrentTokenRange(tokenizer)
                guard let range=Range<String.Index>.init(NSRange(location: cfRange.location, length: cfRange.length), in: self) else{return ""}
                let subString=String(self[range])
                
                if result.contains(.isCJWordMask){
                    if transliterateAll && useRomaji{
                        let cTypeRef=CFStringTokenizerCopyCurrentTokenAttribute(tokenizer, kCFStringTokenizerAttributeLatinTranscription)
                        guard let typeRef=cTypeRef, CFGetTypeID(typeRef) == CFStringGetTypeID() else {return subString}
                        let furigana:String = (typeRef as! CFString) as String
                        let htmlRuby="<ruby>\(subString)<rt>\(furigana)</rt></ruby>"
                        return htmlRuby
                    }
                    else if subString.containsKanjiCharacters{
                        if !disallowedCharacters.isEmpty{
                            if strict{
                                guard disallowedCharacters.isDisjoint(with: Set(subString.kanjiCharacters)) else{
                                    return subString
                                }
                            }
                            else{
                                guard disallowedCharacters.isSuperset(of: Set(subString.kanjiCharacters)) == false else{
                                    return subString
                                }
                            }
                            
                        }

                        let cTypeRef=CFStringTokenizerCopyCurrentTokenAttribute(tokenizer, kCFStringTokenizerAttributeLatinTranscription)
                        guard let typeRef=cTypeRef, CFGetTypeID(typeRef) == CFStringGetTypeID() else {return subString}
                        let furigana:String?
                        
                        if useRomaji{
                            furigana = (typeRef as! CFString) as String
                        }
                        else {
                            furigana=((typeRef as! CFString) as String).applyingTransform(.latinToHiragana, reverse: false)
                        }
                        
                        guard var furigana = furigana else {
                            return subString
                        }
                        if kanjiOnly == true, useRomaji==false{
//                            #warning("this could be solved more elegnatly")
                            furigana=furigana.cleanupFurigana(base: subString)
                        }
                        
                        let htmlRuby="<ruby>\(subString)<rt>\(furigana)</rt></ruby>"
                        return htmlRuby
                    }
                    else{
                        return subString
                    }
                }
                else{
                    return subString
                }
                
            })

            outString.append(annotated)
        }
        
        
        return outString
    }
    
    
    public func cleanupFurigana(base:String)->String{
        let hiraganaRanges=base.hiraganaRanges
        var transliteration=self
        
        
        
        for hiraganaRange in hiraganaRanges{
            switch hiraganaRange {
            case _ where hiraganaRange.upperBound == base.endIndex:
                let trailingDistance=base.distance(from: base.endIndex, to: hiraganaRange.lowerBound)
                
                let transliterationEnd=transliteration.index(transliteration.endIndex, offsetBy: trailingDistance)
                let newTransliterationRange=transliterationEnd..<transliteration.endIndex
                transliteration.replaceSubrange(newTransliterationRange, with: "　")
                
            case _ where hiraganaRange.lowerBound == base.startIndex:
                let leadingDistance=base.distance(from: base.startIndex, to: hiraganaRange.upperBound)
                
                let transliterationStart=transliteration.index(transliteration.startIndex, offsetBy: leadingDistance)
                let newTransliterationRange=transliteration.startIndex..<transliterationStart
                transliteration.replaceSubrange(newTransliterationRange, with: "　")
                
            default:
                let detectedCenterHiragana=base[hiraganaRange]
                transliteration = transliteration.replacingOccurrences(of: detectedCenterHiragana, with: "　")
            }
            
        }
        return transliteration
    }
    
}
