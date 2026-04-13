//
//  TrackerCell.swift
//  Tracker
//
//  Created by Анастасия Федотова on 11.04.2026.
//

import UIKit

protocol TrackerCellDelegate: AnyObject {
    func trackerCellDidTapCompleteButton(_ cell: TrackerCell)
}

final class TrackerCell: UICollectionViewCell {
    
    static let identifier = "TrackerCell"
    
    weak var delegate: TrackerCellDelegate?
    
    // MARK: - UI Elements
    
    private let topContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        let size: CGFloat = 24
        label.layer.cornerRadius = size / 2
        label.clipsToBounds = true
        label.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let daysLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 17
        button.tintColor = .white
        let image = UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupView() {
        contentView.addSubview(topContainerView)
        topContainerView.addSubview(emojiLabel)
        topContainerView.addSubview(nameLabel)
        
        contentView.addSubview(daysLabel)
        contentView.addSubview(completeButton)
        
        NSLayoutConstraint.activate([
            // Top Container
            topContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            topContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topContainerView.heightAnchor.constraint(equalToConstant: 90),
            
            // Emoji Label
            emojiLabel.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: 12),
            emojiLabel.topAnchor.constraint(equalTo: topContainerView.topAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            // Name Label
            nameLabel.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor, constant: -12),
            nameLabel.bottomAnchor.constraint(equalTo: topContainerView.bottomAnchor, constant: -12),
            
            // Days Label
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysLabel.centerYAnchor.constraint(equalTo: completeButton.centerYAnchor),
            
            // Complete Button
            completeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            completeButton.topAnchor.constraint(equalTo: topContainerView.bottomAnchor, constant: 8),
            completeButton.widthAnchor.constraint(equalToConstant: 34),
            completeButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with tracker: Tracker, isCompletedToday: Bool, completedDays: Int) {
        nameLabel.text = tracker.name
        emojiLabel.text = tracker.emoji
        topContainerView.backgroundColor = tracker.color
        
        let daysString = String.localizedStringWithFormat(
            NSLocalizedString("%d days", comment: "Number of days completed"),
            completedDays
        ) 
  
        let formatString: String
        let remainder10 = completedDays % 10
        let remainder100 = completedDays % 100
        
        if remainder10 == 1 && remainder100 != 11 {
            formatString = "%d день"
        } else if (2...4).contains(remainder10) && !(12...14).contains(remainder100) {
            formatString = "%d дня"
        } else {
            formatString = "%d дней"
        }
        daysLabel.text = String(format: formatString, completedDays)
        
        let image = isCompletedToday ? UIImage(systemName: "checkmark") : UIImage(systemName: "plus")
        completeButton.setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        if isCompletedToday {
            completeButton.backgroundColor = tracker.color.withAlphaComponent(0.3)
        } else {
            completeButton.backgroundColor = tracker.color
        }
    }
    
    // MARK: - Actions
    
    @objc private func completeButtonTapped() {
        delegate?.trackerCellDidTapCompleteButton(self)
    }
}
