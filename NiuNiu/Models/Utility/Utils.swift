//
//  Utils.swift
//  NiuNiu
//
//  Created by Han Chu on 22/07/22.
//

import UIKit
import MultipeerConnectivity

class Utils {
    
    // MARK: Costants of the applications
    // Timer values
    static let timerOffset =    1
    static let timerShort =     3
    static let timerMedium =    15
    // Timer values for the game status
    static let timeStartBet =   timerShort + (1 * timerOffset) + (0 * Settings.timerLong)
    static let timeStopBet =    timerShort + (2 * timerOffset) + (1 * Settings.timerLong) - 1
    static let timeStartCheck = timerShort + (2 * timerOffset) + (1 * Settings.timerLong)
    static let timeStopCheck =  timerShort + (2 * timerOffset) + (2 * Settings.timerLong) - 1
    static let timeStartCards = timerShort + (3 * timerOffset) + (2 * Settings.timerLong)
    static let timeStopCards =  timerShort + (3 * timerOffset) + (3 * Settings.timerLong) - 1
    static let timeStartEnd =   timerShort + (4 * timerOffset) + (3 * Settings.timerLong)
    // Some message
    static let confermHostLeftMessage =     "If you quit the lobby, the lobby will close. Are you sure to quit?"
    static let confermClientLeftMessage =   "If you quit the game, you can't play until the game ends. Are you sure to quit?"
    static let hostLeftMessage =            "Lost connection with the server"
    static let clientLeftMessage =          "Lost connection with the clients"
    // Cards settings
    static let cornerRadius = CGFloat(5.0)
    static let cornerRadiusSmall = CGFloat(3.0)

    // MARK: Supporting functions
    /// Find a player by name from the array of `Player` passed by parameter.
    /// - Parameters:
    ///   - playerName: the player name.
    ///   - players: the array.
    /// - Returns: the player that id's matches with the name. If no players match with the name, it return `nil`.
    static func findPlayer(byName playerName: String, from users: [User]) -> User? {
        for user in users {
            if user.id == playerName {
                return user
            }
        }
        return nil
    }
    
    /// Get the names (`MCPeerID.displayName`) in a array from a array of `MCPeerID`.
    /// - Parameter peerIDs: the array of `MCPeerID`.
    /// - Returns: the array of names.
    static func getPeersName(from peerIDs: [MCPeerID]) -> [String] {
        var array = [String]()
        for peerID in peerIDs {
            array.append(peerID.displayName)
        }
        return array
    }
        
    /// The border's width of a card is equal to 1.85% of the card's height.
    /// - Parameter height: the card's height.
    /// - Returns: the border width.
    static func borderWidth(withHeight height: CGFloat) -> CGFloat {
        return height * 1.85 / 100
    }
    
    /// Get the view controller class which is currently visible.
    /// - Returns: the view controller.
    static func getCurrentVC() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        return window?.visibleViewController
    }
    
    /// Return an attributed string with the custom font and the string passed by parameter
    /// - Parameter msg: the string
    /// - Returns: the attributed string
    static func myString(_ msg: String) -> NSAttributedString {
        NSAttributedString(
            string: msg,
            attributes: [NSAttributedString.Key.font: UIFont(name: "Marker Felt Thin", size: 17)!]
        )
    }

}

// MARK: This is an extension used to find the current view controller
extension UIWindow {
    
    /// Returns the currently visible view controller if any reachable within the window.
    public var visibleViewController: UIViewController? {
        return UIWindow.visibleViewController(from: rootViewController)
    }

    /// Recursively follows navigation controllers, tab bar controllers and modal presented view controllers starting
    /// from the given view controller to find the currently visible view controller.
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
