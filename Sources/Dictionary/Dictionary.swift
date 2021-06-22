//
//  Dictionary.swift
//  
//
//  Created by Morten Bertz on 2021/06/22.
//

import Foundation

/**
 The protocol for the dictionary type. One could
 */

public protocol DictionaryProviding:TokenIndexProviding, PartOfSpeechProviding   {
    var url:URL{get}
}

/**
 A protocol to find report the indices of various return values of the tokenizer
 */

public protocol TokenIndexProviding{
    var readingIndex:Int {get}
    var pronunciationIndex:Int {get}
    var dictionaryFormIndex:Int {get}
}


/**
 A protocol for Part-of-Speech tagging
 The ranges of the posID are taken from https://github.com/buruzaemon/natto/wiki/Node-Parsing-posid.
 https://github.com/m4p provided the impetus for this implementation
 An alternative (that potentially allows more granularity) would be to use the POS feature string at position 0.
 */
public protocol PartOfSpeechProviding {
    func partOfSpeech(posID:UInt16)->PartOfSpeech
}
