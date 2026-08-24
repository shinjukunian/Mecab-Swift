//
//  CharacterFilter.swift
//  
//
//  Created by Morten Bertz on 2020/07/06.
//

import Foundation

    /**
     The Character Filtering protocol.
     This protocol permist the customization of Furigana generation.
     */
public protocol CharacterFiltering{
    ///The `Set<String>` of characters that should be excluded.
    var disallowedCharacters:Set<String> {get}
    ///A descriptive name.
    var localizedName:String {get}
}

/**
    A concrete implementation of `CharacterFiltering`.
    CharacterFilter implements filtering by school year, JLPT, and Kanken level.
 */
public enum CharacterFilter:Codable,Equatable,CharacterFiltering, CaseIterable {
    
    public typealias AllCases = [CharacterFilter]
    
    /// no filtering
    case none
    /// filter by school year
    case schoolYear(year: SchoolYearFilter)
    /// filter by JLPT Level
    case JLPT(level: JLPTFilter)
    /// filter by Kanken level
    case kanken(level: KankenFilter)

    public static var allCases: [CharacterFilter]{
        return [.none, .schoolYear(year: .elementary1), .JLPT(level: .JLTP5), .kanken(level: .kanken10)]
    }
    
    public var filters:[CharacterFiltering]{
        switch self {
        case .none:
            return [CharacterFiltering]()
        case .JLPT:
            return JLPTFilter.allCases
        case .schoolYear:
            return SchoolYearFilter.allCases
        case .kanken:
            return KankenFilter.allCases
        }
    }
    
    
    enum CodingKeys: CodingKey {
        case none, schoolYear, JLPT, kanken
    }
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = container.allKeys.first ?? .none
        switch key {
        case .none:
            self = .none
        case .schoolYear:
            let year = try container.decode(SchoolYearFilter.self, forKey: .schoolYear)
            self = .schoolYear(year: year)
        case .JLPT:
            let level = try container.decode(JLPTFilter.self, forKey: .JLPT)
            self = .JLPT(level: level)
        case .kanken:
            let level = try container.decode(KankenFilter.self, forKey: .kanken)
            self = .kanken(level: level)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .none:
            try container.encode(true, forKey: .none)
        case .schoolYear(let year):
            try container.encode(year, forKey: .schoolYear)
        case .JLPT(let level):
            try container.encode(level, forKey: .JLPT)
        case .kanken(let level):
            try container.encode(level, forKey: .kanken)
        }
    }
    
    public init(filter:CharacterFiltering){
        switch filter {
        case let filter as SchoolYearFilter:
            self = .schoolYear(year: filter)
        case let filter as JLPTFilter:
            self = .JLPT(level: filter)
        default:
            self = .none
        }
    }
    
    public var disallowedCharacters: Set<String>{
        switch self {
        case .none:
            return Set<String>()
        case .JLPT(let level):
            return level.disallowedCharacters
        case .schoolYear(let year):
            return year.disallowedCharacters
        case .kanken(let level):
            return level.disallowedCharacters
        }
    }
    
    public var localizedTypeName: String{
        switch self {
        case .none:
            return Bundle.module.localizedString(forKey: "none", value: "None", table: "Localizable")
        case .JLPT(_):
            return Bundle.module.localizedString(forKey: "JLPT", value: "JLPT", table: "Localizable")
        case .schoolYear(_):
            return Bundle.module.localizedString(forKey: "schoolyear", value: "School Year", table: "Localizable")
        case .kanken(_):
            return Bundle.module.localizedString(forKey: "kanken", value: "Kanken Level", table: "Localizable")
        }
    }
    
    public var localizedName: String{
        switch self {
        case .none:
            return self.localizedTypeName
        case .JLPT(let level):
            return level.localizedName
        case .schoolYear(let year):
            return year.localizedName
        case .kanken(let level):
            return level.localizedName
        }
    }
    
    public var idx:Int{
        switch self {
        case .none:
            return 0
        case .schoolYear(_):
            return 1
        case .JLPT(_):
            return 2
        case .kanken(_):
            return 3
        }
    }
}


extension CharacterFilter:Identifiable, Hashable{
    public var id: String{
        switch self {
        case .none:
            return "none"
        case .JLPT(let level):
            return "JLPT_\(level.rawValue)"
        case .schoolYear(let year):
            return "JLPT_\(year.rawValue)"
        case .kanken(let level):
            return "Kanken_\(level.rawValue)"
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


extension CharacterFilter: RawRepresentable{
    public typealias RawValue = String
    
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode(CharacterFilter.self, from: data)
        else {
            return nil
        }
        self = result
    }
    
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return ""
        }
        return result
    }
    
}
