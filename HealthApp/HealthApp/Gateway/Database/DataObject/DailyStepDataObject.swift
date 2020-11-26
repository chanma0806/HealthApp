//
//  DailyStepDataObject.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/11/25.
//

import Foundation
import RealmSwift

class DailyStepDataObject: Object {
    @objc dynamic var step: Int = 0
    /** yyyy-MM-dd */
    @objc dynamic var date: Date = Date(timeIntervalSince1970: 0)
    @objc dynamic var distance: Double = 0.0
    @objc dynamic var dateKey: String = ""
    
    override static func primaryKey() -> String? {
        "dateKey"
    }
    
    override init() {
        super.init()
    }
    
    init(step: Int, date: Date, distance: Double) {
        self.step = step
        self.date = date
        self.distance = distance
        self.dateKey = date.yyyy_mm_dd
        super.init()
    }
}
