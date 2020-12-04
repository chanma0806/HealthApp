//
//  TargetSettingDataObject.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/12/04.
//

import Foundation
import RealmSwift

class TargetSettingDataObject: Object, TargetSettingDataProtocol {
    @objc dynamic var stepTarget: Int = 0
    @objc dynamic var settingDate: Date = Date(timeIntervalSince1970: 0)
    @objc dynamic var dateKey: String = ""
    
    override static func primaryKey() -> String? {
        "dateKey"
    }
    
    override init() {
        super.init()
    }
    
    init(step: Int, date: Date) {
        self.stepTarget = step
        self.settingDate = date
        self.dateKey = date.yyyy_mm_dd
        super.init()
    }
}
