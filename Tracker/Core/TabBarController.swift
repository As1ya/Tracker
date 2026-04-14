//
//  TabBarController.swift
//  Tracker
//
//  Created by Анастасия Федотова on 09.04.2026.
//

import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .trWhite
        
        let trackersVC = TrackersViewController()
        let trackersNavController = UINavigationController(rootViewController: trackersVC)
        trackersNavController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(systemName: "record.circle.fill"),
            selectedImage: nil
        )
        
        let statisticsVC = StatisticsViewController()
        let statisticsNavController = UINavigationController(rootViewController: statisticsVC)
        statisticsNavController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(systemName: "hare.fill"),
            selectedImage: nil
        )
        
        self.viewControllers = [trackersNavController, statisticsNavController]
        
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
