//
//  IPADic.swift
//  
//
//  Created by Morten Bertz on 2021/06/22.
//

import Foundation
import Dictionary

/**
A wrapper around IPADic. A number of dictionaries for mecan can be found on the internet. Different dictionaries privde different features (POS tagging etc), and so far I have not been able to get this information out of mecab at runtime. The dictionary scheme is contained in the dicrc file.
*/
public struct IPADic: DictionaryProviding{
    
    public let url:URL
    /**
    Initializes the IPADic instance with dictionary data at the sepcified `URL`.
     - parameters:
        - url:  The IPADic url.
     */
    public init(url:URL) {
        self.url=url
    }
    
    public var description: String{
        return "Dictionary: \(url), Type: IPADic"
    }
    
    public var dictionaryFormIndex: Int {
        return 6
    }
    
    public var readingIndex:Int{
        return 7
    }
    
    public var pronunciationIndex:Int{
       return 8
    }
    
    public func partOfSpeech(posID: UInt16) -> PartOfSpeech {
        switch posID {
        case 3...9:
            return .symbol
        case 10...12:
            return .adjective
        case 13...24:
            return .particle
        case 27...30:
            return .prefix
        case 31...33:
            return .verb
        case 34...35:
            return .adverb
        case 36...67:
            return .noun
        default:
            return .unknown
        }
    }
}
