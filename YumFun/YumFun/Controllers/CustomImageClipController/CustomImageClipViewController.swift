//
//  CustomImageClipViewController.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/3/4.
//

import Foundation
import QCropper
import JGProgressHUD

class CustomImageClipViewController: CropperViewController {

    lazy var customOverlay: CustomOverlay = {
        let co = CustomOverlay(frame: self.view.bounds)
        co.gridLinesCount = 0

        return co
    }()

    override var overlay: Overlay {
        get {
            return customOverlay
        }

        set {
            if let co = newValue as? CustomOverlay {
                customOverlay = co
            }
        }
    }
    
//    let hud = JGProgressHUD()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        isCropBoxPanEnabled = false
        topBar.isHidden = true
        angleRuler.isHidden = false
        aspectRatioPicker.isHidden = true
        
//        self.view.addSubview(hud.hudView)
//        self.view.bringSubviewToFront(hud.hudView)
//        hud.textLabel.text = "Loading"
        
        
//        cropper.view.addSubview(hud)
//        cropper.view.bringSubviewToFront(hud)
        
//        hud.show(in: self.view)
//        hud.dismiss(afterDelay: 3.0)
    }

    override func resetToDefaultLayout() {
        super.resetToDefaultLayout()

        aspectRatioLocked = true
        setAspectRatioValue(1)
    }
}
