//
//  TLButton.swift
//  ToDoList
//
//  Created by user on 21.02.2026.
//

import SwiftUI

struct TLButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        VStack {
            Button {
                action()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(color)
                    Text(title)
                        .foregroundColor(Color.white)
                        .bold()
                }
            }
        }
    }
}

#Preview {
    TLButton(title: "Title", color: Color.blue, action: {})
}
