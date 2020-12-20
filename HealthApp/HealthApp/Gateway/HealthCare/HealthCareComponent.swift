//
//  HealthCareComponent.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/11/04.
//

import Foundation
import PromiseKit
import HealthKit

let HEALTH_COOPERATION_KEY = "health-cooperation-key"

enum HealthComponentError: Error {
    case notCoopreationEnabled
}

protocol HealthCareEntity {
    var date: Date { get }
    var values: [Int]  { get }
}

public struct DayHeartrRateEntity: HealthCareEntity {
    let date: Date
    let values: [Int]
}

public struct DayStepEntity: HealthCareEntity {
    let date: Date
    let values: [Int]
}

public struct DayBurnCalorieEntity: HealthCareEntity {
    let date: Date
    let values: [Int]
}

public protocol HealthCareComponent {
    
    /**
    　ヘルケア連携が有効か
     */
    var isCooperation: Bool { get set }
    
    /**
     アクセス許可をリクエストする
     */
    func requestAuthorization() -> Promise<Void>
    
    /**
     心拍数を取得する
     */
    func getHeartRates(from: Date, to: Date) -> Promise<[DayHeartrRateEntity]>
    
    /**
     歩数を取得する
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
        let userDefualt = UserDefaults()
        /** プリファレンス初期値はfalse */
        self.isCooperation = userDefualt.bool(forKey: HEALTH_COOPERATION_KEY)
    }

    
    public var isCooperation: Bool {
        didSet {
            let userDefualt = UserDefaults()
            userDefualt.setValue(self.isCooperation, forKey: HEALTH_COOPERATION_KEY)
        }
    }
    
    public func requestAuthorization() -> Promise<Void> {
        let promise = Promise<Void> { seal in
        let reads: Set<HKObjectType> = [HKQuantityType.quantityType(forIdentifier: .stepCount)!,
                         HKQuantityType.quantityType(forIdentifier: .heartRate)!,
                         HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!]
            
            DispatchQueue.main.async {
                self.healthStore.requestAuthorization(toShare: [], read: reads, completion: { didRequest, err in
                    if (didRequest) {
                        self.isCooperation = true
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
            self.queryFirstly()
            .done { _ in
                self.exequteSampleQuery(identifier: .heartRate, from: from, to: to) { (query, results, error) in
                    guard let samples = results else {
                        seal.fulfill([])
                        return
                    }
                    // 日付ごとにデータ抽出
                    let dict: Dictionary<String, [HKQuantitySample]> = self.collectSamplesAtDay(samples)
                    // 日ごとのデータをエンティティに変換
                    let bpm = HKUnit.count().unitDivided(by: .minute())
                    let entities: [DayHeartrRateEntity] = self.convertTo30minEntities(
                        dict: dict,
                        unit: bpm,
                        converter: { (dayDict: Dictionary<String, [Double]>, day: Date) in
                            self.convertToHearRateEntity(from: dayDict, day: day)
                    }) as! [DayHeartrRateEntity]

                    seal.fulfill(entities)
                }
            }
            .catch { (e: Error) in
                guard let componentError = e as? HealthComponentError else {
                    seal.reject(e)
                    return
                }
                
                switch componentError {
                case.notCoopreationEnabled:
                    seal.fulfill([])
                }
            }
        }
        return promise
    }
    
    public func getSteps(from: Date, to: Date) -> Promise<[DayStepEntity]> {
        let promise = Promise<[DayStepEntity]> { seal in
            self.queryFirstly()
            .done { _ in
                //TODO: wacth > iPhoneの優先順でマージ処理を追加
                let device = HKDevice(name: "iPhone", manufacturer: nil, model: nil, hardwareVersion: nil, firmwareVersion: nil, softwareVersion: nil, localIdentifier: nil, udiDeviceIdentifier: nil)
                self.exequteSampleQuery(identifier: .stepCount, from: from, to: to) { (query, results, error) in
                    guard var samples = results else {
                        seal.fulfill([])
                        return
                    }
                    
                    samples = samples.filtered(deviceNames: ["iPhone"])
                    
                    // 日付ごとにデータ抽出
                    let dict: Dictionary<String, [HKQuantitySample]> = self.collectSamplesAtDay(samples)
                    let entities: [DayStepEntity] = self.convertToHourEntities(
                        dict: dict,
                        unit: .count(),
                        converter: {(dayDict: Dictionary<String, [Double]>, day: Date) in
                            self.convertToStepEntity(from: dayDict, day: day)
                        }) as! [DayStepEntity]

                    seal.fulfill(entities)
                }
            }
            .catch { (e: Error) in
                guard let componentError = e as? HealthComponentError else {
                    seal.reject(e)
                    return
                }
                
                switch componentError {
                case.notCoopreationEnabled:
                    seal.fulfill([])
                }
            }
        }
        return promise
    }
    
    public func getBurnCalories(from: Date, to: Date) -> Promise<[DayBurnCalorieEntity]> {
        let promise = Promise<[DayBurnCalorieEntity]> { seal in
            self.queryFirstly()
            .done { _ in
                self.exequteSampleQuery(identifier: .activeEnergyBurned, from: from, to: to) { (query, results, error) in
                    guard var samples = results else {
                        seal.fulfill([])
                        return
                    }
                    
                    samples = samples.filtered(deviceNames: ["iPhone"])
                    
                    // 日付ごとにデータ抽出
                    let dict: Dictionary<String, [HKQuantitySample]> = self.collectSamplesAtDay(samples)
                    let entities: [DayBurnCalorieEntity] = self.convertToHourEntities(
                        dict: dict,
                        unit: .kilocalorie(),
                        converter: {(dayDict: Dictionary<String, [Double]>, day: Date) in
                            self.convertToBurnCalorieEntity(from: dayDict, day: day)
                        }) as! [DayBurnCalorieEntity]

                    seal.fulfill(entities)
                }
            }
            .catch { (e: Error) in
                guard let componentError = e as? HealthComponentError else {
                    seal.reject(e)
                    return
                }
                
                switch componentError {
                case.notCoopreationEnabled:
                    seal.fulfill([])
                }
            }
        }
        return promise
    }
    
    private func exequteSampleQuery(identifier: HKQuantityTypeIdentifier, from:Date, to: Date,  _ handler: @escaping (HKSampleQuery, [HKSample]?, Error?) -> Void) {
        let descriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        var predicate = self.makeDateRangePredicate(from: from, to: to)
        let sampleQuery = HKSampleQuery(
            sampleType: HKQuantityType.quantityType(forIdentifier: identifier)!,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [descriptor],
            resultsHandler:handler)
        
        self.healthStore.execute(sampleQuery)
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
    
    // 心拍エンティティのコンバーター
    private func convertToHearRateEntity(from dict:Dictionary<String, [Double]>, day: Date) -> DayHeartrRateEntity {
        var values = [Int]()
        let every30mins: [String] = [Int]((0..<(24 * 2))).map{(index: Int) in String(Double(index) * 0.5)}
        for minKey in every30mins {
            guard let every30minValues = dict[minKey] else {
                values.append(0)
                continue
            }
            values.append(Int(every30minValues.mean()))
        }
        let entity = DayHeartrRateEntity(date: day, values: values)
        return entity
    }
    
    // 歩数エンティティのコンバーター
    private func convertToStepEntity(from dict:Dictionary<String, [Double]>, day: Date) -> DayStepEntity {
        var values = [Int]()
        let hours_24: [String] = [Int]((0...23)).map{(hour: Int) in String(hour)}
        for hourKey in hours_24 {
            guard let hourValues = dict[hourKey] else {
                values.append(0)
                continue
            }
            values.append(Int(hourValues.total()))
        }
        let entity = DayStepEntity(date: day, values: values)
        return entity
    }
    
    // 消費カロリーエンティティのコンバーター
    private func convertToBurnCalorieEntity(from dict:Dictionary<String, [Double]>, day: Date) -> DayBurnCalorieEntity {
        var values = [Int]()
        let hours_24: [String] = [Int]((0...23)).map{(hour: Int) in String(hour)}
        for hourKey in hours_24 {
            guard let hourValues = dict[hourKey] else {
                values.append(0)
                continue
            }
            values.append(Int(hourValues.total()))
        }
        let entity = DayBurnCalorieEntity(date: day, values: values)
        return entity
    }
    
    //　サンプリングを日毎に集約する
    private func collectSamplesAtDay(_ samples: [HKSample]) -> Dictionary<String, [HKQuantitySample]> {
        var dict: Dictionary<String, [HKQuantitySample]> = [:]
        for sample in samples {
            let qSample: HKQuantitySample = sample as! HKQuantitySample
            if (dict[qSample.startDate.yyyy_mm_dd] != nil) {
                dict[qSample.startDate.yyyy_mm_dd]!.append(qSample)
            } else {
                dict[qSample.startDate.yyyy_mm_dd] = [qSample]
            }
        }
        
        return dict
    }
    
    //　エンティティへの変換
    private func convertToHourEntities(dict: Dictionary<String, [HKQuantitySample]>, unit: HKUnit, converter:(_  dict:Dictionary<String, [Double]>, _ day: Date) -> HealthCareEntity) -> [HealthCareEntity] {
        let calendar = Calendar.current
        var entities = [HealthCareEntity]()
        for dateKey in dict.keys {
            // 時間ごとにデータを抽出
            var dayDict: Dictionary<String, [Double]> = [:]
            for sample in dict[dateKey]! {
                let hour = calendar.dateComponents([.hour], from: sample.startDate).hour!
                let hourStr = String(hour)
                let value = sample.quantity.doubleValue(for: unit)
                if (dayDict[hourStr] != nil) {
                    dayDict[hourStr]!.append(value)
                } else {
                    dayDict[hourStr] = [value]
                }
            }
            let entity = converter(dayDict, dict[dateKey]![0].startDate)
            entities.append(entity)
        }
        
        return entities
    }
    
    //　エンティティへの変換
    private func convertTo30minEntities(dict: Dictionary<String, [HKQuantitySample]>, unit: HKUnit, converter:(_  dict:Dictionary<String, [Double]>, _ day: Date) -> HealthCareEntity) -> [HealthCareEntity] {
        let calendar = Calendar.current
        var entities = [HealthCareEntity]()
        for dateKey in dict.keys {
            // 時間ごとにデータを抽出
            var dayDict: Dictionary<String, [Double]> = [:]
            for sample in dict[dateKey]! {
                let hour = calendar.dateComponents([.hour], from: sample.startDate).hour!
                let min = calendar.dateComponents([.minute], from: sample.startDate).minute!
                let hourHalf = (min < 30) ? Double(hour) : (Double(hour) + 0.5)
                let hourStr = String(hourHalf)
                let value = sample.quantity.doubleValue(for: unit)
                if (dayDict[hourStr] != nil) {
                    dayDict[hourStr]!.append(value)
                } else {
                    dayDict[hourStr] = [value]
                }
            }
            let entity = converter(dayDict, dict[dateKey]![0].startDate)
            entities.append(entity)
        }
        
        return entities
    }
    
    /**
    　クエリ実施の前処理
     */
    private func queryFirstly() -> Promise<Void> {
        guard isCooperation else {
            return Promise(error: HealthComponentError.notCoopreationEnabled)
        }
        
        return Promise.value(())
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

extension Array where Element == Double {
    func total() -> Double {
        self.reduce(0, {
            return ($0 + $1)
        })
    }
    
    func mean() -> Double {
        self.total() / Double(self.count)
    }
}

private extension Array where Element == HKSample {
    func filtered(deviceNames: [String]) -> [HKSample] {
        let result = self.filter { (sample: HKSample) in
            guard let deviceName = sample.device?.name, deviceNames.contains(deviceName) else {
                return false
            }
            
            return true
        }
        
        return result
    }
}
