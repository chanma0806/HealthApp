//
//  HealthCareComponent.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/11/04.
//

import Foundation
import PromiseKit
import HealthKit

public struct DayHeartrRateEntity {
    public let date: Date
    let hearRates: [Int]
}

public struct DayStepEntity {
    let date: Date
    let steps: [Int]
}

public struct DayBurnCalorieEntity {
    let date: Date
    let burnCalories: [Int]
}

public protocol HealthCareComponent {
    
    /**
     - Attention:アクセス許可をリクエストする
     */
    func requestAuthorization() -> Promise<Void>
    
    /**
     - Attention: 心拍数を取得する
     */
    func getHeartRates(from: Date, to: Date) -> Promise<[DayHeartrRateEntity]>
    
    /**
     - Attention: 歩数を取得する
     */
    func getSteps(from: Date, to: Date) -> Promise<[DayStepEntity]>
    
    /**
     - Attention: 消費カロリーを取得する
     */
    func getBurnCalories(from: Date, to: Date) -> Promise<[DayBurnCalorieEntity]>
    
}

public class HealthCareComponentService: HealthCareComponent {
    
    private let healthStore: HKHealthStore
    
    init() {
        self.healthStore = HKHealthStore()
    }
    
    public func requestAuthorization() -> Promise<Void> {
        let promise = Promise<Void> { seal in
            let reads: Set<HKObjectType> = [HKQuantityType.quantityType(forIdentifier: .stepCount)!,
                         HKQuantityType.quantityType(forIdentifier: .heartRate)!,
                         HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!]
            
            DispatchQueue.main.async {
                self.healthStore.requestAuthorization(toShare: [], read: reads, completion: { didRequest, err in
                    if (didRequest) {
                        seal.fulfill(())
                        return
                    }
                    seal.reject(err!)
                })
            }
        }
        
        return promise
    }
    
    public func getHeartRates(from: Date, to: Date) -> Promise<[DayHeartrRateEntity]> {
        let promise = Promise<[DayHeartrRateEntity]> { seal in
            let descriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            let predicate = self.makeDateRangePredicate(from: from, to: to)
            let sampleQuery = HKSampleQuery(
                sampleType: HKQuantityType.quantityType(forIdentifier: .heartRate)!,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [descriptor],
                resultsHandler: { (query, results, error) in
                    guard let samples = results else {
                        return
                    }
                    // 日付ごとにデータ抽出
                    var dict: Dictionary<String, [HKQuantitySample]> = [:]
                    for sample in samples {
                        let qSample: HKQuantitySample = sample as! HKQuantitySample
                        if (dict[qSample.startDate.yyyy_mm_dd] != nil) {
                            dict[qSample.startDate.yyyy_mm_dd]!.append(qSample)
                        } else {
                            dict[qSample.startDate.yyyy_mm_dd] = [qSample]
                        }
                    }
                    // 日毎にエンティティに変換
                    let calendar = Calendar.current
                    var entities = [DayHeartrRateEntity]()
                    for dateKey in dict.keys {
                        // 時間ごとにデータを抽出
                        var dayDict: Dictionary<String, [Int]> = [:]
                        for sample in dict[dateKey]! {
                            let hour = calendar.dateComponents([.hour], from: sample.startDate).hour!
                            let hourStr = String(hour)
                            let bpm: HKUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                            let rate = Int(sample.quantity.doubleValue(for: bpm))
                            if (dayDict[hourStr] != nil) {
                                dayDict[hourStr]!.append(rate)
                            } else {
                                dayDict[hourStr] = [rate]
                            }
                        }
                        let entity = self.convertToEntity(from: dayDict, day: dict[dateKey]![0].startDate)
                        entities.append(entity)
                    }

                    seal.fulfill(entities)
            })
            self.healthStore.execute(sampleQuery)
        }
        return promise
    }
    
    public func getSteps(from: Date, to: Date) -> Promise<[DayStepEntity]> {
        let entity = DayStepEntity(date: Date(), steps: [])
        return Promise.value([entity])
    }
    
    public func getBurnCalories(from: Date, to: Date) -> Promise<[DayBurnCalorieEntity]> {
        let entity = DayBurnCalorieEntity(date: Date(), burnCalories: [])
        return Promise.value([entity])
    }
    
    private func makeDateRangePredicate(from: Date, to: Date) -> NSPredicate {
        /** 区間 　(startDate, endaDate ]  */
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: from)
        var endDate = calendar.date(byAdding: .day, value: 1, to: to)!
        endDate = calendar.startOfDay(for: endDate)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        return predicate
    }
    
    private func convertToEntity(from dict:Dictionary<String, [Int]>, day: Date) -> DayHeartrRateEntity {
        var values = [Int]()
        let hours_24: [String] = [Int]((0...23)).map{(hour: Int) in String(hour)}
        for hourKey in hours_24 {
            guard let hourValues = dict[hourKey] else {
                values.append(0)
                continue
            }
            values.append(hourValues.mean())
        }
        let entity = DayHeartrRateEntity(date: day, hearRates: values)
        return entity
    }
}

extension Date {
    static let formatter = DateFormatter()
    var yyyy_mm_dd: String {
        get {
            Date.formatter.dateFormat = "yyyy-MM-dd"
            return Date.formatter.string(from: self)
        }
    }
}

extension Array where Element == Int{
    func total() -> Int {
        self.reduce(0, {
            return ($0 + $1)
        })
    }
    
    func mean() -> Int {
        self.total() / self.count
    }
}
