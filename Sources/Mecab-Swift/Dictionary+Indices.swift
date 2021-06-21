//
//  Dictionary+Indices.swift
//
//
//  Created by Morten Bertz on 2021/06/21.
//

import Foundation

/**
 A protocol to find report the indices of various return values of the tokenizer
 */

protocol TokenIndexProviding{
    var readingIndex:Int {get}
    var pronunciationIndex:Int {get}
    var dictionaryFormIndex:Int {get}
}

extension Dictionary.DictionaryType:TokenIndexProviding{
    var dictionaryFormIndex: Int {
        switch self {
        case .ipadic:
            return 6
        case .systemTokenizer:
            return 0
        }
    }
    
    var readingIndex:Int{
        switch self {
        case .ipadic:
            return 7
        case .systemTokenizer:
            return 0
        }
    }
    
    var pronunciationIndex:Int{
        switch self {
        case .ipadic:
            return 8
        case .systemTokenizer:
            return 0
        }
    }
}

