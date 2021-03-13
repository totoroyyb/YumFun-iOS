//
//  HeroIdHelper.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/3/11.
//

import Foundation

enum HeroIdType: String {
    case profileImage
    case recipeTitle
    
    func getIdStr(at index: Int? = nil) -> String {
        if let index = index {
            return self.rawValue + String(index)
        }
        return self.rawValue
    }
}
