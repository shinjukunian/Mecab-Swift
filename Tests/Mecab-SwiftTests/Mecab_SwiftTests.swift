import XCTest
import Mecab_Swift
import CharacterFilter
import IPADic
import Dictionary

final class Mecab_SwiftTests: XCTestCase {
        
    
    var dictionaries:[DictionaryProviding]{
        return [IPADic()]
    }
    
    
    func testVersion(){
        let version=Tokenizer.version
        XCTAssertFalse(version.isEmpty)
    }
    
    func testLoading() {
        do{
            let tokenizer=try Tokenizer(dictionary: IPADic())
            XCTAssertNotNil(tokenizer)
        }
        catch let error{
            XCTFail(error.localizedDescription)
        }
    }
    
    func testLoadingFails() {
        do{
            let tokenizer=try Tokenizer(dictionary: IPADic())
            XCTAssertNotNil(tokenizer)
        }
        catch let error{
            XCTAssertFalse(error.localizedDescription.isEmpty)
        }
    }
    
    func testLoadingTokenization() {
        do{
            let tokenizer=try Tokenizer(dictionary: IPADic())
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
            let tokenizer=try Tokenizer(dictionary: IPADic())
            XCTAssertNotNil(tokenizer)
            let string="熊が怖いです。"
            let annotations=tokenizer.tokenize(text: string).filter({$0.containsKanji}).compactMap({$0.furiganaAnnotation(for: string)})
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
            let tokenizers=try self.dictionaries.map({
                try Tokenizer(dictionary: $0)
            }) + [Tokenizer.systemTokenizer]
            
            for tokenizer in tokenizers{
            
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
            
            
        }
        catch let error{
            XCTFail(error.localizedDescription)
        }
    }
    
    func testCenter() {
        do{
            let tokenizers=try self.dictionaries.map({
                try Tokenizer(dictionary: $0)
            }) + [Tokenizer.systemTokenizer]
            
            for tokenizer in tokenizers{
                
                XCTAssertNotNil(tokenizer)
                let string="打ち上げパーティー"
                let annotations=tokenizer.tokenize(text: string).filter({$0.containsKanji}).compactMap({$0.furiganaAnnotation(options: [.kanjiOnly], for: string)})
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
            
            
        }
        catch let error{
            XCTFail(error.localizedDescription)
        }
    }
    
    
    func testTwoRanges() {
        do{
            let tokenizers=try self.dictionaries.map({
                try Tokenizer(dictionary: $0)
            }) + [Tokenizer.systemTokenizer]
            
            for tokenizer in tokenizers{
                XCTAssertNotNil(tokenizer)
                let string="お知らせです"
                let annotations=tokenizer.tokenize(text: string).filter({$0.containsKanji}).compactMap({$0.furiganaAnnotation(options: [.kanjiOnly], for: string)})
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
            
        }
        catch let error{
            XCTFail(error.localizedDescription)
        }
    }
    
    func testTags(){
        do{
            let tokenizers=try self.dictionaries.map({
                try Tokenizer(dictionary: $0)
            }) + [Tokenizer.systemTokenizer]
            
            for tokenizer in tokenizers{
                XCTAssertNotNil(tokenizer)
                let string =
                 """
     JR東日本によると、2日午後7時15分ごろ、JR新宿駅で、線路の上にいた人が、入線した山手線と衝突した。女性とみられ、容体は不明。現場に白杖が落ちており、警視庁などが調べている
     """
                 
                 let rubyString=tokenizer.addRubyTags(to: string, transliteration: .hiragana, options: [.kanjiOnly])
                 XCTAssertFalse(rubyString.isEmpty)
                 XCTAssertFalse(rubyString.range(of: "<ruby>")?.isEmpty ?? true)
            }
           
           
           
       }
       catch let error{
           XCTFail(error.localizedDescription)
       }

    }
    
    func testLong(){
        do{
            let tokenizers=try self.dictionaries.map({
                try Tokenizer(dictionary: $0)
            }) + [Tokenizer.systemTokenizer]
            
            for tokenizer in tokenizers{
                XCTAssertNotNil(tokenizer)
                let string =
                    """
     愛知県で開催中の国際芸術祭「あいちトリエンナーレ2019」の企画展「表現の不自由展・その後」は8日午後に再開する。不自由展は従軍慰安婦を象徴する「平和の少女像」などの展示に抗議が相次ぎ、8月1日の芸術祭開幕から3日で中止に追い込まれていたが、芸術祭実行委員会会長の大村秀章知事が7日、安全対策や入場制限を講じた上で再開すると表明した。【写真特集】大勢の来場者が鑑賞していた「平和の少女像」芸術祭実行委員会のホームページによると、入場は1日2回に制限し、抽選で1回30人に絞り、1回目は午後2時10分から1時間。2回目は午後4時20分から40分間。大村知事の7日の発表によると、鑑賞者は事前にエデュケーション（教育）プログラムを実施し、ガイドを付けて鑑賞する。また、安全を確保するため金属探知機によるチェックも行う。不自由展の中止後、抗議の意思を示すため、芸術祭に参加していた他の国内外10組以上の作家が出展を中止・変更していたが、同展再開に伴い、全作家が復帰する。不自由展が開幕3日で中止になったことを巡っては、文化庁が「（開催により）円滑な運営が脅かされることを認識していたにもかかわらず、申告しなかった」などとして、既に採択していた県への補助金の全額不交付を決めている。芸術祭は14日まで。【竹田直人】
     """
                
                let rubyString=tokenizer.addRubyTags(to: string, transliteration: .hiragana, options: [.kanjiOnly])
                XCTAssertFalse(rubyString.isEmpty)
                XCTAssertFalse(rubyString.range(of: "<ruby>")?.isEmpty ?? true)
            }
            
        }
        catch let error{
            XCTFail(error.localizedDescription)
        }
        
    }
    
    func testLong2(){
        
        // this string has some of the hiragana composed of two characters instead of one, which throws off th erange finding algorithm. the work aroubnd is to restrict searching to tokens with kanji, which is what we care about anyway. If we want to get tokens from katakana words or hiragana expressions, the tokenizer will not produce these
        let string = """
"From: 研究サービス noreply@qemailserver.com Subject: テクノロジーに関するご意見をお聞かせください\nDate: May 28, 2020 8:38\nTo:test\n   簡単なアンケート回答いただいた方に5ドル進 呈いたします。\n私たちはこの異例の困難な状況にあり、アンケートに回答していただくこと は、あなたにとって優先事項でないかもしれないことを理解しております。し かしながら、弊社にとってお客様の声は大変貴重であり、あなたのご意見をぜ\nひお聞かせいただきたいと考えております。\nこのアンケートにお答えいただきますと、 5ドルのAmazonギフトカード を進呈 いたします。ギフトカードは参加条件を満たし、アンケートすべてを完了して\nいただいたご参加者様にのみ贈らせていただきますのでご了承ください。\nこの機密扱いの調査はテクノロジー業界の大手企業であるクライアントに代わ り、Qualtricsアンケートプラットフォーム上で実施されます。この企業のサー ビスについてお伺いするものです。アンケートの所要時間は20~25分ほどで\nす。\n下記をクリックするか、ウェブブラウザにリンクをコピー・アンド・ペースト して回答を始めてください。\nクリック\nありがとうございます。ご協力に感謝いたします。\n本アンケートは任意でご参加いただくものです。条件を満たし、本アンケートを完了された ご参加者様へ、この招待状が送信されたメールアドレス宛にギフトカードが送信されます。\n処理には2~3週間を要しますのでご了承ください。当社は調査を実施することのみを目的 としてご連絡させていただきました。民族性など、基本的な人口統計情報をお尋ねする場合 があります。ご参加者様のデータは機密情報として保持され、テクノロジー業界の大手企業 である当社のクライアントと集計データとしてのみ共有されます。クライアントはこの情報 をサービスの調査の実施およびサービスの向上を目的として使用します。本アンケートを完\n "
"""
        
        
        
        do{
            let tokenizers=try self.dictionaries.map({
                try Tokenizer(dictionary: $0)
            }) + [Tokenizer.systemTokenizer]
            
            for tokenizer in tokenizers{
                XCTAssertNotNil(tokenizer)
                let tokens =  tokenizer.furiganaAnnotations(for: string, options: [.kanjiOnly])
                XCTAssert(tokens.count > 40)
            }
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
            
            let tokenizer=try Tokenizer(dictionary: IPADic())
            
            
            let rubyString=tokenizer.addRubyTags(to: htmlText, transliteration: .hiragana, options: [.kanjiOnly])
            XCTAssertFalse(rubyString.isEmpty)
            XCTAssertFalse(rubyString.range(of: "<ruby>")?.isEmpty ?? true)
            
            
        }
        catch let error{
            XCTFail(error.localizedDescription)
        }
    }
    
    
    
    func testPerformanceClassic(){
        
        let currentURL=URL(fileURLWithPath: #file).deletingLastPathComponent().deletingLastPathComponent()
        let htmlURL=currentURL.appendingPathComponent("Resources", isDirectory: true).appendingPathComponent("helicobacter").appendingPathExtension("html")
        
        measure {
            do{
                let htmlText=try String(contentsOf: htmlURL)
                let tokenizer=Tokenizer.systemTokenizer
                
                
                let rubyString=tokenizer.addRubyTags(to: htmlText, transliteration: .hiragana, options: [.kanjiOnly])
                XCTAssertFalse(rubyString.isEmpty)
                XCTAssertFalse(rubyString.range(of: "<ruby>")?.isEmpty ?? true)
            }
            catch let error{
                XCTFail(error.localizedDescription)
            }
        }
        
        
    }
    
    func testPerformanceStreamingMecab(){
        let currentURL=URL(fileURLWithPath: #file).deletingLastPathComponent().deletingLastPathComponent()
        let htmlURL=currentURL.appendingPathComponent("Resources", isDirectory: true).appendingPathComponent("イギリス").appendingPathExtension("html")
        measure {
            do{
                let htmlText=try String(contentsOf: htmlURL)
                let tokenizer=try Tokenizer(dictionary: IPADic())
                let rubyString=tokenizer.rubyTaggedString(source: htmlText, transliteration: .romaji, options: [.kanjiOnly])
                XCTAssertFalse(rubyString.isEmpty)
                XCTAssertFalse(rubyString.range(of: "<ruby>")?.isEmpty ?? true)
            }
            catch let error{
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    
    func testPerformanceStreamingSystem(){
        let currentURL=URL(fileURLWithPath: #file).deletingLastPathComponent().deletingLastPathComponent()
        let htmlURL=currentURL.appendingPathComponent("Resources", isDirectory: true).appendingPathComponent("イギリス").appendingPathExtension("html")
        measure {
            do{
                let htmlText=try String(contentsOf: htmlURL)
                let tokenizer=Tokenizer.systemTokenizer
                let rubyString=tokenizer.rubyTaggedString(source: htmlText, transliteration: .romaji, options: [.kanjiOnly])
                XCTAssertFalse(rubyString.isEmpty)
                XCTAssertFalse(rubyString.range(of: "<ruby>")?.isEmpty ?? true)
            }
            catch let error{
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testTransliteration(){
        do{
            let tokenizers=try self.dictionaries.map({
                try Tokenizer(dictionary: $0)
            }) + [Tokenizer.systemTokenizer]
            
            for tokenizer in tokenizers{
                let text="世界人口"
                let furigana=tokenizer.furiganaAnnotations(for: text, transliteration: .hiragana, options: [.kanjiOnly])
                XCTAssertNotNil(furigana.first(where: {$0.reading == "じんこう"}))
                
                let romaji=tokenizer.furiganaAnnotations(for: text, transliteration: .romaji, options: [.kanjiOnly])
                
                XCTAssertNotNil(romaji.first(where: {$0.reading == "jinkō"}))
            }
            
            
        }
        catch let error{
            XCTFail(error.localizedDescription)
        }
    }
    
    func testFilter1(){
        do{
            let text="世界人口"
            let tokenizer=try Tokenizer(dictionary: IPADic())
            let disallowed=["口","人"]
            let furigana=tokenizer.furiganaAnnotations(for: text, transliteration: .hiragana, options: [.kanjiOnly, .filter(disallowedCharacters: Set(disallowed), strict: true)])
            XCTAssertNil(furigana.first(where: {$0.reading == "じんこう"}))
            XCTAssertNotNil(furigana.first(where: {$0.reading == "せかい"}))
            XCTAssert(furigana.count == 1)
            
            
        }
        catch let error{
            XCTFail(error.localizedDescription)
        }
    }
    
    func testFilter2(){
        do{
            let text="世界人口"
            let tokenizer=try Tokenizer(dictionary: IPADic())
            let disallowed=["口"]
            let furigana=tokenizer.furiganaAnnotations(for: text, transliteration: .hiragana, options: [.kanjiOnly, .filter(disallowedCharacters: Set(disallowed), strict: false)])
            XCTAssertNotNil(furigana.first(where: {$0.reading == "じんこう"}))
            XCTAssertNotNil(furigana.first(where: {$0.reading == "せかい"}))
            XCTAssert(furigana.count == 2)
            
            
        }
        catch let error{
            XCTFail(error.localizedDescription)
        }
        
        
    }
    
    
    func testFilter3(){
        do{
            let text="世界人口"
            let tokenizer=try Tokenizer(dictionary: IPADic())
            let disallowed=SchoolYearFilter.elementary2.disallowedCharacters
            let furigana=tokenizer.furiganaAnnotations(for: text, transliteration: .hiragana, options: [.kanjiOnly, .filter(disallowedCharacters: disallowed, strict: false)])
            XCTAssertNil(furigana.first(where: {$0.reading == "じんこう"}))
            XCTAssertNotNil(furigana.first(where: {$0.reading == "せかい"}))
            XCTAssert(furigana.count == 1)
            
            
        }
        catch let error{
            XCTFail(error.localizedDescription)
        }
    }
    
    
    func testSystemTokenizer1(){
        
        let text="世界人口"
        let tokenizer=Tokenizer.systemTokenizer
        let disallowed=SchoolYearFilter.elementary2.disallowedCharacters
        let furigana=tokenizer.furiganaAnnotations(for: text, transliteration: .hiragana, options: [.kanjiOnly, .filter(disallowedCharacters: disallowed, strict: false)])
        XCTAssertNil(furigana.first(where: {$0.reading == "じんこう"}))
        XCTAssertNotNil(furigana.first(where: {$0.reading == "せかい"}))
        XCTAssert(furigana.count == 1)
            
            
       
    }
    
    
    
    

    static var allTests = [
        ("Test Loading", testLoading),
    ]
}
