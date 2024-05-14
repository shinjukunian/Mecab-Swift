import mecab
import Foundation
import StringTools
import Dictionary

/**
A tokenizer /  morphological analyzer for Japanese
*/
public class Tokenizer{
    
    /**
    How to display found tokens in Japanese text
    */
   public enum Transliteration{
        case hiragana
        case katakana
        case romaji
    }

    public enum TokenizerError:Error{
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
    
    
    internal let dictionary:DictionaryProviding
    
    internal let _mecab:OpaquePointer!
    
    /**
     The version of the underlying mecab engine.
     */
    public class var version:String{
        return String(cString: mecab_version(), encoding: .utf8) ?? ""
    }
    
    
    
    fileprivate let isSystemTokenizer:Bool

    #if canImport(CoreFoundation)
    fileprivate init(){
        self.isSystemTokenizer=true
        self.dictionary=SystemDictionary()
        _mecab=nil
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
    public init(dictionary:DictionaryProviding) throws{
        self.dictionary=dictionary
        self.isSystemTokenizer=false
        let tokenizer=try dictionary.url.withUnsafeFileSystemRepresentation({path->OpaquePointer in
            guard let path=path,
                let dictPath=String(cString: path).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
                //MeCab splits the commands by spaces, so we need to escape the path passed inti the function.
                //We replace the percent encoded space when opening the dictionary. This is mostly relevant when the dictionary os located inside a folder of which we cannot control the name, i.e. Application Support
                else{ throw TokenizerError.initializationFailure("URL Conversion Failed \(dictionary)")}
            
            guard let tokenizer=mecab_new2("-d \(dictPath)") else {
                let error=String(cString: mecab_strerror(nil), encoding: .utf8) ?? ""
                throw TokenizerError.initializationFailure("Opening Dictionary Failed \(dictionary) \(error)")
            }
            return tokenizer
        })
        
        _mecab=tokenizer
       
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
        if self.isSystemTokenizer{
            return self.systemTokenizerTokenize(text: text, transliteration: transliteration)
        }
        else{
            return mecabTokenize(text: text, transliteration: transliteration)
        }
    }
    
    fileprivate func mecabTokenize(text:String, transliteration:Transliteration = .hiragana)->[Annotation]{
        
        let annotations=text.withCString({s->[Annotation] in
            var annotations=[Annotation]()
            var node=mecab_sparse_tonode(self._mecab, s)
            var pos=text.utf8.startIndex
            while true{
                guard let n = node else {break}
                
                defer{
                    node = UnsafePointer(n.pointee.next)
                }
                
                if let token=Token(node: n.pointee, tokenDescription: self.dictionary){
                                        
                    let endPos=text.utf8.index(pos, offsetBy: token.lengthIncludingWhiteSpace)
                    // this will not work for some strings if the UTF 8 indices refer to composed character sequences.
//                    guard let charEnd=endPos.samePosition(in: text),
//                          let charStart=pos.samePosition(in: text) else{
//                        continue
//                    }
                    
                    let range=pos..<endPos
                    
                    let endPosWhiteSpace=text.utf8.index(pos, offsetBy: token.length)
                            
                    let rangeWhitespace = pos..<endPosWhiteSpace
                    
                    let annotation=Annotation(token: token, range: range, rangeExcludingWhitespace: rangeWhitespace, transliteration: transliteration)
                    
                    pos=endPos
                    
                    annotations.append(annotation)
                }
                
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
        var searchRange:Range<String.Index> = htmlText.startIndex ..< htmlText.endIndex
        var outString=htmlText
        
        for annotation in furigana{
            
            if let tokenRange=outString.range(of: htmlText[annotation.range], options: [], range: searchRange, locale: nil){
                let htmlRuby="<ruby>\(htmlText[annotation.range])<rt>\(annotation.reading)</rt></ruby>"
                outString.replaceSubrange(tokenRange, with: htmlRuby)
                searchRange = outString.index(tokenRange.lowerBound, offsetBy: htmlRuby.count) ..< outString.endIndex
                
            }
        }
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
        
        if self.isSystemTokenizer{
           
            return htmlString.rubyTaggedString(useRomaji: transliteration == .romaji, kanjiOnly: options.contains(.kanjiOnly), disallowedCharacters: characters, strict: disallowedStrict, transliterateAll: transliterateAll)
        }
        else{
            return self.mecab_rubyTaggedString(source: htmlString, transliteration: transliteration, kanjiOnly: options.contains(.kanjiOnly), disallowedCharacters: characters, strict: disallowedStrict, transliterateAll: transliterateAll)
        }
        
    }
    
    deinit {
        mecab_destroy(_mecab)
    }
    
}







