//
//  DashboardUsecaseService.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/11/05.
//

import Foundation
import PromiseKit

class DashboardUsecaseService {
    let healthComponet: HealthCareComponent
    
    init() {
        self.healthComponet = HealthCareComponentService()
    }
    
    func requestHealthAccess() -> Promise<Void> {
        self.healthComponet.requestAuthorization()
    }
    
    func getHeartRates(on date: Date) -> Promise<[DayHeartrRateEntity]> {
        self.healthComponet.getHeartRates(from: date, to: date)
    }
}
