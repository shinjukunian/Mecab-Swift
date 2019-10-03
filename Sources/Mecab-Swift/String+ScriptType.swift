//
//  String+ScriptType.swift
//  Kanjidictionary
//
//  Created by Morten Bertz on 2018/12/28.
//  Copyright © 2018 Morten Bertz. All rights reserved.
//

import Foundation

public extension String{
    struct  ScriptType:OptionSet{
        public let rawValue: Int
        
        public static let noJapaneseScript=ScriptType(rawValue: 1 << 0)
        public static let hiragana=ScriptType(rawValue: 1 << 1)
        public static let katakana=ScriptType(rawValue: 1<<2)
        public static let kanji=ScriptType(rawValue: 1<<3)
        
        public init(rawValue:Int){
            self.rawValue=rawValue
        }
    }
    
    var japaneseScriptType:ScriptType{
        var type = ScriptType.noJapaneseScript
        for character in self{
            guard let firstScalar=character.unicodeScalars.first else{continue}
            if CharacterSet.kanji.contains(firstScalar){
                type.insert(.kanji)
            }
            else if CharacterSet.hiragana.contains(firstScalar){
                type.insert(.hiragana)
            }
            else if CharacterSet.katakana.contains(firstScalar){
                type.insert(.katakana)
            }
        }
        return .noJapaneseScript
    }

    var containsKanjiCharacters:Bool{
        let containedCharacters=CharacterSet.init(charactersIn: self)
        return !containedCharacters.intersection(CharacterSet.kanji).isEmpty
    }
    
    var kanjiCharacters:[String]{
        let characters=self.compactMap({String($0).containsKanjiCharacters ? String($0): nil})
        return characters.uniqueElements
    }
    
    var hiraganaRanges:[Range<String.Index>]{
        var ranges=[Range<String.Index>]()
        var currentHiraganaString=""
        for character in self{
            guard let firstScalar=character.unicodeScalars.first else{continue}
            if CharacterSet.hiragana.contains(firstScalar){
               currentHiraganaString.append(character)
            }
            else{
                if let range=self.range(of: currentHiraganaString){
                    ranges.append(range)
                }
                currentHiraganaString=""
            }
            
        }
        
        if !currentHiraganaString.isEmpty, let range=self.range(of: currentHiraganaString){
            ranges.append(range)
        }
        
        return ranges
    }
}


extension CharacterSet{
    
    static var hiragana:CharacterSet{
        let start=Unicode.Scalar(0x3040)
        let end=Unicode.Scalar(0x309f)
        return CharacterSet.init(charactersIn: start!...end!)
    }
    
    static var katakana:CharacterSet{
        let start=Unicode.Scalar(0x30a0)
        let end=Unicode.Scalar(0x30ff)
        return CharacterSet.init(charactersIn: start!...end!)
    }
    
    
    static var kanji:CharacterSet{
        let start=Unicode.Scalar(0x4e00)
        let end=Unicode.Scalar(0x9fbf)
        return CharacterSet.init(charactersIn: start!...end!)
    }
    
    

}


public extension Sequence where Element: Equatable {
    var uniqueElements: [Element] {
        return self.reduce(into: []) {
            uniqueElements, element in
            
            if !uniqueElements.contains(element) {
                uniqueElements.append(element)
            }
        }
    }
    
    var duplicateElements: [Element] {
        
        return self.reduce(into: []) {
            uniqueElements, element in
            
            if !uniqueElements.contains(element) {
                uniqueElements.append(element)
            }
        }
    }
}
