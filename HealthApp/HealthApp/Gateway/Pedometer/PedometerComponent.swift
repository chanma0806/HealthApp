//
//  PedometerComponent.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/11/25.
//

import Foundation
import PromiseKit
import CoreMotion

typealias StepEventCallBack = (_ stepCount: Int, _ distance: Double, _ date: Date) -> Void

public class PedometerComponent {
    
    let pedometer: CMPedometer
    static let share: PedometerComponent = PedometerComponent()
    private init() {
        self.pedometer = CMPedometer()
    }
    
    func requestStepEvent(_ callback: @escaping StepEventCallBack) -> Void {
        let date = Date()
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
