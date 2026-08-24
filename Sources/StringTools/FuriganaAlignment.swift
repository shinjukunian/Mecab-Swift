//
//  FuriganaAlignment.swift
//
//
//  Created by Morten Bertz on 2026/08/24.
//

import Foundation

/**
 A part of a word, pairing a run of the base string with the part of the reading it is pronounced as.

 `FuriganaSegment`s are produced by `String.furiganaSegments(reading:)`, which aligns a base string (typically a mix of Kanji and Kana) with its reading (Kana only). Segments that consist of Kana shared by base and reading, i.e. okurigana or particles, are marked by `needsReading == false`.
 */
public struct FuriganaSegment: Equatable, Sendable {

    /// The range of the segment in the base string.
    public let baseRange:Range<String.Index>

    /// The range of the corresponding reading in the reading string.
    public let readingRange:Range<String.Index>

    /// `true` for runs that require an annotation (Kanji, numerals, latin characters), `false` for Kana that base and reading have in common, e.g. okurigana.
    public let needsReading:Bool

    public init(baseRange:Range<String.Index>, readingRange:Range<String.Index>, needsReading:Bool) {
        self.baseRange = baseRange
        self.readingRange = readingRange
        self.needsReading = needsReading
    }
}

public extension String {

    /**
     Aligns the string (the base, typically a mix of Kanji and Kana) with its `reading` (Kana).

     The string is split into runs of Kana and runs of characters that require a reading (Kanji, numerals, ...). The Kana runs are then matched against the reading, which assigns each Kanji run the part of the reading that belongs to it. This works for okurigana in any position, including in the middle of a word (e.g. 行き先 → 行:い, き, 先:さき).

     - parameters:
        - reading: the reading of the string, in Hiragana or Katakana. Katakana and Hiragana are considered equivalent for matching.
     - returns: The segments of the word, in order, or `nil` if base and reading cannot be aligned (e.g. because the reading doesn't contain the Kana of the base, as in 今日は → こんにちは).
     */
    func furiganaSegments(reading:String)->[FuriganaSegment]? {

        let baseCharacters=Array(self)
        let readingCharacters=Array(reading)

        guard baseCharacters.isEmpty == false, readingCharacters.isEmpty == false else { return nil }

        let baseFolded=baseCharacters.map({ $0.hiraganaFolded })
        let readingFolded=readingCharacters.map({ $0.hiraganaFolded })

        // Runs of Kana and runs of characters that need a reading.
        var runs=[(range: Range<Int>, needsReading: Bool)]()
        var runStart=0
        while runStart < baseCharacters.count {
            let isKana=baseCharacters[runStart].isKana
            var runEnd=runStart + 1
            while runEnd < baseCharacters.count, baseCharacters[runEnd].isKana == isKana {
                runEnd += 1
            }
            runs.append((runStart..<runEnd, !isKana))
            runStart = runEnd
        }

        guard let readingRuns=Self.alignedReadingRuns(runs: runs, base: baseFolded, reading: readingFolded) else {
            return nil
        }

        let baseIndices=Array(self.indices) + [self.endIndex]
        let readingIndices=Array(reading.indices) + [reading.endIndex]

        return zip(runs, readingRuns).map({ run, readingRun in
            FuriganaSegment(baseRange: baseIndices[run.range.lowerBound]..<baseIndices[run.range.upperBound],
                            readingRange: readingIndices[readingRun.lowerBound]..<readingIndices[readingRun.upperBound],
                            needsReading: run.needsReading)
        })
    }

    /**
     Assigns each run of the base a part of the reading.

     Kana runs have to match the reading exactly, runs that need a reading consume at least one character each. The shortest possible reading is assigned to each run, which is what makes 行き先 → い + き + さき work. If no alignment can be found under the assumption that every character needs at least one Kana, the search is repeated with a minimum of one Kana per run, which covers ateji such as 大人 → おとな.
     */
    private static func alignedReadingRuns(runs:[(range:Range<Int>, needsReading:Bool)], base:[Character], reading:[Character])->[Range<Int>]? {

        for minimumPerCharacter in [true, false] {

            // memoizes (run, position) combinations that are known to fail, to keep the search from blowing up on long words
            var failed=Set<Int>()

            func match(run runIndex:Int, position:Int)->[Range<Int>]? {
                guard runIndex < runs.count else {
                    return position == reading.count ? [] : nil
                }

                let key=runIndex * (reading.count + 1) + position
                guard failed.contains(key) == false else { return nil }

                let run=runs[runIndex]
                let length=run.range.count

                if run.needsReading {
                    let minimumLength=minimumPerCharacter ? length : 1
                    var candidateLength=minimumLength
                    while position + candidateLength <= reading.count {
                        if let rest=match(run: runIndex + 1, position: position + candidateLength) {
                            return [position..<position + candidateLength] + rest
                        }
                        candidateLength += 1
                    }
                }
                else if position + length <= reading.count,
                        base[run.range].elementsEqual(reading[position..<position + length]),
                        let rest=match(run: runIndex + 1, position: position + length) {
                    return [position..<position + length] + rest
                }

                failed.insert(key)
                return nil
            }

            if let aligned=match(run: 0, position: 0) {
                return aligned
            }
        }

        return nil
    }
}

//not public to avoid clashes with the same functionality in client code
internal extension Character {

    /// Whether the character is Hiragana or Katakana (including the prolonged sound mark).
    var isKana:Bool {
        guard let scalar=self.unicodeScalars.first else { return false }
        return CharacterSet.hiraganaRange.contains(scalar) || CharacterSet.katakanaRange.contains(scalar)
    }

    /// The character with Katakana folded to Hiragana, so that readings in either script can be compared.
    var hiraganaFolded:Character {
        let scalars=String(self).precomposedStringWithCanonicalMapping.unicodeScalars.map({ scalar->Unicode.Scalar in
            switch scalar.value {
            case 0x30a1...0x30f6:
                return Unicode.Scalar(scalar.value - 0x60) ?? scalar
            default:
                return scalar
            }
        })
        var view=String.UnicodeScalarView()
        view.append(contentsOf: scalars)
        return Character(String(view))
    }
}
