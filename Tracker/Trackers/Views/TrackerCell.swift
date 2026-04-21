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
    
    private let pinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "pin.fill")
        imageView.tintColor = .white
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    
    func configure(with tracker: Tracker, isCompletedToday: Bool, completedDays: Int) {
        nameLabel.text = tracker.name
        emojiLabel.text = tracker.emoji
        topContainerView.backgroundColor = tracker.color
        pinImageView.isHidden = !tracker.isPinned
        
        if tracker.isHabit {
            let format = NSLocalizedString("trackers.numberOfDays", comment: "")
            daysLabel.text = String.localizedStringWithFormat(format, completedDays)
        } else {
            daysLabel.text = isCompletedToday ? L10n.Trackers.done : ""
        }
        completeButton.isEnabled = true
        
        let image = isCompletedToday ? UIImage(systemName: "checkmark") : UIImage(systemName: "plus")
        completeButton.setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        completeButton.backgroundColor = isCompletedToday ? tracker.color.withAlphaComponent(0.3) : tracker.color
    }
    
    // MARK: - Actions
    
    @objc private func completeButtonTapped() {
        delegate?.trackerCellDidTapCompleteButton(self)
    }

    // MARK: - Private Methods
    
    private func setupView() {
        contentView.addSubview(topContainerView)
        topContainerView.addSubview(emojiLabel)
        topContainerView.addSubview(nameLabel)
        topContainerView.addSubview(pinImageView)
        
        contentView.addSubview(daysLabel)
        contentView.addSubview(completeButton)
        
        NSLayoutConstraint.activate([
            // Top Container
            topContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            topContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topContainerView.heightAnchor.constraint(equalToConstant: 90),
            
            // Emoji Label
            emojiLabel.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: Resources.Constants.mediumPadding),
            emojiLabel.topAnchor.constraint(equalTo: topContainerView.topAnchor, constant: Resources.Constants.mediumPadding),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            // Pin Image View
            pinImageView.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor, constant: -Resources.Constants.mediumPadding),
            pinImageView.topAnchor.constraint(equalTo: topContainerView.topAnchor, constant: Resources.Constants.mediumPadding),
            pinImageView.widthAnchor.constraint(equalToConstant: 24),
            pinImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Name Label
            nameLabel.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: Resources.Constants.mediumPadding),
            nameLabel.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor, constant: -Resources.Constants.mediumPadding),
            nameLabel.bottomAnchor.constraint(equalTo: topContainerView.bottomAnchor, constant: -Resources.Constants.mediumPadding),
            
            // Days Label
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Resources.Constants.mediumPadding),
            daysLabel.centerYAnchor.constraint(equalTo: completeButton.centerYAnchor),
            
            // Complete Button
            completeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Resources.Constants.mediumPadding),
            completeButton.topAnchor.constraint(equalTo: topContainerView.bottomAnchor, constant: Resources.Constants.smallPadding),
            completeButton.widthAnchor.constraint(equalToConstant: 34),
            completeButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }

}
