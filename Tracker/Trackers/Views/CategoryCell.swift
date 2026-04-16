//
//  CategoryCell.swift
//  Tracker
//
//  Created by Анастасия Федотова on 15.04.2026.
//

import UIKit

final class CategoryCell: UITableViewCell {
    
    // MARK: - Static Properties
    static let identifier = "CategoryCell"
    
    // MARK: - UI Elements
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = .trBlue
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    func configure(with title: String, isSelected: Bool, isFirst: Bool, isLast: Bool) {
        textLabel?.text = title
        checkmarkImageView.isHidden = !isSelected
        
        backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.3)
        selectionStyle = .none
        
        layer.masksToBounds = true
        layer.cornerRadius = Resources.Constants.cornerRadius
        
        if isFirst && isLast {
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if isFirst {
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLast {
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            layer.cornerRadius = 0
        }
    }
    
    // MARK: - Setup
    private func setupUI() {
        contentView.addSubview(checkmarkImageView)
        
        NSLayoutConstraint.activate([
            checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Resources.Constants.defaultPadding),
            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        textLabel?.font = UIFont.systemFont(ofSize: 17)
    }
}
