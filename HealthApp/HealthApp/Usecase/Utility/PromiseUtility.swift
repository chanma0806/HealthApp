//
//  PromiseUtility.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/12/19.
//

import Foundation
import PromiseKit

typealias PromiseBlock<T> = () -> Promise<T>

class PromiseUtility {
    
    // プロミスを直列実行する
    static func doSeriesPromises(_ blocks: [PromiseBlock<Void>]) -> Promise<Void> {
        let result = blocks.reduce(Promise.value(()), { pre, next in
            pre.then(next)
        })
        
        return result
    }
}
