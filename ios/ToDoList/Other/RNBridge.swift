//
//  RNBridge.swift
//  ToDoList
//
//  Singleton that owns the React Native factory for creating RN views.
//
//  RN 0.84 hardcodes New Architecture = ON.  The old RCTBridge / RCTRootView
//  APIs are non-functional stubs that produce corrupt objects.
//
//  Correct initialisation chain (confirmed from RCTReactNativeFactory.mm):
//    RCTDefaultReactNativeFactoryDelegate   – provides createJSRuntimeFactory (Hermes)
//    RCTReactNativeFactory(delegate:)       – wires delegate into config + sets up feature flags
//    factory.rootViewFactory                – the RCTRootViewFactory we use for view creation
//    rootViewFactory.view(withModuleName:)  – returns a fully initialised UIView
//

import UIKit
import React
import React_RCTAppDelegate
import ReactAppDependencyProvider

// MARK: - Delegate (provides bundle URL + Hermes runtime)

/// Subclasses the default delegate so we inherit createJSRuntimeFactory (Hermes),
/// turbo-module wiring, Fabric component registration, etc.
/// Only thing we MUST override is bundleURL — the base class throws if it's not overridden.
final class RNFactoryDelegate: RCTDefaultReactNativeFactoryDelegate {

    override func bundleURL() -> URL? {
        #if DEBUG
        return RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index")
        #else
        return Bundle.main.url(forResource: "main", withExtension: "jsbundle")
        #endif
    }
}

// MARK: - Singleton

final class RNBridge {

    static let shared = RNBridge()
    private init() {}

    // Strong references — delegate is held weakly by RCTReactNativeFactory,
    // so we must keep it alive here.
    private var factoryDelegate: RNFactoryDelegate?
    private var reactNativeFactory: RCTReactNativeFactory?

    /// Whether setup() has been called and the factory is ready to create views.
    var isReady: Bool { reactNativeFactory != nil }

    /// Call once from AppDelegate.application(_:didFinishLaunchingWithOptions:).
    func setup() {
        let delegate = RNFactoryDelegate()
        delegate.dependencyProvider = RCTAppDependencyProvider()

        let factory = RCTReactNativeFactory(delegate: delegate)

        self.factoryDelegate = delegate
        self.reactNativeFactory = factory
    }

    /// Creates a new React Native root view for the given JS module name.
    func createView(moduleName: String, initialProperties: [String: Any]? = nil) -> UIView {
        guard let factory = reactNativeFactory else {
            fatalError("RNBridge.setup() must be called before createView()")
        }
        return factory.rootViewFactory.view(withModuleName: moduleName, initialProperties: initialProperties)
    }
}
