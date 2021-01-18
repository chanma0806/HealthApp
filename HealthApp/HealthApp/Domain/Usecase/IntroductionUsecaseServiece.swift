//
//  IntroductionUsecaseServiece.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/12/23.
//

import Foundation
import PromiseKit

enum GuidanceType {
    case Pedmeter
    case HealthCare
}

/**
　初期ガイダンスのユースケース
 
 */
class IntroductionUsecaseServiece {
    private let pedmeter = PedometerComponentService.share
    private let health = HealthCareComponentService.share
    
    /**
　　　認証をリクエストする
     
     - Parameter type: ガイダンス種類
     */
    func requestAuthorization(type: GuidanceType) -> Promise<Void> {
        switch type {
        case .Pedmeter:
            return requestAuthorizationForPedmeter()
        case .HealthCare:
            return requestAuthorizationForHealthCare()
        }
    }
    
    // 歩数計アクセスの認証を要求
    private func requestAuthorizationForPedmeter() -> Promise<Void> {
        let promise = Promise<Void> { seal in
            // 初回の歩数取得で認証ダイアログが表示されるs
            _ = self.pedmeter.getPastStep(on: Date())
                .ensure {
                    seal.fulfill(())
                }
        }
        
        return promise
    }
    
    // ヘルスケアアクセスの認証を要求
    private func requestAuthorizationForHealthCare() -> Promise<Void> {
        self.health.requestAuthorization()
    }
}
