//
//  SettingsViewController.swift
//  ToDoList
//
//  VIPER – View (UIKit)
//  Pure UI. Conforms to SettingsViewProtocol so the Presenter can ask it
//  to reload. Calls Presenter methods for all user interactions.
//

import UIKit

final class SettingsViewController: UIViewController, SettingsViewProtocol {
    // MARK: - VIPER

    private let presenter: SettingsPresenterProtocol

    // MARK: - UI

    private var tableView: UITableView!

    // MARK: - Data

    private enum Section: Int, CaseIterable {
        case appearance
    }

    private enum AppearanceRow: Int, CaseIterable {
        case system, light, dark

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

    // MARK: - Init

    init(presenter: SettingsPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("Use init(presenter:)")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemBackground
        setupTableView()
    }

    // MARK: - SettingsViewProtocol

    func reloadData() {
        tableView.reloadData()
    }

    // MARK: - Private

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
    func numberOfSections(in _: UITableView) -> Int {
        Section.allCases.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard Section(rawValue: section) == .appearance else { return 0 }
        return AppearanceRow.allCases.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        guard let row = AppearanceRow(rawValue: indexPath.row) else { return cell }
        cell.textLabel?.text = row.title
        cell.accessoryType = presenter.selectedAppearance == row.style ? .checkmark : .none
        return cell
    }

    func tableView(_: UITableView,
                   titleForHeaderInSection section: Int) -> String?
    {
        guard Section(rawValue: section) == .appearance else { return nil }
        return "Appearance"
    }
}

// MARK: - UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let row = AppearanceRow(rawValue: indexPath.row) else { return }
        presenter.didSelectAppearance(row.style)
    }
}
