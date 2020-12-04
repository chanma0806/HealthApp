//
//  StepFetchUsecaeService.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/11/25.
//

import Foundation
import PromiseKit

let UPDATE_STEP_VALUE: String = "step_fetch_event"
let PEDOMETER_SAVED_DAY_RANGE = 7

class StepFetchUsecaeService {
    private let pedometer: PedometerComponent
    private let database: DatabaseComponent
    
    init() {
        self.pedometer = PedometerComponent.share
        self.database = DatabaseComponent()
    }
    
    func startFetchStep() {
        var entityContext: DailyStepData?
        self.pedometer.requestStepEvent { step, distance, date in
            let entity = DailyStepData(step: step, date: date, distance: distance)
            if (entityContext == nil || self.updateded(old: entityContext!, new: entity)) {
                entityContext = entity
                self.postNotify(entity)
                self.database.setStepData(entity)
            }
        }
    }
    
    func requestMotionAccess() {
        self.pedometer.requestAccess()
    }
    
    func getDailyStep(on date: Date) -> Promise<DailyStepData?> {
        let savedLastDay = Calendar.current.date(byAdding: .day, value: -(PEDOMETER_SAVED_DAY_RANGE - 1), to: Date())!
        let compare = Calendar.current.compare(date, to: savedLastDay, toGranularity: .day)
        if compare == .orderedAscending {
            let entities: [DailyStepData] = self.database.getStepDatas(from: date, to: date)
            guard entities.count > 0 else {
                return Promise.value(nil)
            }
                return Promise.value(entities[0])
        } else {
            var entity: DailyStepData?
            return self.pedometer.getPastStep(on: date)
            .then { (ret: DailyStepData) -> Promise<Void> in
                entity = ret
                self.database.setStepData(ret)
                return Promise.value(())
            }
            .then { (_) -> Promise<DailyStepData?> in
                return Promise.value(entity)
            }
        }
    }
    
    private func updateded(old: DailyStepData, new: DailyStepData) -> Bool {
        (old.date != new.date) || (old.step != new.step) || (old.distance != new.distance)
    }
    
    private func postNotify(_ entity: DailyStepData) {
        let notification = Notification(name: .init(UPDATE_STEP_VALUE), object: entity, userInfo: nil)
        NotificationCenter.default.post(notification)
    }
}
