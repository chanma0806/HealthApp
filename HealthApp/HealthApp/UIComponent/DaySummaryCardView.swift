//
//  DaySummaryCardView.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/11/28.
//

import SwiftUI

let MIN_DEGRESS = 360.0
let MAX_DEGRESS = 300.0


class SettingData: ObservableObject {
    @Published var goalValue: Int
    let neeedShowGuidance: Bool
    
    init(neeedShowGuidance: Bool) {
        self.goalValue = 0
        self.neeedShowGuidance = neeedShowGuidance
    }
}

/**
 - note:
    bindingプロパティのオブザーバー
    参考: https://stackoverflow.com/questions/58363563/swiftui-get-notified-when-binding-value-changes
 */
struct ChangeObserver<Base: View, Value: Equatable>: View {
    let base: Base
    let value: Value
    let action: (Value) -> Void
    @State private var oldValue: Value
    
    init(base: Base, value: Value, action: @escaping (Value) -> Void) {
        self.base = base
        self.value = value
        self.action = action
        _oldValue = State(initialValue: value)
    }
    
    var body: some View {
        if oldValue != value {
            oldValue = value
            self.action(self.value)
        }
        
        return base
    }
}

struct DaySummaryCardView: View {
        
    init (stepValue: Binding<Int>) {
        self._stepValue = stepValue
    }
    
    @EnvironmentObject var setting: SettingData
    @Binding var stepValue: Int
    @State var ringeProgerss: Double = 0.0
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ProgeressArcBar(progress: self.ringeProgerss, radius: (geo.size.height * 0.4))
                .stroke(Color.white, style: StrokeStyle(lineWidth: geo.size.width * 0.025, lineCap: .round))
                .rotationEffect(.degrees(120))
                .zIndex(2.0)
                
                ProgeressArcBar(progress: 1.0, radius: (geo.size.height * 0.4))
                .stroke(pinkColor, style: StrokeStyle(lineWidth: geo.size.width * 0.025, lineCap: .round))
                .opacity(0.2)
                .rotationEffect(.degrees(120))
                .zIndex(1.0)
                
                Text("\(stepValue)")
                    .font(.system(size: geo.size.width * 0.15))
                    .foregroundColor(.white)
                    .bold()
                    .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                
                HStack(spacing: geo.size.width * 0.01, content: {
                    Image("steps-icon", bundle: .main)
                        .resizable()
                        .frame(width: geo.size.width * 0.1, height: geo.size.width * 0.1)
                        .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                    Text("steps")
                        .font(.system(size: geo.size.width * 0.06))
                        .foregroundColor(.white)
                        .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                })
                .position(x: geo.size.width / 2.0, y: geo.size.height * 0.85)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .background(pinkGradient)
            .cornerRadius(20.0)
        }
        .onAppear {
            let ratio = Double(stepValue) / Double(setting.goalValue)
            self.ringeProgerss = ratio >= 1.0 ? 1.0 : ratio
        }
        .onDataChange(of: stepValue, perform: { _ in
            /** binding変更時 */
            let ratio = Double(stepValue) / Double(setting.goalValue)
            withAnimation(.linear, {
                self.ringeProgerss = ratio >= 1.0 ? 1.0 : ratio
            })
        })
    }
}

struct ProgeressArcBar: Shape {
    
    var progress: Double
    let radius: CGFloat
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let startDegrees = (progress == 0.0) ? 360.0 : (MAX_DEGRESS * progress)
        path.addArc(center: CGPoint(x: rect.size.width / 2.0, y: rect.size.height / 2.0), radius: radius, startAngle: Angle(degrees: startDegrees), endAngle: Angle(degrees: 360.0), clockwise: true)
        
        return path
    }
    
    var animatableData: Double {
        get {
            progress
        }
        set (newProgess) {
            progress = newProgess
        }
    }
    
}


struct DaySummaryCardView_Previews: PreviewProvider {
    static var previews: some View {
        DaySummaryCardView(stepValue: .constant(9000))
            .frame(width: 350, height: 300, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
}

extension View {
    func onDataChange<Value: Equatable>(of value: Value, perform action: @escaping (_ newValue: Value) -> Void) -> some View {
        Group {
            if #available(iOS 14.0, *) {
                self.onChange(of: value, perform: action)
            } else {
                ChangeObserver(base: self, value: value, action: action)
            }
        }
    }
}
