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

let DID_SHOW_INTRODUCTION_KEY = "did_show_introduction"

class SettingUsecaseServicce {
    private let database: DatabaseComponent
    private var health: HealthCareComponent
    
    init () {
        self.database = DatabaseComponent()
        self.health = HealthCareComponentService.share
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
    
    /**
     アプリの設定情報を取得する
     */
    func getSettingData() -> SettingData {
        let needShowGuidance = !self.didShowGuidance()
        let stepTarget = self.getTargetSetting().stepTarget
        let setting = SettingData(neeedShowGuidance: needShowGuidance)
        setting.goalValue = stepTarget
        
        return setting
    }
    
    /**
     ヘルスケア連携が有効か
     */
    func healthCooperationEnabled() -> Bool {
        self.health.isCooperation
    }
    
    /**
     ヘルスケア連携の設定値を保存する
     */
    func setHealthCooperation(enabled: Bool) {
        self.health.isCooperation = enabled
    }
    
    /**
     初回ガイダンスを表示したか？
     */
    func didShowGuidance() -> Bool {
        UserDefaults().bool(forKey: DID_SHOW_INTRODUCTION_KEY)
    }
    
    /**
     初回ガイダンス表示済みを保存する
     */
    func setDidShowGuidance() {
        UserDefaults().set(true, forKey: DID_SHOW_INTRODUCTION_KEY)
    }
}
