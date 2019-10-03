import mecab
import Foundation


public class Tokenizer{
    
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
    
    public class var version:String{
        return String(cString: mecab_version(), encoding: .utf8) ?? ""
    }
    
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
    
    public func tokenize(text:String, transliteration:Transliteration = .hiragana)->[Annotation]{
        
        var tokens=[Token]()
        var annotations=[Annotation]()
        
        guard let nodes=text.withCString({s->UnsafePointer<mecab_node_t>? in
            let length=text.lengthOfBytes(using: .utf8)
            let mecabNodes=mecab_sparse_tonode2(self._mecab, s, length)
            return mecabNodes
        })
            else{
                return annotations
        }
        
        var node=nodes.pointee.next //this makes us skip the beginning of sentence node
        
        while node != nil {
            
            if let token=Token(node: node!.pointee, dictionary:dictionary.type){
                tokens.append(token)
            }
            node=node?.pointee.next
            
        }
        
        var searchRange=text.startIndex..<text.endIndex
        for token in tokens{
            if let foundRange=text.range(of: token.original, options: [], range: searchRange, locale: nil){
                let annotation=Annotation(token: token, range: foundRange, transliteration: transliteration)
                annotations.append(annotation)
                searchRange=foundRange.upperBound..<text.endIndex
            }
        }
        
        return annotations
    }
    
    public func furiganaAnnotations(for text:String, transliteration:Transliteration = .hiragana, options:[Annotation.AnnotationOptions] = [.kanjiOnly])->[FuriganaAnnotation]{
        
        return self.tokenize(text: text, transliteration: transliteration)
            .filter({$0.containsKanji})
            .map({$0.furiganaAnnotation(options: options, for: text)})
    }
    
    
    public func addRubyTags(to htmlText:String, transliteration:Transliteration = .hiragana, options:[Annotation.AnnotationOptions] = [.kanjiOnly])->String{
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







