//
//  SettingsViewController.swift
//  ToDoList
//
//  Created by user on 21.02.2026.
//

import UIKit

/// UIKit Settings screen with MVVM. Handles appearance (light / dark / system).
final class SettingsViewController: UIViewController {

    private let viewModel: SettingsViewViewModel
    private var tableView: UITableView!

    private enum Section: Int, CaseIterable {
        case appearance
    }

    private enum AppearanceRow: Int, CaseIterable {
        case system
        case light
        case dark

        var title: String {
            switch self {
                case .system: return "System"
                case .light: return "Light"
                case .dark: return "Dark"
            }
        }

        var style: UIUserInterfaceStyle {
            switch self {
                case .system: return .unspecified
                case .light: return .light
                case .dark: return .dark
            }
        }
    }

    init(viewModel: SettingsViewViewModel = SettingsViewViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.viewModel = SettingsViewViewModel()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemBackground

        setupTableView()
        viewModel.onAppearanceChanged = { [weak self] in
            self?.tableView.reloadData()
        }
    }

    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
    }
}

// MARK: - UITableViewDataSource

extension SettingsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard Section(rawValue: section) == .appearance else { return 0 }
        return AppearanceRow.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        guard let row = AppearanceRow(rawValue: indexPath.row) else { return cell }
        cell.textLabel?.text = row.title
        cell.accessoryType = viewModel.selectedAppearance == row.style ? .checkmark : .none
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard Section(rawValue: section) == .appearance else { return nil }
        return "Appearance"
    }
}

// MARK: - UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let row = AppearanceRow(rawValue: indexPath.row) else { return }
        viewModel.selectedAppearance = row.style
    }
}
