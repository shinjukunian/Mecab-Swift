//
//  File.swift
//  
//
//  Created by Morten Bertz on 2021/04/15.
//

import Foundation

public protocol FuriganaAnnotating{
    var base:String {get}
    var reading:String {get}
    var range:Range<String.Index> {get}
    
    func furiganaAnnotation(for text:String, kanjiOnly:Bool)->FuriganaAnnotation?
}

extension FuriganaAnnotating{
    public func furiganaAnnotation(for text:String, kanjiOnly:Bool)->FuriganaAnnotation?{
        
        guard kanjiOnly == true else{
            return FuriganaAnnotation(reading: self.reading, range: self.range)
        }
        
        var range=self.range
        var transliteration=self.reading
        
        let hiraganaRanges=self.base.hiraganaRanges
        
        for hiraganaRange in hiraganaRanges{
            switch hiraganaRange {
            case _ where hiraganaRange.upperBound == self.base.endIndex:
                let trailingDistance=self.base.distance(from: self.base.endIndex, to: hiraganaRange.lowerBound)
                let newEndIndex=text.index(range.upperBound, offsetBy: trailingDistance)
                range=range.lowerBound..<newEndIndex
                let transliterationEnd=transliteration.index(transliteration.endIndex, offsetBy: trailingDistance)
                let newTransliterationRange=transliteration.startIndex..<transliterationEnd
                let t2=transliteration[newTransliterationRange]
                transliteration=String(t2)
            case _ where hiraganaRange.lowerBound == self.base.startIndex:
                let leadingDistance=self.base.distance(from: self.base.startIndex, to: hiraganaRange.upperBound)
                let newStartIndex=text.index(range.lowerBound, offsetBy: leadingDistance)// wrong?
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
        
        
        guard transliteration.isEmpty == false else {return nil}
        return FuriganaAnnotation(reading: transliteration, range: range)
    }
}
