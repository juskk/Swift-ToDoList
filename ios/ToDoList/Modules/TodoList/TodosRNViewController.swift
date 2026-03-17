//
//  TodosRNViewController.swift
//  ToDoList
//
//  VIPER – View (React Native host)
//  Wraps a React Native root view in a UIViewController.
//  Also listens for the "TodosOpenNewItem" notification posted by
//  TodosNativeModule.m when the RN FAB is tapped, and presents the
//  Swift NewItem sheet in response.
//

import UIKit
import SwiftUI

final class TodosRNViewController: UIViewController {

    private let userId: String

    init(userId: String) {
        self.userId = userId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("Use init(userId:)") }

    override func viewDidLoad() {
        super.viewDidLoad()

        // ── 1. Factory guard ────────────────────────────────────────────────
        guard RNBridge.shared.isReady else {
            showFallback("React Native factory not initialised.\nRun pod install and rebuild.")
            return
        }

        // ── 2. Create the RN root view ──────────────────────────────────────
        let rnView = RNBridge.shared.createView(
            moduleName: "TodosScreen",
            initialProperties: ["userId": userId]
        )
        rnView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rnView)
        NSLayoutConstraint.activate([
            rnView.topAnchor.constraint(equalTo: view.topAnchor),
            rnView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rnView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rnView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        // ── 3. Listen for "open new item" from the RN FAB ───────────────────
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(presentNewItem),
            name: NSNotification.Name("TodosOpenNewItem"),
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func presentNewItem() {
        let newItemView = NewItemRouter.createModule()
        let hostingVC = UIHostingController(rootView: newItemView)
        hostingVC.modalPresentationStyle = .pageSheet
        if let sheet = hostingVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        present(hostingVC, animated: true)
    }

    private func showFallback(_ message: String) {
        let label = UILabel()
        label.text = message
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
        ])
    }
}

struct TodosRNView: UIViewControllerRepresentable {
    let userId: String

    func makeUIViewController(context: Context) -> TodosRNViewController {
        TodosRNViewController(userId: userId)
    }

    func updateUIViewController(_ uiViewController: TodosRNViewController, context: Context) {}
}
