//
//  DashboardUsecaseService.swift
//  HealthAppUITests
//
//  Created by 丸山大幸 on 2020/10/31.
//

import XCTest
@testable import meters

class DashboardUsecaseServiceTest: XCTestCase {

    override func setUp() {
        
    }

    override func tearDown() {
        
    }
    
    func testGetHeartRate() throws {
        XCTContext.runActivity(named: "正常系", block: { act in
            XCTContext.runActivity(named: "境界値 最大値 onポインt", block: { act in
                let exp = XCTestExpectation()
                let health = HealthCareComponentMock()
                // ヘルスケアから取得されるダミーを用意
                // １件/30分
                var values = [Int](repeating: 0, count: 24 * 2)
                let REPLACE_INDEX = 10
                values[REPLACE_INDEX] = MAX_HEART_RATE
                let dto = DayHeartrRateDto(date: Date(), values: values)
                var healthParam = HealthCareComponentMockParam()
                healthParam.heartRates = [dto]
                health.param = healthParam
                let usecase = getUsecase(health: health)
                usecase.getHeartRate(on: Date())
                    .done { ret in
                        // バリデーション後の評価
                        XCTAssertEqual(ret.values.count, dto.values.count)
                        XCTAssertEqual(ret.values[REPLACE_INDEX], MAX_HEART_RATE)
                        exp.fulfill()
                    }
                    .catch { error in
                        XCTFail()
                        exp.fulfill()
                    }
                wait(for: [exp], timeout: 5)
            })
            XCTContext.runActivity(named: "境界値 最小値 offポインt", block: { act in
                let exp = XCTestExpectation()
                let health = HealthCareComponentMock()
                // ヘルスケアから取得されるダミーを用意
                // １件/30分
                var values = [Int](repeating: 0, count: 24 * 2)
                let REPLACE_INDEX = 10
                values[REPLACE_INDEX] = MIN_HEART_RATE - 1
                let dto = DayHeartrRateDto(date: Date(), values: values)
                var healthParam = HealthCareComponentMockParam()
                healthParam.heartRates = [dto]
                health.param = healthParam
                let usecase = getUsecase(health: health)
                usecase.getHeartRate(on: Date())
                    .done { ret in
                        // バリデーション後の評価
                        XCTAssertEqual(ret.values.count, dto.values.count)
                        XCTAssertEqual(ret.values[REPLACE_INDEX], MIN_HEART_RATE)
                        exp.fulfill()
                    }
                    .catch { error in
                        XCTFail()
                        exp.fulfill()
                    }
                wait(for: [exp], timeout: 5)
            })
        })
    }
        
    func testGetStep() throws {
        XCTContext.runActivity(named: "正常系", block: { act in
            XCTContext.runActivity(named: "境界値 最小値 onポインt", block: { act in
                let exp = XCTestExpectation()
                let health = HealthCareComponentMock()
                // ヘルスケアから取得されるダミーを用意
                // １件 / 時間
                var values = [Int](repeating: 0, count: 24)
                let REPLACE_INDEX = 10
                values[REPLACE_INDEX] = MIN_STEPS
                let dto = DayStepDto(date: Date(), values: values)
                var healthParam = HealthCareComponentMockParam()
                healthParam.steps = [dto]
                health.param = healthParam
                let usecase = getUsecase(health: health)
                usecase.getStep(on: Date())
                    .done { ret in
                        // バリデーション後の評価
                        XCTAssertEqual(ret.values.count, dto.values.count)
                        XCTAssertEqual(ret.values[REPLACE_INDEX], MIN_STEPS)
                        exp.fulfill()
                    }
                    .catch { error in
                        XCTFail()
                        exp.fulfill()
                    }
                wait(for: [exp], timeout: 5)
            })
            XCTContext.runActivity(named: "境界値 最大値 offポインt", block: { act in
                let exp = XCTestExpectation()
                let health = HealthCareComponentMock()
                // ヘルスケアから取得されるダミーを用意
                // １件/1時間
                var values = [Int](repeating: 0, count: 24)
                let REPLACE_INDEX = 10
                values[REPLACE_INDEX] = MAX_STEPS + 1
                let dto = DayStepDto(date: Date(), values: values)
                var healthParam = HealthCareComponentMockParam()
                healthParam.steps = [dto]
                health.param = healthParam
                let usecase = getUsecase(health: health)
                usecase.getStep(on: Date())
                    .done { ret in
                        // バリデーション後の評価
                        XCTAssertEqual(ret.values.count, dto.values.count)
                        XCTAssertEqual(ret.values[REPLACE_INDEX], MAX_STEPS)
                        exp.fulfill()
                    }
                    .catch { error in
                        XCTFail()
                        exp.fulfill()
                    }
                wait(for: [exp], timeout: 5)
            })
        })
    }
    
    func testGetBurnCalorie() throws {
        XCTContext.runActivity(named: "正常系", block: { act in
            XCTContext.runActivity(named: "境界値 最大値 onポインt", block: { act in
                let exp = XCTestExpectation()
                let health = HealthCareComponentMock()
                // ヘルスケアから取得されるダミーを用意
                // １件 / 時間
                var values = [Int](repeating: 0, count: 24)
                let REPLACE_INDEX = 10
                values[REPLACE_INDEX] = MAX_CALORIE
                let dto = DayBurnCalorieDto(date: Date(), values: values)
                var healthParam = HealthCareComponentMockParam()
                healthParam.calories = [dto]
                health.param = healthParam
                let usecase = getUsecase(health: health)
                usecase.getBurnCalorie(on: Date())
                    .done { ret in
                        // バリデーション後の評価
                        XCTAssertEqual(ret.values.count, dto.values.count)
                        XCTAssertEqual(ret.values[REPLACE_INDEX], MAX_CALORIE)
                        exp.fulfill()
                    }
                    .catch { error in
                        XCTFail()
                        exp.fulfill()
                    }
                wait(for: [exp], timeout: 5)
            })
            XCTContext.runActivity(named: "境界値 最小値 offポイント", block: { act in
                let exp = XCTestExpectation()
                let health = HealthCareComponentMock()
                // ヘルスケアから取得されるダミーを用意
                // １件/1時間
                var values = [Int](repeating: 0, count: 24)
                let REPLACE_INDEX = 10
                values[REPLACE_INDEX] = MIN_CALORIE - 1
                let dto = DayBurnCalorieDto(date: Date(), values: values)
                var healthParam = HealthCareComponentMockParam()
                healthParam.calories = [dto]
                health.param = healthParam
                let usecase = getUsecase(health: health)
                usecase.getBurnCalorie(on: Date())
                    .done { ret in
                        // バリデーション後の評価
                        XCTAssertEqual(ret.values.count, dto.values.count)
                        XCTAssertEqual(ret.values[REPLACE_INDEX], MIN_CALORIE)
                        exp.fulfill()
                    }
                    .catch { error in
                        XCTFail()
                        exp.fulfill()
                    }
                wait(for: [exp], timeout: 5)
            })
            XCTContext.runActivity(named: "補正", block: { act in
                let exp = XCTestExpectation()
                let health = HealthCareComponentMock()
                // １件/1時間
                // ヘルスケアから取得されるダミーを用意
                let values = [Int](repeating: 0, count: 24)
                let REPLACE_INDEX = 10
                let calorieDto = DayBurnCalorieDto(date: Date(), values: values)
                var healthParam = HealthCareComponentMockParam()
                healthParam.calories = [calorieDto]
                
                // 補正時に参照される歩数値もダミーで用意
                var stepValues = [Int](repeating: 0, count: 24)
                stepValues[REPLACE_INDEX] = 8000
                let stepDto = DayStepDto(date: Date(), values: stepValues)
                healthParam.steps = [stepDto]
                health.param = healthParam
                let usecase = getUsecase(health: health)
                usecase.getBurnCalorie(on: Date())
                    .done { ret in
                        // バリデーション後の評価
                        XCTAssertEqual(ret.values.count, calorieDto.values.count)
                        /** 歩数による補正により取得結果のカロリーの方が大きい */
                        XCTAssertGreaterThan(ret.values[REPLACE_INDEX], calorieDto.values[REPLACE_INDEX])
                        exp.fulfill()
                    }
                    .catch { error in
                        XCTFail()
                        exp.fulfill()
                    }
                wait(for: [exp], timeout: 1000)
            })
        })
    }
    
    private func getUsecase(health: HealthCareComponentMock) -> DashboardUsecaseService {
        return DashboardUsecaseFactory.getTestableInstance(health: health)
    }
}
