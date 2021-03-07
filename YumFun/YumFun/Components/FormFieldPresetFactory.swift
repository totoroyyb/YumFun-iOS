//
//  FormFieldPresetFactory.swift
//  SwiftEntryKitDemo
//
//  Created by Daniel Huri on 5/18/18.
//  Copyright (c) 2018 huri000@gmail.com. All rights reserved.
//

import Foundation
import SwiftEntryKit

struct TextFieldOptionSet: OptionSet {
    let rawValue: Int
    static let fullName = TextFieldOptionSet(rawValue: 1 << 0)
    static let mobile = TextFieldOptionSet(rawValue: 1 << 1)
    static let email = TextFieldOptionSet(rawValue: 1 << 2)
    static let password = TextFieldOptionSet(rawValue: 1 << 3)
}

enum FormStyle {
    case light
    case metallic
    case standard
        
    var buttonTitle: EKProperty.LabelStyle {
        return .init(
            font: MainFont.bold.with(size: 18),
            color: buttonTitleColor
        )
    }
    
    var textColor: EKColor {
        switch self {
        case .metallic:
            return .white
        case .light:
            return .standardContent
        case .standard:
            return .text
        }
    }
    
    var buttonTitleColor: EKColor {
        switch self {
        case .metallic:
            return .black
        case .light:
            return .white
        case .standard:
            return .black
        }
    }
    
    var buttonBackground: EKColor {
        switch self {
        case .metallic:
            return .white
        case .light:
            return .redish
        case .standard:
            return .white
        }
    }
    
    var placeholder: EKProperty.LabelStyle {
        let font = MainFont.medium.with(size: 18)
        switch self {
        case .metallic:
            return .init(font: font, color: UIColor(white: 0.8, alpha: 1).ekColor)
        case .light:
            return .init(font: font, color: UIColor(white: 0.5, alpha: 1).ekColor)
        case .standard:
            return .init(font: font, color: UIColor.placeholderText.ekColor)
        }
    }
    
    var separator: EKColor {
        switch self {
        case .standard:
            return UIColor.placeholderText.ekColor
        default:
            return UIColor(white: 0.8784, alpha: 0.6).ekColor
        }
    }
}

final class FormFieldPresetFactory {
    class func email(placeholderStyle: EKProperty.LabelStyle,
                     textStyle: EKProperty.LabelStyle,
                     separatorColor: EKColor,
                     style: FormStyle) -> EKProperty.TextFieldContent {
        let emailPlaceholder = EKProperty.LabelContent(
            text: "Email Address",
            style: placeholderStyle
        )
        return .init(keyboardType: .emailAddress,
                     placeholder: emailPlaceholder,
                     tintColor: .text,
                     displayMode: displayMode,
                     textStyle: textStyle,
                     leadingImage: UIImage(named: "ic_mail_light")!.withRenderingMode(.alwaysTemplate),
                     bottomBorderColor: separatorColor,
                     accessibilityIdentifier: "emailTextField")
    }
    
    class func password(placeholderStyle: EKProperty.LabelStyle,
                        textStyle: EKProperty.LabelStyle,
                        separatorColor: EKColor,
                        style: FormStyle) -> EKProperty.TextFieldContent {
        let passwordPlaceholder = EKProperty.LabelContent(text: "Password",
                                                          style: placeholderStyle)
        return .init(keyboardType: .alphabet,
                     placeholder: passwordPlaceholder,
                     tintColor: .text,
                     displayMode: displayMode,
                     textStyle: textStyle,
                     isSecure: true,
                     leadingImage: UIImage(named: "ic_lock_light")!.withRenderingMode(.alwaysTemplate),
                     bottomBorderColor: separatorColor,
                     accessibilityIdentifier: "passwordTextField")
    }
    
    class func fields(by set: TextFieldOptionSet,
                      style: FormStyle) -> [EKProperty.TextFieldContent] {
        var array: [EKProperty.TextFieldContent] = []
        let placeholderStyle = style.placeholder
        let textStyle = EKProperty.LabelStyle(
            font: MainFont.medium.with(size: 18),
            color: .standardContent,
            displayMode: displayMode
        )
        let separatorColor = style.separator

        if set.contains(.email) {
            array.append(email(placeholderStyle: placeholderStyle,
                               textStyle: textStyle,
                               separatorColor: separatorColor,
                               style: style))
        }
        if set.contains(.password) {
            array.append(password(placeholderStyle: placeholderStyle,
                                  textStyle: textStyle,
                                  separatorColor: separatorColor,
                                  style: style))
        }
        return array
    }
}
