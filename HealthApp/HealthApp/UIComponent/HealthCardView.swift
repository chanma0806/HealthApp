//
//  HealthCardView.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/11/01.
//

import SwiftUI

enum GraphCase: Int {
    case Bar
    case Line
}

extension CGFloat {
    func between(a: CGFloat, b: CGFloat) -> Bool {
        return self >= Swift.min(a, b) && self <= Swift.max(a, b)
    }
}

/**
   カードビューのファクトリー
 */
public class CardFactory {
    @ViewBuilder
    static func StepCard(datas: Binding<[Int]>) -> some View {
        HealthCardView(title: "Steps", cardColor: greenGradient, graph: .Bar, datas: datas)
    }
    
    @ViewBuilder
    static func HeartRateCard(datas: Binding<[Int]>) -> some View {
        HealthCardView(title: "Heart Rate", cardColor: redGradient, graph: .Line, datas: datas)
    }
    
    @ViewBuilder
    static func BurnCalorieCard(datas: Binding<[Int]>) -> some View {
        HealthCardView(title: "Burn Calorie", cardColor: orangeGradient, graph: .Bar, datas: datas)
    }
}

/**
  カードビュー
 */
struct HealthCardView: View {
    let title: String
    let cardColor: LinearGradient
    let graphCase: GraphCase
    @Binding var datas: [Int]
    
    init(title: String, cardColor: LinearGradient, graph: GraphCase, datas: Binding<[Int]>) {
        self.title = title
        self.cardColor = cardColor
        self.graphCase = graph
        self._datas = datas
    }
    
    @ViewBuilder
    private func graphBuild() -> some View {
        switch self.graphCase {
        case .Bar:
            GraphView(self.datas, graphType: .bar)
        case .Line:
            GraphView(self.datas, graphType: .line)
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading, spacing: 0, content: {
                Text(self.title)
                    .foregroundColor(commonTextColor)
                    .font(.system(size: 25))
                    .frame(width: geo.size.width*0.9, alignment: .leading)
                Spacer()
                    .frame(height: 20)
                self.graphBuild()
                    .frame(width: geo.size.width*0.9, height: 100)
                    
            })
            .padding(EdgeInsets(top: 10.0, leading: geo.size.width * 0.05, bottom: 10.0, trailing: geo.size.width * 0.05))
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            .background(self.cardColor)
            .cornerRadius(20)
            .shadow(radius: 5)
        }
    }
}

struct HealthCard_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            VStack(alignment: .center, spacing: nil, content: {
                CardFactory.HeartRateCard(datas: .constant(LinerGraph.getDummyDatas()))
                    .frame(height: geo.size.height*0.3)
            })
            .padding(EdgeInsets(top: 0.0, leading: geo.size.width*0.1, bottom: 0.0, trailing: geo.size.width*0.1))
        }
    }
}
