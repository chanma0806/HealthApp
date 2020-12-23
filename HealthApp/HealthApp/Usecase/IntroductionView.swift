//
//  IntroductionView.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/12/20.
//

import SwiftUI
import PromiseKit

let STEP_GUIDANCE_IMAGE = "pedmetor-authorization-sample"
let STEP_GUIDANCE_TITLE = "モーション連携"
let STEP_GUIDANCE_TEXT = "お使いのiPhoneから歩数データを取得します"

let HEALTH_GUIDANCE_IMAGE = "health-authorization-sample"
let HEALTH_GUIDANCE_TITLE = "ヘルスケア連携"
let HEALTH_GUIDANCE_TEXT = "「ヘルスケア」のデータをアプリに表示します"

struct IntoductioContent {
    let imageSrc: String
    let explainTitle: String
    let explainText: String
    let guidanceType: GuidanceType
}

struct IntroductionView: View {
    
   @EnvironmentObject var setting: SettingData
    
    let usease = IntroductionUsecaseServiece()
    
    var contents: [IntoductioContent] {
        get {
            [IntoductioContent(imageSrc: STEP_GUIDANCE_IMAGE,
                               explainTitle: STEP_GUIDANCE_TITLE,
                               explainText: STEP_GUIDANCE_TEXT,
                               guidanceType: .Pedmeter),
             
            IntoductioContent(imageSrc: HEALTH_GUIDANCE_IMAGE,
                              explainTitle: HEALTH_GUIDANCE_TITLE,
                              explainText: HEALTH_GUIDANCE_TEXT,
                              guidanceType: .HealthCare)]
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
                    }, label: {
                        Text("OK")
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
            
            NavigationLink(destination: destination(), isActive: $navigateActive, label: {})
                .hidden()
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
    var content: IntoductioContent
    
    init (content: IntoductioContent) {
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                VStack {
                    Image(content.imageSrc, bundle: .main)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geo.size.width * 0.8,
                               height: geo.size.width * 0.8)
                    
                    VStack(spacing: 20, content: {
                        Text(content.explainTitle)
                            .font(.system(size: 20))
                            .bold()
                            .frame(width: geo.size.width * 0.8, alignment: .leading)
                        
                        Text(content.explainText)
                            .font(.system(size: 20))
                            .frame(width: geo.size.width * 0.8, alignment: .leading)
                            .padding(.leading, 10)
                    })
                    .frame(width: geo.size.width * 0.8)
                    .foregroundColor(commonTextColor)
                }
                .frame(alignment: .top)
            }
            .padding(.leading, geo.size.width * 0.1)
            .padding(.trailing, geo.size.width * 0.1)
            .onAppear {

            }
        }
    }
}

struct IntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
        IntroductionView()
        }
    }
}
