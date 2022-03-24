//
//  PartOfSpeech.swift
//  
//
//  Created by Morten Bertz on 2021/06/22.
//

import Foundation

/// Various Tokens ofr Part-of-Speech tagging.
public enum PartOfSpeech:CustomStringConvertible{
    case verb
    case particle
    case noun
    case adjective
    case adverb
    case prefix
    case suffix
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
        case .suffix:
            return "suffix"
        }
    }
}
