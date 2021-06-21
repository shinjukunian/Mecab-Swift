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

public protocol TokenIndexProviding{
    var readingIndex:Int {get}
    var pronunciationIndex:Int {get}
    var dictionaryFormIndex:Int {get}
}

extension Dictionary.DictionaryType:TokenIndexProviding{
    public var dictionaryFormIndex: Int {
        switch self {
        case .ipadic:
            return 6
        }
    }
    
    public var readingIndex:Int{
        switch self {
        case .ipadic:
            return 7
        }
    }
    
    public var pronunciationIndex:Int{
        switch self {
        case .ipadic:
            return 8
        }
    }
}

