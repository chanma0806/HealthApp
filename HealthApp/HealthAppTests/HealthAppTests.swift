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
        let db = DatabaseComponent()
        let enetity = TargetSettingData(step: 100)
        db.setTargetSettingData(enetity)
        guard let ret_entity = db.getTargetSettingData() else {
            XCTFail()
            return
        }
        XCTAssertEqual(ret_entity.stepTarget, enetity.stepTarget)
        
        var entity_past = TargetSettingData(step: 200)
        entity_past.settingDate = Calendar.current.date(byAdding: .day, value: -1, to: entity_past.settingDate)!
        db.setTargetSettingData(enetity)
        guard let ret_entity_2 = db.getTargetSettingData() else {
            XCTFail()
            return 
        }
        
        XCTAssertEqual(ret_entity_2.stepTarget, enetity.stepTarget)
    }

}
