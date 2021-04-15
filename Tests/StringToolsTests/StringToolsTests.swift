//
//  File.swift
//  
//
//  Created by Morten Bertz on 2021/04/15.
//

import Foundation
import XCTest
import StringTools

final class StringToolsTests: XCTestCase {
    
    func testStart() {
        let string="お電話ください。"
        let annotations=string.furiganaReplacements()
        
        XCTAssertFalse(annotations.isEmpty)
        let expectedFurigana=["でんわ"]
        for annotation in annotations{
            let subString=string[annotation.range]
            print("\(String(subString)), reading: \(annotation)")
        }
        for (expected,found) in zip(expectedFurigana,annotations.map({$0.reading})){
            XCTAssertEqual(expected, found)
        } 
    }
    
    func testCenter(){
        let string="打ち上げパーティー"
        let annotations=string.furiganaReplacements()
        XCTAssertFalse(annotations.isEmpty)
        let expectedFurigana=["う　あ"]
        for annotation in annotations{
            let subString=string[annotation.range]
            print("\(String(subString)), reading: \(annotation)")
        }
        for (expected,found) in zip(expectedFurigana,annotations.map({$0.reading})){
            XCTAssertEqual(expected, found)
        }
    }
    
    func testTwoRanges(){
        let string="お知らせです"
        let annotations=string.furiganaReplacements()
        XCTAssertFalse(annotations.isEmpty)
        let expectedFurigana=["し"]
        for annotation in annotations{
            let subString=string[annotation.range]
            print("\(String(subString)), reading: \(annotation)")
        }
        for (expected,found) in zip(expectedFurigana,annotations.map({$0.reading})){
            XCTAssertEqual(expected, found)
        }
    }
    
    func testEnd(){
        let string="熊が怖いです。"
        let annotations=string.furiganaReplacements()
        XCTAssertFalse(annotations.isEmpty)
        let expectedFurigana=["くま","こわ"]
        for annotation in annotations{
            let subString=string[annotation.range]
            print("\(String(subString)), reading: \(annotation)")
        }
        for (expected,found) in zip(expectedFurigana,annotations.map({$0.reading})){
            XCTAssertEqual(expected, found)
        }
    }
}
