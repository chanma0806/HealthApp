//
//  DashboardUsecaseService.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/11/05.
//

import Foundation
import PromiseKit

let MAX_HEART_RATE: Int = 200
let MIN_HEART_RATE: Int = 0

let MAX_STEPS: Int = 5000
let MIN_STEPS: Int = 0

let MAX_CALORIE: Int = 1000
let MIN_CALORIE: Int = 0

#if DEBUG

class DashboardUsecaseFactory {
    static func getTestableInstance(health: HealthCareComponentProtocol) -> DashboardUsecaseService {
        return DashboardUsecaseService(health: health)
    }
}

#endif


/**
  ダッシュボード画面のユースケース
 */
class DashboardUsecaseService {
    let healthComponet: HealthCareComponentProtocol
    
    init() {
        self.healthComponet = HealthCareComponentService.share
    }
    
    fileprivate init(health: HealthCareComponentProtocol) {
        self.healthComponet = health
    }
    
    func requestHealthAccess() -> Promise<Void> {
        self.healthComponet.requestAuthorization()
    }
    
    func getHeartRate(on date: Date) -> Promise<DayHeartrRateDto> {
        let promise = Promise<DayHeartrRateDto> { seal in
            self.healthComponet.getHeartRates(from: date, to: date)
            .done { (enities: [DayHeartrRateDto]) in
                guard enities.count != 0 else {
                    let zeroEntity = DayHeartrRateDto(date: date, values: [0])
                    seal.fulfill(zeroEntity)
                    return
                }

                // バリデーション後に返却
                let values = enities[0].values.validated(max: MAX_HEART_RATE, min: MIN_HEART_RATE)
                let entity = DayHeartrRateDto(date: enities[0].date, values: values)
                seal.fulfill(entity)
            }
            .catch { error in
                seal.reject(error)
            }
        }

        return promise
    }
    
    func getStep(on date: Date) -> Promise<DayStepDto> {
        let promise = Promise<DayStepDto> { seal in
            self.healthComponet.getSteps(from: date, to: date)
            .done { (enities: [DayStepDto]) in
                guard enities.count != 0 else {
                    let zeroEntity = DayStepDto(date: date, values: [0])
                    seal.fulfill(zeroEntity)
                    return
                }

                // バリデーション後に返却
                let values = enities[0].values.validated(max: MAX_STEPS, min: MIN_STEPS)
                let entity = DayStepDto(date: enities[0].date, values: values)
                seal.fulfill(entity)
            }
            .catch { error in
                seal.reject(error)
            }
        }

        return promise
    }
    
    func getBurnCalorie(on date: Date) -> Promise<DayBurnCalorieDto> {
        let promise = Promise<DayBurnCalorieDto> { seal in
            when(fulfilled: self.healthComponet.getSteps(from: date, to: date),
                 self.healthComponet.getBurnCalories(from: date, to: date))
                .done { (stepEnties: [DayStepDto] , calorieEnties: [DayBurnCalorieDto]) in
                var calories = calorieEnties.count > 0 ? calorieEnties[0].values : [Int](repeating: 0, count: 24)
                let steps = stepEnties.count > 0 ? stepEnties[0].values : []
                /** カロリー値がない時間帯は歩数から算出  */
                for (index, step) in zip(steps.indices, steps) {
                    if calories[index] < 1 {
                        calories[index] = self.calcStepCalorie(step: step)
                    }
                }
                
                // バリデーション
                calories = calories.validated(max: MAX_CALORIE, min: MIN_CALORIE)
                let entity = DayBurnCalorieDto(date: date, values: calories)

                seal.fulfill(entity)
            }
            .catch { error in
                seal.reject(error)
            }
        }
        
        return promise
    }
    
    private func calcStepCalorie(step: Int) -> Int {
        // TODO: 身長、体重設定
        let height = 170
        let weight = 65
        let strideCM: Float = Float(height) * 0.45
        let mets: Float = 3.0
        let speendMinMeter: Float = 67.0
        let stepDurationMin: Float = strideCM * Float(step) / ( speendMinMeter * 100.0 )
        
        // 運動量 = メッツ * 時間
        let exercise = mets * (stepDurationMin / 60)
        
        let calorie = 1.05 * exercise * Float(weight)
        
        return Int(calorie)
    }
}

extension Array where Element == Int {
    func validated(max: Int, min: Int) -> [Int] {
        let result = self.map { (element: Int) -> Int  in
            if (element >= max) {
                return max
            }
            if (element <= min) {
                return min
            }
            
            return element
        }
        
        return result
    }
}
