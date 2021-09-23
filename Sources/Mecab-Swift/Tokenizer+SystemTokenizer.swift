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
        let annotations=text.systemTokenizerFuriganaAnnotations()
        
        return annotations.map({annotation in
            return autoreleasepool(invoking: {
                Annotation(base: annotation.base, reading: annotation.reading, range: annotation.range, dictionaryForm: annotation.base, transliteration: transliteration)
            })
            
        })
        
    }
}
