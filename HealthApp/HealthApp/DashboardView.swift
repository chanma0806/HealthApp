//
//  DashboardView.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/10/31.
//

import SwiftUI

public struct DashboardView: View {
    public var body: some View {
        GeometryReader { geo in
            VStack(alignment: .center, spacing: nil, content: {
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 0, content: {
                    Triangle(size: 20, color: commonTextColor).rotationEffect(Angle(degrees: 180))
                    Spacer()
                        .frame(width:10)
                    Text("2020/")
                        .font(.system(size: 15))
                    Text("10/30")
                        .font(.system(size: 20))
                        .bold()
                    Spacer()
                        .frame(width:10)
                    Triangle(size: 20, color: commonTextColor)
                })
                    Group {
                        CardFactory.StepCard()
                        CardFactory.HeartRateCard()
                    }.frame(width: .infinity,
                            height: geo.size.height*0.3,
                            alignment: .center)
                Spacer()
                    .frame(height:.infinity)
                SyncButton(size: 70.0)
                
            }).padding(EdgeInsets(top: 0, leading: geo.size.width*0.05, bottom: 10, trailing: geo.size.width*0.05))
            .frame(width: .infinity, height: geo.size.height, alignment: .topLeading)
        }
        .background(dashbordBackColor)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DashboardView()
        }
    }
}
