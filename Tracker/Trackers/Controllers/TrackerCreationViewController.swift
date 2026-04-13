//
//  TrackerCreationViewController.swift
//  Tracker
//
//  Created by Анастасия Федотова on 11.04.2026.
//

import UIKit

final class TrackerCreationViewController: UIViewController {
    
    // MARK: - Delegate
    weak var delegate: TrackerCreationDelegate?
    
    // MARK: - Properties
    private let isHabit: Bool
    private var trackerName: String = ""
    private var selectedSchedule: [WeekDay] = []
    private let tableOptions: [String]
    
    // MARK: - UI Elements
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = isHabit ? "Новая привычка" : "Новое нерегулярное событие"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.3)
        textField.layer.cornerRadius = 16
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 75))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.delegate = self
        table.dataSource = self
        table.layer.cornerRadius = 16
        table.isScrollEnabled = false
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.trRed, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.trRed.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.trWhite, for: .normal)
        button.backgroundColor = .trGray 
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Init
    init(isHabit: Bool) {
        self.isHabit = isHabit
        self.tableOptions = isHabit ? ["Категория", "Расписание"] : ["Категория"]
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .trWhite
        setupViews()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(nameTextField)
        view.addSubview(tableView)
        view.addSubview(buttonStackView)
        
        let tableHeight: CGFloat = CGFloat(tableOptions.count * 75)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: tableHeight),
            
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Actions
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func cancelTapped() {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc private func createTapped() {
        guard !trackerName.isEmpty else { return }
        
        let color = UIColor.trSelections.randomElement() ?? .trBlue
        let emojis: [String] = ["🙂", "😻", "🌺", "🐶", "❤️", "🍔", "😇", "😡", "🥶", "🤔", "🙌", "🍒"]
        let emoji = emojis.randomElement() ?? "🙂"
        
        // Handle Irregular Events
        let scheduleToSave: [WeekDay]
        if isHabit {
            scheduleToSave = selectedSchedule
        } else {
            scheduleToSave = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        }
        
        let tracker = Tracker(id: UUID(), name: trackerName, color: color, emoji: emoji, schedule: scheduleToSave)
        
        delegate?.didCreateTracker(tracker, category: "Важное")
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc private func textFieldDidChange() {
        trackerName = nameTextField.text ?? ""
        updateCreateButtonState()
    }
    
    // MARK: - Helpers
    private func updateCreateButtonState() {
        let isNameFilled = !trackerName.isEmpty
        let isScheduleFilled = !isHabit || !selectedSchedule.isEmpty
        
        let isEnabled = isNameFilled && isScheduleFilled
        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled ? .trBlack : .trGray
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension TrackerCreationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableOptions.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let option = tableOptions[indexPath.row]
        
        cell.textLabel?.text = option
        cell.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.3)
        cell.accessoryType = .disclosureIndicator
        
        if option == "Расписание" {
            var detailText = ""
            if selectedSchedule.count == 7 {
                detailText = "Каждый день"
            } else if !selectedSchedule.isEmpty {
                detailText = "\(selectedSchedule.count) дн."
            }
            cell.detailTextLabel?.text = detailText
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selection = tableOptions[indexPath.row]
        
        if selection == "Расписание" {
            let vc = ScheduleViewController(selectedDays: selectedSchedule)
            vc.delegate = self
            present(vc, animated: true)
        } else if selection == "Категория" {
            // Functionality for "Category" is a placeholder
        }
    }
}

// MARK: - ScheduleViewControllerDelegate
extension TrackerCreationViewController: ScheduleViewControllerDelegate {
    func didSelectDays(_ days: [WeekDay]) {
        self.selectedSchedule = days
        updateCreateButtonState()
        tableView.reloadData()
    }
}

// MARK: - UITextFieldDelegate
extension TrackerCreationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
