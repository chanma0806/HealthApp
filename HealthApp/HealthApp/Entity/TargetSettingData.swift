//
//  TargetSettingData.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/11/25.
//

import Foundation

protocol TargetSettingDataProtocol {
    var stepTarget: Int { get set }
    var settingDate: Date { get set}
}

public struct TargetSettingData: TargetSettingDataProtocol{
    var stepTarget: Int
    var settingDate: Date
    
    init () {
        self.stepTarget = 0
        self.settingDate = Date()
    }
    
    init (step: Int) {
        self.stepTarget = step
        self.settingDate = Date()
    }
}
