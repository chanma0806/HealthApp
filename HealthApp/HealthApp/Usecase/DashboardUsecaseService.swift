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

class DashboardUsecaseService {
    let healthComponet: HealthCareComponent
    
    init() {
        self.healthComponet = HealthCareComponentService()
    }
    
    func requestHealthAccess() -> Promise<Void> {
        self.healthComponet.requestAuthorization()
    }
    
    func getHeartRate(on date: Date) -> Promise<DayHeartrRateEntity> {
        let promise = Promise<DayHeartrRateEntity> { seal in
            self.healthComponet.getHeartRates(from: date, to: date)
            .done { (enities: [DayHeartrRateEntity]) in
                guard enities.count != 0 else {
                    let zeroEntity = DayHeartrRateEntity(date: date, values: [0])
                    seal.fulfill(zeroEntity)
                    return
                }
                
                // バリデーション後に返却
                let values = enities[0].values.validated(max: MAX_HEART_RATE, min: MIN_HEART_RATE)
                let entity = DayHeartrRateEntity(date: enities[0].date, values: values)
                seal.fulfill(entity)
            }
            .catch { error in
                seal.reject(error)
            }
        }
        
        return promise
    }
    
    func getStep(on date: Date) -> Promise<DayStepEntity> {
        let promise = Promise<DayStepEntity> { seal in
            self.healthComponet.getSteps(from: date, to: date)
            .done { (enities: [DayStepEntity]) in
                guard enities.count != 0 else {
                    let zeroEntity = DayStepEntity(date: date, values: [0])
                    seal.fulfill(zeroEntity)
                    return
                }
                
                // バリデーション後に返却
                let values = enities[0].values.validated(max: MAX_STEPS, min: MIN_STEPS)
                let entity = DayStepEntity(date: enities[0].date, values: values)
                seal.fulfill(entity)
            }
            .catch { error in
                seal.reject(error)
            }
        }
        
        return promise
    }
    
    func getBurnCalorie(on date: Date) -> Promise<DayBurnCalorieEntity> {
        let promise = Promise<DayBurnCalorieEntity> { seal in
            when(fulfilled: self.healthComponet.getSteps(from: date, to: date),
                 self.healthComponet.getBurnCalories(from: date, to: date))
                .done { (stepEnties: [DayStepEntity] , calorieEnties: [DayBurnCalorieEntity]) in
                    guard stepEnties.count != 0 && calorieEnties.count != 0 else {
                        let zeroEntity = DayBurnCalorieEntity(date: date, values: [0])
                        seal.fulfill(zeroEntity)
                        return
                    }
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
                let entity = DayBurnCalorieEntity(date: date, values: calories)

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
