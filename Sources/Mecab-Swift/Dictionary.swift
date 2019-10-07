//
//  File.swift
//  
//
//  Created by Morten Bertz on 2019/10/03.
//

import Foundation

/**
A wrapper around a dictionary, for example IPADic. A number of dictionaries for mecan can be found on the internet. Different dictionaries privde different features (POS tagging etc), and so far I have not been able to get this information out of mecab at runtime. The dictionary scheme is contained in the dicrc file.
*/
public struct Dictionary:CustomStringConvertible{
    
    /**
     A dictionary type. This type (will eventually) encapsulate the positional information of the output of the dictionary (POS etc). So far, only IPADic is implemented. Eventually, this enum might be better served by a protocol.
     */
    public enum DictionaryType:CustomStringConvertible{
        case ipadic
        
        public var description: String{
            switch self {
            case .ipadic:
                return "IPADic"
            }
        }
    }
    
    let url:URL
    let type:DictionaryType
    
    public init(url:URL, type:DictionaryType) {
        self.url=url
        self.type=type
    }
    
    public var description: String{
        return "Dictionary: \(url), Type: \(type)"
    }
}
