//
//  TabBarController.swift
//  Tracker
//
//  Created by Анастасия Федотова on 09.04.2026.
//

import UIKit

// MARK: - TabBarController
final class TabBarController: UITabBarController {

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupViewControllers()
        setupTabBarAppearance()
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = .trWhite
    }
    
    private func setupViewControllers() {
        let trackers = makeNavigationController(
            rootViewController: TrackersViewController(),
            title: L10n.Trackers.title,
            imageName: Resources.Images.trackersTab
        )
        
        let statistics = makeNavigationController(
            rootViewController: StatisticsViewController(),
            title: L10n.Statistics.title,
            imageName: Resources.Images.statisticsTab
        )
        
        viewControllers = [trackers, statistics]
    }
    
    // MARK: - Navigation Helpers
    private func makeNavigationController(
        rootViewController: UIViewController,
        title: String,
        imageName: String
    ) -> UINavigationController {
        
        let navController = UINavigationController(rootViewController: rootViewController)
        
        navController.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: imageName),
            selectedImage: nil
        )
        
        return navController
    }
    
    // MARK: - TabBar Appearance
    private func setupTabBarAppearance() {
        tabBar.isTranslucent = false
        tabBar.tintColor = .trBlue
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .trWhite
        
        tabBar.standardAppearance = appearance
        
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}
