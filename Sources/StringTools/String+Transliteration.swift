//
//  String+Transliteration.swift
//  Kanjidictionary
//
//  Created by Morten Bertz on 2019/01/04.
//  Copyright © 2019 Morten Bertz. All rights reserved.
//

import Foundation

/// Functions to deal with transliteration
extension String{
    
    /// Romanization methods for Japanese text
    public enum RomanizationMethod:Int{
        
        /**
         Word Processor input.
         
         Mostly follows Hepburn transcription, e.g. し becomes shi. Long vowels are translated literally, e.g. `とうきょう` becomes `toukyou`.
        */
        case waPro
        
        /**
         Hepburn
         
         Hepburn transcription. Long vowels (o and u) are indicated by a macron (overbar), e.g., `とうきょう` becomes `tōkyō`,
         
         */
        case hepburn
    }
    
    
    /**
     Converts a string (hiragana or katakana) to latin characters.
     - parameters:
        - method: a RomanizationMethod (the default is .hepburn).
     - returns: the romanized String
     */
    public func romanizedString(method:RomanizationMethod = .hepburn)->String{
        
        var transformed:String
        if self.japaneseScriptType.contains(.hiragana){
            transformed=self.applyingTransform(.latinToHiragana, reverse: true) ?? ""
        }
        else if self.japaneseScriptType.contains(.katakana){
            transformed=self.applyingTransform(.latinToKatakana, reverse: true) ?? ""
        }
        else{
            transformed=self
        }

        
        switch method {
        case .waPro:
            return transformed
        case .hepburn:
            
            transformed=transformed.replacingOccurrences(of: "ou", with: "ō", options: [.literal], range: transformed.startIndex..<transformed.endIndex)
            transformed=transformed.replacingOccurrences(of: "Ou", with: "Ō", options: [.literal], range: transformed.startIndex..<transformed.endIndex)
            transformed=transformed.replacingOccurrences(of: "Oo", with: "Ō", options: [.literal], range: transformed.startIndex..<transformed.endIndex)
            transformed=transformed.replacingOccurrences(of: "oo", with: "ō", options: [.literal], range: transformed.startIndex..<transformed.endIndex)
            transformed=transformed.replacingOccurrences(of: "aa", with: "ā", options: [.literal], range: transformed.startIndex..<transformed.endIndex)
            transformed=transformed.replacingOccurrences(of: "Aa", with: "Ā", options: [.literal], range: transformed.startIndex..<transformed.endIndex)
            transformed=transformed.replacingOccurrences(of: "ee", with: "ē", options: [.literal], range: transformed.startIndex..<transformed.endIndex)
            transformed=transformed.replacingOccurrences(of: "Ee", with: "Ē", options: [.literal], range: transformed.startIndex..<transformed.endIndex)
            transformed=transformed.replacingOccurrences(of: "ii", with: "ī", options: [.literal], range: transformed.startIndex..<transformed.endIndex)
            transformed=transformed.replacingOccurrences(of: "Ii", with: "Ī", options: [.literal], range: transformed.startIndex..<transformed.endIndex)
            transformed=transformed.replacingOccurrences(of: "uu", with: "ū", options: [.literal], range: transformed.startIndex..<transformed.endIndex)
            transformed=transformed.replacingOccurrences(of: "Uu", with: "Ū", options: [.literal], range: transformed.startIndex..<transformed.endIndex)
            return transformed
        }
        
    }
}

public extension String{
    
    /// Converts a Katakana string to Hiragana.
    var hiraganaString:String{
        return self.applyingTransform(.hiraganaToKatakana, reverse: true) ?? self
    }
}
