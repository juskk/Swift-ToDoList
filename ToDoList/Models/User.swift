//
//  User.swift
//  ToDoList
//
//  Created by user on 21.02.2026.
//

import Foundation

struct User: Codable {
    let id: String;
    let name: String;
    let email: String;
    let joined: TimeInterval;
}
