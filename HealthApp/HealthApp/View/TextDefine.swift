//
//  TextDefine.swift
//  meters
//
//  Created by 丸山大幸 on 2021/01/19.
//

import Foundation

enum AppText: String {
    /** 設定画面 */
    case STR_SETTING_TARGET_STEP
    case STR_SETTING_SYNC_HEALTH
    case STR_SETTING_SECTION
    case STR_SETTING_FINISH
    case STR_SETTING_TITLE
    
    /** SNS投稿 */
    case STR_SHARE_TEXT
    case STR_SHARE_BUTTON
    
    /** ガイダンス画面 */
    case STR_INTRODUCTION_STEP_EXPLAIN
    case STR_INTRODUCTION_HEALTH_EXPLAIN
    
    var localized: String {
        get {
            NSLocalizedString(self.rawValue, comment: "")
        }
    }
}
