//
//  StepFetchUsecaeService.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/11/25.
//

import Foundation

let UPDATE_STEP_VALUE: String = "step_fetch_event"

class StepFetchUsecaeService {
    private let pedometer: PedometerComponent
    private let database: DatabaseComponent
    
    init() {
        self.pedometer = PedometerComponent.share
        self.database = DatabaseComponent()
    }
    
    func startFetchStep() {
        let notificationCenter = NotificationCenter.default
        self.pedometer.requestStepEvent { step, distance, date in
            let entity = DailyStepData(step: step, date: date, distance: distance)
            let notification = Notification(name: .init(UPDATE_STEP_VALUE), object: entity, userInfo: nil)
            notificationCenter.post(notification)
            _ = self.database.setStepData(entity)
        }
    }
}
