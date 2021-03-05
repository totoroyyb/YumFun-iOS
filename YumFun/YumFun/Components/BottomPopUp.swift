//
//  BottomPopUp.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/3/4.
//

import Foundation
import SwiftEntryKit

var displayMode: EKAttributes.DisplayMode {
    return .inferred
}

func displaySuccessBottomPopUp(title: String,
                               description: String,
                               buttonText: String? = nil) {
    let actionButton = EKProperty.ButtonContent(
        label: .init(
            text: buttonText ?? "Got it!",
            style: .init(
                font: MainFont.bold.with(size: 16),
                color: .black,
                displayMode: displayMode
            )
        ),
        backgroundColor: .white,
        highlightedBackgroundColor: Color.Teal.a600.with(alpha: 0.05),
        displayMode: displayMode,
        accessibilityIdentifier: "button"
    )
    
    showPopupMessage(attributes: bottomPopUpSuccessAlertAttributes,
                     title: title,
                     titleColor: .white,
                     description: description,
                     descriptionColor: .white,
                     buttonTitleColor: .white,
                     buttonBackgroundColor: .amber,
                     actionButton: actionButton,
                     image: UIImage(named: "ic_success"))
}

func displayErrorBottomPopUp(title: String,
                             description: String,
                             buttonText: String? = nil) {
    let actionButton = EKProperty.ButtonContent(
        label: .init(
            text: buttonText ?? "Sad",
            style: .init(
                font: MainFont.bold.with(size: 16),
                color: .black,
                displayMode: displayMode
            )
        ),
        backgroundColor: .white,
        highlightedBackgroundColor: EKColor.black.with(alpha: 0.05),
        displayMode: displayMode,
        accessibilityIdentifier: "button"
    )
    
    showPopupMessage(attributes: bottomPopUpErrorAlertAttributes,
                     title: title,
                     titleColor: .white,
                     description: description,
                     descriptionColor: .white,
                     buttonTitleColor: .black,
                     buttonBackgroundColor: .white,
                     actionButton: actionButton,
                     image: UIImage(named: "ic_error"))
}

private func showPopupMessage(attributes: EKAttributes,
                              title: String,
                              titleColor: EKColor,
                              description: String,
                              descriptionColor: EKColor,
                              buttonTitleColor: EKColor,
                              buttonBackgroundColor: EKColor,
                              actionButton: EKProperty.ButtonContent? = nil,
                              image: UIImage? = nil) {
    
    var themeImage: EKPopUpMessage.ThemeImage?
    
    if let image = image {
        themeImage = EKPopUpMessage.ThemeImage(
            image: EKProperty.ImageContent(
                image: image,
                displayMode: displayMode,
                size: CGSize(width: 60, height: 60),
                tint: titleColor,
                contentMode: .scaleAspectFit
            )
        )
    }
    
    let title = EKProperty.LabelContent(
        text: title,
        style: .init(
            font: MainFont.medium.with(size: 24),
            color: titleColor,
            alignment: .center,
            displayMode: displayMode
        ),
        accessibilityIdentifier: "title"
    )
    
    let description = EKProperty.LabelContent(
        text: description,
        style: .init(
            font: MainFont.light.with(size: 16),
            color: descriptionColor,
            alignment: .center,
            displayMode: displayMode
        ),
        accessibilityIdentifier: "description"
    )
    
    let button = actionButton ?? EKProperty.ButtonContent(
        label: .init(
            text: "Sad",
            style: .init(
                font: MainFont.bold.with(size: 16),
                color: buttonTitleColor,
                displayMode: displayMode
            )
        ),
        backgroundColor: buttonBackgroundColor,
        highlightedBackgroundColor: buttonTitleColor.with(alpha: 0.05),
        displayMode: displayMode,
        accessibilityIdentifier: "button"
    )
    
    let message = EKPopUpMessage(
        themeImage: themeImage,
        title: title,
        description: description,
        button: button) {
            SwiftEntryKit.dismiss()
    }
    
    let contentView = EKPopUpMessageView(with: message)
    SwiftEntryKit.display(entry: contentView, using: attributes)
}

var bottomPopUpSuccessAlertAttributes: EKAttributes {
    var attributes = bottomAlertAttributes
    attributes.hapticFeedbackType = .success
    attributes.entryBackground = .color(color: Color.Teal.a600)
    return attributes
}

var bottomPopUpErrorAlertAttributes: EKAttributes {
    var attributes = bottomAlertAttributes
    attributes.hapticFeedbackType = .error
    attributes.entryBackground = .color(color: .pinky)
    return attributes
}

var bottomAlertAttributes: EKAttributes {
    var attributes = EKAttributes.bottomFloat
    attributes.hapticFeedbackType = .error
    attributes.displayDuration = .infinity
    attributes.entryBackground = .color(color: .pinky)
    attributes.screenBackground = .color(color: .dimmedDarkBackground)
    
    attributes.shadow = .active(
        with: .init(
            color: .black,
            opacity: 0.3,
            radius: 8
        )
    )
    
    attributes.screenInteraction = .dismiss
    attributes.entryInteraction = .absorbTouches
    attributes.scroll = .enabled(
        swipeable: true,
        pullbackAnimation: .jolt
    )
    
    attributes.roundCorners = .all(radius: 25)
    
    attributes.entranceAnimation = .init(
        translate: .init(
            duration: 0.5,
            spring: .init(damping: 0.8, initialVelocity: 0)
        ),
        scale: .init(
            from: 1.05,
            to: 1,
            duration: 0.4,
            spring: .init(damping: 1, initialVelocity: 0)
        )
    )
    
    attributes.exitAnimation = .init(
        translate: .init(duration: 0.2)
    )
    
    attributes.popBehavior = .animated(
        animation: .init(
            translate: .init(duration: 0.2)
        )
    )
    
    attributes.positionConstraints.verticalOffset = 10
    attributes.positionConstraints.size = .init(
        width: .offset(value: 20),
        height: .intrinsic
    )
    
    attributes.positionConstraints.maxSize = .init(
        width: .constant(value: UIScreen.main.bounds.maxX),
        height: .intrinsic
    )
    
    attributes.statusBar = .dark
    return attributes
}
