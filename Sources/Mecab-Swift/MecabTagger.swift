//
//  MecabTagger.swift
//  
//
//  Created by Morten Bertz on 2026/08/24.
//

import Foundation
import mecab
import Dictionary

/**
 Owns the `mecab` tagger and ties the lifetime of the C object to its own.
 
 `mecab` writes into the lattice of the tagger while parsing, so the tagger is not thread safe. Access is serialized by a lock, which is what makes the class safe to share (`@unchecked Sendable`).
 */
final class MecabTagger: @unchecked Sendable{
    
    private let tagger:OpaquePointer
    private let lock=NSLock()
    let dictionary:any DictionaryProviding
    
    init(dictionary:any DictionaryProviding) throws{
        self.dictionary=dictionary
        self.tagger=try dictionary.url.withUnsafeFileSystemRepresentation({path->OpaquePointer in
            guard let path=path,
                let dictPath=String(cString: path).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
                //MeCab splits the commands by spaces, so we need to escape the path passed inti the function.
                //We replace the percent encoded space when opening the dictionary. This is mostly relevant when the dictionary os located inside a folder of which we cannot control the name, i.e. Application Support
                else{ throw Tokenizer.TokenizerError.initializationFailure("URL Conversion Failed \(dictionary)")}
            
            guard let tagger=mecab_new2("-d \(dictPath)") else {
                let error=String(cString: mecab_strerror(nil), encoding: .utf8) ?? ""
                throw Tokenizer.TokenizerError.initializationFailure("Opening Dictionary Failed \(dictionary) \(error)")
            }
            return tagger
        })
    }
    
    /**
     Performs `body` with exclusive access to the `mecab` tagger.
     
     - warning: `body` must not call back into the tagger, the lock is not recursive.
     */
    func withTagger<T>(_ body:(OpaquePointer, any DictionaryProviding) throws->T) rethrows ->T{
        self.lock.lock()
        defer{self.lock.unlock()}
        return try body(self.tagger, self.dictionary)
    }
    
    deinit {
        mecab_destroy(tagger)
    }
}
