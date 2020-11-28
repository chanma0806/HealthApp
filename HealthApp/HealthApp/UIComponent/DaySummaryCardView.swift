//
//  DaySummaryCardView.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/11/28.
//

import SwiftUI

let MIN_DEGRESS = 360.0
let MAX_DEGRESS = 300.0

struct DaySummaryCardView: View {
    
    @State var ringeProgerss: Double = 0.0
    var goalValue: Int = 10000
    var stepValue: Int = 9000
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ProgeressArcBar(progress: self.ringeProgerss, radius: (geo.size.height * 0.4))
                .stroke(Color.white, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(120))
                Text("\(stepValue)")
                    .font(.system(size: geo.size.width * 0.15))
                    .foregroundColor(.white)
                    .bold()
                    .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                
                HStack{
                    Image("steps-icon", bundle: .main)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                    Text("steps")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                }
                .position(x: geo.size.width / 2.0, y: geo.size.height * 0.85)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .background(pinkGradient)
            .cornerRadius(20.0)
        }
        .onAppear {
            let ratio = Double(stepValue) / Double(goalValue)
            withAnimation(.linear, {
                self.ringeProgerss = ratio >= 1.0 ? 1.0 : ratio
            })
        }
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
        DaySummaryCardView()
            .frame(width: 350, height: 300, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
}
