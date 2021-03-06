//
//  SceneDelegate.swift
//  YumFun
//
//  Created by Failury on 2/16/21.
//

import UIKit
import Firebase

enum TestViewType {
    case testViewComponents
    case noTestView
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    let testViewType: TestViewType = .noTestView

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        if navToTestViews(windowScene) {
            return
        }
        
        if Auth.auth().currentUser != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            guard let homeViewController = storyboard.instantiateViewController(identifier: "tabBarView") as? UITabBarController else {
                assertionFailure("Cannot instantiate HomeViewController.")
                return
            }
            
            self.window?.windowScene = windowScene
            self.window?.rootViewController = homeViewController
            self.window?.makeKeyAndVisible()
        }
        
        self.scene(scene, openURLContexts: connectionOptions.urlContexts)
    }
    
    func navToTestViews(_ windowScene: UIWindowScene) -> Bool {
        switch testViewType {
        case .testViewComponents:
            let storyboard = UIStoryboard(name: "ViewComponentTest", bundle: nil)
            guard let viewComponentTestViewController = storyboard.instantiateViewController(identifier: "ViewComponentTestViewController") as? ViewComponentTestViewController else {
                assertionFailure("Cannot instantiate ViewComponentTestViewController")
                return true
            }
            self.window?.windowScene = windowScene
            self.window?.rootViewController = viewComponentTestViewController
            self.window?.makeKeyAndVisible()
            return true
        default:
            return false
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        
        let sendingAppID = URLContexts.first?.options.sourceApplication
        print("source application = \(sendingAppID ?? "Unknown")")
        
        // Process the URL.
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
            let host = components.host,
            let params = components.queryItems else {
                print("Invalid URL or host missing")
            return
        }
        
        let path = components.path
        
        switch host {
        case "collabcook":
            if let collabCookAction = path {
                if collabCookAction == "/join", let sessionId = params.first(where: { $0.name == "sessionid" })?.value {
                    print("Session ID: \(sessionId)")
                    Core.urlOpenTask = .joinCollabSession(sessionId: sessionId)
                } else {
                    print("No session id is detected or path is not right.")
                }
            } else {
                print("No action detected.")
            }
        default:
            return
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

