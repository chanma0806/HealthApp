//
//  AppBaseView.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/12/23.
//

import SwiftUI

struct AppBaseView: View, ModalDelegate {
    @State var modalType: ModalType? = nil
    @State var modalContent: ModalContent = ModalContent()
    @EnvironmentObject var setting: SettingData
    var needGuidance: Bool {
        get {
            setting.neeedShowGuidance
        }
    }
    
    init () {
        
    }
    
    var body: some View {
        ZStack {
            if needGuidance {
                NavigationView {
                    IntroductionView()
                }
            } else {
                DashboardView()
            }
            
            /** モーダル */
            
            if modalType != nil {
                Color.black
                    .opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
            }
                
            if modalType != nil {
                Group {
                    switch modalType! {
                    case .SNSShare:
                        showModalSnsShare {
                            self.modalType = nil
                        }
                    case .Introduction :
                        showModalIntroduction {
                            self.modalType = nil
                        }
                    }
                }
                .transition(.move(edge: .bottom))
            }
        }
        .onAppear {
            ModalUsecaseService.share.delegate = self
        }
    }
    
    func recievedModalRequest(type: ModalType) {
        withAnimation {
            self.modalType = type
        }
    }
}

struct AppBaseView_Previews: PreviewProvider {
    static var previews: some View {
        AppBaseView()
    }
}
