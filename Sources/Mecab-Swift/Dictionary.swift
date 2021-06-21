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
public struct Dictionary:CustomStringConvertible, TokenIndexProviding, PartOfSpeechProviding{
    
    /**
     A dictionary type. This type (will eventually) encapsulate the positional information of the output of the dictionary (POS etc). So far, only IPADic is implemented.
     */
    public enum DictionaryType:CustomStringConvertible{
        #if canImport(CoreFoundation)
        case systemTokenizer
        #endif
        
        case ipadic
        
        public var description: String{
            switch self {
            case .systemTokenizer:
                return "System Tokenizer"
            case .ipadic:
                return "IPADic"
            }
        }
    }
    
   
    #if canImport(CoreFoundation)
    public static let systemDictionary = Dictionary(url: URL(fileURLWithPath: ""), type: .systemTokenizer)
    #endif
    
    
    let url:URL
    let type:DictionaryType
    
    public init(url:URL, type:DictionaryType) {
        self.url=url
        self.type=type
    }
    
    public var description: String{
        return "Dictionary: \(url), Type: \(type)"
    }
    
    var readingIndex: Int{
        return self.type.readingIndex
    }
    
    var pronunciationIndex: Int{
        return self.type.pronunciationIndex
    }
    
    var dictionaryFormIndex: Int{
        return self.type.dictionaryFormIndex
    }
    
    func partOfSpeech(posID: UInt16) -> PartOfSpeech {
        return self.type.partOfSpeech(posID: posID)
    }

}
