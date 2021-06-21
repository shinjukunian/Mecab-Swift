//
//  Dictionary+PartOfSpeech.swift
//
//
//  Created by Morten Bertz on 2021/06/21.
//

import Foundation

/**
 A protocol for Part-of-Speech tagging
 The ranges of the PosID are taken from https://github.com/buruzaemon/natto/wiki/Node-Parsing-posid.
 https://github.com/m4p provided the impetus for this implementation
 An alternative (that potentially allows more granularity) would be to use the POS feature at position 0.
 */
protocol PartOfSpeechProviding {
    func partOfSpeech(posID:UInt16)->PartOfSpeech
}

extension Dictionary.DictionaryType:PartOfSpeechProviding{
    func partOfSpeech(posID: UInt16) -> PartOfSpeech {
        switch self {
        case .ipadic:
            switch posID {
            case 3...9:
                return .symbol
            case 10...12:
                return .adverb
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
        default:
            return .unknown
        }
    }
}

