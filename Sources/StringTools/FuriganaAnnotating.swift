//
//  FuriganaAnnotating.swift
//
//
//  Created by Morten Bertz on 2021/04/15.
//

import Foundation

public protocol FuriganaAnnotating: Sendable{
    var base:String {get}
    var reading:String {get}
    var range:Range<String.Index> {get}

    func furiganaAnnotation(for text:String, kanjiOnly:Bool)->FuriganaAnnotation?
}

extension FuriganaAnnotating{

    /**
     Creates a `FuriganaAnnotation` for the token.

     With `kanjiOnly` set, leading and trailing Kana (okurigana, particles) are removed from the reading and the range is shortened accordingly, and Kana in the middle of the token are replaced by ideographic spaces, e.g. 打ち合わせ → う　あ for the range covering 打ち合. Base and reading are aligned to determine which part of the reading belongs to which character, so okurigana in the middle of a word are handled correctly (行き先 → い　さき). If base and reading cannot be aligned, the untouched reading for the full range of the token is returned.

     - parameters:
        - text: the text the token was found in. Ranges are expressed in terms of this string.
        - kanjiOnly: whether to strip the Kana that base and reading have in common.
     - returns: A `FuriganaAnnotation`, or `nil` if nothing is left to annotate.
     */
    public func furiganaAnnotation(for text:String, kanjiOnly:Bool)->FuriganaAnnotation?{
        return self.furiganaAnnotation(for: text, in: self.range, kanjiOnly: kanjiOnly)
    }

    /**
     Creates a `FuriganaAnnotation` for the token, for a range that differs from the `range` of the token itself.

     This is useful for tokens whose `range` includes characters that are not part of the token, e.g. leading white space.

     - parameters:
        - text: the text the token was found in. Ranges are expressed in terms of this string.
        - range: the range of `base` in `text`.
        - kanjiOnly: whether to strip the Kana that base and reading have in common.
     - returns: A `FuriganaAnnotation`, or `nil` if nothing is left to annotate.
     */
    public func furiganaAnnotation(for text:String, in range:Range<String.Index>, kanjiOnly:Bool)->FuriganaAnnotation?{

        guard kanjiOnly == true else{
            return FuriganaAnnotation(reading: self.reading, range: range)
        }

        guard let segments=self.base.furiganaSegments(reading: self.reading) else{
            // base and reading cannot be aligned (sound changes, readings that don't contain the okurigana, ...). The reading for the whole token is the safe fallback.
            return self.reading.isEmpty ? nil : FuriganaAnnotation(reading: self.reading, range: range)
        }

        guard let firstAnnotated=segments.firstIndex(where: {$0.needsReading}),
              let lastAnnotated=segments.lastIndex(where: {$0.needsReading})
        else{
            //the token is Kana only, there is nothing to annotate
            return nil
        }

        let annotated=segments[firstAnnotated...lastAnnotated]

        let leading=self.base.distance(from: self.base.startIndex, to: segments[firstAnnotated].baseRange.lowerBound)
        let trailing=self.base.distance(from: segments[lastAnnotated].baseRange.upperBound, to: self.base.endIndex)

        guard let lowerBound=text.index(range.lowerBound, offsetBy: leading, limitedBy: range.upperBound),
              let upperBound=text.index(range.upperBound, offsetBy: -trailing, limitedBy: lowerBound)
        else{
            return FuriganaAnnotation(reading: self.reading, range: range)
        }

        let transliteration=annotated.map({segment->String in
            guard segment.needsReading else{
                //Kana in the middle of the token are kept as spacers to keep the reading aligned with the base
                let length=self.base.distance(from: segment.baseRange.lowerBound, to: segment.baseRange.upperBound)
                return String(repeating: "　", count: length)
            }
            return String(self.reading[segment.readingRange])
        }).joined()

        guard transliteration.isEmpty == false else {return nil}
        return FuriganaAnnotation(reading: transliteration, range: lowerBound..<upperBound)
    }
}
