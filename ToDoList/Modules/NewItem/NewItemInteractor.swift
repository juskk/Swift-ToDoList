//
//  NewItemInteractor.swift
//  ToDoList
//
//  VIPER – Interactor
//  Only place that touches FirebaseAuth and Firestore for the NewItem feature.
//  Builds the ToDoListItem entity and persists it.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

protocol NewItemInteractorOutput: AnyObject {
    func saveDidSucceed()
    func saveDidFail(message: String)
}

protocol NewItemInteractorProtocol: AnyObject {
    var output: NewItemInteractorOutput? { get set }
    func save(title: String, dueDate: Date)
}

final class NewItemInteractor: NewItemInteractorProtocol {
    weak var output: NewItemInteractorOutput?

    func save(title: String, dueDate: Date) {
        guard let userId = Auth.auth().currentUser?.uid else {
            output?.saveDidFail(message: "You must be signed in to add items.")
            return
        }

        let id = UUID().uuidString
        let item = ToDoListItem(
            id: id,
            title: title,
            dueDate: dueDate.timeIntervalSince1970,
            createdDate: Date().timeIntervalSince1970,
            isDone: false
        )

        Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("todos")
            .document(id)
            .setData(item.asDictionary()) { [weak self] error in
                DispatchQueue.main.async {
                    if let error {
                        self?.output?.saveDidFail(message: error.localizedDescription)
                    } else {
                        self?.output?.saveDidSucceed()
                    }
                }
            }
    }
}
