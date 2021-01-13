//
//  ModalUsecaseService.swift
//  Meters
//
//  Created by 丸山大幸 on 2020/12/28.
//

import Foundation
import SwiftUI

class ModalUsecaseService {
    static let share = ModalUsecaseService()
    var delegate: ModalDelegate?
    
    init () {
        
    }
    
    func requestSNSShareModal(content: ShareCardData, dismiss: @escaping ()->Void) {
        self.delegate?.modalContent = ModalContent(snsShareContent: content, dismissAction: dismiss)
        self.delegate?.recievedModalRequest(type: .SNSShare)
    }
    
    func requestIntroductionModal(content: IntroductioContent, dismiss: @escaping ()->Void) {
        self.delegate?.modalContent = ModalContent(introductionContent: content, dismissAction: dismiss)
        self.delegate?.recievedModalRequest(type: .Introduction)
    }
}

enum ModalType {
    case SNSShare
    case Introduction
}

struct ModalContent {
    /**  ビューモデル */
    var introductionContent: IntroductioContent?
    var snsShareContent: ShareCardData?
    
    /** ハンドラー */
    var dismissAction: (()->Void)?
}

protocol ModalDelegate {
    var modalType: ModalType? { get set }
    var modalContent: ModalContent { get set }

    func recievedModalRequest(type: ModalType)
}

extension ModalDelegate {
    @ViewBuilder func showModalIntroduction(_ dismissAction: @escaping ()->Void) -> some View {
        let content = modalContent.introductionContent!
        GeometryReader { geo in
            ZStack {
                VStack(alignment: .trailing, content: {
                    Image(content.modalImageSrc, bundle: .main)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geo.size.width * 0.7, height: geo.size.width * 0.7)
                    
                    Button(action: {
                        dismissAction()
                        self.modalContent.dismissAction?()
                    }, label: {
                        Text("OK")
                            .font(.system(size: 16.0))
                            .bold()
                    })
                    .frame(width: 100, height: 40, alignment: .center)
                    .foregroundColor(.white)
                    .background(pinkColor)
                    .cornerRadius(35.0)
                })
                .padding(20)
                .background(Color.white)
                .cornerRadius(25)
            }.frame(width: geo.size.width, height: geo.size.height, alignment: .center)
        }
    }
    
    @ViewBuilder func showModalSnsShare(_ dismissAction: @escaping ()->Void) -> some View {
        let shareCardData = self.modalContent.snsShareContent!
        GeometryReader { geo in
            ZStack {
                /** モーダル背景 */
                Button(action: {
                    dismissAction()
                    self.modalContent.dismissAction?()
                }, label: {
                    Color.clear
                })
                
                /** モーダル  */
                SociaShareModalView(
                    cardData: shareCardData,
                    dismisssAction: {
                        withAnimation {
                            dismissAction()
                            self.modalContent.dismissAction?()
                        }
                    })
                    .frame(width: geo.size.width * 0.8, height: geo.size.height * 0.5, alignment: .center)
                    .animation(.easeIn(duration: 0.2))
                    .transition(.move(edge: .bottom))
            }
            .frame(alignment: .center)
            .edgesIgnoringSafeArea(.all)
        }
    }
}
