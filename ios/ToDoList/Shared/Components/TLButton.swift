//
//  TLButton.swift
//  ToDoList
//
//  Shared reusable UI component. No business logic.
//

import SwiftUI

struct TLButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(color)
                Text(title)
                    .foregroundColor(.white)
                    .bold()
            }
        }
    }
}

#Preview {
    TLButton(title: "Save", color: .blue, action: {})
}
