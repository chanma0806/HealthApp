//
//  LinerGraphView.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/11/03.
//

import SwiftUI

public struct GraphData: Identifiable{
    public var id: String
    public var value: Int
    
    init (id: String, value: Int) {
        self.id = id
        self.value = value
    }
}

public struct YtickData: Identifiable{
    public var id: String
    public var value: Int
    public var yPosition: CGFloat
    
    init (id: String, value: Int, bottom: CGFloat, height: CGFloat, graphHeight: CGFloat) {
        self.id = id
        self.value = value
        self.yPosition = (1.0 - (CGFloat(value) - bottom) / height) * graphHeight
    }
}

let MIN_VALUE_RANGE_Y: CGFloat = 30.0

struct GraphScaleData {
    /** y座標の上限 */
    var topY: CGFloat
    /** y座標の下限 */
    var bottomY: CGFloat
    /** y座標の幅 */
    var rangeY: CGFloat
    /** 入力データの最大値 */
    var maxValue: CGFloat
    /** 入力データの最小値 */
    var minValue: CGFloat
    /** 入力データ幅の中心*/
    var centerY: CGFloat {
        get {
            (maxValue - minValue) / 2.0 + minValue
        }
    }
}

/**
    線形グラフビュー
 */
public struct LinerGraphView: View {
    
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
        
//        return [0, 0, 0, 0, 0, 0, 0, 0, 94, 93, 88, 85, 85, 96, 97, 95, 90, 87, 87, 88, 91, 0, 0, 0]
        return [
            70, /* 00:00 */
            60, /* 01:00 */
            100, /* 02:00 */
            55, /* 03:00 */
            90, /* 04:00 */
            60, /* 05:00 */
            80, /* 06:00 */
            72, /* 07:00 */
            75, /* 08:00 */
            110, /* 09:00 */
            90, /* 10:00 */
            69, /* 11:00 */
            100, /* 12:00 */
            122, /* 13:00 */
            99, /* 14:00 */
            101, /* 15:00 */
            90, /* 16:00 */
            80, /* 17:00 */
            87, /* 18:00 */
            80, /* 19:00 */
            75, /* 20:00 */
            80, /* 21:00 */
            75, /* 22:00 */
            80, /* 23:00 */
        ]
    }
    
    @ViewBuilder
    private func quadCurvedPath(points: [CGPoint]) -> some View {

        Path { path in
            var oldControlP: CGPoint?
            var p1 = points[0]
            path.move(to: p1)
            for i in 1..<points.count {
                let p2 = points[i]
                var p3: CGPoint?
                if i < points.count - 1 {
                    p3 = points[i+1]
                }

                let newControlP = self.controlPointForPoints(p1: p1, p2: p2, next: p3)

                path.addCurve(to: p2, control1: oldControlP ?? p1, control2: newControlP ?? p2)

                p1 = p2
                oldControlP = antipodalFor(point: newControlP, center: p2)
            }
        }.stroke(Color.white, style: StrokeStyle(lineWidth: 2, lineCap: .round))
        
    }

    /// located on the opposite side from the center point
    private func antipodalFor(point: CGPoint?, center: CGPoint?) -> CGPoint? {
        guard let p1 = point, let center = center else {
            return nil
        }
        let newX = 2 * center.x - p1.x
        let diffY = abs(p1.y - center.y)
        let newY = center.y + diffY * (p1.y < center.y ? 1 : -1)

        return CGPoint(x: newX, y: newY)
    }

    /// halfway of two points
    private func calcMidpoint(p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    }

    /// Find controlPoint2 for addCurve
    /// - Parameters:
    ///   - p1: first point of curve
    ///   - p2: second point of curve whose control point we are looking for
    ///   - next: predicted next point which will use antipodal control point for finded
    private func controlPointForPoints(p1: CGPoint, p2: CGPoint, next p3: CGPoint?) -> CGPoint? {
        guard let p3 = p3 else {
            return nil
        }

        let leftMidPoint  = calcMidpoint(p1: p1, p2: p2)
        let rightMidPoint = calcMidpoint(p1: p2, p2: p3)

        var controlPoint = calcMidpoint(p1: leftMidPoint, p2: antipodalFor(point: rightMidPoint, center: p2)!)

        if p1.y.between(a: p2.y, b: controlPoint.y) {
            controlPoint.y = p1.y
        } else if p2.y.between(a: p1.y, b: controlPoint.y) {
            controlPoint.y = p2.y
        }


        let imaginContol = antipodalFor(point: controlPoint, center: p2)!
        if p2.y.between(a: p3.y, b: imaginContol.y) {
            controlPoint.y = p2.y
        }
        if p3.y.between(a: p2.y, b: imaginContol.y) {
            let diffY = abs(p2.y - p3.y)
            controlPoint.y = p2.y + diffY * (p3.y < p2.y ? 1 : -1)
        }

        // make lines easier
        controlPoint.x += (p2.x - p1.x) * 0.1

        return controlPoint
    }
    
    private func getPoints(_ datas: [Int], scale: GraphScaleData, barAreaWidth: CGFloat, graphHeight: CGFloat) -> [CGPoint] {
        let height: CGFloat = scale.topY - scale.bottomY
        let points: [CGPoint] = datas.enumerated().map {
            guard ($0.element) > 30  else {
                return nil
            }
            let x: CGFloat = (CGFloat($0.offset) + 0.5) * barAreaWidth
            let y: CGFloat = (1.0 - (CGFloat($0.element) - scale.bottomY) / height) * graphHeight
            return CGPoint(x: x, y: y)
        }.compactMap{ $0 }
        
        return points
    }
    
    private func makeYticks(scale: GraphScaleData, height: CGFloat, graphHeight: CGFloat) -> [YtickData] {
        var yticks: [YtickData] = []
        var ytickValue: CGFloat = scale.topY
        while ytickValue >= scale.bottomY {
            let ytick: YtickData  = YtickData(id: "\(Int(ytickValue))", value: Int(ytickValue), bottom: scale.bottomY, height: height, graphHeight: graphHeight)
            yticks.append(ytick)
            ytickValue += -10.0
        }
        
        return yticks
    }
    
    mutating private func makeGraphScaleData(_ datas: [Int]) -> GraphScaleData {
        let maxValue = CGFloat(datas.max()!)
        let minValue = CGFloat(datas.filter{ $0 > 30 }.min()!)
        let valueRange = CGFloat(maxValue - minValue)
        let centerValue = (maxValue - minValue) / 2.0 + minValue
        var topValue = (CGFloat(maxValue) * (1.05)).roundedUp(tenPow: 1)
        var bottomValue = (CGFloat(minValue) * (0.95)).roundedDown(tenPow: 1)
        if (MIN_VALUE_RANGE_Y >= valueRange) {
            topValue = ((centerValue + MIN_VALUE_RANGE_Y / 2)).roundedUp(tenPow: 1)
            bottomValue = topValue - MIN_VALUE_RANGE_Y
        }
        
        return GraphScaleData(topY: topValue,
                              bottomY: bottomValue,
                              rangeY: valueRange,
                              maxValue: maxValue,
                              minValue: minValue)
    }
    
    public var body: some View {
        let datas: [GraphData] = rawDatas.enumerated().map{
            GraphData(id: String($0.offset), value: $0.element)
        }
        
        return GeometryReader { geo in
            let graphWidth: CGFloat = geo.size.width
            let graphHeight: CGFloat = (geo.size.height * 0.9)
            let barAreaWidth: CGFloat = graphWidth / CGFloat(datas.count)
            let barWidth: CGFloat = barAreaWidth / 1.5
            let barOffset: CGFloat = barAreaWidth - barWidth
            let drawHeiht:CGFloat = graphHeight - (barWidth + barOffset)
            let height: CGFloat = grapScale.topY - grapScale.bottomY
            let yticks: [YtickData] = self.makeYticks(scale: self.grapScale, height: height, graphHeight: graphHeight)
            HStack(alignment: .top, spacing: 0.0, content: {
                // Y軸
                ZStack {
                    ForEach(yticks, content: { (d: YtickData) in
                        Text(d.id)
                        .font(.system(size: barWidth))
                        .foregroundColor(.white)
                        .bold()
                        .position(x: barWidth / 2, y: d.yPosition)
                        .frame(width: barWidth * 2.0, height: barWidth)
                    })
                }
                .frame(width: barWidth * 2.0, height: graphHeight, alignment: .topLeading)
                VStack(alignment: .leading, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                    // グラフ描画エリア
                    let graphPoints: [CGPoint] = self.getPoints(rawDatas, scale: self.grapScale, barAreaWidth: barAreaWidth, graphHeight: drawHeiht)
                    VStack(alignment: .center, spacing:0, content: {
                        self.quadCurvedPath(points: graphPoints)
                    })
                    .frame(height: graphHeight)
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
                })
            })
        }
    }
}

struct LinerGraphView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            LinerGraphView(LinerGraphView.getDummyDatas())
        }
        .frame(width: 300, height: 250, alignment: .center)
        .padding()
        .background(redGradient)
        .cornerRadius(25.0)
    }
}

public extension CGFloat {
    // 任意のくらいで切り上げ
    func roundedUp(tenPow: Int) -> CGFloat {
        let decimical = Decimal(10)
        let digit: Double = pow(decimical, tenPow).doubleValue
        return CGFloat((Double(self) / digit).rounded(.up) * digit)
    }
    
    // 任意のくらいで切り下げ
    func roundedDown(tenPow: Int) -> CGFloat {
        let decimical = Decimal(10)
        let digit: Double = pow(decimical, tenPow).doubleValue
        return CGFloat((Double(self) / digit).rounded(.down) * digit)
    }
}

public extension Decimal {
    var doubleValue: Double {
        get {
            (self as NSDecimalNumber).doubleValue
        }
    }
}

