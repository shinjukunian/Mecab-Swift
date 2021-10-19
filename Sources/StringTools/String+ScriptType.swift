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
            if CharacterSet.kanjiRange.contains(firstScalar){
                type.insert(.kanji)
            }
            else if CharacterSet.hiraganaRange.contains(firstScalar){
                type.insert(.hiragana)
            }
            else if CharacterSet.katakanaRange.contains(firstScalar){
                type.insert(.katakana)
            }
        }
        return type
    }

    @inlinable var containsKanjiCharacters:Bool{
        return self.unicodeScalars.contains(where: {scalar in
            CharacterSet.kanjiRange.contains(scalar)
        })
    }
    
    @inlinable var containsJapaneseScript:Bool{
        for character in self{
            guard let firstScalar=character.unicodeScalars.first else{continue}
            if  CharacterSet.kanjiRange.contains(firstScalar) ||
                CharacterSet.hiraganaRange.contains(firstScalar) ||
                CharacterSet.katakanaRange.contains(firstScalar){
                return true
            }
        }
        return false
    }
    
    //This version is a lot slower than the raw comparison above
    @inlinable var containsKanjiCharacters_old:Bool{
        let containedCharacters=CharacterSet.init(charactersIn: self)
        return !containedCharacters.intersection(CharacterSet.kanji).isEmpty
    }
    
    @inlinable var kanjiCharacters:[String]{
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


public extension CharacterSet{
    
    static let unicodeKanjiStart=Unicode.Scalar(0x4e00)!
    static let unicodeKanjiEnd=Unicode.Scalar(0x9fbf)!
    static let kanjiRange=Unicode.Scalar(0x4e00)!...Unicode.Scalar(0x9fbf)!
    static let hiraganaRange=Unicode.Scalar(0x3040)!...Unicode.Scalar(0x309f)!
    static let katakanaRange=Unicode.Scalar(0x30a0)!...Unicode.Scalar(0x30ff)!
    
    static var hiragana:CharacterSet{
        return CharacterSet.init(charactersIn: hiraganaRange)
    }
    
    static var katakana:CharacterSet{
        return CharacterSet.init(charactersIn: katakanaRange)
    }
    
    static var kanji:CharacterSet{
        return CharacterSet.init(charactersIn: kanjiRange)
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
