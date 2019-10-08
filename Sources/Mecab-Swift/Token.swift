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
        self.partOfSpeech = .unknown
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
