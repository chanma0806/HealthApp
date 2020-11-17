//
//  BarGraphView.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/11/03.
//

import SwiftUI


// MARK: View

/**
    バーグラフビュー
 */
public struct BarGraphView: View {
    let rawDatas: [Int]
    lazy var _grapScale: GraphScaleData = self.makeGraphScaleData(rawDatas)
    var grapScale: GraphScaleData {
        get {
            var mutatingSelf = self
            return mutatingSelf._grapScale
        }
    }
    init(_ datas: [Int]) {
        self.rawDatas = datas
    }
    
    public static func getDummyDatas() -> [Int] {
        return  [
            300, /* 00:00 */
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
            300, /* 23:00 */
        ]
    }
    
    public var body: some View {
        let maxValue = self.rawDatas.max() ?? 0
        let datas: [GraphData] = rawDatas.enumerated().map{
            GraphData(id: String($0.offset), value: $0.element)
        }
        GeometryReader { geo in
            let graphWidth: CGFloat = geo.size.width
            let graphHeight: CGFloat  = geo.size.height * 0.9
            let barAreaWidth: CGFloat  = graphWidth / CGFloat(datas.count)
            let barWidth: CGFloat  = barAreaWidth / 1.5
            let barOffset: CGFloat  = barAreaWidth - barWidth
            let yticks: [YtickData] = self.makeYticks(scale: self.grapScale, graphHeight: graphHeight)
            let property = BarGraph.calcProperty(graphHeight: graphHeight, graphWidth: graphWidth, barOffset: barOffset, barWidth: barWidth, maxValue: maxValue)
            
            HStack(alignment: .top, spacing: 0, content: {
                // Y軸
                ZStack {
                    ForEach(yticks, content: { (d: YtickData) in
                        Text(d.id)
                        .font(.system(size: barWidth))
                        .foregroundColor(.white)
                        .bold()
                        .position(x: barWidth / 2, y: d.yPosition)
                        .frame(width: barWidth * 3.0, height: barWidth)
                    })
                }
                .frame(width: barWidth * 3.0, height: graphHeight, alignment: .topLeading)
                VStack {
                    BarGraph(datas: datas, property: property)
                    // X軸
                    HStack(alignment: .bottom, spacing: 0, content: {
                        ForEach((0 ..< 24), content: { num in
                            VStack(alignment: .center , spacing: 0, content: {
                                let xTick: String = num % 2 == 0 ? String(num) : ""
                                Text(xTick)
                                    .font(.system(size: barWidth))
                                    .foregroundColor(.white)
                                    .bold()
                                    .frame(width: barWidth + barOffset, height: barWidth + barOffset, alignment: .center)
                            }).frame(height: barWidth + barOffset, alignment: .bottomTrailing)
                        })
                    })
                }
            })
        }
    }
    
    private func makeYticks(scale: GraphScaleData, graphHeight: CGFloat) -> [YtickData] {
        var yticks: [YtickData] = []
        var ytickValue: CGFloat = scale.topY
        while ytickValue >= scale.bottomY {
            let ytick: YtickData  = YtickData(id: "\(Int(ytickValue))", value: Int(ytickValue), bottom: scale.bottomY, height: scale.topY, graphHeight: graphHeight)
            yticks.append(ytick)
            ytickValue += -100.0
        }
        
        return yticks
    }
    
    mutating private func makeGraphScaleData(_ datas: [Int]) -> GraphScaleData {
        let maxValue = CGFloat(datas.max()!)
        let topValue = (CGFloat(maxValue) * (1.05)).roundedUp(tenPow: 2)
        
        return GraphScaleData(topY: topValue,
                              bottomY: 0.0,
                              rangeY: 0.0,
                              maxValue: maxValue,
                              minValue: 0.0)
    }
}

public struct NoDataGraph: View {
    
    private static var noDataRawValues: [Int] {
        get {
            [20, 60, 100, 80, 40, 15]
        }
    }
    
    let viewProperty: ViewProperty
    
    init(property: ViewProperty) {
        self.viewProperty = property
    }
    
    public var body: some View {
        
        let noDatas: [GraphData] = NoDataGraph.noDataRawValues.map { (num: Int) -> GraphData in
            GraphData(id: String(num), value: num)
        }
        
        ZStack {
            Text("No Data")
                .font(.system(size: 20.0))
                .bold()
                .foregroundColor(.white)
                .zIndex(2.0)
            HStack(alignment: .bottom, spacing: viewProperty.barOffset, content: {
                ForEach(noDatas, content: { d in
                    // グラフエリア
                    Rectangle()
                        .fill(noDataColor)
                        .frame(width: viewProperty.barWidth, height: CGFloat(d.value) / CGFloat(150) * viewProperty.graphHeight)
                })
            }).frame(height: viewProperty.graphHeight,alignment: .bottomTrailing)
        }
    }
    
    public static func calcProperty(parentWidth: CGFloat, parentHeight: CGFloat) -> ViewProperty {
        let offset: CGFloat = 5.0
        let barWidth: CGFloat = (parentWidth - 5.0 * CGFloat(noDataRawValues.count - 1)) / CGFloat(noDataRawValues.count)
        
        return ViewProperty(graphHeight: parentWidth, graphWidth: parentHeight, barWidth: barWidth, barOffset: offset)
    }
}

public struct BarGraph: View {
    
    let datas: [GraphData]
    let viewProperty: ViewProperty
    
    init(datas: [GraphData], property: ViewProperty) {
        self.datas = datas
        self.viewProperty = property
    }
    
    public var body: some View {
        let calcBarHeight = viewProperty.heigthScaler!
        HStack(alignment: .bottom, spacing: viewProperty.barOffset, content: {
            ForEach(datas, content: { d in
                // グラフエリア
                Rectangle()
                    .fill(Color.white)
                    .frame(width: viewProperty.barWidth, height: calcBarHeight(d.value))
                    .animation(.linear(duration: 0.5))
            })
        }).frame(height: viewProperty.graphHeight, alignment: .bottomTrailing)
    }
    
    public static func calcProperty(graphHeight: CGFloat, graphWidth: CGFloat, barOffset: CGFloat, barWidth: CGFloat, maxValue: Int) -> ViewProperty {
        
        return ViewProperty(graphHeight: graphHeight, graphWidth: graphWidth, barWidth: barWidth, barOffset: barOffset, maxValue: maxValue)
    }
}

// MARK: Model

public struct ViewProperty {
    let graphHeight: CGFloat
    let graphWidth: CGFloat
    let barWidth: CGFloat
    let barOffset: CGFloat
    private let maxValue: Int
    var heigthScaler: ((_ dataValue: Int) -> CGFloat)? {
        get {
            guard maxValue != 0 else {
                return nil
            }
            return {
                (dataValue: Int) -> CGFloat in
                return (CGFloat(dataValue) / CGFloat(maxValue) * graphHeight)
            }
        }
    }
    
    init(graphHeight: CGFloat, graphWidth: CGFloat, barWidth: CGFloat = 0.0, barOffset: CGFloat = 0.0, maxValue: Int = 0) {
        self.graphHeight = graphHeight
        self.graphWidth = graphWidth
        self.barWidth = barWidth
        self.barOffset = barOffset
        self.maxValue = maxValue
    }
}


// MARK: Preview

struct BarGraphView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            BarGraphView(BarGraphView.getDummyDatas())
        }
        .frame(width: 300, height: 250, alignment: .center)
        .padding()
        .background(greenGradient)
        .cornerRadius(25.0)
    }
}
