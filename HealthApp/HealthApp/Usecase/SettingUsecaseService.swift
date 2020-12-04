//
//  SettingUsecaseService.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/12/04.
//

import Foundation
import PromiseKit

/** 歩数目標初期値 */
let INITIAL_STEP_TARGET: Int = 10000

class SettingUsecaseServicce {
    private let database: DatabaseComponent
    
    init () {
        self.database = DatabaseComponent()
    }
    
    /**
   　 目標値を保存する
     */
    func setTargteSetting(_ target: TargetSettingData) {
        database.setTargetSettingData(target)
    }
    
    /**
     目標値を取得する
     */
    func getTargetSetting() -> TargetSettingData {
        let setting = database.getTargetSettingData()
        guard let settingContext = setting else {
            let initialSetting = TargetSettingData(step: INITIAL_STEP_TARGET)
            return initialSetting
        }
        
        return settingContext
    }
}
