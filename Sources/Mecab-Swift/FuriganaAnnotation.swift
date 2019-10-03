//
//  File.swift
//  
//
//  Created by Morten Bertz on 2019/10/02.
//

import Foundation

public struct FuriganaAnnotation:CustomStringConvertible,Equatable,Comparable{
   
    public let reading:String
    public let range:Range<String.Index>
    
    public var description: String{
        return "\(reading), \(range)"
    }
    
    public static func < (lhs: FuriganaAnnotation, rhs: FuriganaAnnotation) -> Bool {
        return lhs.range.lowerBound < rhs.range.lowerBound
    }
}

#if canImport(CoreText)
import CoreText

@available(OSX 10.12, iOS 10.0, *)
extension FuriganaAnnotation{
   
    public func rubyAnnotation(alignment:CTRubyAlignment = .auto, overhang:CTRubyOverhang = .auto, sizeFActor:CGFloat = 0.5, position:CTRubyPosition = .before, attributes:[NSAttributedString.Key:Any] = [:])->CTRubyAnnotation{
        var finalAttributes:[CFString:Any]=[kCTRubyAnnotationSizeFactorAttributeName:sizeFActor]
        for item in attributes{
            finalAttributes[item.key.rawValue as CFString]=item.value
        }
        let ruby=CTRubyAnnotationCreateWithAttributes(alignment, overhang, position, self.reading as CFString, finalAttributes as CFDictionary)
        return ruby
    }
}

#endif
