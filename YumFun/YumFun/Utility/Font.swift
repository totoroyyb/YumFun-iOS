//
//  Font.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/3/5.
//

import Foundation
import UIKit

typealias MainFont = Font.HelveticaNeue

enum Font {
    enum HelveticaNeue: String {
        case ultraLightItalic = "UltraLightItalic"
        case medium = "Medium"
        case mediumItalic = "MediumItalic"
        case ultraLight = "UltraLight"
        case italic = "Italic"
        case light = "Light"
        case thinItalic = "ThinItalic"
        case lightItalic = "LightItalic"
        case bold = "Bold"
        case thin = "Thin"
        case condensedBlack = "CondensedBlack"
        case condensedBold = "CondensedBold"
        case boldItalic = "BoldItalic"
        
        func with(size: CGFloat) -> UIFont {
            return UIFont(name: "HelveticaNeue-\(rawValue)", size: size)!
        }
    }
    
    enum icon: String {
        case fontAwesome5 = "FontAwesome5Free-Regular"
        case fontAwesome5Brand = "FontAwesome5Brands-Regular"
        case fontAwesome5Solid = "FontAwesome5Free-Solid"
        case iconic = "open-iconic"
        case ionicon = "Ionicons"
        case octicon = "octicons"
        case themify = "themify"
        case mapIcon = "map-icons"
        case materialIcon = "MaterialIcons-Regular"
        case segoeMDL2 = "Segoe mdl2 assets"
        case foundation = "fontcustom"
        case elegantIcon = "ElegantIcons"
        case captain = "captainicon"
    }
}
