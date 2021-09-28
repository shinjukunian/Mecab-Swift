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
        let ruby=string.rubyTaggedString(useRomaji: false, kanjiOnly: true)
        XCTAssert(ruby != string)
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
        
        let ruby=string.rubyTaggedString(useRomaji: false, kanjiOnly: true)
        XCTAssert(ruby != string)
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
        
        let ruby=string.rubyTaggedString(useRomaji: false, kanjiOnly: true)
        XCTAssert(ruby != string)
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
    
    func testEndRuby(){
        let string="熊が怖いです。"
        let ruby=string.rubyTaggedString(useRomaji: false, kanjiOnly: true)
        XCTAssertFalse(string == ruby)
        
    }
    
    
    func testTags(){
        
        
        let string =
             """
 JR東日本によると、2日午後7時15分ごろ、JR新宿駅で、線路の上にいた人が、入線した山手線と衝突した。女性とみられ、容体は不明。現場に白杖が落ちており、警視庁などが調べている
 """
        let outString=string.rubyTaggedString(useRomaji: false, kanjiOnly: true)
        print(outString)
        XCTAssert(string != outString)
        
        
    }
    
    
    func testLong(){
        let text =
        """
西南戦争で、薩軍に投降を促す官軍のビラ。漢字が苦手な者でも読めるよう、振り仮名が書かれている。

宇田川榕菴が著した『舎密開宗』の化学実験図。ガスなどの外来語には、漢字を宛てた上で振り仮名をつけている。
振り仮名（ふりがな）とは、日本語において、文字（主に漢字）に対して、その読み方を示すために、その字の周りに添える表音文字である仮名[1]（平仮名や片仮名）のことをいう。
活版印刷において、基本的な本文の文字の大きさであった五号格の活字に対して、振り仮名として用いた七号格の活字が別名「ルビー（Ruby）」であったため、印刷物の振り仮名を「ルビ」ともいう。

目次
1    概要
2    脚注・出典
3    参考文献
4    関連項目
概要[編集]
漢文訓読のため、平安時代に使われるようになった「訓点」を起源とする見解がある。江戸時代に出版が盛んになると、読者層の広がりから、漢字の識字率が低い層でも読みやすくするための補助として発生・普及した。仮名交じり文の漢字に添えることが増えた。漢字の左右に、読み方（発音）と意味を並べた例もある。滝沢馬琴『南総里見八犬伝』では「梟首台」の右に「きゃうしゅだい」（きょうしゅだい）、左に「ゴクモンダイ」と振られている[1]。
活版印刷の流れを汲む出版作業では、振り仮名の大きさは、振り仮名を添える（振る）対象の文字（親文字）の半分とする。本文中の漢字全てに振り仮名を振るものと、読者対象や書物の内容などから文字を選んで振るものとがある。
明治時代に入って以降、第二次世界大戦まで、活版が盛んになっても全ての漢字に振り仮名が振ってあった。新聞、書籍等の、通常の成人日本語話者を読者として想定している出版物でも、振り仮名が振られている場合が多かった。
戦後になって作家の山本有三により「振り仮名がないと字が読めないようなのは恥ずかしいから振り仮名を全廃しよう、そして、振り仮名が無くとも読める字だけで書こう」との提言がなされた[2]。山本は戦前の小説『戦争と二人の婦人』（1938年刊）巻末で、振り仮名を「黒い虫の行列」と呼んだ[1]。これには振り仮名入り活字などの費用を抑えられることから印刷所なども同調し、さらに当用漢字表において振り仮名を使用しないこととされて使用が減った。しかし後に見直されて、難しい漢字でも場合によっては使用し、振り仮名を振った方が良いとの意見も出てくる。現在では、印刷技術も発達し、振り仮名を手軽に利用できるようになったので、振り仮名を振るものが主流となった。
子供や外国人を読者として想定している出版物は、漢字に振り仮名が付けられるのが普通である（片仮名にも平仮名でルビが振られることもある）。2008年頃から一部のテレビゲームにおいても振り仮名が付くようになった。また、人名の場合は漢字の読みが多種多様であるため（人名に使用できる漢字には規定があるが、読み方には規定が存在しない）、個人を扱う公式の書類の多くは、氏名と読みがなを併記する。
漢語で記しておいて、振り仮名はその意味の和語によってするというものも多く見られる。特に小説などの表現技法としてよく用いられる。また漫画や小説、歌の歌詞などでは、特殊な効果を狙って、漢字や外来語で記したものを全く別の振り仮名で読ませることもある[3]。こうした当て読みの例としては、「本気（マジ）」「瞬間（とき）」などがある[1]（「義訓」も参照）。
漢字を読む際の補助だけでなく、上記のような表現の多様性や文化・芸術的な意義から、振り仮名を積極的に評価する意見もある。井上ひさしは『私家版　日本語文法』（1981年刊）所収の「振仮名損得勘定」で「働き者の黒い虫たちにこれ以上、駆除剤を撒くと日本語はバラバラになってしまう」と唱えた。円城塔は小説『文字渦』（2018年刊）で、本文と別の文章を振り仮名で綴った[1]。
"""
        
    }
    
    
    
    func testHTML(){
        
        do{
            let currentURL=URL(fileURLWithPath: #file).deletingLastPathComponent().deletingLastPathComponent()
            let htmlURL=currentURL.appendingPathComponent("Resources", isDirectory: true).appendingPathComponent("helicobacter").appendingPathExtension("html")
            let htmlText=try String(contentsOf: htmlURL)
            
            
            
            
            let rubyString=htmlText.rubyTaggedString(useRomaji: false, kanjiOnly: true, disallowedCharacters: Set<String>())
            XCTAssertFalse(rubyString.isEmpty)
            XCTAssertFalse(rubyString.range(of: "<ruby>")?.isEmpty ?? true)
            
            
        }
        catch let error{
            XCTFail(error.localizedDescription)
        }
    }
}
