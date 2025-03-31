//
//  String+ScriptType.swift
//  Kanjidictionary
//
//  Created by Morten Bertz on 2018/12/28.
//  Copyright © 2018 Morten Bertz. All rights reserved.
//

import Foundation

///Convenience functions to deal with Japanese text.
public extension String{
    
    /**
        `ScriptType`, an `OptionSet` to detect the presence of the three major Japanese scripts in a string.
     */
    
    struct ScriptType:OptionSet{
        public let rawValue: Int
        
        /// no Japanese characters present
        public static let noJapaneseScript=ScriptType(rawValue: 1 << 0)
        /// Hiragana present
        public static let hiragana=ScriptType(rawValue: 1 << 1)
        /// Katakana present
        public static let katakana=ScriptType(rawValue: 1<<2)
        /// Kanji present
        public static let kanji=ScriptType(rawValue: 1<<3)
        
        public init(rawValue:Int){
            self.rawValue=rawValue
        }
    }
    
    /// Detects the presence or absence of Hiragana, Katakana, or Kanji in a text.
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
    
    ///Detects whether the string contains Kanji characters.
    @inlinable var containsKanjiCharacters:Bool{
        return self.unicodeScalars.contains(where: {scalar in
            CharacterSet.kanjiRange.contains(scalar)
        })
    }
    
    ///Detects whether the string contains any Japanese script.
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
    @available(*, deprecated, message: "This function is outdated and shouldn't be used. Use `containsKanjiCharacters` instead.")
    @inlinable var containsKanjiCharacters_old:Bool{
        let containedCharacters=CharacterSet.init(charactersIn: self)
        return !containedCharacters.intersection(CharacterSet.kanji).isEmpty
    }
    
    ///A list of the unique Kanji characters in the string, in order of occurence.
    @inlinable var kanjiCharacters:[String]{
        let characters=self.compactMap({String($0).containsKanjiCharacters ? String($0): nil})
        return characters.uniqueElements
    }
    
    /// The ranges of Hiragana characters, useful for stripping okurinaga.
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

/// Extensions to CharacterSet to deal with Japanese text.
public extension CharacterSet{
    
    /// The range of Kanji characters.
    static let kanjiRange=Unicode.Scalar(0x4e00)!...Unicode.Scalar(0x9fbf)!
    
    ///The range of Hiragana Characters.
    static let hiraganaRange=Unicode.Scalar(0x3040)!...Unicode.Scalar(0x309f)!
    
    /// The range of Katakana characters.
    static let katakanaRange=Unicode.Scalar(0x30a0)!...Unicode.Scalar(0x30ff)!
    
    /// The Hiragana CharacterSet
    static var hiragana:CharacterSet{
        return CharacterSet.init(charactersIn: hiraganaRange)
    }
    
    /// The Katakana CharacterSet
    static var katakana:CharacterSet{
        return CharacterSet.init(charactersIn: katakanaRange)
    }
    
    /// The Kanji CharacterSet
    static var kanji:CharacterSet{
        return CharacterSet.init(charactersIn: kanjiRange)
    }
}


extension Sequence where Element: Equatable {
    public var uniqueElements: [Element] {
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
