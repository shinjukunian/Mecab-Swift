//
//  Tokenizer+Ruby.swift
//  
//
//  Created by Morten Bertz on 2021/09/28.
//

import Foundation
import mecab

extension Tokenizer{
    
    
    
    func mecab_rubyTaggedString(source:String, transliteration:Transliteration, kanjiOnly:Bool = true, disallowedCharacters:Set<String> = Set<String>(), strict:Bool = false)->String{
        
        
        func parse(subString:String)->String{
            return subString.withCString({s->String in
                var retVal=""
                var node=mecab_sparse_tonode(self._mecab, s)
                while true{
                    
                    
                    guard let n = node else {break}
                    
                    defer{
                        node = UnsafePointer(n.pointee.next)
                    }
                    
                    
                    if let token=Token(node: n.pointee, tokenDescription: self.dictionary){
                        if token.original.containsKanjiCharacters{
                            
                            if disallowedCharacters.isEmpty == false {
                                if strict{
                                    guard disallowedCharacters.isDisjoint(with: Set(token.original.kanjiCharacters)) == false else{
                                        retVal.append(token.original)
                                        continue
                                    }
                                }
                                else{
                                    guard disallowedCharacters.isSuperset(of: Set(token.original.kanjiCharacters)) == false else{
                                        retVal.append(token.original)
                                        continue
                                    }
                                }
                            }
                            
                            var reading:String
                            switch transliteration {
                            case .hiragana where kanjiOnly == true:
                                reading=token.reading.hiraganaString.cleanupFurigana(base: token.original)
                            case .hiragana,
                                    .hiragana where kanjiOnly == false:
                                reading=token.reading.hiraganaString
                            case .katakana:
                                reading=token.reading
                            case .romaji:
                                reading=token.reading.romanizedString()
                            }
                            
                            
                            
                            
                            let htmlRuby="<ruby>\(token.original)<rt>\(reading)</rt></ruby>"
                            retVal.append(htmlRuby)
                        }
                        else{
                            retVal.append(token.original)
                        }
                        
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
            let subString=String(source[startIDX..<endIDX])
            let annotated=parse(subString: subString)
            returnString.append(annotated)
        }
        
        
        
        return returnString
    }
}
