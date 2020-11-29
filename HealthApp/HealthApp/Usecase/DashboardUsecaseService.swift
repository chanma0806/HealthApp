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
    
    func getHeartRate(on date: Date) -> Promise<DayHeartrRateEntity?> {
        let promise = Promise<DayHeartrRateEntity?> { seal in
            self.healthComponet.getHeartRates(from: date, to: date)
            .done { (enities: [DayHeartrRateEntity]) in
                guard enities.count != 0 else {
                    seal.fulfill(nil)
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
    
    func getStep(on date: Date) -> Promise<DayStepEntity?> {
        let promise = Promise<DayStepEntity?> { seal in
            self.healthComponet.getSteps(from: date, to: date)
            .done { (enities: [DayStepEntity]) in
                guard enities.count != 0 else {
                    seal.fulfill(nil)
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
    
    func getBurnCalorie(on date: Date) -> Promise<DayBurnCalorieEntity?> {
        let promise = Promise<DayBurnCalorieEntity?> { seal in
            self.healthComponet.getBurnCalories(from: date, to: date)
            .done { (enities: [DayBurnCalorieEntity]) in
                guard enities.count != 0 else {
                    seal.fulfill(nil)
                    return
                }
                
                // バリデーション後に返却
                let values = enities[0].values.validated(max: MAX_CALORIE, min: MIN_CALORIE)
                let entity = DayBurnCalorieEntity(date: enities[0].date, values: values)
                seal.fulfill(entity)
            }
            .catch { error in
                seal.reject(error)
            }
        }
        
        return promise
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
