//
//  OkuriganaTests.swift
//  
//
//  Created by Morten Bertz on 2026/08/24.
//

import XCTest
import Mecab_Swift
import IPADic
import IPADicDefinition
import Dictionary
import StringTools

final class OkuriganaTests: XCTestCase {
    
    ///Okurigana in the middle of a word must not strip Kana that belong to the reading of the following Kanji.
    func testCenterOkurigana() throws {
        let tokenizer=try Tokenizer(dictionary: IPADic())
        let text="持ち帰りできますか。"
        let annotations = tokenizer.furiganaAnnotations(for: text, options: [.kanjiOnly])
        let annotation=try XCTUnwrap(annotations.first)
        XCTAssertEqual(annotation.reading, "も　かえ")
        XCTAssertEqual(String(text[annotation.range]), "持ち帰")
    }
    
    func testCenterOkurigana_ruby() throws {
        let tokenizer=try Tokenizer(dictionary: IPADic())
        let ruby = tokenizer.rubyTaggedString(source: "書き置きを読む", transliteration: .hiragana, options: [.kanjiOnly])
        //the trailing き of 置き must not remove the き of 書き
        XCTAssertEqual(ruby, "<ruby>書き置き<rt>か　お　</rt></ruby>を<ruby>読む<rt>よ　</rt></ruby>")
    }
    
    ///`mecab` reports tokens including the white space that precedes them. Furigana must not be placed over that white space.
    func testWhitespaceRanges() throws {
        let tokenizer=try Tokenizer(dictionary: IPADic())
        let text="犬が寝る。\n   現場に"
        let annotations = tokenizer.furiganaAnnotations(for: text, options: [.kanjiOnly])
        let annotation=try XCTUnwrap(annotations.first(where: {$0.reading == "げんば"}))
        XCTAssertEqual(String(text[annotation.range]), "現場")
        
        let tokens = tokenizer.tokenize(text: text)
        for token in tokens{
            XCTAssertEqual(String(text[token.rangeExcludingWhitespace]), token.base)
        }
    }
    
    ///The virtual beginning/end of sentence nodes of `mecab` carry no text and are not returned as tokens.
    func testNoEmptyTokens() throws {
        let tokenizer=try Tokenizer(dictionary: IPADic())
        let tokens = tokenizer.tokenize(text: "犬が寝る。")
        XCTAssertFalse(tokens.isEmpty)
        XCTAssertFalse(tokens.contains(where: {$0.base.isEmpty}))
        XCTAssertEqual(tokens.map({$0.base}).joined(), "犬が寝る。")
    }
    
    ///The ruby tagger must not lose text, even for input mecab cannot parse.
    func testRubyPreservesText() throws {
        let tokenizer=try Tokenizer(dictionary: IPADic())
        let text="犬が寝る。\n   現場に白杖が落ちて Hello 100人"
        let ruby = tokenizer.rubyTaggedString(source: text, transliteration: .hiragana, options: [.kanjiOnly])
        let stripped=ruby.replacingOccurrences(of: "<rt>[^<]*</rt>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "<ruby>", with: "")
            .replacingOccurrences(of: "</ruby>", with: "")
        XCTAssertEqual(stripped, text)
    }
}
