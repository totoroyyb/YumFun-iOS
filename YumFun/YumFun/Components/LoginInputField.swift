//
//  LoginInputField.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/3/7.
//

import AnimatedField

var emailFieldFormat: AnimatedFieldFormat {
    var format = AnimatedFieldFormat()

    /// Title always visible
    format.titleAlwaysVisible = false

    /// Font for title label
    format.titleFont = MainFont.medium.with(size: 15)
        
    /// Font for text field
    format.textFont = MainFont.bold.with(size: 20)
        
    /// Line color
    format.lineColor = UIColor.lightGray
        
    /// Title label text color
    format.titleColor = UIColor.lightGray
        
    /// TextField text color
    format.textColor = UIColor.white
        
    /// Enable alert
    format.alertEnabled = true

    /// Font for alert label
    format.alertFont = MainFont.medium.with(size: 15)

    /// Alert status color
    format.alertColor = UIColor.red
        
    /// Colored alert field text
    format.alertFieldActive = true
        
    /// Colored alert line
    format.alertLineActive = true
        
    /// Colored alert title
    format.alertTitleActive = true

    /// Alert position
    format.alertPosition = .top
        
    /// Highlight color when becomes active
    format.highlightColor = UIColor.white

    return format
}

var passwordFieldFormat: AnimatedFieldFormat {
    var format = AnimatedFieldFormat()

    /// Title always visible
    format.titleAlwaysVisible = false

    /// Font for title label
    format.titleFont = MainFont.medium.with(size: 15)
        
    /// Font for text field
    format.textFont = MainFont.bold.with(size: 20)
        
    /// Line color
    format.lineColor = UIColor.lightGray
        
    /// Title label text color
    format.titleColor = UIColor.lightGray
        
    /// TextField text color
    format.textColor = UIColor.white
        
    /// Enable alert
    format.alertEnabled = true

    /// Font for alert label
    format.alertFont = MainFont.medium.with(size: 15)

    /// Alert status color
    format.alertColor = UIColor.red
        
    /// Colored alert field text
    format.alertFieldActive = true
        
    /// Colored alert line
    format.alertLineActive = true
        
    /// Colored alert title
    format.alertTitleActive = true

    /// Alert position
    format.alertPosition = .top
        
    /// Secure icon image (On status)
//    format.visibleOnImage = IconsLibrary.imageOfEye(color: .red)
        
    /// Secure icon image (Off status)
//    format.visibleOffImage = IconsLibrary.imageOfEyeoff(color: .red)
        
    /// Enable counter label
    format.counterEnabled = false
        
    /// Set count down if counter is enabled
    format.countDown = false

    /// Enable counter animation on change
    format.counterAnimation = false
        
    /// Highlight color when becomes active
    format.highlightColor = UIColor.white
    
    return format
}
