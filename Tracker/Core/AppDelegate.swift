//
//  AppDelegate.swift
//  Tracker
//
//  Created by Анастасия Федотова on 09.04.2026.
//

import UIKit
import AppMetricaCore

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - UIApplication Lifecycle

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if let configuration = AppMetricaConfiguration(apiKey: "accfa1c7-d420-4880-ba50-cec2d35b23aa") {
            AppMetrica.activate(with: configuration)
        }
        return true
    }

    // MARK: - UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
