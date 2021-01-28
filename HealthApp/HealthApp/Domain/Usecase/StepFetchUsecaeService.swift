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

/**
  歩数フェッチのユースケース
 
 */
class StepFetchUsecaeService {
    /** シングルトンなインスタンス */
    static let shared = StepFetchUsecaeService()
    
    // 歩数計コンポーネント
    private let pedometer: PedometerComponentProtocol
    // DBコンポーネント
    private let database: DatabaseComponentProtocol
    
    // 初期化処理
    private init() {
        self.pedometer = PedometerComponentService.share
        self.database = DatabaseComponentService()
    }
    
    /**
     歩数フェッチを開始する
     */
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
     
    /**
     指定日の歩数を取得する
     
        - Parameters:
            - date: 取得日
     */
    func getDailyStep(on date: Date) -> Promise<DailyStepData?> {
        let savedLastDay = Calendar.current.date(byAdding: .day, value: -(PEDOMETER_SAVED_DAY_RANGE - 1), to: Date())!
        let compare = Calendar.current.compare(date, to: savedLastDay, toGranularity: .day)
        if compare == .orderedAscending {
            var entities: [DailyStepData] = []
            let result = self.database.getStepDatas(from: date, to: date)
            switch result {
            case .success(let steps):
                entities = steps
            case .failure(_):
                break
            }
            guard entities.count > 0 else {
                return Promise.value(nil)
            }
                return Promise.value(entities[0])
        } else {
            var entity: DailyStepData?
            return self.pedometer.getPastStep(on: date)
            .then { (ret: DailyStepData) -> Promise<Void> in
                entity = ret
                let result = self.database.setStepData(ret)
                
                switch (result) {
                case .failure(let dbError):
                    os_log("%s", "\(String(describing: self)).\(#function): failure")
                case .success():
                    break
                }
                
                return Promise.value(())
            }
            .then { (_) -> Promise<DailyStepData?> in
                return Promise.value(entity)
            }
        }
    }
    
    /**
     バックグラウンドでの歩数フェッチを開始する
     
     日付更新時に歩数を更新する
       
     */
    func requestBackgroundFetch() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: BGTASK_FETCH_STEPS, using: DispatchQueue.global(), launchHandler: { task in
            
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
    
    // バックグラウンドタスクに歩数フェッチを登録
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
    
    // 歩数計の最終保持日から現在日までの歩数値をフェッチ
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
    
    // 歩数更新を通知する
    private func postNotify(_ entity: DailyStepData) {
        let notification = Notification(name: .init(UPDATE_STEP_VALUE), object: entity, userInfo: nil)
        NotificationCenter.default.post(notification)
    }
    
    // 最後に実行したバックグラウンドフェッチの日時を取得
    private func getLastBackgroundFetchedDate() -> Date? {
        UserDefaults().value(forKey: BG_FETCHED_STEPS_DATE_KEY) as? Date
    }
    
    // 最後に実行したバックグラウンドフェッチの日時を保存
    private func setLastBackgroundFetchedDate() {
        UserDefaults().setValue(Date(), forKey: BG_FETCHED_STEPS_DATE_KEY)
    }
}
