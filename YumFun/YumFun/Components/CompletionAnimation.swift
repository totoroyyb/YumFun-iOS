//
//  CompletionAnimation.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/3/12.
//

import TKSwarmAlert

func displayCompletionAnimation() {
    let alert = TKSwarmAlert(backgroundType: .brightBlur)
    
    let componentHeight: CGFloat = 60
    let spacing: CGFloat = 15
    let startY = UIScreen.main.bounds.height / 5
    
    let view1 = constructComponent(imageName: "crown.fill", textContent: "You have completed a dish!", yPosition: startY + componentHeight + spacing)
    
    let view2 = constructComponent(imageName: "checkmark.seal", textContent: "First meal with YumFun!", yPosition: startY + (componentHeight + spacing) * 2)

    
    alert.show([view1, view2])
}

func constructComponent(imageName: String, textContent: String, yPosition: CGFloat) -> UIView {
    let componentHeight: CGFloat = 60
    let componentWidth: CGFloat = UIScreen.main.bounds.width > 400 ? 320 : UIScreen.main.bounds.width * 0.8
    let start = (UIScreen.main.bounds.width - componentWidth ) / 2
    
    let component = UIView(frame: CGRect(x: start, y: yPosition, width: componentWidth, height: componentHeight))
    component.backgroundColor = UIColor(named: "cell_bg_color")
    let testImageView = UIImageView()

    testImageView.contentMode = .scaleAspectFill
    testImageView.image = UIImage(systemName: imageName)
    component.addSubview(testImageView)
    
    let label = UILabel()
    label.text = textContent
    
    component.addSubview(label)
    
    component.layer.addShadow(color: UIColor(named: "shadow_color") ?? .darkGray)
    component.layer.roundCorners(radius: 20)
    
    testImageView.snp.makeConstraints { (make) in
        make.leading.equalTo(component.snp.leading).offset(20)
        make.centerY.equalTo(component.snp.centerY)
        make.height.equalTo(component.snp.height).offset(-30)
        make.width.equalTo(component.snp.height).offset(-30)
    }
    
    label.snp.makeConstraints { (make) in
        make.leading.equalTo(testImageView.snp.trailing).offset(20)
        make.trailing.equalTo(component.snp.trailing).offset(-20)
        make.centerY.equalTo(testImageView.snp.centerY)
        make.height.equalTo(component.snp.height)
    }
    
    return component
}
