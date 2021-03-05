//
//  TopPopUp.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/3/5.
//

import Foundation
import SwiftEntryKit

func displayWarningTopPopUp(title: String,
                            description: String) {
    showNotificationMessage(attributes: topPopUpWarningAttribute,
                            title: title,
                            desc: description,
                            textColor: .white,
                            imageContent: UIImage(named: "ic_warning"))
}

func showNotificationMessage(attributes: EKAttributes,
                             title: String,
                             desc: String,
                             textColor: EKColor,
                             imageContent: UIImage? = nil) {
    let title = EKProperty.LabelContent(
        text: title,
        style: .init(
            font: MainFont.medium.with(size: 16),
            color: textColor,
            displayMode: displayMode
        ),
        accessibilityIdentifier: "title"
    )
    
    let description = EKProperty.LabelContent(
        text: desc,
        style: .init(
            font: MainFont.light.with(size: 14),
            color: textColor,
            displayMode: displayMode
        ),
        accessibilityIdentifier: "description"
    )
    
    var image: EKProperty.ImageContent?
    
    if let imageContent = imageContent {
        image = EKProperty.ImageContent(
            image: imageContent,
            displayMode: displayMode,
            size: CGSize(width: 35, height: 35),
            tint: textColor,
            accessibilityIdentifier: "thumbnail"
        )
    }
    
    let simpleMessage = EKSimpleMessage(
        image: image,
        title: title,
        description: description
    )
    
    let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
    let contentView = EKNotificationMessageView(with: notificationMessage)
    SwiftEntryKit.display(entry: contentView, using: attributes)
}

var topPopUpWarningAttribute: EKAttributes {
    var attribute = topPopUpAttribute
    attribute.displayDuration = 5
    attribute.hapticFeedbackType = .warning
//    attribute.entryBackground = .gradient(
//        gradient: .init(
//            colors: [.amber, .pinky],
//            startPoint: .zero,
//            endPoint: CGPoint(x: 1, y: 1)
//        )
//    )
    attribute.entryBackground = .color(
        color: EKColor(
            UIColor(named: "warningBgColor") ?? .pinky
        )
    )
    return attribute
}

var topPopUpAttribute: EKAttributes {
    var attributes = EKAttributes()
    
    attributes = .topFloat
    attributes.displayMode = displayMode
    attributes.hapticFeedbackType = .success
    attributes.entryBackground = .gradient(
        gradient: .init(
            colors: [.amber, .pinky],
            startPoint: .zero,
            endPoint: CGPoint(x: 1, y: 1)
        )
    )
    attributes.popBehavior = .animated(
        animation: .init(
            translate: .init(duration: 0.3),
            scale: .init(from: 1, to: 0.7, duration: 0.7)
        )
    )
    attributes.shadow = .active(
        with: .init(
            color: .black,
            opacity: 0.5,
            radius: 10
        )
    )
    attributes.statusBar = .dark
    attributes.scroll = .enabled(
        swipeable: true,
        pullbackAnimation: .easeOut
    )
    attributes.positionConstraints.maxSize = .init(
        width: .constant(value: UIScreen.main.bounds.maxX),
        height: .intrinsic
    )
    
    return attributes
}
