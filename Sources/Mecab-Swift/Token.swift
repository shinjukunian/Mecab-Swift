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
    case unknown
    
    public var description: String{
        switch self {
        case .verb:
            return "verb"
        case .unknown:
            return "unknown"
        }
    }
}


struct Token{

    let surface:String
    let features:[String]
    let partOfSpeech:PartOfSpeech
    let dictionary:Dictionary.DictionaryType

    init?(node:mecab_node_t, dictionary:Dictionary.DictionaryType) {
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
        self.partOfSpeech = .unknown
        self.dictionary=dictionary
    }
    
    var reading:String{
        if self.features.count > self.dictionary.readingIndex{
            return self.features[self.dictionary.readingIndex]
        }
        return self.surface
    }
    
    var pronunciation:String{
        if self.features.count > self.dictionary.pronunciationIndex{
            return self.features[self.dictionary.pronunciationIndex]
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
