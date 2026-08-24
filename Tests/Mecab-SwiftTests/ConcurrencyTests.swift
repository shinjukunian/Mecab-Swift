//
//  ConcurrencyTests.swift
//  
//
//  Created by Morten Bertz on 2026/08/24.
//

import XCTest
import Dispatch
import Mecab_Swift
import IPADic
import IPADicDefinition
import Dictionary

final class ConcurrencyTests: XCTestCase {
    
    ///Collects the results of the concurrently running iterations.
    private final class Results<Element>: @unchecked Sendable{
        private let lock=NSLock()
        private var storage=[Element]()
        
        func append(_ element:Element){
            self.lock.lock()
            defer{self.lock.unlock()}
            self.storage.append(element)
        }
        
        var elements:[Element]{
            self.lock.lock()
            defer{self.lock.unlock()}
            return self.storage
        }
    }
    
    ///One `Tokenizer` shared by many threads. `mecab` itself is not thread safe, the `Tokenizer` serializes access to it.
    func testConcurrentAccess() throws {
        let tokenizer=try Tokenizer(dictionary: IPADic())
        let text="持ち帰りできますか。行き先を教えてください。"
        let expectedRuby=tokenizer.rubyTaggedString(source: text, transliteration: .hiragana, options: [.kanjiOnly])
        XCTAssertFalse(expectedRuby.isEmpty)
        
        let results=Results<(ruby:String, readings:[String])>()
        
        DispatchQueue.concurrentPerform(iterations: 100, execute: {_ in
            let ruby=tokenizer.rubyTaggedString(source: text, transliteration: .hiragana, options: [.kanjiOnly])
            let readings=tokenizer.furiganaAnnotations(for: text, options: [.kanjiOnly]).map({$0.reading})
            results.append((ruby, readings))
        })
        
        let elements=results.elements
        XCTAssertEqual(elements.count, 100)
        for element in elements{
            XCTAssertEqual(element.ruby, expectedRuby)
            XCTAssertEqual(element.readings, ["も　かえ","ゆ　さき","おし"])
        }
    }
}
