//
//  TodoListInteractor.swift
//  ToDoList
//
//  VIPER – Interactor
//  Owns the Firestore real-time listener and all todo mutations.
//  Replaces the @FirestoreQuery (SwiftUI property wrapper) that was
//  previously in the View — data-fetching is now properly in the Interactor.
//  Also absorbs the old ToDoListItemViewViewModel toggle logic.
//

import FirebaseFirestore
import Foundation

protocol TodoListInteractorOutput: AnyObject {
    func itemsDidUpdate(_ items: [ToDoListItem])
    func deleteDidFail(message: String)
    func toggleDidFail(message: String)
}

protocol TodoListInteractorProtocol: AnyObject {
    var output: TodoListInteractorOutput? { get set }
    func startObserving(userId: String)
    func delete(id: String)
    func toggleDone(item: ToDoListItem)
}

final class TodoListInteractor: TodoListInteractorProtocol {
    weak var output: TodoListInteractorOutput?

    private var userId: String = ""
    private var listener: ListenerRegistration?

    func startObserving(userId: String) {
        self.userId = userId

        listener = Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("todos")
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                let items: [ToDoListItem] = documents.compactMap { doc in
                    let data = doc.data()
                    guard
                        let id = data["id"] as? String,
                        let title = data["title"] as? String,
                        let dueDate = data["dueDate"] as? TimeInterval,
                        let createdDate = data["createdDate"] as? TimeInterval,
                        let isDone = data["isDone"] as? Bool
                    else { return nil }
                    return ToDoListItem(
                        id: id,
                        title: title,
                        dueDate: dueDate,
                        createdDate: createdDate,
                        isDone: isDone
                    )
                }
                DispatchQueue.main.async {
                    self?.output?.itemsDidUpdate(items)
                }
            }
    }

    func delete(id: String) {
        Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("todos")
            .document(id)
            .delete { [weak self] error in
                if let error {
                    DispatchQueue.main.async {
                        self?.output?.deleteDidFail(message: error.localizedDescription)
                    }
                }
            }
    }

    func toggleDone(item: ToDoListItem) {
        Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("todos")
            .document(item.id)
            .updateData(["isDone": !item.isDone]) { [weak self] error in
                if let error {
                    DispatchQueue.main.async {
                        self?.output?.toggleDidFail(message: error.localizedDescription)
                    }
                }
            }
    }

    deinit {
        listener?.remove()
    }
}
