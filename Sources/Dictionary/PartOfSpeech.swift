//
//  PartOfSpeech.swift
//  
//
//  Created by Morten Bertz on 2021/06/22.
//

import Foundation

public enum PartOfSpeech:CustomStringConvertible{
    case verb
    case particle
    case noun
    case adjective
    case adverb
    case prefix
    case symbol
    case unknown

    
    public var description: String{
        switch self {
        case .verb:
            return "verb"
        case .unknown:
            return "unknown"
        case .particle:
            return "particle"
        case .noun:
            return "noun"
        case .adjective:
            return "adjective"
        case .adverb:
            return "adverb"
        case .prefix:
            return "prefix"
        case .symbol:
            return "symbol"

        }
    }
}
