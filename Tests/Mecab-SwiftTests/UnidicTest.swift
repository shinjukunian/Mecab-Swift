//
//  File.swift
//  Mecab-Swift
//
//  Created by Morten Bertz on 2025/05/15.
//

import Testing
import Foundation
import Dictionary
import Mecab_Swift

class UniDic:DictionaryProviding{
    let url: URL = URL.init(string: ".")!
    
    var readingIndex: Int = 9
    
    var pronunciationIndex: Int = 0
    
    var dictionaryFormIndex: Int = 6
    
    func partOfSpeech(posID: UInt16) -> PartOfSpeech {
        return .unknown
    }
    
}


@Test func testUnidic() throws {
    
    let unidic = UniDic()
    
    #expect(throws: Tokenizer.TokenizerError.self, performing: {
        let tokenizer = try Tokenizer(dictionary: unidic)
        
        let string = "2025年3月16日"
        
        let tokens = tokenizer.tokenize(text: string)
        for token in tokens{
            print("token: \(token.base), reading: \(token.reading)")
        }
        #expect(tokens.isEmpty == false)
    })

    
    
}
