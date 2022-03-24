//
//  Tokenizer+Ruby.swift
//  
//
//  Created by Morten Bertz on 2021/09/28.
//

import Foundation
import mecab

extension Tokenizer{
    
    func mecab_rubyTaggedString(source:String, transliteration:Transliteration, kanjiOnly:Bool = true, disallowedCharacters:Set<String> = Set<String>(), strict:Bool = false, transliterateAll:Bool = false)->String{
        
        
        func parse(subString:String)->String{
            
            var pos=subString.startIndex
            
            return subString.withCString({s->String in
                var retVal=""
                
                var node=mecab_sparse_tonode(self._mecab, s)
                
                while true{
                    
                    guard let n = node else {
                        break
                    }
                    
                    defer{
                        node = UnsafePointer(n.pointee.next)
                    }
                    
                    
                    guard let token=Token(node: n.pointee, tokenDescription: self.dictionary) else{
                        continue
                    }
                    
                    let endPos=subString.utf8.index(pos, offsetBy: token.lengthIncludingWhiteSpace)
                    let original=String(subString[pos..<endPos])
                    pos=endPos
                    
                    if  transliterateAll,
                        transliteration == .romaji,
                        token.surface.containsJapaneseScript{
                        let reading=token.reading.romanizedString()
                        let htmlRuby="<ruby>\(original)<rt>\(reading)</rt></ruby>"
                        retVal.append(htmlRuby)
                    }
                    else if original.containsKanjiCharacters{
                        
                        if disallowedCharacters.isEmpty == false {
                            let presentKanji=Set(token.original.kanjiCharacters)
                            if strict{
                                guard disallowedCharacters.isDisjoint(with: presentKanji) else{
                                    retVal.append(original)
                                    continue
                                }
                            }
                            else{
                                guard disallowedCharacters.isSuperset(of: presentKanji) else{
                                    retVal.append(original)
                                    continue
                                }
                            }
                        }
                        
                        var reading:String
                        switch transliteration {
                        case .hiragana where kanjiOnly == true:
                            reading=token.reading.hiraganaString.cleanupFurigana(base: original)
                        case .hiragana,
                                .hiragana where kanjiOnly == false:
                            reading=token.reading.hiraganaString
                        case .katakana:
                            reading=token.reading
                        case .romaji:
                            reading=token.reading.romanizedString()
                        }

                        let htmlRuby="<ruby>\(original)<rt>\(reading)</rt></ruby>"
                        retVal.append(htmlRuby)
                    }
                    else{
                        retVal.append(original)
                    }
                    
                }
                return retVal
            })
        }
        
        
        let sliceLength=100_000 // mecab has a size limit
        let strides=stride(from: 0, to: source.count, by: sliceLength)
        
        var returnString=""
        returnString.reserveCapacity(source.count)
        
        for start in strides{
            let startIDX=source.index(source.startIndex, offsetBy: start)
            let endIDX=source.index(source.startIndex, offsetBy: start + sliceLength, limitedBy: source.endIndex) ?? source.endIndex
            let subString=String(source[startIDX..<endIDX]).precomposedStringWithCanonicalMapping
            let annotated=parse(subString: subString)
            returnString.append(annotated)
        }
        
        
        
        return returnString
    }
}
