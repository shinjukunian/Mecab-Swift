import XCTest
@testable import Mecab_Swift

final class Mecab_SwiftTests: XCTestCase {
    
    //this seems clumsy, but is is important to check whether we can load dictionaries located at URLs that contain spaces
    lazy var dictionaryURL:URL = {
        let currentURL=URL(fileURLWithPath: #file).deletingLastPathComponent().deletingLastPathComponent()
        let modelURL=currentURL.appendingPathComponent("Resources", isDirectory: true).appendingPathComponent("ipadic dictionary", isDirectory: true)
        return modelURL
    }()
    
    
    func testVersion(){
        let version=Tokenizer.version
        XCTAssertFalse(version.isEmpty)
    }
    
    func testLoading() {
        do{
            let tokenizer=try Tokenizer(dictionary: Dictionary(url: self.dictionaryURL, type: .ipadic))
            XCTAssertNotNil(tokenizer)
        }
        catch let error{
            XCTFail(error.localizedDescription)
        }
    }
    
    func testLoadingFails() {
        do{
            let tokenizer=try Tokenizer(dictionary: Dictionary(url: URL(fileURLWithPath: ""), type: .ipadic))
            XCTAssertNotNil(tokenizer)
        }
        catch let error{
            XCTAssertFalse(error.localizedDescription.isEmpty)
        }
    }
    
    func testLoadingTokenization() {
        do{
            let tokenizer=try Tokenizer(dictionary: Dictionary(url: self.dictionaryURL, type: .ipadic))
            XCTAssertNotNil(tokenizer)
            let string="熊が怖いです。"
            let tokens=tokenizer.tokenize(text: string)
            XCTAssertFalse(tokens.isEmpty)
            print(tokens)
           
            
        }
        catch let error{
            XCTFail(error.localizedDescription)
        }
    }
    
    func testEnd() {
        do{
            let tokenizer=try Tokenizer(dictionary: Dictionary(url: self.dictionaryURL, type: .ipadic))
            XCTAssertNotNil(tokenizer)
            let string="熊が怖いです。"
            let annotations=tokenizer.tokenize(text: string).filter({$0.containsKanji}).map({$0.furiganaAnnotation(for: string)})
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
        catch let error{
            XCTFail(error.localizedDescription)
        }
    }
    
    
    func testStart() {
        do{
            let tokenizer=try Tokenizer(dictionary: Dictionary(url: self.dictionaryURL, type: .ipadic))
            XCTAssertNotNil(tokenizer)
            let string="お電話ください。"
            let annotations=tokenizer.tokenize(text: string).filter({$0.containsKanji}).map({$0.furiganaAnnotation(for: string)})
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
        catch let error{
            XCTFail(error.localizedDescription)
        }
    }
    
    func testCenter() {
        do{
            let tokenizer=try Tokenizer(dictionary: Dictionary(url: self.dictionaryURL, type: .ipadic))
            XCTAssertNotNil(tokenizer)
            let string="打ち上げパーティー"
            let annotations=tokenizer.tokenize(text: string).filter({$0.containsKanji}).map({$0.furiganaAnnotation(for: string)})
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
        catch let error{
            XCTFail(error.localizedDescription)
        }
    }
    
    func testTags(){
        do{
           let tokenizer=try Tokenizer(dictionary: Dictionary(url: self.dictionaryURL, type: .ipadic))
           XCTAssertNotNil(tokenizer)
           let string =
            """
JR東日本によると、2日午後7時15分ごろ、JR新宿駅で、線路の上にいた人が、入線した山手線と衝突した。女性とみられ、容体は不明。現場に白杖が落ちており、警視庁などが調べている
"""
            
            let rubyString=tokenizer.addRubyTags(to: string, transliteration: .hiragana, options: [.kanjiOnly])
            XCTAssertFalse(rubyString.isEmpty)
            XCTAssertFalse(rubyString.range(of: "<ruby>")?.isEmpty ?? true)
           
           
       }
       catch let error{
           XCTFail(error.localizedDescription)
       }

    }
    
    
    
    

    static var allTests = [
        ("Test Loading", testLoading),
    ]
}
