//
//  DashboardView.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/10/31.
//

import SwiftUI
import PromiseKit

public struct DashboardView: View {
    public var body: some View {
        CustomNavigationView(content: DashboardViewContext(), to: SettingView())
        .edgesIgnoringSafeArea(.all)
    }
}

class DashBordData: ObservableObject {
    @Published var dayTotalStep: Int
    @Published var stepData: [Int]
    @Published var heartRateData: [Int]
    @Published var burnCalorieData: [Int]
    
    init(stepData: [Int], heartRateData: [Int], burnCalorieData: [Int]) {
        self.dayTotalStep = 0
        self.stepData = stepData
        self.heartRateData = heartRateData
        self.burnCalorieData = burnCalorieData
    }
    
    func startObserveTodayUpdate() {
        NotificationCenter.default.addObserver(self, selector: #selector(recievedEvnet(_:)), name: .init(UPDATE_STEP_VALUE), object: nil)
    }
    
    func stopObserveTodayUpdate() {
        NotificationCenter.default.removeObserver(self, name: .init(UPDATE_STEP_VALUE), object: nil)
    }
    
    @objc func recievedEvnet(_ notification: Notification) {
        DispatchQueue.main.async {
            if let entity = notification.object as? DailyStepData {
                self.dayTotalStep = entity.step
            }
        }
    }
}

struct DashboardViewContext: View, NavigateReuest {
    var delegate: NavigateReuestDelegate?
    
    @EnvironmentObject var setting: SettingData
    @State var reversed: Bool = false {
        willSet(newReversed) {
            if (newReversed) {
                self.dashboardData.stepData = LinerGraph.getDummyDatas()
                self.dashboardData.heartRateData = GraphView.getDummyDatas()
            } else {
                self.dashboardData.stepData = GraphView.getDummyDatas()
                self.dashboardData.heartRateData = LinerGraph.getDummyDatas()
            }
        }
    }
    @ObservedObject var dashboardData: DashBordData = DashBordData(
        stepData: GraphView.getDummyDatas(),
        heartRateData: LinerGraph.getDummyDatas(),
        burnCalorieData: GraphView.getDummyDatas()
    )
    
    let dashboardUsecase: DashboardUsecaseService
    let fetchUsecase: StepFetchUsecaeService
    @State var selectedDate: Date = Date()
    @State var isShowingShareModal: Bool = false
    
    var shareCardData: ShareCardData {
        get {
            return ShareCardData(summaryTotalStep: dashboardData.dayTotalStep,
                                 steps: dashboardData.stepData,
                                 heartRates: dashboardData.heartRateData,
                                 calories: dashboardData.burnCalorieData)
        }
    }
    
    init() {
        self.dashboardUsecase = DashboardUsecaseService()
        self.fetchUsecase = StepFetchUsecaeService()
        self.selectedDate = Date()
    }
    
    public var body: some View {
        GeometryReader { geo in
            ZStack {
                /** バックグラウンドカラー */
                dashbordBackColor
                .edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .center, spacing: nil, content: {
                    /** ヘッダー */
                    HStack{
                        Button(action: {
                            self.requestNavigation()
                        }, label: {
                            MenuButton()
                        })
                        DaySlider { (date: Date) in
                            self.reversed.toggle()
                            self.selectedDate = date
                            
                            if (Calendar.current.isDateInToday(date)) {
                                self.dashboardData.startObserveTodayUpdate()
                            } else {
                                self.dashboardData.stopObserveTodayUpdate()
                            }
                            
                            self.fetchUsecase.getDailyStep(on: selectedDate)
                                .done { (entity: DailyStepData?) in
                                    let step = entity?.step ?? 0
                                    self.dashboardData.dayTotalStep = step
                                }
                                .catch { _ in
                                    
                                }
                        }.frame(width: geo.size.width * 0.8, height: 30)
                        
                        Button(action: {
                            withAnimation {
                                isShowingShareModal.toggle()
                            }
                        }, label: {
                            Image(systemName: "square.and.arrow.up")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .foregroundColor(commonTextColor)
                        })
                    }
                    Spacer()
                        .frame(height: 15)
                    
                    /** カードエリア */
                    ScrollView {
                        Group {
                            DaySummaryCardView(stepValue: self.$dashboardData.dayTotalStep)
                                .frame(height: geo.size.height*0.4,
                                        alignment: .center)
                            Group {
                                CardFactory.StepCard(datas: self.$dashboardData.stepData)
                                CardFactory.HeartRateCard(datas: self.$dashboardData.heartRateData)
                                CardFactory.BurnCalorieCard(datas: self.$dashboardData.burnCalorieData)
                            }
                            .frame(height: geo.size.height*0.3)
                        }
                         .frame(width: geo.size.width * 0.9)
                        Spacer()
                            .frame(height:.infinity)
                        SyncButton(size: 70.0, action: {
                            self.synHealth()
                        })
                    }
                    .padding(EdgeInsets(top: 0, leading: geo.size.width*0.04, bottom: 10, trailing: geo.size.width*0.04))
                    
                })
                .frame(width: .infinity, height: geo.size.height, alignment: .topLeading)
                
                ZStack {
                    if isShowingShareModal {
                        Color.black.opacity(0.4)
                        SociaShareModalView(
                            cardData: shareCardData,
                            dismisssAction: {
                                withAnimation {
                                    isShowingShareModal.toggle()
                                }
                            })
                            .frame(width: 320, height: 380, alignment: .center)
                            .animation(.easeIn(duration: 0.2))
                            .transition(.move(edge: .bottom))
                        }
                }.edgesIgnoringSafeArea(.all)
            }
        }
        .onAppear {
            /** フェッチ監視 */
            self.fetchUsecase.startFetchStep()
            self.dashboardData.startObserveTodayUpdate()
            
            /** 現在日のデータを取得 */
            self.fetchUsecase.getDailyStep(on: selectedDate)
                .done { (entity: DailyStepData?) in
                    let step = entity?.step ?? 0
                    self.dashboardData.dayTotalStep = step
                }
                .catch { _ in
                    
                }
        }
    }
    
    func synHealth() {
        self.dashboardUsecase.requestHealthAccess()
        .then { _ in
            self.dashboardUsecase.getHeartRate(on: self.selectedDate)
        }
        .then { (entity: DayHeartrRateEntity?) -> Promise<DayStepEntity?> in
            if (entity != nil) {
                self.dashboardData.heartRateData = entity!.values
            }
            return self.dashboardUsecase.getStep(on: self.selectedDate)
        }
        .then { (entity: DayStepEntity?) -> Promise<DayBurnCalorieEntity?> in
            if (entity != nil) {
                self.dashboardData.stepData = entity!.values
            }
            return self.dashboardUsecase.getBurnCalorie(on: self.selectedDate)
        }
        .done { (entity: DayBurnCalorieEntity?) in
            if (entity != nil) {
                self.dashboardData.burnCalorieData = entity!.values
            }
        }
        .catch { _ in
            
        }
    }
}

typealias DayChanged = (_ changedDay: Date) -> Void

struct DaySlider: View {
    let dayChanged: DayChanged
    @State var date: Date = Date() {
        didSet {
            self.dayChanged(self.date)
        }
    }
    
    init(dayChanged: @escaping DayChanged) {
        self.dayChanged = dayChanged
    }
    
    var body: some View {
        HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 0, content: {
            TriangleButton {
                self.date = self.addDay(-1, date: self.date)
            }
                .rotationEffect(Angle(degrees: 180))
            HStack {
                Text(self.yearString + "/")
                    .font(.system(size: 15))
                Text(self.monthString + "/" + self.dayString)
                    .font(.system(size: 20))
                    .bold()
            }.frame(width: 110)
            let opacity = Calendar.current.isDateInToday(self.date) ? 0.7 : 1.0
            TriangleButton {
                // action
                let ret = self.addDay(1, date: self.date)
                guard (self.isOverThanNow(date: ret)) else {
                    return
                }
                self.date = ret
            }
            .opacity(opacity)
            .frame(alignment: .bottomTrailing)
            
        })
    }
    
    // 指定日数追加する
    private func addDay(_ addDays: Int, date: Date) -> Date {
        let calendar = Calendar.current
        let ret = calendar.date(byAdding: .day, value: addDays, to: date) ?? Date()
        return ret
    }

    // 現在日を超えたか
    private func isOverThanNow(date: Date) -> Bool {
        let calendar = Calendar.current
        let set: Set<Calendar.Component> = [.year, .month, .day]
        let nowComponent: DateComponents = calendar.dateComponents(set, from: Date())
        let dateComponent: DateComponents = calendar.dateComponents(set, from: date)
        let compared = calendar.dateComponents(set, from: dateComponent, to: nowComponent)
        
        return (compared.day! > 0 && compared.month! > 0 && compared.year! > 0)
    }
    
    var dayString: String {
        get {
            String(Calendar.current.component(.day, from: self.date))
        }
    }
    
    var monthString: String {
        get {
            String(Calendar.current.component(.month, from: self.date))
        }
    }
    
    var yearString: String {
        get {
            String(Calendar.current.component(.year, from: self.date))
        }
    }
}

struct TriangleButton: View {
    let action: ()->Void
    init(_ action: @escaping ()->Void) {
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            Triangle(size: 20, color: commonTextColor)
                .frame(width: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        })
    }
}

struct MenuButton: View {
    var body: some View {
        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 5, content: {
            ForEach(0 ..< 3, content: { _ in
                Rectangle()
                    .fill()
                    .frame(width: 20, height: 2)
                    .foregroundColor(commonTextColor)
            })
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DashboardViewContext()
        }
    }
}
