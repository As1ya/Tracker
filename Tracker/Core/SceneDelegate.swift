//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Анастасия Федотова on 09.04.2026.
//

import UIKit

// MARK: - SceneDelegate

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // MARK: - Properties
    
    var window: UIWindow?

    // MARK: - UIWindowSceneDelegate
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        setupWindow(windowScene)
    }

    // MARK: - Private Methods
    
    private func setupWindow(_ windowScene: UIWindowScene) {
        let window = UIWindow(windowScene: windowScene)
        
        let hasSeenOnboarding = UserDefaultsService.shared.hasSeenOnboarding
        
        if hasSeenOnboarding {
            window.rootViewController = TabBarController()
        } else {
            window.rootViewController = OnboardingViewController()
        }
        
        self.window = window
        window.makeKeyAndVisible()
    }
}

