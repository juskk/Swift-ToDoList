//
//  TodosRNViewController.swift  (can be renamed TodosRNView.swift)
//  ToDoList
//
//  VIPER – View (React Native host)
//  Pure SwiftUI view that hosts the React Native Todos screen.
//
//  UIViewRepresentable is the only UIKit seam: RN's factory always returns
//  a UIView, so a thin bridge is unavoidable. Everything else — the sheet,
//  fallback state, and notification lifecycle — is handled by SwiftUI.
//

import SwiftUI

// ─── Public SwiftUI view (entry point used by TodoListRouter) ──────────────

struct TodosRNView: View {
    let userId: String

    @State private var showNewItem = false

    var body: some View {
        Group {
            if RNBridge.shared.isReady {
                RNViewBridge(userId: userId, onOpenNewItem: { showNewItem = true })
                    .ignoresSafeArea()
            } else {
                Text("React Native not initialised.\nRun pod install and rebuild.")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 15))
                    .multilineTextAlignment(.center)
                    .padding(24)
            }
        }
        .sheet(isPresented: $showNewItem) {
            NewItemRouter.createModule()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}

// ─── Private UIViewRepresentable bridge ────────────────────────────────────
//
// Sole UIKit seam: wraps the UIView returned by RN's root view factory.
// The Coordinator owns the NSNotificationCenter observer lifetime so the
// subscription is cleaned up automatically when the view is dismantled.

private struct RNViewBridge: UIViewRepresentable {
    let userId: String
    let onOpenNewItem: () -> Void

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> UIView {
        context.coordinator.onOpenNewItem = onOpenNewItem
        context.coordinator.startObserving()
        return RNBridge.shared.createView(
            moduleName: "TodosScreen",
            initialProperties: ["userId": userId]
        )
    }

    // Keep the closure current across SwiftUI re-renders.
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.onOpenNewItem = onOpenNewItem
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.stopObserving()
    }

    // ── Coordinator ─────────────────────────────────────────────────────────

    final class Coordinator {
        var onOpenNewItem: (() -> Void)?
        private var observer: NSObjectProtocol?

        func startObserving() {
            observer = NotificationCenter.default.addObserver(
                forName: NSNotification.Name("TodosOpenNewItem"),
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.onOpenNewItem?()
            }
        }

        func stopObserving() {
            if let observer {
                NotificationCenter.default.removeObserver(observer)
                self.observer = nil
            }
        }

        deinit { stopObserving() }
    }
}
