//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Анастасия Федотова on 15.04.2026.
//

import UIKit

protocol NewCategoryViewControllerDelegate: AnyObject {
    func didCreateCategory(_ title: String)
    func didEditCategory(oldTitle: String, newTitle: String)
}

final class NewCategoryViewController: UIViewController {
    
    // MARK: - Types
    enum Mode {
        case create
        case edit(String)
    }
    
    // MARK: - Properties
    weak var delegate: NewCategoryViewControllerDelegate?
    private let mode: Mode
    private let existingTitles: Set<String>
    
    // MARK: - UI Elements
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = modeTitle
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
        textField.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.3)
        textField.layer.cornerRadius = Resources.Constants.cornerRadius
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        textField.text = initialTitle
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: Resources.Constants.defaultPadding, height: Resources.Constants.cellHeight))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = initialTitle.isEmpty ? .trGray : .trBlack
        button.setTitleColor(.trWhite, for: .normal)
        button.layer.cornerRadius = Resources.Constants.cornerRadius
        button.isEnabled = !initialTitle.isEmpty
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        return button
    }()
    
    private var modeTitle: String {
        switch mode {
        case .create: return "Новая категория"
        case .edit: return "Редактирование категории"
        }
    }
    
    private var initialTitle: String {
        if case .edit(let title) = mode { return title }
        return ""
    }
    
    // MARK: - Init
    init(mode: Mode = .create, existingTitles: Set<String> = []) {
        self.mode = mode
        self.existingTitles = existingTitles
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .trWhite
        
        view.addSubview(titleLabel)
        view.addSubview(textField)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Resources.Constants.defaultPadding),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Resources.Constants.defaultPadding),
            textField.heightAnchor.constraint(equalToConstant: Resources.Constants.cellHeight),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Resources.Constants.largePadding),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Resources.Constants.largePadding),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Resources.Constants.defaultPadding),
            doneButton.heightAnchor.constraint(equalToConstant: Resources.Constants.buttonHeight)
        ])
    }
    
    // MARK: - Actions
    @objc private func textFieldDidChange() {
        let isEmpty = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
        doneButton.isEnabled = !isEmpty
        doneButton.backgroundColor = isEmpty ? .trGray : .trBlack
    }
    
    @objc private func doneTapped() {
        let normalizedTitle = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !normalizedTitle.isEmpty else {
            showError(message: "Название не может быть пустым.")
            return
        }

        let normalizedExistingTitles = Set(existingTitles.map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        })

        switch mode {
        case .create:
            guard !normalizedExistingTitles.contains(normalizedTitle.lowercased()) else {
                showError(message: "Категория с таким названием уже существует.")
                return
            }
            delegate?.didCreateCategory(normalizedTitle)
        case .edit(let oldTitle):
            let normalizedOldTitle = oldTitle.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let duplicateExists = normalizedExistingTitles.contains(normalizedTitle.lowercased()) && normalizedTitle.lowercased() != normalizedOldTitle
            guard !duplicateExists else {
                showError(message: "Категория с таким названием уже существует.")
                return
            }
            delegate?.didEditCategory(oldTitle: oldTitle, newTitle: normalizedTitle)
        }
        dismiss(animated: true)
    }

    private func showError(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension NewCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
