//
//  CustomTabBarViewController.swift
//  YumFun
//
//  Created by Yibo Yan on 2021/3/3.
//

import UIKit
import NVActivityIndicatorView

class CustomTabBarViewController: UITabBarController {
    var indicatorFrame: CGRect {
        let frame = self.view.frame
        
        let side: CGFloat = 30
        let origin = CGPoint(x: (frame.width - side) / 2,
                             y: (frame.height - side) / 2)
        return CGRect(origin: origin, size: CGSize(width: side, height: side))
    }
    
    var overlay: UIView {
        let overlay = UIView(frame: self.view.frame)
        overlay.backgroundColor = UIColor.black
        overlay.alpha = 0.6
        return overlay
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(handleUrlTaskAdded), name: .newUrlTaskAdded, object: nil)
        
        let user = Core.currentUser
        
        if Core.currentUser == nil {
            let backdrop = self.overlay
            
            self.view.addSubview(backdrop)
            self.view.bringSubviewToFront(backdrop)

            let indicator = NVActivityIndicatorView(frame: indicatorFrame)
            self.view.addSubview(indicator)
            self.view.bringSubviewToFront(indicator)

//            print("Frame \(indicator.frame)")
            indicator.startAnimating()
//            print("Animating: \(indicator.isAnimating)")

            Core.setupCurrentUser { (error) in
                indicator.stopAnimating()
                
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut) {
                    backdrop.alpha = 0
                } completion: { (_) in
                    backdrop.removeFromSuperview()
                }
                
                if let error = error {
                    print("Failed to setup current user \(error)")
                } else {
                    self.handleUrlTaskAdded()
                }
            }
        }
    }
    
    @objc private func handleUrlTaskAdded() {
        guard Core.currentUser != nil else {
            return
        }
        
        switch Core.urlOpenTask {
        case .joinCollabSession(let sessionId):
            Core.urlOpenTask = nil
            self.navToCollabSession(with: sessionId)
        default:
            print("NO TASK")
        }
    }
    
    private func navToCollabSession(with sessionId: String) {
        let storyboard = UIStoryboard(name: "CollabTest", bundle: nil)
        
        guard let collabViewController = storyboard.instantiateViewController(identifier: "CollabTestViewController") as? CollabTestViewController else {
            assertionFailure("Cannot instantiate CollabTestViewController.")
            return
        }
        
        collabViewController.sessionID = sessionId
        
        self.present(collabViewController, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .newUrlTaskAdded, object: nil)
        
        super.viewWillDisappear(animated)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
