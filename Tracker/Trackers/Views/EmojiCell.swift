//
//  EmojiCell.swift
//  Tracker
//
//  Created by Анастасия Федотова on 13.04.2026.
//

import UIKit

// MARK: - EmojiCell
final class EmojiCell: UICollectionViewCell {
    
    // MARK: - Static Properties
    static let identifier = "EmojiCell"
    
    // MARK: - UI Elements
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Properties
    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected ? .trLightGray : .clear
        }
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        
        contentView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    func configure(with emoji: String) {
        emojiLabel.text = emoji
    }
}
