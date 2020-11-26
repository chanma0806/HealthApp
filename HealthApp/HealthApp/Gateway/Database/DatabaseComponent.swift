//
//  DatabaseComponent.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/11/25.
//

import Foundation
import PromiseKit
import RealmSwift
import Realm

public class DatabaseComponent {
    
    public func getStepDatas(from: Date, to: Date) -> Promise<[DailyStepData]> {
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
        
        return Promise.value(datas)
    }
    
    public func setStepData(_ entity: DailyStepData) -> Promise<Void> {
        let realm = try! Realm()
        let obj = DailyStepDataObject(step: entity.step, date: entity.date, distance: entity.distance)
        try! realm.write {
            realm.add(obj)
        }
        
        return Promise.value(())
    }
    
    public func getTargetSettingData() -> Promise<TargetSettingData?> {
        Promise.value(nil)
    }
    
    public func setTargetSettingData(_ targetSettingData: TargetSettingData) -> Promise<Void> {
        Promise.value(())
    }
}
