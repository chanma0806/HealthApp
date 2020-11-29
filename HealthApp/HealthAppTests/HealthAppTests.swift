//
//  HealthAppTests.swift
//  HealthAppTests
//
//  Created by 丸山大幸 on 2020/10/31.
//

import XCTest
import PromiseKit
import RealmSwift
import Realm

@testable import HealthApp

class HealthAppTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let exp = XCTestExpectation()
        let db = DatabaseComponent()
        let enetity = DailyStepData(step: 100, date: Date(), distance: 10.0)
        db.setStepData(enetity)
        .then { _ in
            db.getStepDatas(from: Date(), to: Date())
        }
        .done { entities in
            XCTAssertEqual(1, entities.count)
        }
        .catch { _ in
            XCTFail()
        }
        .finally {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5)
    }

}
