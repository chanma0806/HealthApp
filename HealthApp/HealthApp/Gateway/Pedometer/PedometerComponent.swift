//
//  PedometerComponent.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/11/25.
//

import Foundation
import PromiseKit
import CoreMotion

typealias StepEventCallBack = (_ stepCount: Int, _ distance: Double) -> Void

public class PedometerComponent {
    
    let pedometer: CMPedometer
    static let share: PedometerComponent = PedometerComponent()
    private init() {
        self.pedometer = CMPedometer()
    }
    
    func requestStepEvent(date: Date, _ callback: @escaping StepEventCallBack) -> Void {
        pedometer.startUpdates(from: date, withHandler: { (data: CMPedometerData?, error: Error?) -> Void in
            guard let dataContext: CMPedometerData = data else {
                return
            }
            let steps: Int = dataContext.numberOfSteps.intValue
            let distance: Double = dataContext.distance?.doubleValue ?? 0
            callback(steps, distance)
        })
    }
    
    func stopStepEvent() -> Void {
        pedometer.stopUpdates()
    }
}
