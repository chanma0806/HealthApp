//
//  DatabaseComponent.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/11/25.
//

import Foundation
import RealmSwift
import Realm

/**
　データベースのアクセッサー
 */
public class DatabaseComponent {
    
    public func getStepDatas(from: Date, to: Date) -> [DailyStepData] {
        let realm = try! Realm()
        // 同期処理
        let calendar = Calendar.current
        /** from 00:00:00 */
        let fromFirst = calendar.startOfDay(for: from)
        let toNext = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: to))!
        /** to 23:59:59 */
        let toLast = calendar.date(byAdding: .second, value: -1, to: toNext)!
        let predicate = NSPredicate(format: "date >= %@ AND date <= %@", argumentArray: [fromFirst, toLast])
        let results: Results<DailyStepDataObject> = realm.objects(DailyStepDataObject.self).filter(predicate)
        var datas = [DailyStepData]()
        for obj in results {
            let entity = DailyStepData(step: obj.step, date: obj.date, distance: obj.distance)
            datas.append(entity)
        }
        
        return datas
    }
    
    public func setStepData(_ entity: DailyStepData) {
        let realm = try! Realm()
        let obj = DailyStepDataObject(step: entity.step, date: entity.date, distance: entity.distance)
        try! realm.write {
            realm.add(obj, update: .modified)
        }
    }
    
    public func getTargetSettingData() -> TargetSettingData? {
        let realm = try! Realm()
        guard let obj = realm.objects(TargetSettingDataObject.self).sorted(byKeyPath: TargetSettingDataObject.primaryKey()!, ascending:false).first else {
            return nil
        }
        var entity = TargetSettingData()
        entity.stepTarget = obj.stepTarget
        entity.settingDate = obj.settingDate
        
        return entity
    }
    
    public func setTargetSettingData(_ targetSettingData: TargetSettingData) {
        let reamlm: Realm = try! Realm()
        let obj = TargetSettingDataObject(step: targetSettingData.stepTarget, date: targetSettingData.settingDate)
        try! reamlm.write {
            reamlm.add(obj, update: .modified)
        }
    }
}
