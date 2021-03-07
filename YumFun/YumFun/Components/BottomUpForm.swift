//
//  BottomUpForm.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/3/8.
//

import SwiftEntryKit

func displayBottomUpSignUpForm(prefillEmail: String?,
                               _ handler: @escaping (EKProperty.TextFieldContent,
                                           EKProperty.TextFieldContent) -> Void) {
    var attribute = getBottomUpFormAttribute()
    showSignupForm(attribute: &attribute, style: .standard, prefillEmail: prefillEmail, handler: handler)
}

private func getBottomUpFormAttribute() -> EKAttributes {
    var attribute: EKAttributes
    
    attribute = .toast
    attribute.displayMode = displayMode
    attribute.windowLevel = .normal
    attribute.position = .bottom
    attribute.displayDuration = .infinity
    attribute.entranceAnimation = .init(
        translate: .init(
            duration: 0.65,
            spring: .init(damping: 1, initialVelocity: 0)
        )
    )
    attribute.exitAnimation = .init(
        translate: .init(
            duration: 0.65,
            spring: .init(damping: 1, initialVelocity: 0)
        )
    )
    attribute.popBehavior = .animated(
        animation: .init(
            translate: .init(
                duration: 0.65,
                spring: .init(damping: 1, initialVelocity: 0)
            )
        )
    )
    attribute.entryInteraction = .absorbTouches
    attribute.screenInteraction = .dismiss
    attribute.entryBackground = .clear
    attribute.shadow = .active(
        with: .init(
            color: .black,
            opacity: 0.3,
            radius: 3
        )
    )
    attribute.screenBackground = .visualEffect(style: .standard)
    attribute.scroll = .edgeCrossingDisabled(swipeable: true)
    attribute.statusBar = .light
    attribute.positionConstraints.keyboardRelation = .bind(
        offset: .init(
            bottom: 0,
            screenEdgeResistance: 0
        )
    )
    attribute.positionConstraints.maxSize = .init(
        width: .constant(value: UIScreen.main.bounds.maxX),
        height: .intrinsic
    )
    return attribute
}

var bottomUpFormAttribute: EKAttributes = { () -> EKAttributes in
    var attribute: EKAttributes
    
    attribute = .toast
    attribute.displayMode = displayMode
    attribute.windowLevel = .normal
    attribute.position = .bottom
    attribute.displayDuration = .infinity
    attribute.entranceAnimation = .init(
        translate: .init(
            duration: 0.65,
            spring: .init(damping: 1, initialVelocity: 0)
        )
    )
    attribute.exitAnimation = .init(
        translate: .init(
            duration: 0.65,
            spring: .init(damping: 1, initialVelocity: 0)
        )
    )
    attribute.popBehavior = .animated(
        animation: .init(
            translate: .init(
                duration: 0.65,
                spring: .init(damping: 1, initialVelocity: 0)
            )
        )
    )
    attribute.entryInteraction = .absorbTouches
    attribute.screenInteraction = .dismiss
    attribute.entryBackground = .clear
    attribute.shadow = .active(
        with: .init(
            color: .black,
            opacity: 0.3,
            radius: 3
        )
    )
    attribute.screenBackground = .visualEffect(style: .standard)
    attribute.scroll = .edgeCrossingDisabled(swipeable: true)
    attribute.statusBar = .light
    attribute.positionConstraints.keyboardRelation = .bind(
        offset: .init(
            bottom: 0,
            screenEdgeResistance: 0
        )
    )
    attribute.positionConstraints.maxSize = .init(
        width: .constant(value: UIScreen.main.bounds.maxX),
        height: .intrinsic
    )
    return attribute
}()

// Not done yet.
private func showSignupForm(attribute: inout EKAttributes,
                            style: FormStyle,
                            prefillEmail: String?,
                            handler:
                                @escaping (EKProperty.TextFieldContent,
                                           EKProperty.TextFieldContent) -> Void) {
    
    let headerStyle = EKProperty.LabelStyle(
        font: MainFont.bold.with(size: 22),
        color: .text,
        displayMode: displayMode
    )
    
    let title = EKProperty.LabelContent(
        text: "Fill the info, let's YUMFUM!",
        style: headerStyle
    )
    
    var textFields = FormFieldPresetFactory.fields(
        by: [.email, .password],
        style: style
    )
    
    if let email = prefillEmail {
        textFields[0].textContent = email
    }
    
    let button = EKProperty.ButtonContent(
        label: .init(text: "Signup", style: style.buttonTitle),
        backgroundColor: style.buttonBackground,
        highlightedBackgroundColor: style.buttonBackground.with(alpha: 0.8),
        displayMode: displayMode) {
        handler(textFields[0], textFields[1])
    }
    
    let contentView = EKFormMessageView(
        with: title,
        textFieldsContent: textFields,
        buttonContent: button
    )
    
    attribute.lifecycleEvents.didAppear = {
        contentView.becomeFirstResponder(with: 0)
    }
    
    SwiftEntryKit.display(entry: contentView, using: attribute, presentInsideKeyWindow: true)
}
