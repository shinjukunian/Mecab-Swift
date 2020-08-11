import mecab
import Foundation
import StringTools

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
        
        public var localizedDescription: String{
            switch self {
            case .initializationFailure(let error):
                return error
            }
        }
    }
    
    
    private let dictionary:Dictionary
    
    fileprivate let _mecab:OpaquePointer
    
    
    /**
     The version of the underlying mecab engine.
     */
    public class var version:String{
        return String(cString: mecab_version(), encoding: .utf8) ?? ""
    }
    
    /**
     Initializes the Tokenizer.
     - parameters:
        - dictionary:  A Dictionary struct that encapsulates the dictionary and its positional information.
     - throws:
        * `TokenizerError`: Typically an error that indicates that the dictionary didn't exist or couldn't be opened.
     */
    public init(dictionary:Dictionary) throws{
        self.dictionary=dictionary
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
    public func tokenize(text:String, transliteration:Transliteration = .hiragana)->[Annotation]{
        
         let tokens=text.withCString({s->[Token] in
            var tokens=[Token]()
            var node=mecab_sparse_tonode(self._mecab, s)
            while true{
                guard let n = node else {break}
            
                    if let token=Token(node: n.pointee, tokenDescription: self.dictionary.type){
                        tokens.append(token)
                    }
                
                    node = UnsafePointer(n.pointee.next)
            }
            return tokens
        })
        
       
        var annotations=[Annotation]()
        var searchRange=text.startIndex..<text.endIndex
        for token in tokens{
            let searchString=token.original
            if searchString.containsKanjiCharacters == false{ // this might be a bit too strict
                continue
            }
            if let foundRange=text.range(of: searchString, options: [], range: searchRange, locale: nil){
                let annotation=Annotation(token: token, range: foundRange, transliteration: transliteration)
                annotations.append(annotation)
                
                if foundRange.upperBound < text.endIndex{
                    searchRange=foundRange.upperBound..<text.endIndex
                }
            }
        }
    
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
    public func addRubyTags(to htmlText:String, transliteration:Transliteration = .hiragana, options:[Annotation.AnnotationOption] = [.kanjiOnly])->String{
        let furigana=self.furiganaAnnotations(for: htmlText, transliteration: transliteration, options: options)
        var searchRange:Range<String.Index> = htmlText.startIndex ..< htmlText.endIndex
        var outString=htmlText
        for annotation in furigana{
            
            if let tokenRange=outString.range(of: htmlText[annotation.range], options: [], range: searchRange, locale: nil){
                let htmlRuby="<ruby>\(htmlText[annotation.range])<rt>\(annotation.reading)</rt></ruby>"
                outString=outString.replacingCharacters(in: tokenRange, with: htmlRuby)
                searchRange = outString.index(tokenRange.lowerBound, offsetBy: htmlRuby.count) ..< outString.endIndex
                
            }
        }
        return outString
    
    }
    
    deinit {
        mecab_destroy(_mecab)
    }
    
}







