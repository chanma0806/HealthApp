//
//  StepFetchUsecaeService.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/11/25.
//

import Foundation
import PromiseKit
import BackgroundTasks
import OSLog

let BGTASK_FETCH_STEPS = "com.meters.fetch-steps"
let BG_FETCHED_STEPS_DATE_KEY = "com.meters.fetched-steps-date"
let UPDATE_STEP_VALUE: String = "step_fetch_event"
let PEDOMETER_SAVED_DAY_RANGE = 7

class StepFetchUsecaeService {
    
    static let shared = StepFetchUsecaeService()
    
    private let pedometer: PedometerComponent
    private let database: DatabaseComponent
    
    private init() {
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
    
    func requestBackgroundFetch() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: BGTASK_FETCH_STEPS, using: DispatchQueue.global(), launchHandler: { task in
            
            DispatchQueue.main.async {
                let path = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("background_feth_log").appendingPathExtension("txt").path
                let date = Date()
                let message = "background fecth on: \(date)"
                FileManager.default.createFile(atPath: path, contents: message.data(using: .utf8), attributes: nil)
            }
            
            self.fetchStepsFromLastToNow()
                .done { _ in
                    task.setTaskCompleted(success: true)
                    self.setLastBackgroundFetchedDate()
                    
                    // 翌々日のフェッチをスケジューリング
                    self.submitFetchTask()
                }
                .catch { error in
                    os_log("%@.%@: failure fetch task", String(describing: self), #function)
                    task.setTaskCompleted(success: false)
                    
                }
        })
        
        self.submitFetchTask()
    }
    
    private func submitFetchTask() {
        // 翌日を迎えたらフェッチさせる
        let cal = Calendar.current
        let request = BGAppRefreshTaskRequest(identifier: BGTASK_FETCH_STEPS)
        let lastFetched = getLastBackgroundFetchedDate() ?? Date()
        let taskFireTiming = cal.startOfDay(for: cal.date(byAdding: .day, value: 1, to: lastFetched)!)
        request.earliestBeginDate = taskFireTiming
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            os_log("%@.%@: failure submit task", String(describing: self), #function)
        }
    }
    
    private func fetchStepsFromLastToNow() -> Promise<Void> {
        let savedLastDay = Calendar.current.date(byAdding: .day, value: -PEDOMETER_SAVED_DAY_RANGE, to: Calendar.current.startOfDay(for: Date()))!
        
        // 日ごとのフェッチブロックを作成
        var fetchBlocks = [PromiseBlock<Void>]()
        for dayCount in 0 ..< PEDOMETER_SAVED_DAY_RANGE {
            fetchBlocks.append { () -> Promise<Void> in
                let promise: Promise<Void> = self.pedometer.getPastStep(on: Calendar.current.date(byAdding: .day, value: dayCount, to: savedLastDay)!)
                    .then { (dayStep: DailyStepData) -> Promise<Void> in
                    self.database.setStepData(dayStep)
                    return  Promise.value(())
                }
                
                return promise
            }
        }
        
        // 直列実行
        return PromiseUtility.doSeriesPromises(fetchBlocks)
    }
    
    private func updateded(old: DailyStepData, new: DailyStepData) -> Bool {
        (old.date != new.date) || (old.step != new.step) || (old.distance != new.distance)
    }
    
    private func postNotify(_ entity: DailyStepData) {
        let notification = Notification(name: .init(UPDATE_STEP_VALUE), object: entity, userInfo: nil)
        NotificationCenter.default.post(notification)
    }
    
    private func getLastBackgroundFetchedDate() -> Date? {
        UserDefaults().value(forKey: BG_FETCHED_STEPS_DATE_KEY) as? Date
    }
    
    private func setLastBackgroundFetchedDate() {
        UserDefaults().setValue(Date(), forKey: BG_FETCHED_STEPS_DATE_KEY)
    }
}
