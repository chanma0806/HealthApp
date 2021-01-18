//
//  HealthCareComponentProtocol.swift
//  meters
//
//  Created by 丸山大幸 on 2021/01/18.
//

import Foundation
import PromiseKit

/**ヘルスケアコンポーネントエラー*/
enum HealthComponentError: Error {
    case notCoopreationEnabled
}

/** ヘルスケア DTO */
protocol HealthCareDto {
    var date: Date { get }
    var values: [Int]  { get }
}

/** ヘルスケア心拍データ */
public struct DayHeartrRateDto: HealthCareDto {
    let date: Date
    let values: [Int]
}

/** ヘルスケア歩数データ */
public struct DayStepDto: HealthCareDto {
    let date: Date
    let values: [Int]
}

/** ヘルスケア消費カロリーデータ */
public struct DayBurnCalorieDto: HealthCareDto {
    let date: Date
    let values: [Int]
}

/**
 ヘルスケアコンポーネント
 */
protocol HealthCareComponentProtocol {
    
    /**
    　ヘルケア連携が有効か
     */
    var isCooperation: Bool { get set }
    
    /**
     アクセス許可をリクエストする
     */
    func requestAuthorization() -> Promise<Void>
    
    /**
     心拍数を取得する
     */
    func getHeartRates(from: Date, to: Date) -> Promise<[DayHeartrRateDto]>
    
    /**
     歩数を取得する
     */
    func getSteps(from: Date, to: Date) -> Promise<[DayStepDto]>
    
    /**
     消費カロリーを取得する
     */
    func getBurnCalories(from: Date, to: Date) -> Promise<[DayBurnCalorieDto]>
    
}
