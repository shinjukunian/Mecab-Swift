//
//  FuriganaAlignmentTests.swift
//  
//
//  Created by Morten Bertz on 2026/08/24.
//

import Foundation
import XCTest
import StringTools

final class FuriganaAlignmentTests: XCTestCase {
    
    private struct Token:FuriganaAnnotating{
        let base:String
        let reading:String
        let range:Range<String.Index>
    }
    
    private func annotation(base:String, reading:String, in text:String)->FuriganaAnnotation?{
        guard let range=text.range(of: base) else{
            XCTFail("\(base) not found in \(text)")
            return nil
        }
        return Token(base: base, reading: reading, range: range).furiganaAnnotation(for: text, kanjiOnly: true)
    }
    
    func testSegments(){
        let segments=("行き先").furiganaSegments(reading: "いきさき")
        XCTAssertNotNil(segments)
        XCTAssertEqual(segments?.count, 3)
        XCTAssertEqual(segments?.map({"いきさき"[$0.readingRange]}), ["い","き","さき"])
        XCTAssertEqual(segments?.map({$0.needsReading}), [true, false, true])
    }
    
    func testSegmentsKatakanaReading(){
        //readings from mecab are Katakana, the base is Hiragana
        let segments=("打ち合わせ").furiganaSegments(reading: "ウチアワセ")
        XCTAssertEqual(segments?.map({"ウチアワセ"[$0.readingRange]}), ["ウ","チ","ア","ワセ"])
    }
    
    ///Okurigana in the middle of a word have to be aligned with the reading, a Kana that also occurs in the reading of a Kanji must not be stripped.
    func testCenterOkurigana(){
        XCTAssertEqual("いきさき".cleanupFurigana(base: "行き先"), "い　さき")
        XCTAssertEqual("もちかえり".cleanupFurigana(base: "持ち帰り"), "も　かえ　")
        XCTAssertEqual("かきおき".cleanupFurigana(base: "書き置き"), "か　お　")
        XCTAssertEqual("まちあわせばしょ".cleanupFurigana(base: "待ち合わせ場所"), "ま　あ　　ばしょ")
    }
    
    func testLeadingAndTrailingOkurigana(){
        XCTAssertEqual("おしらせ".cleanupFurigana(base: "お知らせ"), "　し　　")
        XCTAssertEqual("うながす".cleanupFurigana(base: "促す"), "うなが　")
    }
    
    ///Words without Kana are left alone, words that cannot be aligned keep their reading.
    func testAlignmentFailure(){
        XCTAssertEqual("せかい".cleanupFurigana(base: "世界"), "せかい")
        //the pronunciation field of mecab spells は as わ, which cannot be aligned with the base
        XCTAssertNil(("今日は").furiganaSegments(reading: "きょうわ"))
        XCTAssertEqual("きょうわ".cleanupFurigana(base: "今日は"), "きょうわ")
        //but the reading field can be aligned
        XCTAssertEqual("こんにちは".cleanupFurigana(base: "今日は"), "こんにち　")
    }
    
    ///Readings that are shorter than the number of Kanji, e.g. ateji.
    func testAteji(){
        XCTAssertEqual("おとなになる".cleanupFurigana(base: "大人になる"), "おとな　　　")
        XCTAssertEqual(("大人").furiganaSegments(reading: "おとな")?.count, 1)
    }
    
    func testAnnotationRanges(){
        let text="明日の打ち合わせは中止です。"
        let annotation=self.annotation(base: "打ち合わせ", reading: "うちあわせ", in: text)
        XCTAssertEqual(annotation?.reading, "う　あ")
        XCTAssertEqual(annotation.map({String(text[$0.range])}), "打ち合")
        
        let center=self.annotation(base: "行き先", reading: "いきさき", in: "行き先を教えて")
        XCTAssertEqual(center?.reading, "い　さき")
        XCTAssertEqual(center.map({String("行き先を教えて"[$0.range])}), "行き先")
        
        let leading=self.annotation(base: "お知らせ", reading: "おしらせ", in: "重要なお知らせです")
        XCTAssertEqual(leading?.reading, "し")
        XCTAssertEqual(leading.map({String("重要なお知らせです"[$0.range])}), "知")
    }
    
    ///Kana only tokens have nothing to annotate
    func testKanaOnly(){
        let text="ください"
        XCTAssertNil(self.annotation(base: "ください", reading: "ください", in: text))
    }
    
    func testHiraganaRanges(){
        let base="書き置き"
        let ranges=base.hiraganaRanges
        XCTAssertEqual(ranges.count, 2)
        XCTAssertEqual(ranges.map({String(base[$0])}), ["き","き"])
        //the two runs are distinct, the second one is at the end of the string
        XCTAssertNotEqual(ranges.first, ranges.last)
        XCTAssertEqual(ranges.last?.upperBound, base.endIndex)
    }
}
