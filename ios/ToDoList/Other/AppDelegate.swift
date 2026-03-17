//
//  AppDelegate.swift
//  ToDoList
//
//  UIKit app-delegate.
//  Only responsibility: initialise the React Native RCTRootViewFactory at launch.
//

import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        RNBridge.shared.setup()
        return true
    }
}
