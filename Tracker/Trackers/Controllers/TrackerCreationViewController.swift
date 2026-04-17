//
//  TrackerCreationViewController.swift
//  Tracker
//
//  Created by Анастасия Федотова on 13.04.2026.
//

import UIKit

final class TrackerCreationViewController: UIViewController {
    enum Mode {
        case create
        case edit(original: Tracker, category: String)
    }
    
    // MARK: - Delegate
    weak var delegate: TrackerCreationDelegate?
    
    // MARK: - Properties
    private let isHabit: Bool
    private let mode: Mode
    private var trackerName: String = ""
    private var selectedCategory: String?
    private var selectedSchedule: [WeekDay] = []
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private var didApplyInitialSelections = false
    
    private let tableOptions: [String]
    private let emojis = MockData.emojis
    private let colors = UIColor.trSelections
    
    // MARK: - UI Elements
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    } ()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = screenTitle
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .trBlack
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.3)
        textField.layer.cornerRadius = Resources.Constants.cornerRadius
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        textField.text = trackerName
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: Resources.Constants.defaultPadding, height: Resources.Constants.cellHeight))
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
        table.layer.cornerRadius = Resources.Constants.cornerRadius
        table.isScrollEnabled = false
        table.separatorInset = UIEdgeInsets(top: 0, left: Resources.Constants.defaultPadding, bottom: 0, right: Resources.Constants.defaultPadding)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.identifier)
        collection.register(TrackerCategoryHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerCategoryHeader.identifier)
        collection.delegate = self
        collection.dataSource = self
        collection.isScrollEnabled = false
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .clear
        return collection
    }()
    
    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.identifier)
        collection.register(TrackerCategoryHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerCategoryHeader.identifier)
        collection.delegate = self
        collection.dataSource = self
        collection.isScrollEnabled = false
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .clear
        return collection
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.trRed, for: .normal)
        button.layer.cornerRadius = Resources.Constants.cornerRadius
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.trRed.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(actionButtonTitle, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.trWhite, for: .normal)
        button.backgroundColor = .trGray 
        button.layer.cornerRadius = Resources.Constants.cornerRadius
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
    init(isHabit: Bool, mode: Mode = .create) {
        self.isHabit = isHabit
        self.mode = mode
        self.tableOptions = isHabit ? ["Категория", "Расписание"] : ["Категория"]

        switch mode {
        case .create:
            break
        case .edit(let tracker, let category):
            self.trackerName = tracker.name
            self.selectedCategory = category
            self.selectedSchedule = tracker.schedule
            self.selectedEmoji = tracker.emoji
            self.selectedColor = tracker.color
        }

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
        updateCreateButtonState()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyInitialSelectionsIfNeeded()
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(nameTextField)
        contentView.addSubview(tableView)
        contentView.addSubview(emojiCollectionView)
        contentView.addSubview(colorCollectionView)
        contentView.addSubview(buttonStackView)
        
        let tableHeight: CGFloat = CGFloat(tableOptions.count) * Resources.Constants.cellHeight
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Resources.Constants.extraLargePadding),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Resources.Constants.defaultPadding),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Resources.Constants.defaultPadding),
            nameTextField.heightAnchor.constraint(equalToConstant: Resources.Constants.cellHeight),
            
            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: Resources.Constants.extraLargePadding),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Resources.Constants.defaultPadding),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Resources.Constants.defaultPadding),
            tableView.heightAnchor.constraint(equalToConstant: tableHeight),
            
            emojiCollectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            colorCollectionView.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: Resources.Constants.defaultPadding),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            buttonStackView.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: Resources.Constants.defaultPadding),
            buttonStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Resources.Constants.largePadding),
            buttonStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Resources.Constants.largePadding),
            buttonStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Resources.Constants.defaultPadding),
            buttonStackView.heightAnchor.constraint(equalToConstant: Resources.Constants.buttonHeight)
        ])
    }
    
    // MARK: - Actions
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createTapped() {
        guard let emoji = selectedEmoji, let color = selectedColor, let category = selectedCategory else { return }
        let normalizedName = trackerName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedName.isEmpty else { return }
        
        let scheduleToSave: [WeekDay] = isHabit ? selectedSchedule : WeekDay.allCases
        
        let tracker: Tracker

        switch mode {
        case .create:
            tracker = Tracker(id: UUID(), name: normalizedName, color: color, emoji: emoji, schedule: scheduleToSave, isPinned: false)
            delegate?.didCreateTracker(tracker, category: category)
        case .edit(let original, _):
            tracker = Tracker(
                id: original.id,
                name: normalizedName,
                color: color,
                emoji: emoji,
                schedule: scheduleToSave,
                isPinned: original.isPinned
            )
            delegate?.didUpdateTracker(tracker, category: category)
        }
    }
    
    @objc private func textFieldDidChange() {
        trackerName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        updateCreateButtonState()
    }
    
    // MARK: - Helpers
    private func updateCreateButtonState() {
        let isNameFilled = !trackerName.isEmpty
        let isCategorySelected = selectedCategory != nil
        let isScheduleFilled = !isHabit || !selectedSchedule.isEmpty
        let isEmojiSelected = selectedEmoji != nil
        let isColorSelected = selectedColor != nil
        
        let isEnabled = isNameFilled && isCategorySelected && isScheduleFilled && isEmojiSelected && isColorSelected
        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled ? .trBlack : .trGray
    }

    private var screenTitle: String {
        switch mode {
        case .create:
            return isHabit ? "Новая привычка" : "Новое нерегулярное событие"
        case .edit:
            return "Редактирование трекера"
        }
    }

    private var actionButtonTitle: String {
        switch mode {
        case .create:
            return "Создать"
        case .edit:
            return "Сохранить"
        }
    }

    private func applyInitialSelectionsIfNeeded() {
        guard !didApplyInitialSelections else { return }
        didApplyInitialSelections = true

        if let selectedEmoji, let emojiIndex = emojis.firstIndex(of: selectedEmoji) {
            let indexPath = IndexPath(item: emojiIndex, section: 0)
            emojiCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }

        if let selectedColor, let colorIndex = colors.firstIndex(where: { $0.isEqual(selectedColor) }) {
            let indexPath = IndexPath(item: colorIndex, section: 0)
            colorCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
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
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let option = tableOptions[indexPath.row]
        
        cell.textLabel?.text = option
        cell.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.3)
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        
        if option == "Категория" {
            cell.detailTextLabel?.text = selectedCategory
            cell.detailTextLabel?.textColor = .trGray
        } else if option == "Расписание" {
            var detailText = ""
            if selectedSchedule.count == 7 {
                detailText = "Каждый день"
            } else if !selectedSchedule.isEmpty {
                let order: [WeekDay] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
                let sorted = selectedSchedule.sorted { 
                    (order.firstIndex(of: $0) ?? 0) < (order.firstIndex(of: $1) ?? 0)
                }
                detailText = sorted.map { $0.shortTitle }.joined(separator: ", ")
            }
            cell.detailTextLabel?.text = detailText
            cell.detailTextLabel?.textColor = .trGray
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selection = tableOptions[indexPath.row]
        
        if selection == "Категория" {
            let vc = CategoryViewController(selectedCategory: selectedCategory)
            vc.delegate = self
            present(vc, animated: true)
        } else if selection == "Расписание" {
            let vc = ScheduleViewController(selectedDays: selectedSchedule)
            vc.delegate = self
            present(vc, animated: true)
        }
    }
}

// MARK: - CategoryViewControllerDelegate
extension TrackerCreationViewController: CategoryViewControllerDelegate {
    func didSelectCategory(_ category: String) {
        self.selectedCategory = category
        updateCreateButtonState()
        tableView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate
extension TrackerCreationViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == emojiCollectionView ? emojis.count : colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.identifier, for: indexPath) as? EmojiCell else { return UICollectionViewCell() }
            cell.configure(with: emojis[indexPath.row])
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.identifier, for: indexPath) as? ColorCell else { return UICollectionViewCell() }
            cell.configure(with: colors[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            selectedEmoji = emojis[indexPath.row]
        } else {
            selectedColor = colors[indexPath.row]
        }
        updateCreateButtonState()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            selectedEmoji = nil
        } else {
            selectedColor = nil
        }
        updateCreateButtonState()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerCategoryHeader.identifier, for: indexPath) as? TrackerCategoryHeader else { return UICollectionReusableView() }
        header.titleLabel.text = collectionView == emojiCollectionView ? "Emoji" : "Цвет"
        header.titleLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
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
