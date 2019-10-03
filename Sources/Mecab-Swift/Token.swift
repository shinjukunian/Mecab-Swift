//
//  File.swift
//  
//
//  Created by Morten Bertz on 2019/10/02.
//

import Foundation
import mecab

public enum PartOfSpeech{
    case verb
    case unknown
}


struct Token{

    let surface:String
    let features:[String]
    let partOfSpeech:PartOfSpeech

    init?(node:mecab_node_t, dictionary:Dictionary.DictionaryType) {
        
        guard let surfacePTR=UnsafeMutableRawPointer(mutating: node.surface),
            let surface=String(bytesNoCopy: surfacePTR, length: Int(node.length), encoding: .utf8, freeWhenDone: false),
                let features=String(cString: node.feature, encoding: .utf8)?.split(separator: ","),
                features.count > 0
                else{
            return nil
        }
        
        self.surface=surface
        self.features=features.map({String($0)})
        self.partOfSpeech = .unknown
    }
    
    var reading:String{
        if self.features.count>7{
            return self.features[8]
        }
        return self.surface
        
    }
    
    var original:String{
        return self.surface
    }
    var dictionaryForm:String{
        return self.features[6]
    }
}
