//
//  Triangle.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/10/31.
//

import SwiftUI

public struct Triangle: View {
    let size: CGFloat
    let color: Color
    init (size: CGFloat, color: Color) {
        self.size = size
        self.color = color
    }
    public var body: some View {
        ZStack {
            TrianglShape()
                .fill(color)
                .frame(width: size*0.8, height: size*0.8, alignment: .center)
        }
    }
}

struct TrianglShape: Shape {
    func path(in rect: CGRect) -> Path {
        let x = rect.width / 2
        let y = rect.height / 2
        let radius: CGFloat = rect.width/2
        
        let pos1 = CGPoint(x: x + radius, y: y)
        let pos2 = CGPoint(x: x - 0.5*radius, y: y + radius*0.5*sqrt(3.0))
        let pos3 = CGPoint(x: x - 0.5*radius, y: y - radius*0.5*sqrt(3.0))
        
        return Path { path in
            path.move(to: CGPoint(x:x, y:(y*0.5)*sqrt(3.0)/2))
            path.addArc(tangent1End: pos1, tangent2End: pos2, radius: radius/10)
            path.addArc(tangent1End: pos2, tangent2End: pos3, radius: radius/10)
            path.addArc(tangent1End: pos3, tangent2End: pos1, radius: radius/10)
            path.closeSubpath()
        }
    }
}

struct Triangle_Previews: PreviewProvider {
    static var previews: some View {
        Triangle(size: 300, color: Color.blue)
    }
}
