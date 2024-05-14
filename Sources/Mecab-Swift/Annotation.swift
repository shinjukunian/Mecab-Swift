//
//  File.swift
//  
//
//  Created by Morten Bertz on 2019/10/02.
//

import Foundation
import StringTools
import Dictionary

/**
`Annotation`s encapsulate the information of the `Tokenizer`.
*/
@available(macOS 10.11, *)
public struct Annotation:Equatable, FuriganaAnnotating{
    
    ///Represents the string value of the token in the original text
    public let base:String
    
    ///In case `base` contains Kanji characters, the reading if the characters. The reading is formatted according to `Transliteration`
    public let reading:String
    
    ///A member of the `PartOfSpeech` enum.
    public let partOfSpeech:PartOfSpeech
    
    ///The range of the annotation in the original string, in UTF8 format.
    public let range:Range<String.Index>
    
    ///The range of the annotation in the original string excluding surrounding whitespace, in UTF8 format.
    public let rangeExcludingWhitespace:Range<String.Index>
    
    ///In case of verbs or adjectives, the dictionary form of the token.
    public let dictionaryForm:String
    
    let transliteration:Tokenizer.Transliteration
    
    init(token:Token, range:Range<String.Index>, rangeExcludingWhitespace:Range<String.Index>, transliteration:Tokenizer.Transliteration) {
        self.init(base: token.original, reading: token.reading, range: range, rangeExcludingWhitespace: rangeExcludingWhitespace, dictionaryForm: token.dictionaryForm, transliteration: transliteration, POS: token.partOfSpeech)
    }
    
    init(base:String, reading:String, range:Range<String.Index>, rangeExcludingWhitespace:Range<String.Index>, dictionaryForm:String, transliteration:Tokenizer.Transliteration, POS:PartOfSpeech = .unknown){
        self.base=base
        self.range=range
        self.rangeExcludingWhitespace=rangeExcludingWhitespace
        self.partOfSpeech = POS
        self.transliteration = transliteration
        
        if !base.containsKanjiCharacters{
            self.reading=reading
            self.dictionaryForm=dictionaryForm
        }
        else{
            switch transliteration {
            case .katakana:
                self.reading=reading
                self.dictionaryForm=dictionaryForm
            case .hiragana:
                self.reading=reading.hiraganaString
                self.dictionaryForm=dictionaryForm.hiraganaString
            case .romaji:
                self.reading=reading.romanizedString(method: .hepburn)
                self.dictionaryForm=dictionaryForm.romanizedString(method: .hepburn)
            }
        }
 
    }
    
    /**
     Checks whether the `base` of the `Annotation` contains Kanji characters.
     */
    @inlinable public var containsKanji:Bool{
        return self.base.containsKanjiCharacters
    }
    
    /**
       A convenience function to create properly formatted `FuriganaAnnotations` from an `Annotation`
    - parameters:
           - string: the underlying text for which the `FuriganaAnnotation` should be generated. This parameter is required because some options can change the range of the token in the base text.
    - returns: A  `FuriganaAnnotation`.
    */
    public func furiganaAnnotation(for string:String)->FuriganaAnnotation{
         return FuriganaAnnotation(reading: self.reading , range: self.range)
    }
    
    
    
    /**
        A convenience function to create properly formatted `FuriganaAnnotations` from an `Annotation`
     - parameters:
            - options: `AnnotationOptions` how to format the `FuriganaAnnotations`
            - string: the underlying text for which the `FuriganaAnnotation` should be generated. This parameter is required because some options can change the range of the token in the base text.
     - returns: A  `FuriganaAnnotation`.
     */
    public func furiganaAnnotation(options:[AnnotationOption] = [.kanjiOnly], for string:String)->FuriganaAnnotation?{
        
         for case let AnnotationOption.filter(disallowed, strict) in options{
            let kanji=Set(self.base.kanjiCharacters)
            if strict == true, disallowed.isDisjoint(with: kanji) == false{
                return nil
            }
            else if strict == false, disallowed.isSuperset(of: kanji){
                return nil
            }
        }
        
        if options.contains(.kanjiOnly), self.transliteration != .romaji{
            guard self.containsKanji else{
                return nil
            }
            return self.furiganaAnnotation(for: string, kanjiOnly: true)
        }
        else{
            return FuriganaAnnotation(reading: self.reading , range: self.rangeExcludingWhitespace)
        }
    }
}

@available(macOS 10.11, *)
extension Annotation:CustomStringConvertible{
    public var description: String{
        return "Base: \(base), reading: \(reading), POS: \(partOfSpeech)"
    }
}
