//
//  TutorialViewController.swift
//  YumFun
//
//  Created by Xiyu Zhang on 3/11/21.
//

import UIKit
import paper_onboarding

struct PageInfo {
    var image: UIImage
    var title: String
    var description: String
    var icon: UIImage
    var color: UIColor
    var titleColor: UIColor
    var descripColor: UIColor
    var titleFont: UIFont
    var descripFont: UIFont
}

class TutorialViewController: UIViewController {

    @IBOutlet weak var contentView: PaperOnboarding!
    weak var cookingViewController: CookingViewController?

    
    var pageInfos = [PageInfo(image: UIImage(named: "palm") ?? UIImage(),
                              title: "Palm",
                              description: "To view the detail of a step, face your palm down to, about 20cm away from the front camera.",
                              icon: UIImage(systemName: "plus.circle.fill")  ?? UIImage(),
                              color: UIColor(named: "cell_bg_color") ?? UIColor.systemBackground,
                              titleColor: UIColor(named: "text_high_emphasis") ?? UIColor.label,
                              descripColor: UIColor(named: "text_medium_emphasis") ?? UIColor.label,
                              titleFont: UIFont.systemFont(ofSize: 25),
                              descripFont: UIFont.systemFont(ofSize: 20)),
                     PageInfo(image: UIImage(named: "side") ?? UIImage(),
                               title: "Side",
                               description: "To close the detail of a step, face the side of your palm down to, about 20cm away from the front camera.",
                               icon: UIImage(systemName: "minus.circle.fill") ?? UIImage(),
                               color: UIColor(named: "cell_bg_color") ?? UIColor.systemBackground,
                               titleColor: UIColor(named: "text_high_emphasis") ?? UIColor.label,
                               descripColor: UIColor(named: "text_medium_emphasis") ?? UIColor.label,
                               titleFont: UIFont.systemFont(ofSize: 25),
                               descripFont: UIFont.systemFont(ofSize: 20)),
                     PageInfo(image: UIImage(named: "round") ?? UIImage(),
                               title: "Round",
                               description: "To check a step, curl your hand and place it about 20cm away from the front camera.",
                               icon: UIImage(systemName: "checkmark.circle.fill") ?? UIImage(),
                               color: UIColor(named: "cell_bg_color") ?? UIColor.systemBackground,
                               titleColor: UIColor(named: "text_high_emphasis") ?? UIColor.label,
                               descripColor: UIColor(named: "text_medium_emphasis") ?? UIColor.label,
                               titleFont: UIFont.systemFont(ofSize: 25),
                               descripFont: UIFont.systemFont(ofSize: 20))]
    
    override func viewDidLoad() {
//        for i in 0..<pageInfos.count {
//            pageInfos[i].icon = pageInfos[i].icon.sd_resizedImage(with: CGSize(width: 20, height: 20), scaleMode: .aspectFit) ?? pageInfos[i].icon
//        }
        super.viewDidLoad()
    }
    
    @IBAction func okPressed() {
        dismiss(animated: true) {
            self.cookingViewController?.toggleCapture()
        }
    }
    
    @IBAction func dontPressed() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: "disableTutorial")
        dismiss(animated: true) {
            self.cookingViewController?.toggleCapture()
        }
    }
}

extension TutorialViewController: PaperOnboardingDataSource {
    func onboardingItemsCount() -> Int {
        3
    }
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
        let info = pageInfos[index]
        return OnboardingItemInfo(informationImage: info.image,
                               title: info.title,
                               description: info.description,
                               pageIcon: info.icon,
                               color: info.color,
                               titleColor: info.titleColor,
                               descriptionColor: info.descripColor,
                               titleFont: info.titleFont,
                               descriptionFont: info.descripFont)
    }
    
    
    
    func onboardingPageItemColor(at index: Int) -> UIColor {
        return UIColor(named: "secondary") ?? .white
    }
    

    func onboardinPageItemRadius() -> CGFloat {
        8
    }

    
    func onboardingPageItemSelectedRadius() -> CGFloat {
        15
    }
}


