//
//  DatabaseComponentService.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/11/25.
//

import Foundation
import RealmSwift
import Realm
import OSLog

public struct DatabaseError: Error {
    enum DatabaseErrorCode {
        /** 致命的 */
        case fatal
        /** 不明 */
        case unknown
        /** 未初期化 */
        case uninitialized
        /** アクセス失敗 */
        case failureAccess
    }
    
    var errorCode: DatabaseErrorCode
}

/**
　DatabaseComponentProtocolの実装クラス
 */
public class DatabaseComponentService: DatabaseComponentProtocol {
    
    static let share: DatabaseComponentService = DatabaseComponentService()

    private var realm: Realm?
    
    public func initialize() throws {
        do {
            self.realm = try Realm()
        } catch let realmError as Realm.Error {
            os_log("%s", "\(String(describing: self)).\(#function): realmError -> \(realmError.localizedDescription)")
            throw DatabaseError(errorCode: .fatal)
        } catch let error {
            os_log("%s", "\(String(describing: self)).\(#function): unkwonError -> \(error.localizedDescription)")
            throw DatabaseError(errorCode: .unknown)
        }
    }
    
    public func getStepDatas(from: Date, to: Date) -> Result<[DailyStepData], DatabaseError> {
        realmAccess { realmContext -> [DailyStepData] in
            // 同期処理
            let calendar = Calendar.current
            /** from 00:00:00 */
            let fromFirst = calendar.startOfDay(for: from)
            let toNext = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: to))!
            /** to 23:59:59 */
            let toLast = calendar.date(byAdding: .second, value: -1, to: toNext)!
            let predicate = NSPredicate(format: "date >= %@ AND date <= %@", argumentArray: [fromFirst, toLast])
            let results: Results<DailyStepDataObject> = realmContext.objects(DailyStepDataObject.self).filter(predicate)
            var datas = [DailyStepData]()
            
            for obj in results {
                let entity = DailyStepData(step: obj.step, date: obj.date, distance: obj.distance)
                datas.append(entity)
            }
            
            return datas
        }
    }
    
    public func setStepData(_ entity: DailyStepData) -> Result<Void, DatabaseError> {
        realmAccess { realmContext in
            let obj = DailyStepDataObject(step: entity.step, date: entity.date, distance: entity.distance)
            
            try realmContext.write {
                realmContext.add(obj, update: .modified)
            }
        }
    }
    
    public func getTargetSettingData() -> Result<TargetSettingData?, DatabaseError>  {
        realmAccess { realmContext -> TargetSettingData? in
            guard let obj = realmContext.objects(TargetSettingDataObject.self).sorted(byKeyPath: TargetSettingDataObject.primaryKey()!, ascending:false).first else {
                return nil
            }
            var entity = TargetSettingData()
            entity.stepTarget = obj.stepTarget
            entity.settingDate = obj.settingDate
            
            return entity
        }
    }
    
    public func setTargetSettingData(_ targetSettingData: TargetSettingData) -> Result<Void, DatabaseError> {
        realmAccess { realmContext in
            let obj = TargetSettingDataObject(step: targetSettingData.stepTarget, date: targetSettingData.settingDate)
            try realmContext.write {
                realmContext.add(obj, update: .modified)
            }
        }
    }
    
    private func realmAccess<T>(_ accessClosure: @escaping (_ realm: Realm) throws -> T) -> Result<T, DatabaseError> {
        guard let realmContext = realm else {
            return .failure(.init(errorCode: .uninitialized))
        }
        do {
            let ret = try accessClosure(realmContext)
            return .success(ret)
        } catch let realmError as Realm.Error {
            os_log("%s", "\(String(describing: self)).\(#function): realmError -> \(realmError.localizedDescription)")
            return .failure(.init(errorCode: .failureAccess))
        } catch let error {
            os_log("%s", "\(String(describing: self)).\(#function): unkwonError -> \(error.localizedDescription)")
            return .failure(.init(errorCode: .unknown))
        }
    }
}
