//
//  DashboardView.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/10/31.
//

import SwiftUI
import PromiseKit

class DashBordData: ObservableObject {
    @Published var stepData: [Int]
    @Published var heartRateData: [Int]
    @Published var burnCalorieData: [Int]
    
    init(stepData: [Int], heartRateData: [Int], burnCalorieData: [Int]) {
        self.stepData = stepData
        self.heartRateData = heartRateData
        self.burnCalorieData = burnCalorieData
    }
}

public struct DashboardView: View {
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
    
    let usecase: DashboardUsecaseService
    @State var selectedDate: Date = Date()
    
    init() {
        self.usecase = DashboardUsecaseService()
        self.selectedDate = Date()
    }
    
    public var body: some View {
        GeometryReader { geo in
            VStack(alignment: .center, spacing: nil, content: {
                DaySlider { (date: Date) in
                    self.reversed.toggle()
                    self.selectedDate = date
                }
                Group {
                    CardFactory.StepCard(datas: self.$dashboardData.stepData)
                    CardFactory.HeartRateCard(datas: self.$dashboardData.heartRateData)
                    CardFactory.BurnCalorieCard(datas: self.$dashboardData.burnCalorieData)
                }.frame(height: geo.size.height*0.3,
                        alignment: .center)
                Spacer()
                    .frame(height:.infinity)
                SyncButton(size: 70.0, action: {
                    self.synHealth()
                })
                
            }).padding(EdgeInsets(top: 0, leading: geo.size.width*0.05, bottom: 10, trailing: geo.size.width*0.05))
            .frame(width: .infinity, height: geo.size.height, alignment: .topLeading)
        }
        .background(dashbordBackColor)
    }
    
    func synHealth() {
        self.usecase.requestHealthAccess()
        .then { _ in
            self.usecase.getHeartRate(on: self.selectedDate)
        }
        .then { (entity: DayHeartrRateEntity?) -> Promise<DayStepEntity?> in
            if (entity != nil) {
                self.dashboardData.heartRateData = entity!.values
            }
            return self.usecase.getStep(on: self.selectedDate)
        }
        .then { (entity: DayStepEntity?) -> Promise<DayBurnCalorieEntity?> in
            if (entity != nil) {
                self.dashboardData.stepData = entity!.values
            }
            return self.usecase.getBurnCalorie(on: self.selectedDate)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DashboardView()
        }
    }
}
