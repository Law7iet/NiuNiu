//
//  Utils.swift
//  NiuNiu
//
//  Created by Han Chu on 22/07/22.
//

import UIKit
import MultipeerConnectivity

class Utils {
    // Debug
    static let numberOfPlayers = 6
    static let pendingTimer = 2.5
    
    // Game setting
    static let timerOffset = 1
    static let timerShort = 2
    static let timerLong = 10
    static let points = 100
    
    // Card setting
    static let cornerRadius = CGFloat(5.0)
    static let cornerRadiusSmall = CGFloat(3.0)
    // borderWitdh it's equal to: 1.85% of the card's height
    static func borderWidth(withHeight height: CGFloat) -> CGFloat {
        return height * 1.85 / 100
    }

    static func findPlayer(byName playerName: String, from players: [Player]) -> Player? {
        for player in players {
            if player.id == playerName {
                return player
            }
        }
        return nil
    }
    
    static func getNames(fromPeerIDs peerIDs: [MCPeerID]) -> [String] {
        var array = [String]()
        for peerID in peerIDs {
            array.append(peerID.displayName)
        }
        return array
    }
    
    static func getOneButtonAlert(title: String, message: String, action: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: action))
        return alert
    }
    
    static func getCurrentVC() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        return window?.visibleViewController
    }
}

extension UIWindow {
    /// Returns the currently visible view controller if any reachable within the window.
    public var visibleViewController: UIViewController? {
        return UIWindow.visibleViewController(from: rootViewController)
    }

    /// Recursively follows navigation controllers, tab bar controllers and modal presented view controllers starting
    /// from the given view controller to find the currently visible view controller.
    ///
    /// - Parameters:
    ///   - viewController: The view controller to start the recursive search from.
    /// - Returns: The view controller that is most probably visible on screen right now.
    public static func visibleViewController(from viewController: UIViewController?) -> UIViewController? {
        switch viewController {
        case let navigationController as UINavigationController:
            return UIWindow.visibleViewController(from: navigationController.visibleViewController ?? navigationController.topViewController)

        case let tabBarController as UITabBarController:
            return UIWindow.visibleViewController(from: tabBarController.selectedViewController)

        case let presentingViewController where viewController?.presentedViewController != nil:
            return UIWindow.visibleViewController(from: presentingViewController?.presentedViewController)

        default:
            return viewController
        }
    }
}
