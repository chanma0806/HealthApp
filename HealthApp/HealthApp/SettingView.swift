//
//  SettingView.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/11/30.
//

import SwiftUI

let STR_TARGET_STEP = "1日の歩数目標"
let targetStep = 10000
let STR_SYNC_HEALTH = "ヘルスケア連携"

struct SettingView: View {
    var body: some View {
        GeometryReader { geo in
            List {
                Section(header: Text(STR_TARGET_STEP), content: {
                    HStack {
                        ZStack {
                            Circle()
                                .fill()
                                .frame(width: 45, height: 45)
                                .foregroundColor(.gray)
                            Text("+")
                                .bold()
                                .font(.system(size: 35.0))
                        }
                        
                        Text("\(targetStep)")
                            .bold()
                            .font(.system(size: 40.0))
                            .frame(width: 200, height: 30, alignment: .center)
                        
                        ZStack {
                            Circle()
                                .fill()
                                .frame(width: 45, height: 45)
                                .foregroundColor(.gray)
                            Text("-")
                                .bold()
                                .font(.system(size: 35.0))
                        }
                    }
                    .frame(width: geo.size.width, height: 100/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                })
                Section(header: Text("項目"), content: {
                    Toggle(isOn: .constant(true), label: {
                        Text(STR_SYNC_HEALTH)
                    })
                })
            }
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
