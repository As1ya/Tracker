//
//  ColorCell.swift
//  Tracker
//
//  Created by Анастасия Федотова on 13.04.2026.
//

import UIKit

// MARK: - ColorCell
final class ColorCell: UICollectionViewCell {
    
    // MARK: - Static Properties
    static let identifier = "ColorCell"
    
    // MARK: - UI Elements
    private let innerColorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Properties
    override var isSelected: Bool {
        didSet {
            if isSelected {
                contentView.layer.borderWidth = 3
                contentView.layer.borderColor = innerColorView.backgroundColor?.withAlphaComponent(0.3).cgColor
            } else {
                contentView.layer.borderWidth = 0
            }
        }
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(innerColorView)
        
        NSLayoutConstraint.activate([
            innerColorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            innerColorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            innerColorView.widthAnchor.constraint(equalToConstant: 40),
            innerColorView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    func configure(with color: UIColor) {
        innerColorView.backgroundColor = color
        if isSelected {
            contentView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        }
    }
}
