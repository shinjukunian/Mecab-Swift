//
//  IPADic+Bundle.swift
//  
//
//  Created by Morten Bertz on 2021/11/30.
//

import Foundation
import IPADicDefinition

/**
A wrapper around IPADic containing the actual dictionary file
*/
public extension IPADic{
    /**
     Initializes an IPADic instance with the bundled dictionary data.
    */
    init(){
        let url = Bundle.module.url(forResource: "ipadic dictionary", withExtension: nil)!
        self.init(url: url)
    }
}
