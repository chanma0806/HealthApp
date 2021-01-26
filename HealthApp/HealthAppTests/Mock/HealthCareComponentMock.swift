//
//  HealthCareComponentMock.swift
//  meters
//
//  Created by 丸山大幸 on 2021/01/25.
//

import Foundation
import PromiseKit

struct HealthCareComponentMockParam {
    /** getHeartRatesで返却されるパラメータ  */
    var heartRates: [DayHeartrRateDto] = []
    /** getStepsで返却されるパラメータ */
    var steps: [DayStepDto] = []
    /** getBurnCalorieで返却されるパラメータ*/
    var calories: [DayBurnCalorieDto] = []
}

class HealthCareComponentMock: HealthCareComponentProtocol {
    var isCooperation: Bool = true
    var param = HealthCareComponentMockParam()
    
    func requestAuthorization() -> Promise<Void> {
        Promise.value(())
    }
    
    func getHeartRates(from: Date, to: Date) -> Promise<[DayHeartrRateDto]> {
        
        return Promise.value(param.heartRates)
    }
    
    func getBurnCalories(from: Date, to: Date) -> Promise<[DayBurnCalorieDto]> {
        
        return Promise.value(param.calories)
    }
    
    func getSteps(from: Date, to: Date) -> Promise<[DayStepDto]> {
        
        return Promise.value(param.steps)
    }
}
