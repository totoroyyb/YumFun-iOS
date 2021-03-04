//
//  CustomImageClipViewController.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/3/4.
//

import Foundation
import QCropper
import JGProgressHUD
import SwiftEntryKit

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

    override func viewDidLoad() {
        super.viewDidLoad()
        isCropBoxPanEnabled = false
        topBar.isHidden = true
        angleRuler.isHidden = false
        aspectRatioPicker.isHidden = true
    }

    override func resetToDefaultLayout() {
        super.resetToDefaultLayout()

        aspectRatioLocked = true
        setAspectRatioValue(1)
    }
}
