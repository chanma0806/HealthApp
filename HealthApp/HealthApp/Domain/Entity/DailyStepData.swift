//
//  DailyStepData.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/11/25.
//

import Foundation

protocol DailyStepDataProtocol {
    var step: Int {get set}
    var date: Date {get set}
    var distance: Double { get set}
}

public struct DailyStepData: DailyStepDataProtocol {
    var step: Int
    var date: Date
    var distance: Double
}
