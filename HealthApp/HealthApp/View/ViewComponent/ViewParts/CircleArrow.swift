//
//  CircleArrow.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/11/01.
//

import SwiftUI

struct CircleArrow: View {
    let size: CGFloat
    let color: Color
    init (size: CGFloat, color: Color) {
        self.size = size
        self.color = color
    }
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.25, to: 1)
                .stroke(self.color, style: StrokeStyle(lineWidth: size*0.2))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(90))
            Triangle(size: size*0.6, color: self.color)
                .rotationEffect(.degrees(180))
                .position(x: size*0.4, y: size)
        }
        .frame(width: size, height: size)
    }
}

struct CircleArrow_Previews: PreviewProvider {
    static var previews: some View {
        CircleArrow(size: 300, color: Color.gray)

    }
}
