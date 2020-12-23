//
//  IntroductionUsecaseServiece.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/12/23.
//

import Foundation
import PromiseKit

enum GuidanceType {
    case Pedmeter
    case HealthCare
}

class IntroductionUsecaseServiece {
    private let pedmeter = PedometerComponent.share
    private let health = HealthCareComponentService()
    
    func requestAuthorization(type: GuidanceType) -> Promise<Void> {
        switch type {
        case .Pedmeter:
            return requestAuthorizationForPedmeter()
        case .HealthCare:
            return requestAuthorizationForHealthCare()
        }
    }
    
    private func requestAuthorizationForPedmeter() -> Promise<Void> {
        let promise = Promise<Void> { seal in
            _ = self.pedmeter.getPastStep(on: Date())
                .ensure {
                    seal.fulfill(())
                }
        }
        
        return promise
    }
    
    private func requestAuthorizationForHealthCare() -> Promise<Void> {
        self.health.requestAuthorization()
    }
}
