import UIKit
import PlaygroundSupport
import CoreText

import IPADic
import StringTools
import Mecab_Swift
import Foundation
import CoreGraphics
import NaturalLanguage

/*:
 # Welcome to the Mecab Playgorund.
 Let's define a short piece of Japanese text:
*/
let text = "蜂蜜は熊の大好物です。"

/*:We can use _Mecab_ to tokenize this text. For this, we need a dictionary. This package includes the IPADic dictionary <https://github.com/taku910/mecab/tree/master/mecab-ipadic>.
 */

let ipadic=IPADic()
let ipadicTokenizer = try Tokenizer(dictionary: ipadic)

/*:The tokenizer can be used to tokenize text. The return is an array of `Annotation`, which contain information about the tokens (the token itself, the reading, part of speech etc).
 */

let ipadicFurigana=ipadicTokenizer.tokenize(text: text, transliteration: .hiragana)
print(ipadicFurigana)

let nouns=ipadicFurigana.filter {$0.partOfSpeech == .noun}.map {$0.base}

print("The nouns in \"\(text)\" are \(ListFormatter().string(from: nouns) ?? "")")

let hiraganized =
    ipadicFurigana.map{$0.reading}.joined()
print(hiraganized)


/*:The transliteration for the reading can be changed from hiragana to romaji if desired.
 */
let romaji=ipadicTokenizer.tokenize(text: text, transliteration: .romaji)
print(romaji)
let romanized = romaji.map{$0.reading}.joined(separator: " ")
print(romanized)

/*:One application of _Mecab_ is producing furigana annotations to provide readings for Kanji characters. This can be achieved using:
 */
let kanjiAnnotations=ipadicTokenizer.furiganaAnnotations(for: text, transliteration: .katakana, options: [.kanjiOnly])
print(kanjiAnnotations)

/*:Here, the `.kanjiOnly` option, which is the default, signifies that we only want `FuriganaAnnotation`s for tokens containing Kanji characters. In addition, Furigana will only be added for the Kanji character itself, Okurigana will be omitted. Compare
 */

let text2 = "熊は蜂蜜を食べています。"
let furiganaWithOkurigana=ipadicTokenizer.furiganaAnnotations(for: text2, transliteration: .hiragana, options: [])
print(furiganaWithOkurigana)
print(furiganaWithOkurigana.map{$0.reading}.joined(separator: " "))
let furiganaWithOutOkurigana=ipadicTokenizer.furiganaAnnotations(for: text2, transliteration: .hiragana, options: [.kanjiOnly])
print(furiganaWithOutOkurigana)
print(furiganaWithOutOkurigana.map{$0.reading}.joined(separator:" "))
/*:On Apple platforms, `CFStringTokenizer` provides most of this functionality (except for part-of-speech tagging). `Tokenizer` wraps `CFStringTokenizer` using the same API
 */

let tokenizer = Tokenizer.systemTokenizer
let annotations = tokenizer.tokenize(text: text)
print(annotations)

print(annotations.map {$0.reading}.joined())

let longerText=text2 + text + "でも鮭もよく食べます。"

let furigana=ipadicTokenizer.furiganaAnnotations(for:longerText, transliteration: .hiragana, options: [.kanjiOnly])
print(furigana)

/*:We can use the `FuriganaAnnotation`s to produce `CTRubyAnnotation`s that allow Furigana display on Apple platforms
 */

let attributed=NSMutableAttributedString(string: longerText)
for furi in furigana{
    attributed.addAttribute(NSAttributedString.Key(kCTRubyAnnotationAttributeName as String), value: furi.rubyAnnotation(), range: NSRange(furi.range, in: longerText))
}

class FuriganaView: UIView{
    
    let textFrame:CTFrame
    
    init(furiganaString:NSAttributedString) {

        let frameSetter=CTFramesetterCreateWithAttributedString(furiganaString)
        let range=CFRange(location: 0, length: furiganaString.length)
        let size=CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, range, [:] as CFDictionary, CGSize(width: 100, height: CGFloat.greatestFiniteMagnitude), nil)
        self.layoutedSize=size
        let frame=CTFramesetterCreateFrame(frameSetter, range, CGPath(rect: CGRect(origin: .zero, size: size), transform: nil), [:] as CFDictionary)
        self.textFrame=frame
        super.init(frame: .zero)
    }
    
    var layoutedSize:CGSize = CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
    
    override var intrinsicContentSize: CGSize{
        return layoutedSize
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let ctx=UIGraphicsGetCurrentContext() else{return}
        ctx.setFillColor(UIColor.white.cgColor)
        ctx.fill(rect)
        ctx.saveGState()
        defer{
            ctx.restoreGState()
        }
        ctx.textMatrix = .identity
        ctx.scaleBy(x: 1, y: -1)
        ctx.translateBy(x: 0, y: -rect.height)
        CTFrameDraw(textFrame, ctx)
    }
}

PlaygroundPage.current.liveView=FuriganaView(furiganaString: attributed)


/*:Mecab also provides lemmatization of Japanese verbs:
 */

let text3="でも鮭もよく食べます。"
let lemmatized = ipadicTokenizer.tokenize(text: text3)
    .filter {$0.partOfSpeech == .verb}
    .map {$0.dictionaryForm}
print(lemmatized)

/*:We can compare this output to `NLTokenizer`
 */
let NLtokenizer=NLTokenizer(unit: .word)
NLtokenizer.string=text3
let NLtokens=NLtokenizer.tokens(for: text3.startIndex..<text3.endIndex).map{text3[$0]}
print(NLtokens)

/*:`NLTagger` also provides part-of-speech tagging, unfortunately not for Japanese
 */
let avaliableTags=NLTagger.availableTagSchemes(for: .sentence, language: NLLanguage.japanese)
print(avaliableTags.map({$0.rawValue}))
