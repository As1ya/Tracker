//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Анастасия Федотова on 09.04.2026.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        setupWindow(windowScene)
    }

    private func setupWindow(_ windowScene: UIWindowScene) {
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = TabBarController()
        self.window = window
        window.makeKeyAndVisible()
    }
}

