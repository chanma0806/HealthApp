//
//  PedometerComponentProtocol.swift
//  meters
//
//  Created by 丸山大幸 on 2021/01/18.
//

import Foundation
import PromiseKit

typealias StepEventCallBack = (_ stepCount: Int, _ distance: Double, _ date: Date) -> Void

enum PedometerError: Error {
    case failureAccess
}


/**
 歩数計コンポーネント
 
 */
protocol PedometerComponentProtocol {
    
    /**
     指定日の歩数値を取得する
     　
     - Parameter date: 取得日
     */
    func getPastStep(on date: Date) -> Promise<DailyStepData>
    
    /**
     歩数値の配信をリクエストする
     
    　歩数計内の歩数が更新される毎に `callback`が起動する
     */
    func requestStepEvent(_ callback: @escaping StepEventCallBack) -> Void
    
    
    /**
     `requestStepEvent`の配信を停止する
     */
    func stopStepEvent() -> Void
}
