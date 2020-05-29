//
//  File.swift
//  
//
//  Created by Morten Bertz on 2019/10/02.
//

import Foundation

/**
 `Annotation`s encapsulate the information of the `Tokenizer`.
 - base: represents the string value of the token in the original text
 - reading: in case `base` contains Kanji characters, the reading if the characters. The reading is formatted according to `Transliteration`
 - partOfSpeech: A member of the `PartOfSpeech` enum.
 - dictionaryForm: in case of verbs or adjectives, the dictionary form of the token.
 */

public struct Annotation:Equatable{
    
    /**
     Various options to format `Annotation` output
     */
    public struct AnnotationOptions:OptionSet{
        public let rawValue: Int
        
        /**
        The reading of the `Annotation` should only conatain information for the actual Kanji characters, skipping leading or trailing Kana, e.g. okurigana.
         
         For example the reading for 打ち合わせ would typically be うちわわせ. With `kanjiOnly` set, the reading skips the kana common in reading and base, the resulting reading is う＿あ, with ＿ representing a fulll-width space. The start and end of th erange are adjusted appropriately.
         */
        public static let kanjiOnly=AnnotationOptions(rawValue: 1 << 0)
        
        public init(rawValue: Int){
            self.rawValue=rawValue
        }
    }
    
    public let base:String
    public let reading:String
    public let partOfSpeech:PartOfSpeech
    public let range:Range<String.Index>
    public let dictionaryForm:String
    let transliteration:Tokenizer.Transliteration
    
    init(token:Token, range:Range<String.Index>, transliteration:Tokenizer.Transliteration) {
        self.base=token.original
        
        self.partOfSpeech=token.partOfSpeech
        self.range=range
        self.transliteration=transliteration
        
        switch transliteration {
        case .katakana:
            self.reading=token.pronunciation
            self.dictionaryForm=token.dictionaryForm
        case .hiragana:
            self.reading=token.reading.hiraganaString
            self.dictionaryForm=token.dictionaryForm.hiraganaString
        case .romaji:
            self.reading=token.reading.romanizedString(method: .hepburn)
            self.dictionaryForm=token.dictionaryForm.romanizedString(method: .hepburn)
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
            - options: `AnnotationOptions` how to format the `FuriganaAnnotations`
            - string: the underlying text for which the `FuriganaAnnotation` should be generated. This parameter is required because some options can change the range of the token in the base text.
     - returns: A  `FuriganaAnnotation`.
     */
    public func furiganaAnnotation(options:[AnnotationOptions] = [.kanjiOnly], for string:String)->FuriganaAnnotation{
        
        if options.contains(.kanjiOnly){
            let hiraganaRanges=self.base.hiraganaRanges
            var transliteration=self.reading
            var range=self.range
            for hiraganaRange in hiraganaRanges{
                switch hiraganaRange {
                case _ where hiraganaRange.upperBound == self.base.endIndex:
                    let trailingDistance=self.base.distance(from: self.base.endIndex, to: hiraganaRange.lowerBound)
                    let newEndIndex=string.index(range.upperBound, offsetBy: trailingDistance)
                    range=range.lowerBound..<newEndIndex
                    let transliterationEnd=transliteration.index(transliteration.endIndex, offsetBy: trailingDistance)
                    let newTransliterationRange=transliteration.startIndex..<transliterationEnd
                    let t2=transliteration[newTransliterationRange]
                    transliteration=String(t2)
                case _ where hiraganaRange.lowerBound == self.base.startIndex:
                    let leadingDistance=self.base.distance(from: self.base.startIndex, to: hiraganaRange.upperBound)
                    let newStartIndex=string.index(range.lowerBound, offsetBy: leadingDistance)// wrong?
                    range=newStartIndex..<range.upperBound
                    let transliterationStart=transliteration.index(transliteration.startIndex, offsetBy: leadingDistance)
                    let newTransliterationRange=transliterationStart..<transliteration.endIndex
                    let t2=transliteration[newTransliterationRange]
                    transliteration=String(t2)
                default:
                    let detectedCenterHiragana=self.base[hiraganaRange]
                    transliteration = transliteration.replacingOccurrences(of: detectedCenterHiragana, with: "　")
                    //this only works when the kanji is has a reading of exactly one character
                //the hackish replacement liekly works better
//                    let leadingDistance=self.base.distance(from: self.base.startIndex, to: hiraganaRange.lowerBound)
//                    let trailingDistance=self.base.distance(from: self.base.endIndex, to: hiraganaRange.upperBound)
//                    let transliterationStart=transliteration.index(transliteration.startIndex, offsetBy: leadingDistance)
//                    let transliterationEnd=transliteration.index(transliteration.endIndex, offsetBy: trailingDistance)
//                    let newTransliterationRange=transliterationStart..<transliterationEnd
//                    let length=self.base.distance(from: hiraganaRange.lowerBound, to: hiraganaRange.upperBound)
//                    let replacementString=String(repeatElement("　", count: length))
//                    transliteration.replaceSubrange(newTransliterationRange, with: replacementString)
                }
            }
            return FuriganaAnnotation(reading: transliteration , range: range)
        }
        else{
            return FuriganaAnnotation(reading: self.reading , range: self.range)
        }
    }
}


extension Annotation:CustomStringConvertible{
    public var description: String{
        return "Base: \(base), reading: \(reading), POS: \(partOfSpeech)"
    }
}
