//
//  IntroductionView.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/12/20.
//

import SwiftUI
import PromiseKit

let STEP_GUIDANCE_IMAGE = "pedmetor-authorization-sample"
let STEP_PHONE_ICON = "phone-step"
let HEALTH_GUIDANCE_IMAGE = "health-authorization-sample"
let HEALTH_ICON = "health-icon"

struct IntroductioContent {
    let imageSrc: String
    let modalImageSrc: String
    let explainText: String
    let guidanceType: GuidanceType
    let imgaeSizeRatio: CGSize
}

/** ガイダンス画面 */
struct IntroductionView: View {
    
    @EnvironmentObject var setting: SettingData
    @State var showingModal: Bool = true
    
    let usease = IntroductionUsecaseServiece()
    
    var contents: [IntroductioContent] {
        get {
            [IntroductioContent(imageSrc: STEP_PHONE_ICON,
                                modalImageSrc: STEP_GUIDANCE_IMAGE,
                               explainText: AppText.STR_INTRODUCTION_STEP_EXPLAIN.localized,
                               guidanceType: .Pedmeter,
                               imgaeSizeRatio: CGSize(width: 0.3, height: 0.3)),
            IntroductioContent(imageSrc: HEALTH_ICON,
                               modalImageSrc: HEALTH_GUIDANCE_IMAGE,
                               explainText: AppText.STR_INTRODUCTION_HEALTH_EXPLAIN.localized,
                              guidanceType: .HealthCare,
                              imgaeSizeRatio: CGSize(width: 0.25, height: 0.25)),]
        }
    }
    
    @State var page: Int = 0
    @State var navigateActive: Bool = false
    
    var isLastPage: Bool {
        get {
            page >= contents.count - 1
        }
    }

    @ViewBuilder func destination() -> some View {
        DashboardView()
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack(alignment: .leading , content: {
                    HStack(alignment: .center, spacing: 0, content: {
                        Group {
                            IntroductionContentView(content: self.contents[0])
                            IntroductionContentView(content: self.contents[1])
                        }
                        .frame(width: geo.size.width)
                    })
                    .frame(width: geo.size.width * CGFloat(self.contents.count), height: geo.size.height * 0.8)
                    .offset(x: -(CGFloat(page) * geo.size.width), y:0)
                    
                    VStack {
                        Button(action: {
                            ModalUsecaseService.share.requestIntroductionModal(content: self.contents[self.page], dismiss: {
                                let _ = usease.requestAuthorization(type: contents[page].guidanceType)
                                    .done {
                                        if (isLastPage) {
                                            self.navigateActive = true
                                            return
                                        }
                                        withAnimation {
                                            self.page += 1
                                        }
                                    }
                            })
                        }, label: {
                            Text("連携")
                                .foregroundColor(.white)
                                .font(.system(size: 25))
                        })
                        .frame(width: geo.size.width * 0.8, height: 60)
                        .background(pinkColor)
                        .cornerRadius(15)
                        
                        PageViewControlView(page: $page, pageMax: contents.count)
                    }
                    .frame(width: geo.size.width ,height: geo.size.height * 0.2)
                })
                
                // 遷移先
                NavigationLink(destination: destination(), isActive: $navigateActive, label: {})
                    .hidden()
            }
        }
        .navigationBarTitle(Text("初期設定"), displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .background(Color.white)
        .onDisappear {
            SettingUsecaseServicce().setDidShowGuidance()
        }
    }
}

struct IntroductionContentView: View {
    var content: IntroductioContent
    
    init (content: IntroductioContent) {
        self.content = content
    }
    
    func GetAppIcon() -> UIImage {
        
      return UIImage(named: "AppIcon60x60")!
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                VStack {
                    HStack {
                        ZStack {
                            Image(content.imageSrc, bundle: .main)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geo.size.width * content.imgaeSizeRatio.width, height: geo.size.width * content.imgaeSizeRatio.height)
                                .shadow(radius: 0.5)
                        }
                        .frame(width: geo.size.width * 0.3, height: geo.size.width * 0.3)
                        
                        Arrow()
                            .fill()
                            .frame(width: 100, height: 100)
                            .foregroundColor(pinkColor)
                            .opacity(0.5)
                            .rotationEffect(.degrees(90))
                        ZStack {
                            Image(uiImage: GetAppIcon())
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geo.size.width * 0.25, height: geo.size.width * 0.25)
                        }
                        .frame(width: geo.size.width * 0.3, height: geo.size.width * 0.3)
                    }
                    
                    Spacer()
                        .frame(height: 40)
                
                    Text(content.explainText)
                        .font(.system(size: 16))
                        .frame(width: geo.size.width * 0.6, alignment: .leading)
                        .padding(.leading, 10)
                        .foregroundColor(commonTextColor)
                }
                .frame(alignment: .center)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .onAppear {

            }
        }
    }
}

struct IntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ZStack {
                NavigationView {
                    IntroductionView().environmentObject(SettingData(neeedShowGuidance: false))
                }
                
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    
                }
                .frame(width: 300, height: 400)
                .background(Color.white)
            }
//            NavigationView {
//                IntroductionView().environmentObject(SettingData(neeedShowGuidance: false))
//            }
        }
    }
}
