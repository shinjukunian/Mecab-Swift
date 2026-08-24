[![Swift](https://github.com/shinjukunian/Mecab-Swift/actions/workflows/swift.yml/badge.svg?branch=master)](https://github.com/shinjukunian/Mecab-Swift/actions/workflows/swift.yml)

# Mecab-Swift

This package provides a Swift wrapper around MeCab <https://taku910.github.io/mecab/>, a part-of-speech and morphological analyzer for Japanese.
MeCab can tokenize Japanese text, provide readings for words containing Kanji characters as well as part-of-speech annotation of the tokens.
This package is used in Furiganify <https://apps.apple.com/us/app/furiganify/id1151320968?mt=12> and FuriganaPDF <https://apps.apple.com/us/app/furigana-pdf/id1516570722>.

## Requirements

The package is built with `swift-tools-version:6.0` in the Swift 6 language mode and requires macOS 10.15 or iOS 13. The public types are `Sendable`, `Tokenizer` included: it is a class that serializes access to the underlying MeCab tagger internally, so a single instance can be shared across threads. All functions are synchronous, callers are free to do their own threading.

## Installation
Using the Swift package manager. Simply add

```swift
.package(url: "https://github.com/shinjukunian/Mecab-Swift", branch: "master")
```

to dependencies in your `Package.swift` file or add Mecab-Swift via Xcode as a package dependency using `https://github.com/shinjukunian/Mecab-Swift` as the URL.

Mecab-Swift contains the following targets:

- *Dictionary*: This package provides protocols, i.e. `DictionaryProviding`, that can be used to use other dictionaries with Mecab-Swift
- *Mecab-Swift*: The package that provides the core functionality, i.e. tokenization and tagging
- *IPADicDefinition*: This package wraps the IPADic dictionary and provides a sample implementation of `DictionaryProviding`. It can be initialized from a `URL`, which is useful if the dictionary data is shipped separately.
- *IPADic*: This package contains the `IPADic` dictionary resources, i.e. the actual dictionary data.
- *StringTools*: Various tools for handling Japanese text and a wrapper around `CFStringTokenizer`, which provides some of the functionality of Mecab on Apple platforms
- *CharacterFilter*: Character lists of Japanese Kanji characters by school year, JLPT level and Kanken level. Useful for formatting Furigana annotations.

## Usage
Mecab-Swift requires dictionary files to work. This package includes the IPADic dictionary (<https://github.com/taku910/mecab/tree/master/mecab-ipadic>), which is quite old. A number of dictionaries compatible with Mecab are available on the internet. To use a dictionary, you have to tell Mecab-Swift how to interpret the information returned from the tokenizer. This is achieved by conforming to the `DictionaryProviding` protocol, see the `IPADicDefinition` target for reference. 

Mecab-Swift provides a playground that illustrates some use cases. 

```swift
import IPADic
import Mecab_Swift
```

 Using a brief text
 
```swift
let text = "蜂蜜は熊の大好物です。"
```

Instantiate the tokenizer with IPADic

```swift
import IPADicDefinition // Tells mecab how to interpret the output of the IPADic dictionary
import IPADic // contains the actual dictionary resource data.  

let ipadic=IPADic()
let ipadicTokenizer = try Tokenizer(dictionary: ipadic)
```
To get the tokens, we can use

```swift
let ipadicTokens=ipadicTokenizer.tokenize(text: text, transliteration: .hiragana)
//[Base: 蜂蜜, reading: はちみつ, POS: noun, Base: は, reading: ハ, POS: particle, Base: 熊, reading: くま, POS: noun, Base: の, reading: ノ, POS: particle, Base: 大, reading: だい, POS: prefix, Base: 好物, reading: こうぶつ, POS: noun, Base: です, reading: デス, POS: unknown, Base: 。, reading: 。, POS: symbol]
```

We can get all nouns in the sentence

```swift
let nouns=ipadicTokens.filter {$0.partOfSpeech == .noun}.map {$0.base}
print("The nouns in \"\(text)\" are \(ListFormatter().string(from: nouns) ?? "")")
//The nouns in "蜂蜜は熊の大好物です。" are 蜂蜜, 熊, and 好物
```

We can use the tokens to convert the the text to hiragana. Note that the `transliteration` is applied to tokens that contain Kanji characters, tokens without Kanji keep the reading as the dictionary reports it, which is Katakana in the case of IPADic:

```swift
let hiraganized = ipadicTokens.map{$0.containsKanji ? $0.reading : $0.base}.joined()
//はちみつはくまのだいこうぶつです。
```
or to Romaji

```swift
let romajiTokens=ipadicTokenizer.tokenize(text: text, transliteration: .romaji)
let romanized = romajiTokens.map{$0.reading}.joined(separator: " ")
//hachimitsu ハ kuma ノ dai kōbutsu デス 。
```

We can compare this to the output of the system tokenizer

```swift
let system=Tokenizer.systemTokenizer
let systemTokens=system.tokenize(text: text)
//[Base: 蜂蜜, reading: はちみつ, POS: unknown, Base: は, reading: は, POS: unknown, Base: 熊, reading: くま, POS: unknown, Base: の, reading: の, POS: unknown, Base: 大, reading: だい, POS: unknown, Base: 好物, reading: こうぶつ, POS: unknown, Base: です, reading: です, POS: unknown, Base: 。, reading: 。, POS: unknown]
//no part-of-speech annotation here
let hiragana=systemTokens.map {$0.reading}.joined()
//はちみつはくまのだいこうぶつです。
```

One key application is Kanji-to-Kana conversion, e.g. for Furigana annotations. This can be achieved by

```swift
let longerText=text + "でも鮭もよく食べます。"
let furigana=ipadicTokenizer.furiganaAnnotations(for: longerText, transliteration: .hiragana, options: [.kanjiOnly])
//蜂蜜=はちみつ, 熊=くま, 大=だい, 好物=こうぶつ, 鮭=さけ, 食=た
```
This returns an array of `FuriganaAnnotation`, which contains the reading and the range of the token in the original text. `FuriganaAnnotation`s can easily be converted to `CTRubyAnnotation`s for display with CoreText.

The `.kanjiOnly` option, which is the default, omits furigana for okurigana. Base and reading are aligned to determine which part of the reading belongs to which character, so okurigana are handled wherever they occur, including in the middle of a word:

```swift
let annotations=ipadicTokenizer.furiganaAnnotations(for: "行き先", options: [.kanjiOnly])
//行き先=ゆ　さき (IPADic reads 行き先 as ゆきさき)
//only the okurigana き is replaced by an ideographic space, the き of 先(さき) is part of the reading and is kept
```

The alignment is available on its own as `String.furiganaSegments(reading:)` in *StringTools*, which pairs the parts of a word with the parts of its reading. Tokens for which base and reading cannot be aligned keep their reading as is.


Mecab also provides deinflected (lemmatized) forms of Japanese verbs.

```swift
let lemmatized = ipadicTokenizer.tokenize(text: "でも鮭もよく食べます。")
    .filter {$0.partOfSpeech == .verb}
    .map {$0.dictionaryForm}
//["食べる"]
```

On Apple platforms, tokenization is also provided by the `NaturalLanguage` framework. We can compare the output
```swift
let text="でも鮭もよく食べます。"
let NLtokenizer=NLTokenizer(unit: .word)
NLtokenizer.string=text
let NLtokens=NLtokenizer.tokens(for: text.startIndex..<text.endIndex).map{text[$0]}
//["で", "も", "鮭", "も", "よく", "食べ", "ます"]
```
As of iOS14, part-of-speech tagging and lemmatization appear to be unavailable for Japanese.

# HTML annotation
Mecab-Swift provides convenience functions to add `<ruby>` tags to HTML text. `rubyTaggedString` processes the text in chunks and does not keep the annotations of the entire document in memory, which makes it suitable for large documents.

```swift
let text="でも鮭もよく食べます。"
let rubyAnnotated=ipadicTokenizer.rubyTaggedString(source: text, transliteration: .hiragana, options: [.kanjiOnly])
//でも<ruby>鮭<rt>さけ</rt></ruby>もよく<ruby>食べ<rt>た　</rt></ruby>ます。
```
でも<ruby>鮭<rt>さけ</rt></ruby>もよく<ruby>食べ<rt>た　</rt></ruby>ます。

Furigana generation can be customized by filters. 

```swift
let rubyAnnotated=ipadicTokenizer.rubyTaggedString(source: text, transliteration: .hiragana, options: [.kanjiOnly, .filter(disallowedCharacters: Set(["食"]), strict: true)])
//でも<ruby>鮭<rt>さけ</rt></ruby>もよく食べます。
```
でも<ruby>鮭<rt>さけ</rt></ruby>もよく食べます。

This is more conveniently expressed using the `CharacterFiltering` protocol. `Mecab-Swift` includes filters for school year as well as JLPT and Kanken Level.

```Swift
let long="熊のプーさんの大好物はハチミツです。熊のプーさんは英語でWinni-The-Poohと呼ぶんです。"
let ruby=ipadicTokenizer.rubyTaggedString(source: long,
                                          transliteration: .hiragana,
                                          options: [
                                                    .kanjiOnly,
                                                    .filter(disallowedCharacters: 
                                                        CharacterFilter.schoolYear(year: .elementary3)
                                                        .disallowedCharacters, strict: true)
                                                    ])
//<ruby>熊<rt>くま</rt></ruby>のプーさんの大好物はハチミツです。<ruby>熊<rt>くま</rt></ruby>のプーさんは英語でWinni-The-Poohと<ruby>呼ぶ<rt>よ　</rt></ruby>んです。
```
<ruby>熊<rt>くま</rt></ruby>のプーさんの大好物はハチミツです。<ruby>熊<rt>くま</rt></ruby>のプーさんは英語でWinni-The-Poohと<ruby>呼ぶ<rt>よ　</rt></ruby>んです。

With `transliterateAll`, every token that contains Japanese script is annotated, not just the ones containing Kanji characters. This is mostly useful for Romaji, e.g. for learners who cannot read Kana yet.

```swift
let ruby=ipadicTokenizer.rubyTaggedString(source: "熊のプーさん", transliteration: .romaji, options: [], transliterateAll: true)
//<ruby>熊<rt>kuma</rt></ruby><ruby>の<rt>no</rt></ruby><ruby>プー<rt>pū</rt></ruby><ruby>さん<rt>san</rt></ruby>
```

The same functions are available on the `systemTokenizer`, which uses `CFStringTokenizer` instead of MeCab and requires no dictionary, as well as on `String` directly (`String.rubyTaggedString(useRomaji:kanjiOnly:...)` in *StringTools*).

## Licence
MIT for Mecab-Swift

[Mecab](https://taku910.github.io/mecab/) and the dictionaries come with their own licence.
