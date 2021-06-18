//
//  File.swift
//  
//
//  Created by Morten Bertz on 2019/10/02.
//

import Foundation
import mecab

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

    static public func partOfSpeechForMecabID(posid:UInt16) -> PartOfSpeech {
        // See https://github.com/buruzaemon/natto/wiki/Node-Parsing-posid

        if posid >= 3 && posid <= 9 {
            return .symbol
        }

        if posid >= 10 && posid <= 12 {
            return .adjective
        }

        if posid >= 13 && posid <= 24 {
            return .particle
        }

        if posid >= 27 && posid <= 30 {
            return .prefix
        }

        if posid >= 27 && posid <= 30 {
            return .prefix
        }

        if posid >= 31 && posid <= 33 {
            return .verb
        }

        if posid >= 34 && posid <= 35 {
            return .adverb
        }

        if posid >= 36 && posid <= 67 {
            return .noun
        }

        return .unknown
    }
}


struct Token{

    let surface:String
    let features:[String]
    let partOfSpeech:PartOfSpeech
    let tokenDescription:TokenIndexProviding

    init?(node:mecab_node_t, tokenDescription:TokenIndexProviding) {
        guard let sPTR=node.surface else{return nil}
        let data=Data(bytes: sPTR, count: Int(node.length))
        guard  let surface=String(data: data, encoding: .utf8),
                let features=String(cString: node.feature, encoding: .utf8)?.split(separator: ","),
                features.count > 0
                else{
            return nil
        }

        self.surface=surface
        self.features=features.map({String($0)})
        self.partOfSpeech = PartOfSpeech.partOfSpeechForMecabID(posid: node.posid)
        self.tokenDescription=tokenDescription
    }
    
    var reading:String{
        if self.features.count > self.tokenDescription.readingIndex{
            return self.features[self.tokenDescription.readingIndex]
        }
        return self.surface
    }
    
    var pronunciation:String{
        if self.features.count > self.tokenDescription.pronunciationIndex{
            return self.features[self.tokenDescription.pronunciationIndex]
        }
        return self.reading
    }
    
    var original:String{
        return self.surface
    }
    var dictionaryForm:String{
        return self.features[6]
    }
}
