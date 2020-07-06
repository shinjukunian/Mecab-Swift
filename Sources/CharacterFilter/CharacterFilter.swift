//
//  CharacterFilter.swift
//  
//
//  Created by Morten Bertz on 2020/07/06.
//

import Foundation

public protocol CharacterFiltering {
    var disallowedCharacters:Set<String> {get}
    var localizedName:String {get}
}

public enum SchoolYearFilter:String, CharacterFiltering, Equatable, Codable, CaseIterable{
   
    case elementary1
    case elementary2
    case elementary3
    case elementary4
    case elementary5
    case elementary6
    case middle1
    case middle2
    case middle3
    case highSchool
    
    
    
    public var disallowedCharacters: Set<String>{
        switch self {
        case .elementary1:
            return Set(SchoolYearFilter.elementary1Characters.map({String($0)}))
        case .elementary2:
            return SchoolYearFilter.elementary1.disallowedCharacters.union(SchoolYearFilter.elementary2Characters.map({String($0)}))
        case .elementary3:
            return SchoolYearFilter.elementary2.disallowedCharacters.union(SchoolYearFilter.elementary3Characters.map({String($0)}))
        case .elementary4:
            return SchoolYearFilter.elementary3.disallowedCharacters.union(SchoolYearFilter.elementary4Characters.map({String($0)}))
        case .elementary5:
            return SchoolYearFilter.elementary4.disallowedCharacters.union(SchoolYearFilter.elementary5Characters.map({String($0)}))
        case .elementary6:
            return SchoolYearFilter.elementary5.disallowedCharacters.union(SchoolYearFilter.elementary6Characters.map({String($0)}))
        case .middle1:
            return SchoolYearFilter.elementary6.disallowedCharacters.union(SchoolYearFilter.middle1Characters.map({String($0)}))
        case .middle2:
            return SchoolYearFilter.middle1.disallowedCharacters.union(SchoolYearFilter.middle2Characters.map({String($0)}))
        case .middle3:
            return SchoolYearFilter.middle2.disallowedCharacters.union(SchoolYearFilter.middle3Characters.map({String($0)}))
        case .highSchool:
            return SchoolYearFilter.middle3.disallowedCharacters.union(SchoolYearFilter.highSchoolCharacters.map({String($0)}))
        
        }
    }
       
    public var localizedName: String{
        switch self {
        default:
            return self.rawValue
        }
    }
    
}


public enum JLPTFilter:String, CharacterFiltering, Equatable, Codable, CaseIterable{
    
    case JLTP5
    case JLPT4
    case JLPT3
    case JLPT2
    case JLPT1
    
    public var disallowedCharacters: Set<String>{
        switch self {
        case .JLTP5:
            return Set(JLPTFilter.JLPT5Characters.map({String($0)}))
        case .JLPT4:
            return JLPTFilter.JLTP5.disallowedCharacters.union(JLPTFilter.JLPT4Characters.map({String($0)}))
        case .JLPT3:
            return JLPTFilter.JLPT4.disallowedCharacters.union(JLPTFilter.JLPT3Characters.map({String($0)}))
        case .JLPT2:
            return JLPTFilter.JLPT3.disallowedCharacters.union(JLPTFilter.JLPT2Characters.map({String($0)}))
        case .JLPT1:
            return JLPTFilter.JLPT2.disallowedCharacters.union(JLPTFilter.JLPT1Characters.map({String($0)}))
        
        }
    }
    
    
    public var localizedName: String{
        switch self {
        default:
            return self.rawValue
        }
    }
}
