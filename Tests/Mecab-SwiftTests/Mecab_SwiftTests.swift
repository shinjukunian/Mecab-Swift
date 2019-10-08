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
    
    
    func testTwoRanges() {
        do{
            let tokenizer=try Tokenizer(dictionary: Dictionary(url: self.dictionaryURL, type: .ipadic))
            XCTAssertNotNil(tokenizer)
            let string="お知らせです"
            let annotations=tokenizer.tokenize(text: string).filter({$0.containsKanji}).map({$0.furiganaAnnotation(for: string)})
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
    
    func testLong(){
            do{
               let tokenizer=try Tokenizer(dictionary: Dictionary(url: self.dictionaryURL, type: .ipadic))
               XCTAssertNotNil(tokenizer)
               let string =
                """
愛知県で開催中の国際芸術祭「あいちトリエンナーレ2019」の企画展「表現の不自由展・その後」は8日午後に再開する。不自由展は従軍慰安婦を象徴する「平和の少女像」などの展示に抗議が相次ぎ、8月1日の芸術祭開幕から3日で中止に追い込まれていたが、芸術祭実行委員会会長の大村秀章知事が7日、安全対策や入場制限を講じた上で再開すると表明した。【写真特集】大勢の来場者が鑑賞していた「平和の少女像」芸術祭実行委員会のホームページによると、入場は1日2回に制限し、抽選で1回30人に絞り、1回目は午後2時10分から1時間。2回目は午後4時20分から40分間。大村知事の7日の発表によると、鑑賞者は事前にエデュケーション（教育）プログラムを実施し、ガイドを付けて鑑賞する。また、安全を確保するため金属探知機によるチェックも行う。不自由展の中止後、抗議の意思を示すため、芸術祭に参加していた他の国内外10組以上の作家が出展を中止・変更していたが、同展再開に伴い、全作家が復帰する。不自由展が開幕3日で中止になったことを巡っては、文化庁が「（開催により）円滑な運営が脅かされることを認識していたにもかかわらず、申告しなかった」などとして、既に採択していた県への補助金の全額不交付を決めている。芸術祭は14日まで。【竹田直人】
"""
                
                let rubyString=tokenizer.addRubyTags(to: string, transliteration: .hiragana, options: [.kanjiOnly])
                XCTAssertFalse(rubyString.isEmpty)
                XCTAssertFalse(rubyString.range(of: "<ruby>")?.isEmpty ?? true)
               
               
           }
           catch let error{
               XCTFail(error.localizedDescription)
           }

        }
    
    
    func testHTML(){
        do{
            let currentURL=URL(fileURLWithPath: #file).deletingLastPathComponent().deletingLastPathComponent()
            let htmlURL=currentURL.appendingPathComponent("Resources", isDirectory: true).appendingPathComponent("helicobacter").appendingPathExtension("html")
            let htmlText=try String(contentsOf: htmlURL)
            let tokenizer=try Tokenizer(dictionary: Dictionary(url: self.dictionaryURL, type: .ipadic))
            let rubyString=tokenizer.addRubyTags(to: htmlText, transliteration: .hiragana, options: [.kanjiOnly])
            XCTAssertFalse(rubyString.isEmpty)
            XCTAssertFalse(rubyString.range(of: "<ruby>")?.isEmpty ?? true)
        }
        catch let error{
            XCTFail(error.localizedDescription)
        }
    }
    
    func testTransliteration(){
        do{
            let text="世界人口"
            let tokenizer=try Tokenizer(dictionary: Dictionary(url: self.dictionaryURL, type: .ipadic))
            let furigana=tokenizer.furiganaAnnotations(for: text, transliteration: .hiragana, options: [.kanjiOnly])
            XCTAssertNotNil(furigana.first(where: {$0.reading == "じんこう"}))
            
            let romaji=tokenizer.furiganaAnnotations(for: text, transliteration: .romaji, options: [.kanjiOnly])
            
            XCTAssertNotNil(romaji.first(where: {$0.reading == "jinkō"}))
            
        }
        catch let error{
            XCTFail(error.localizedDescription)
        }
    }
    
    
    
    
    
    
    
    

    static var allTests = [
        ("Test Loading", testLoading),
    ]
}
