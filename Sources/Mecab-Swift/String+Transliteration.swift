//
//  String+Transliteration.swift
//  Kanjidictionary
//
//  Created by Morten Bertz on 2019/01/04.
//  Copyright © 2019 Morten Bertz. All rights reserved.
//

import Foundation

extension String{
    
    public enum RomanizationMethod:Int{
        case waPro
        case hepburn
    }
    
    public func romanizedString(method:RomanizationMethod = .hepburn)->String{
        
        let mutableSelf=CFStringCreateMutableCopy(nil, 0, self as CFString)
        if self.japaneseScriptType.contains(.hiragana){
            CFStringTransform(mutableSelf, nil, kCFStringTransformLatinHiragana, true)
        }
        else if self.japaneseScriptType.contains(.katakana){
            CFStringTransform(mutableSelf, nil, kCFStringTransformLatinKatakana, true)
        }
        let transformed=CFStringCreateCopy(nil, mutableSelf)
        
        switch method {
        case .waPro:
            
            return (transformed as String?) ?? self
            
        case .hepburn:
            guard let t=CFStringCreateCopy(nil, mutableSelf) else{return self}
            var transformed=t as String
            
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
