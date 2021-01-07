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
        self.healthComponet = HealthCareComponentService.share
    }
    
    func requestHealthAccess() -> Promise<Void> {
        self.healthComponet.requestAuthorization()
    }
    
    func getHeartRate(on date: Date) -> Promise<DayHeartrRateEntity> {
        
//        let data = [
//            80, /** 0 */
//            79, /** 1 */
//            80, /** 2 */
//            75, /** 3 */
//            71, /** 4 */
//            75, /** 5 */
//            0, /** 6 */
//            0, /** 7 */
//            0, /** 8 */
//            0, /** 9 */
//            0, /** 10 */
//            0, /** 11 */
//            0, /** 12 */
//            0, /** 13 */
//            0, /** 14 */
//            0, /** 15 */
//            0, /** 16 */
//            0, /** 17 */
//            0, /** 18 */
//            0, /** 19 */
//            0, /** 20 */
//            84, /** 21 */
//            84, /** 22 */
//            85, /** 23 */
//            94, /** 24 */
//            104, /** 25 */
//            99, /** 26 */
//            96, /** 27 */
//            114, /** 28 */
//            121, /** 29 */
//            109, /** 30 */
//            102, /** 31 */
//            101, /** 32 */
//            100, /** 33 */
//            98, /** 34 */
//            99, /** 35 */
//            97, /** 36 */
//            95, /** 37 */
//            96, /** 38 */
//            95, /** 39 */
//            94, /** 40 */
//            88, /** 41 */
//            86, /** 42 */
//            92, /** 43 */
//            85, /** 44 */
//            82, /** 45 */
//            80, /** 46 */
//            77, /** 47 */
//        ]
//
//        return Promise.value(DayHeartrRateEntity(date: date, values: data))
        
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
//        let data = [
//            0, /* 0 */
//            0, /* 1 */
//            0, /* 2 */
//            0, /* 3 */
//            0, /* 4 */
//            0, /* 5 */
//            0, /* 6 */
//            0, /* 7 */
//            0, /* 8 */
//            0, /* 9 */
//            0, /* 10 */
//            133, /* 11 */
//            966, /* 12 */
//            51, /* 13 */
//            3310, /* 14 */
//            589, /* 15 */
//            109, /* 16 */
//            224, /* 17 */
//            16, /* 18 */
//            0, /* 19 */
//            0, /* 20 */
//            43, /* 21 */
//            24, /* 22 */
//            0, /* 23 */
//        ]
//
//        return Promise.value(DayStepEntity(date: date, values: data))
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
                    guard stepEnties.count != 0 else {
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
