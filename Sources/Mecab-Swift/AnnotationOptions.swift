//
//  AnnotationOptions.swift
//  
//
//  Created by Morten Bertz on 2020/06/13.
//

import Foundation

extension Annotation{
    
    //Ideally, this should be an option set with associated values, but that doesnt seem to exist in swift
    
    /**
     Various options to format `Annotation` output
     */
    public enum AnnotationOption:Equatable, Hashable{
    
        /**
        The reading of the `Annotation` should only conatain information for the actual Kanji characters, skipping leading or trailing Kana, e.g. okurigana.

         For example the reading for 打ち合わせ would typically be うちわわせ. With `kanjiOnly` set, the reading skips the kana common in reading and base, the resulting reading is う＿あ, with ＿ representing a fulll-width space. The start and end of the range are adjusted appropriately.
         */
        case kanjiOnly
        
        /**
         Filter tokens - for certain characters no tokens are returned.
        -  `disallowedCharacters:` a set of Kanji characters for which no tokens are returned.
        -  `strict`: determines whether tokens are filtered if only some characters or all characters in the token are in the set of disallowed characters

         */
        case filter(disallowedCharacters:Set<String>, strict:Bool)
        
    }
}

