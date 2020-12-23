//
//  AppBaseView.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/12/23.
//

import SwiftUI

struct AppBaseView: View {
    @EnvironmentObject var setting: SettingData
    var needGuidance: Bool {
        get {
            setting.neeedShowGuidance
        }
    }
    var body: some View {
        if needGuidance {
            NavigationView {
                IntroductionView()
            }
        } else {
            DashboardView()
        }
    }
}

struct AppBaseView_Previews: PreviewProvider {
    static var previews: some View {
        AppBaseView()
    }
}
