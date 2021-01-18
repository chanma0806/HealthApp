//
//  PedometerComponentService.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/11/25.
//

import Foundation
import PromiseKit
import CoreMotion

/**
 PedometerComponentProtocolの実装クラス
 */
public class PedometerComponentService: PedometerComponentProtocol {
    
    let pedometer: CMPedometer
    static let share: PedometerComponentService = PedometerComponentService()
    private init() {
        self.pedometer = CMPedometer()
    }
    
    
    func requestAccess() {
        _ = CMPedometer.isStepCountingAvailable()
    }
    
    func getPastStep(on date: Date) -> Promise<DailyStepData> {
        let promise = Promise<DailyStepData> { seal in
            let from = Calendar.current.startOfDay(for: date)
            let to = Calendar.current.date(byAdding: .second, value: -1, to: Calendar.current.date(byAdding: .day, value: 1, to: from)!)!
            self.pedometer.queryPedometerData(from: from, to: to, withHandler: { (data: CMPedometerData?, error: Error?) -> Void in
                guard let dataContext: CMPedometerData = data else {
                    seal.reject(PedometerError.failureAccess)
                    return
                }
                let distance = dataContext.distance?.doubleValue ?? 0.0
                let entity = DailyStepData(step: dataContext.numberOfSteps.intValue, date: date, distance: distance)
                seal.fulfill(entity)
            })
        }
        
        return promise
    }
    
    func requestStepEvent(_ callback: @escaping StepEventCallBack) -> Void {
        let date = Calendar.current.startOfDay(for: Date())
        pedometer.startUpdates(from: date, withHandler: { (data: CMPedometerData?, error: Error?) -> Void in
            guard let dataContext: CMPedometerData = data else {
                return
            }
            
            let exitAction = {
                let steps: Int = dataContext.numberOfSteps.intValue
                let distance: Double = dataContext.distance?.doubleValue ?? 0
                callback(steps, distance, date)
            }
            
            guard !Calendar.current.isDate(date, inSameDayAs: dataContext.endDate) else {
                // 日付変更時は変更前の歩数を確定データとして別クエリで取得
                self.pedometer.stopUpdates()
                self.pedometer.queryPedometerData(from: date, to: date, withHandler: { (data: CMPedometerData?, error: Error?) -> Void in
                    exitAction()
                    // イベント配信再開
                    self.requestStepEvent(callback)
                })
                return
            }
            
            exitAction()
        })
    }
    
    func stopStepEvent() -> Void {
        pedometer.stopUpdates()
    }
}
