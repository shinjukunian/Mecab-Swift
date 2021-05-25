//
//  CharacterFilter.swift
//  
//
//  Created by Morten Bertz on 2020/07/06.
//

import Foundation

public protocol CharacterFiltering{
    var disallowedCharacters:Set<String> {get}
    var localizedName:String {get}
}

public enum CharacterFilter:Codable,Equatable,CharacterFiltering, CaseIterable {
    
    public typealias AllCases = [CharacterFilter]
    
    case none
    case schoolYear(year:SchoolYearFilter)
    case JLPT(level:JLPTFilter)

    public static var allCases: [CharacterFilter]{
        return [.none, .schoolYear(year: .elementary1), .JLPT(level: .JLTP5)]
    }
    
    public var filters:[CharacterFiltering]{
        switch self {
        case .none:
            return [CharacterFiltering]()
        case .JLPT:
            return JLPTFilter.allCases
        case .schoolYear:
            return SchoolYearFilter.allCases
        }
    }
    
    
    enum CodingKeys: CodingKey {
        case none, schoolYear, JLPT
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
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
