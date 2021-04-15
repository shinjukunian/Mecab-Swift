//
//  File.swift
//  
//
//  Created by Morten Bertz on 2021/04/15.
//

import Foundation
import StringTools

@available(OSX 10.11, *)
extension Tokenizer{
    func systemTokenizerTokenize(text:String, transliteration:Transliteration = .hiragana)->[Annotation]{
        
        return text.systemTokenizerFuriganaAnnotations().map({annotation in
            return Annotation(base: annotation.base, reading: annotation.reading, range: annotation.range, dictionaryForm: text, transliteration: transliteration)
        })
        
    }
}
