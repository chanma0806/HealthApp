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
    /** getHeartRatesでrejectするパラメータ */
    var rejectReasonOnGetHeartRates: Error?
    /** getStepsで返却されるパラメータ */
    var steps: [DayStepDto] = []
    /** getStepsでrejectするパラメータ */
    var rejectReasonOnGetSteps: Error?
    /** getBurnCalorieで返却されるパラメータ*/
    var calories: [DayBurnCalorieDto] = []
    /** getBurnCalorieでrejectするパラメータ */
    var rejectReasonOnGetBurnCalorie: Error?
}

class HealthCareComponentMock: HealthCareComponentProtocol {
    var isCooperation: Bool = true
    var param = HealthCareComponentMockParam()
    
    func requestAuthorization() -> Promise<Void> {
        Promise.value(())
    }
    
    func getHeartRates(from: Date, to: Date) -> Promise<[DayHeartrRateDto]> {
        if (param.rejectReasonOnGetHeartRates != nil) {
            return Promise(error: param.rejectReasonOnGetHeartRates!)
        }
        
        return Promise.value(param.heartRates)
    }
    
    func getBurnCalories(from: Date, to: Date) -> Promise<[DayBurnCalorieDto]> {
        if (param.rejectReasonOnGetBurnCalorie != nil) {
            return Promise(error: param.rejectReasonOnGetBurnCalorie!)
        }
        
        return Promise.value(param.calories)
    }
    
    func getSteps(from: Date, to: Date) -> Promise<[DayStepDto]> {
        if (param.rejectReasonOnGetSteps != nil) {
            return Promise(error: param.rejectReasonOnGetSteps!)
        }
        
        return Promise.value(param.steps)
    }
}
