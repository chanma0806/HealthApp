//
//  DatastoreComponentProtocol.swift
//  meters
//
//  Created by 丸山大幸 on 2021/01/18.
//

import Foundation

/**
　DBコンポーネント
 */
protocol DatabaseComponentProtocol {
    /**
    　指定範囲の歩数データを取得する
     　　
     - Parameters:
        - from: 範囲開始日
        - to: 範囲終了日
     */
    func getStepDatas(from: Date, to: Date) -> [DailyStepData]
    
    /**
     歩数を保存する

     - Parameter entity: 歩数データ
     
     */
    func setStepData(_ entity: DailyStepData)
        
    /**
    　目標設定を取得する
     */
    func getTargetSettingData() -> TargetSettingData?
    
    
    /**
     目標設定を保存する
     
     - Parameter targetSettingData: 目標設定
     */
    func setTargetSettingData(_ targetSettingData: TargetSettingData)
}
