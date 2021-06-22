//
//  SystemDictionary.swift
//  
//
//  Created by Morten Bertz on 2021/06/21.
//

import Foundation
import Dictionary

struct SystemDictionary: DictionaryProviding{
    public var url: URL{
        return URL(fileURLWithPath: "")
    }
    
    public var readingIndex: Int{
        return 0
    }
    
    public var pronunciationIndex: Int{
        return 0
    }
    
    public var dictionaryFormIndex: Int{
        return 0
    }
    
    public func partOfSpeech(posID: UInt16) -> PartOfSpeech {
        return .unknown
    }
    
    
}
