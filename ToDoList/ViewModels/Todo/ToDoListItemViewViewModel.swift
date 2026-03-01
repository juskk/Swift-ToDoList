//
//  ToDoListItemViewViewModel.swift
//  ToDoList
//
//  Created by user on 21.02.2026.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class ToDoListItemViewViewModel: ObservableObject {
    init() {}
    
    func toggleIsDone(item: ToDoListItem) {
        let newIsDone = !item.isDone

        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }

        let db = Firestore.firestore()
        db.collection("users")
            .document(userId)
            .collection("todos")
            .document(item.id)
            .updateData(["isDone": newIsDone])
    }
}
