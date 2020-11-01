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

struct HealthCardView: View {
    let title: String
    let cardColor: LinearGradient
    let graphCase: GraphCase
    
    init(title: String, cardColor: LinearGradient, graph: GraphCase) {
        self.title = title
        self.cardColor = cardColor
        self.graphCase = graph
    }
    
    @ViewBuilder
    private func graphBuild() -> some View {
        switch self.graphCase {
        case .Bar:
            VerticalGraphView()
        case .Line:
            LineGraphView()
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
            .cornerRadius(25)
            .shadow(radius: 5)
        }
    }
}

struct GraphData: Identifiable{
    var id: String
    var value: Int
    
    init (id: String, value: Int) {
        self.id = id
        self.value = value
    }
}

struct VerticalGraphView: View {
    var body: some View {
    
        let rawData: [Int] = [
            0, /* 00:00 */
            0, /* 01:00 */
            0, /* 02:00 */
            0, /* 03:00 */
            0, /* 04:00 */
            0, /* 05:00 */
            300, /* 06:00 */
            400, /* 07:00 */
            1201, /* 08:00 */
            390, /* 09:00 */
            43, /* 10:00 */
            40, /* 11:00 */
            500, /* 12:00 */
            40, /* 13:00 */
            34, /* 14:00 */
            35, /* 15:00 */
            50, /* 16:00 */
            54, /* 17:00 */
            64, /* 18:00 */
            870, /* 19:00 */
            350, /* 20:00 */
            200, /* 21:00 */
            150, /* 22:00 */
            0, /* 23:00 */
            0, /* 24:00 */
        ]
        let maxValue = rawData.max()!
        let datas: [GraphData] = rawData.enumerated().map{
            GraphData(id: String($0.offset), value: $0.element)
        }
        GeometryReader { geo in
            let graphWidth = geo.size.width
            let graphHeight = geo.size.height * 0.9
            let barAreaWidth = graphWidth / CGFloat(datas.count)
            let barWidth = barAreaWidth / 1.5
            let barOffset = barAreaWidth - barWidth
            
            HStack(alignment: .bottom, spacing: 0, content: {
                ForEach(datas, content: { d in
                    VStack(alignment: .center , spacing: 0, content: {
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: barWidth, height: CGFloat(d.value) / CGFloat(maxValue) * graphHeight)
                            .animation(.linear(duration: 0.5))
                        let xTick = Int(d.id)! % 2 == 0 ? d.id : ""
                        Text(xTick)
                            .font(.system(size: barWidth))
                            .foregroundColor(.white)
                            .bold()
                            .frame(width: barWidth + barOffset, height: barWidth + barOffset, alignment: .center)
                    }).frame(alignment: .bottomTrailing)
                })
            })
        }
    }
}

struct LineGraphView: View {
    
    private func getDummyData() -> [Int] {
        return [
            50, /* 00:00 */
            70, /* 01:00 */
            60, /* 02:00 */
            55, /* 03:00 */
            90, /* 04:00 */
            60, /* 05:00 */
            80, /* 06:00 */
            72, /* 07:00 */
            75, /* 08:00 */
            60, /* 09:00 */
            90, /* 10:00 */
            69, /* 11:00 */
            100, /* 12:00 */
            122, /* 13:00 */
            99, /* 14:00 */
            101, /* 15:00 */
            110, /* 16:00 */
            80, /* 17:00 */
            87, /* 18:00 */
            80, /* 19:00 */
            75, /* 20:00 */
            80, /* 21:00 */
            75, /* 22:00 */
            70, /* 23:00 */
            63, /* 24:00 */
        ]
    }
    
    private func getPoints(_ datas: [Int], barAreaWidth: CGFloat, graphHeight: CGFloat, minValue:Int, maxValue: Int) -> [CGPoint] {
        datas.enumerated().map {
            let x: CGFloat = (CGFloat($0.offset) + 0.5) * barAreaWidth
            let y: CGFloat = (1.0 - (CGFloat($0.element) - CGFloat(minValue)) / CGFloat(maxValue - minValue)) * graphHeight
            return CGPoint(x: x, y: y)
        }
    }
    
    var body: some View {
        
        let rawData: [Int] = self.getDummyData()
        let maxValue = rawData.max()!
        let minValue = rawData.min()!
        let datas: [GraphData] = rawData.enumerated().map{
            GraphData(id: String($0.offset), value: $0.element)
        }
        
        return GeometryReader { geo in
            let graphWidth: CGFloat = geo.size.width
            let graphHeight: CGFloat = (geo.size.height * 0.9)
            let barAreaWidth: CGFloat = graphWidth / CGFloat(datas.count)
            let barWidth: CGFloat = barAreaWidth / 1.5
            let barOffset: CGFloat = barAreaWidth - barWidth
            let drawHeiht:CGFloat = graphHeight - (barWidth + barOffset)
            ZStack {
                HStack(alignment: .bottom, spacing: 0, content: {
                    ForEach(datas, content: { d in
                        VStack(alignment: .center , spacing: 0, content: {
                            let xTick: String = Int(d.id)! % 2 == 0 ? d.id : ""
                            Text(xTick)
                                .font(.system(size: barWidth))
                                .foregroundColor(.white)
                                .bold()
                                .frame(width: barWidth + barOffset, height: barWidth + barOffset, alignment: .center)
                        }).frame(height: graphHeight, alignment: .bottomTrailing)
                    })
                })
                VStack(alignment: .center, spacing:0, content: {
                    Path { path in
                        let graphPoints: [CGPoint] = self.getPoints(rawData, barAreaWidth: barAreaWidth, graphHeight: drawHeiht, minValue: minValue, maxValue: maxValue)
                        path.move(to: graphPoints[0])
                        graphPoints.forEach { point in
                            path.addLine(to: point)
                        }
                    }
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 1, lineCap: .round))
                })
            }
        }
    }
}

public class CardFactory {
    static func StepCard() -> some View {
        HealthCardView(title: "Steps", cardColor: greenGradient, graph: .Bar)
    }
    
    static func HeartRateCard() -> some View {
        HealthCardView(title: "Heart Rate", cardColor: redGradient, graph: .Line)
    }
}

struct HealthCard_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            VStack(alignment: .center, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                CardFactory.HeartRateCard()
                    .frame(height: geo.size.height*0.3)
//                LineGraphView()
            })
            .padding(EdgeInsets(top: 0.0, leading: geo.size.width*0.1, bottom: 0.0, trailing: geo.size.width*0.1))
        }
    }
}
