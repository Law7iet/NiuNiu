//
//  AppDelegate.swift
//  NiuNiu
//
//  Created by Han Chu on 06/06/22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Marker Felt Thin", size: 20)!]
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Marker Felt Thin", size: 20)!], for: UIControl.State.normal)
        UIBarButtonItem.appearance().tintColor = UIColor(named: "Orange")
        
        return true
    }
    
}

