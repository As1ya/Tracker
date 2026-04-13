//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Анастасия Федотова on 09.04.2026.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .trWhite
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        title = "Статистика"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
