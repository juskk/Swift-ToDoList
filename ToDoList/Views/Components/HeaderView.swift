//
//  HeaderView.swift
//  ToDoList
//
//  Created by user on 21.02.2026.
//

import SwiftUI

struct HeaderView: View {
    let title: String
    let subTitle: String
    let angle: Double
    let backgroundColor: Color

    private let headerHeight: CGFloat = 225

    private var totalHeight: CGFloat {
        let w = UIScreen.main.bounds.width
        let bottomDrop = abs(w * CGFloat(tan(angle * .pi / 180)))
        return headerHeight + bottomDrop
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let slant = w * CGFloat(tan(angle * .pi / 180))
            let bottomDrop = abs(slant)
            let slantRight = angle >= 0

            ZStack(alignment: .top) {
                AngledBandShape(height: headerHeight, bottomSlant: bottomDrop, slantRight: slantRight)
                    .fill(backgroundColor)

                VStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                        .bold()
                    Text(subTitle)
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
                .padding(.top, 100)
            }
            .frame(width: w, height: headerHeight + bottomDrop)
        }
        .frame(height: totalHeight)
        .ignoresSafeArea(edges: .top)
    }
}

private struct AngledBandShape: Shape {
    var height: CGFloat
    var bottomSlant: CGFloat
    var slantRight: Bool

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let drop = abs(bottomSlant)
        p.move(to: CGPoint(x: 0, y: 0))
        p.addLine(to: CGPoint(x: w, y: 0))
        if slantRight {
            p.addLine(to: CGPoint(x: w, y: height + drop))
            p.addLine(to: CGPoint(x: 0, y: height))
        } else {
            p.addLine(to: CGPoint(x: w, y: height))
            p.addLine(to: CGPoint(x: 0, y: height + drop))
        }
        p.closeSubpath()
        return p
    }
}

#Preview {
    HeaderView(title: "To Do List", subTitle: "Get Things Done", angle: 15, backgroundColor: .pink)
}
