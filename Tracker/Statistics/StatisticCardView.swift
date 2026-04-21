//
//  StatisticCardView.swift
//  Tracker
//
//  Created by Анастасия Федотова on 19.04.2026.
//

import UIKit

// MARK: - StatisticCardView

final class StatisticCardView: UIView {
    
    // MARK: - UI Components
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Private Properties

    private let borderGradientLayer = CAGradientLayer()
    private let borderMaskLayer = CAShapeLayer()

    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        borderGradientLayer.frame = bounds
        borderMaskLayer.path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5),
            cornerRadius: Resources.Constants.cornerRadius
        ).cgPath
    }

    // MARK: - Public Methods
    
    func configure(value: Int, title: String) {
        valueLabel.text = "\(value)"
        titleLabel.text = title
    }

    // MARK: - Private Methods
    
    private func setupView() {
        backgroundColor = .trWhite
        layer.cornerRadius = Resources.Constants.cornerRadius

        borderGradientLayer.colors = [
            UIColor.systemRed.cgColor,
            UIColor.systemGreen.cgColor,
            UIColor.systemBlue.cgColor
        ]
        borderGradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        borderGradientLayer.endPoint = CGPoint(x: 1, y: 0.5)

        borderMaskLayer.lineWidth = 1
        borderMaskLayer.fillColor = UIColor.clear.cgColor
        borderMaskLayer.strokeColor = UIColor.black.cgColor
        borderGradientLayer.mask = borderMaskLayer
        layer.addSublayer(borderGradientLayer)

        addSubview(valueLabel)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 90),

            valueLabel.topAnchor.constraint(equalTo: topAnchor, constant: Resources.Constants.defaultPadding),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Resources.Constants.defaultPadding),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Resources.Constants.defaultPadding),

            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Resources.Constants.defaultPadding),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Resources.Constants.defaultPadding),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Resources.Constants.defaultPadding)
        ])
    }
}
