import mecab
import Foundation
import StringTools
import Dictionary

/**
A tokenizer /  morphological analyzer for Japanese
 
 The `Tokenizer` is safe to share across threads: the `mecab` tagger it wraps is not thread safe, so access to it is serialized internally. All functions are synchronous, callers are free to do their own threading.
*/
public final class Tokenizer: @unchecked Sendable{

    /**
    How to display found tokens in Japanese text
    */
    public enum Transliteration: Sendable{
        case hiragana
        case katakana
        case romaji
    }

    public enum TokenizerError:Error, Sendable{
        case initializationFailure(String)
        case parsingError(String)

        public var localizedDescription: String{
            switch self {
            case .initializationFailure(let error):
                return error
            case .parsingError(let error):
                return "Parising Error \(error)"
            }
        }
    }

    /// The tokenizer implementation that backs the `Tokenizer`.
    enum Backend:Sendable{
        case mecab(MecabTagger)
        case system
    }

    let backend:Backend

    /**
     The version of the underlying mecab engine.
     */
    public static var version:String{
        return String(cString: mecab_version(), encoding: .utf8) ?? ""
    }

    #if canImport(CoreFoundation)
    fileprivate init(){
        self.backend = .system
    }


     /*
     The CoreFoundation CFStringTokenizer
     **/
    public static let systemTokenizer:Tokenizer = {
        return Tokenizer()
    }()
    #endif

    /**
     Initializes the Tokenizer.
     - parameters:
        - dictionary: A Dictionary struct that encapsulates the dictionary and its positional information.
     - throws:
        - `TokenizerError`: Typically an error that indicates that the dictionary didn't exist or couldn't be opened.
     */
    public init(dictionary:any DictionaryProviding) throws{
        self.backend = .mecab(try MecabTagger(dictionary: dictionary))
    }

    /**
     The fundamental function to tokenize Japanese text with an initialized `Tokenizer`
     - parameters:
        - text: A `string` that contains the text to tokenize.
        - transliteration : A `Transliteration` method. The text content of found tokens will be displayed using this.
     - returns: An array of `Annotation`, a struct that contains the found tokens (the token value, the reading, POS, etc.).
     */
    @available(macOS 10.11, *)
    public func tokenize(text:String, transliteration:Transliteration = .hiragana)->[Annotation]{
        switch self.backend {
        case .system:
            return self.systemTokenizerTokenize(text: text, transliteration: transliteration)
        case .mecab(let mecab):
            return mecab.withTagger({tagger, dictionary in
                Self.mecabTokenize(text: text, tagger: tagger, dictionary: dictionary, transliteration: transliteration)
            })
        }
    }

    fileprivate static func mecabTokenize(text:String, tagger:OpaquePointer, dictionary:any DictionaryProviding, transliteration:Transliteration = .hiragana)->[Annotation]{

        let annotations=text.withCString({s->[Annotation] in
            var annotations=[Annotation]()
            var node=mecab_sparse_tonode(tagger, s)
            var pos=text.utf8.startIndex
            while true{
                guard let n = node else {break}

                defer{
                    node = UnsafePointer(n.pointee.next)
                }

                //the beginning and end of sentence nodes are virtual and carry no text
                guard n.pointee.isVirtualNode == false,
                      let token=Token(node: n.pointee, tokenDescription: dictionary) else{
                    continue
                }

                // the utf8 offsets reported by mecab refer to the same bytes we passed in, but we guard against
                // running off the end of the string in case the text contained something mecab choked on.
                guard let endPos=text.utf8.index(pos, offsetBy: token.lengthIncludingWhiteSpace, limitedBy: text.utf8.endIndex),
                      let tokenStart=text.utf8.index(pos, offsetBy: token.whiteSpaceLength, limitedBy: endPos) else{
                    break
                }
                // this will not work for some strings if the UTF 8 indices refer to composed character sequences.
                //`mecab` reports the length of a token including the white space preceding it, so the token itself starts after that white space.
                let range=pos..<endPos
                let rangeWhitespace = tokenStart..<endPos

                let annotation=Annotation(token: token, range: range, rangeExcludingWhitespace: rangeWhitespace, transliteration: transliteration)

                pos=endPos

                annotations.append(annotation)
            }
            return annotations
        })

       return annotations
    }


    /**
    A convenience function to tokenize text into `FuriganaAnnotations`.

    `FuriganaAnnotations` are meant for displaying furigana reading aids for Japanese Kanji characters, and consequently tokens that don't contain Kanji are skipped.
    - parameters:
       - text: A `string` that contains the text to tokenize.
       - transliteration : A `Transliteration` method. The text content of found tokens will be displayed using this.
       - options : Options to pass to the tokenizer
    - returns: An array of `FuriganaAnnotations`, which contain the reading o fthe token and the range of the token in the original text.
    */
    @available(macOS 10.11, *)
    public func furiganaAnnotations(for text:String, transliteration:Transliteration = .hiragana, options:[Annotation.AnnotationOption] = [.kanjiOnly])->[FuriganaAnnotation]{

        return self.tokenize(text: text, transliteration: transliteration)
            .filter({$0.containsKanji})
            .compactMap({$0.furiganaAnnotation(options: options, for: text)})
    }

    /**
       A convenience function to add `<ruby>` tags to  text.

     `<ruby>` tags are added to all tokens that contain Kanji characters, regardless of whether they are on specific parts of an HTML document or not. This can potentially disrupt scripts or navigation.
       - parameters:
          - htmlText: A `string` that contains the text to tokenize.
          - transliteration: A `Transliteration` method. The text content of found tokens will be displayed using this.
          - options: Options to pass to the tokenizer
       - returns: A text with `<ruby>` annotations.
       */
    @available(*, deprecated, message: "Use the streaming function rubyTaggedString instead")
    @available(macOS 10.11, *)
    public func addRubyTags(to htmlText:String, transliteration:Transliteration = .hiragana, options:[Annotation.AnnotationOption] = [.kanjiOnly])->String{
        let furigana=self.furiganaAnnotations(for: htmlText, transliteration: transliteration, options: options)
        var outString=""
        var endIDX = htmlText.startIndex

        for annotation in furigana{
            outString += htmlText[endIDX..<annotation.range.lowerBound]

            let original = htmlText[annotation.range]
            let htmlRuby="<ruby>\(original)<rt>\(annotation.reading)</rt></ruby>"
            outString += htmlRuby
            endIDX = annotation.range.upperBound
        }

        outString += htmlText[endIDX..<htmlText.endIndex]

        return outString

    }

    /**
       A convenience function to add `<ruby>` tags to  text.

        `<ruby>` tags are added to all tokens that contain Kanji characters, regardless of whether they are on specific parts of an HTML document or not. This can potentially disrupt scripts or navigation.
       - parameters:
          - htmlText: A `string` that contains the text to tokenize.
          - transliteration: A `Transliteration` method. The text content of found tokens will be displayed using this.
          - options: Options to pass to the tokenizer
       - returns: A text with `<ruby>` annotations.
       */
    @available(macOS 10.11, *)
    public func rubyTaggedString(source htmlString:String, transliteration:Transliteration = .hiragana, options:[Annotation.AnnotationOption] = [.kanjiOnly], transliterateAll:Bool = false)->String{

        var characters=Set<String>()
        var disallowedStrict = false
        for case let Annotation.AnnotationOption.filter(disallowed, strict) in options{
            characters=characters.union(disallowed)
            disallowedStrict=strict
        }

        switch self.backend {
        case .system:
            return htmlString.rubyTaggedString(useRomaji: transliteration == .romaji, kanjiOnly: options.contains(.kanjiOnly), disallowedCharacters: characters, strict: disallowedStrict, transliterateAll: transliterateAll)
        case .mecab(let mecab):
            return mecab.withTagger({tagger, dictionary in
                Self.mecab_rubyTaggedString(source: htmlString, tagger: tagger, dictionary: dictionary, transliteration: transliteration, kanjiOnly: options.contains(.kanjiOnly), disallowedCharacters: characters, strict: disallowedStrict, transliterateAll: transliterateAll)
            })
        }

    }

}

extension Tokenizer.TokenizerError:LocalizedError{
    public var errorDescription: String?{
        return self.localizedDescription
    }
}
