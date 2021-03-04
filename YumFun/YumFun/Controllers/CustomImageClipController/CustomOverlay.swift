//
//  CustomOverlay.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/3/4.
//

import Foundation
import QCropper

class CustomOverlay: Overlay {

    lazy var borderLayer: CAShapeLayer = {
        let bl = CAShapeLayer()
        bl.strokeColor = UIColor.white.cgColor
        bl.fillColor = UIColor.clear.cgColor
        return bl
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        cropBox.isHidden = true
        layer.addSublayer(borderLayer)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateMask(animated: Bool) {
        var maskLayer: CAShapeLayer
        if let ml = translucentMaskView.layer.mask as? CAShapeLayer {
            maskLayer = ml
        } else {
            maskLayer = CAShapeLayer()
            translucentMaskView.layer.mask = maskLayer
        }

        let bezierPath = UIBezierPath(rect: translucentMaskView.bounds)
        let center = UIBezierPath(rect: cropBox.frame)
        
        bezierPath.append(center)

        maskLayer.fillRule = .evenOdd
        bezierPath.usesEvenOddFillRule = true

        borderLayer.path = center.cgPath
        borderLayer.lineWidth = 2.0

        if animated {
            let animation = CABasicAnimation(keyPath: "path")
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            maskLayer.path = bezierPath.cgPath
            animation.duration = 0.2
            maskLayer.add(animation, forKey: animation.keyPath)
        } else {
            maskLayer.path = bezierPath.cgPath
        }
    }
}
