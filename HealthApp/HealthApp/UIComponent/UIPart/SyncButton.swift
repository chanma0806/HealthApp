//
//  SyncButton.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/11/01.
//

import SwiftUI

struct SyncButton: View {
    let size: CGFloat
    init (size: CGFloat) {
        self.size = size
    }
    var body: some View {
        ZStack(alignment:.center , content: {
            Circle()
                .fill(pinkGradient)
                .frame(width: size, height: size, alignment: .center)
                .shadow(radius: 5)
            CircleArrow(size: size*0.6, color: .white)
        })
    }
}

struct SyncButton_Previews: PreviewProvider {
    static var previews: some View {
        SyncButton(size: 200.0)
    }
}
