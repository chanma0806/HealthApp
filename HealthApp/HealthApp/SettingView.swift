//
//  SettingView.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/11/30.
//

import SwiftUI
import UIKit
import PromiseKit

let STR_TARGET_STEP = "1日の歩数目標"
let targetStep = 10000
let STR_SYNC_HEALTH = "ヘルスケア連携"
let STR_SECTION_SETTING = "項目"
let STR_SETTING_FINISH = "完了"
let SETTING_TITLE = "設定"

let MAX_TARGET_STEP = 50000
let MIN_TARGET_STEP = 1000

let TARGET_STEP_CHANGE_RANGE = 500

struct SettingView: View {
    
    enum ButtonType: Int {
        case Plus
        case Minus
    }
    
    @EnvironmentObject var setting: SettingData
    @Environment(\.presentationMode) var presentation
    @State var targetStepValue: Int = 0
    
    let settingUsecase = SettingUsecaseServicce()
        
    var body: some View {
        GeometryReader { geo in
            List {
                Section(header: Text(STR_TARGET_STEP), content: {
                    HStack {
                        Button(action: {
                            tappedTargetEditAction(.Plus)
                        }, label: {
                            ZStack {
                                Circle()
                                    .fill()
                                    .frame(width: 45, height: 45)
                                    .foregroundColor(.gray)
                                Text("+")
                                    .bold()
                                    .font(.system(size: 35.0))
                            }
                        })
                        .buttonStyle(BorderlessButtonStyle())
                        
                        Text("\(self.targetStepValue)")
                            .bold()
                            .font(.system(size: 40.0))
                            .frame(width: 200, height: 30, alignment: .center)
                        
                        Button(action: {
                            tappedTargetEditAction(.Minus)
                        }, label: {
                            ZStack {
                                Circle()
                                    .fill()
                                    .frame(width: 45, height: 45)
                                    .foregroundColor(.gray)
                                Text("-")
                                    .bold()
                                    .font(.system(size: 35.0))
                            }
                        })
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    .frame(width: geo.size.width, height: 100, alignment: .center)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                })
                Section(header: Text(STR_SECTION_SETTING), content: {
                    Toggle(isOn: .constant(true), label: {
                        Text(STR_SYNC_HEALTH)
                    })
                })
            }
            .background(dashbordBackColor)
            .onAppear {
                self.targetStepValue = setting.goalValue
            }
            .navigationBarBackButtonHidden(true)
            /** クローズボタン */
            .navigationBarItems(leading: Button(STR_SETTING_FINISH, action: {
                _ = self.tappedCloseView()
                .done { _ in
                    presentation.wrappedValue.dismiss()
                }
            }))
            .navigationBarTitle(Text(SETTING_TITLE), displayMode: .inline)
        }
    }
    
    // 退場処理
    func tappedCloseView() -> Promise<Void> {
        /** 非同期処理の追加を考慮してPromiseでラップ */
        let promise = Promise<Void> { seal in
            let target = TargetSettingData(step: self.targetStepValue)
            self.settingUsecase.setTargteSetting(target)
            seal.fulfill(())
        }
        
        return promise
    }
    
    private func tappedTargetEditAction(_ buttonType: ButtonType) {
        switch buttonType {
        case .Plus:
            guard targetStepValue < MAX_TARGET_STEP else {
                return
            }
            targetStepValue += TARGET_STEP_CHANGE_RANGE
        case .Minus:
            guard targetStepValue > MIN_TARGET_STEP else {
                return
            }
            
            targetStepValue += -TARGET_STEP_CHANGE_RANGE
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var setting: SettingData {
        get {
            let setting = SettingData()
            setting.goalValue = 9000
            return setting
        }
    }
    
    static var previews: some View {
        
        SettingView().environmentObject(SettingView_Previews.setting)
    }
}
