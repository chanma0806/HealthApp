//
//  SyncButton.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/11/01.
//

import SwiftUI

/**
   同期ボタン
 */
public struct SyncButton: View {
    let size: CGFloat
    let action: ()->Void
    init (size: CGFloat, action: @escaping ()->Void) {
        self.size = size
        self.action = action
    }
    public var body: some View {
        Button(action: {
            print("tappefd")
            self.action()
        }, label: {
            ZStack(alignment:.center , content: {
                Circle()
                    .fill(pinkGradient)
                    .frame(width: size, height: size, alignment: .center)
                    .shadow(radius: 5)
                CircleArrow(size: size*0.6, color: .white)
            })
        })
    }
}

struct SyncButton_Previews: PreviewProvider {
    static var previews: some View {
        SyncButton(size: 200.0, action: {})
    }
}
