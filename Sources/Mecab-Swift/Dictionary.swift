//
//  File.swift
//  
//
//  Created by Morten Bertz on 2019/10/03.
//

import Foundation

public struct Dictionary:CustomStringConvertible{
    
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
