//
//  Arrow.swift
//  Meters
//
//  Created by 丸山大幸 on 2020/12/28.
//

import SwiftUI

struct Arrow: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            let width = rect.width
            let height = rect.height
            
            path.addLines([
                CGPoint(x: width * 0.4, y: height * 0.9),
                CGPoint(x: width * 0.4, y: height * 0.4),
                CGPoint(x: width * 0.25, y: height * 0.4),
                CGPoint(x: width * 0.5, y: height * 0.1),
                CGPoint(x: width * 0.75, y: height * 0.4),
                CGPoint(x: width * 0.6, y: height * 0.4),
                CGPoint(x: width * 0.6, y: height * 0.9),
            ])
            
            path.closeSubpath()
        }
    }
}

struct ArrowView_Previews: PreviewProvider {
    static var previews: some View {
        Arrow().fill()
            .rotationEffect(.degrees(90))
            .frame(width: 100, height: 100, alignment: .center)
    }
}
