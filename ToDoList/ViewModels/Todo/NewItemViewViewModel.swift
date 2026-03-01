//
//  NewItemViewViewModel.swift
//  ToDoList
//
//  Created by user on 21.02.2026.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class NewItemViewViewModel: ObservableObject {
    @Published var title = ""
    @Published var dueDate = Date()
    @Published var showAlert = false
    @Published var alertMessage = ""

    init() {}

    var validationMessage: String {
        if title.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Please enter a title."
        }
        if dueDate < Date().addingTimeInterval(-86400) {
            return "Due date must be today or in the future."
        }
        return ""
    }

    func save(completion: @escaping (Result<Void, Error>) -> Void) {
        guard canSave else {
            completion(.failure(NSError(domain: "ToDoList", code: 0, userInfo: [NSLocalizedDescriptionKey: validationMessage])))
            return
        }
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "ToDoList", code: 0, userInfo: [NSLocalizedDescriptionKey: "You must be signed in to add items."])))
            return
        }

        let newId = UUID().uuidString
        let newItem = ToDoListItem(
            id: newId,
            title: title,
            dueDate: dueDate.timeIntervalSince1970,
            createdDate: Date().timeIntervalSince1970,
            isDone: false
        )

        let db = Firestore.firestore()
        db.collection("users")
            .document(userId)
            .collection("todos")
            .document(newId)
            .setData(newItem.asDictionary()) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
    }

    var canSave: Bool {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }
        guard dueDate >= Date().addingTimeInterval(-86400) else {
            return false
        }
        return true
    }
}
