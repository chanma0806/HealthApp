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

// 連続なプロットの集合
struct GraphPlotSeries: Identifiable {
    enum PlotStyle {
        case Path
        case Dot
        case None
    }
    
    // 連続な座標リスト
    var points: [CGPoint]
    var index: Int
    
    var id: String {
        get {
            String(index)
        }
    }
    
    var plotStyle: PlotStyle {
        get {
            switch points.count {
                case let count where count > 2:
                    return .Path
                case let count where count == 1:
                    return .Dot
                case let count where count < 1:
                    return .None
            default:
                return .None
            }
        }
    }
}

/**
    線形グラフビュー
 */
public struct LinerGraph: View {
    public static func getDummyDatas() -> [Int] {
            
        var dummies = [Int]()
        for _ in 0..<(24 * 2) {
            dummies.append(Int.random(in: (100 ..< 110)))
        }
                
        return dummies
//        return [
//            70, /* 00:00 */
//            60, /* 01:00 */
//            100, /* 02:00 */
//            55, /* 03:00 */
//            90, /* 04:00 */
//            60, /* 05:00 */
//            80, /* 06:00 */
//            72, /* 07:00 */
//            75, /* 08:00 */
//            110, /* 09:00 */
//            90, /* 10:00 */
//            69, /* 11:00 */
//            100, /* 12:00 */
//            122, /* 13:00 */
//            99, /* 14:00 */
//            101, /* 15:00 */
//            90, /* 16:00 */
//            80, /* 17:00 */
//            87, /* 18:00 */
//            80, /* 19:00 */
//            75, /* 20:00 */
//            80, /* 21:00 */
//            75, /* 22:00 */
//            80, /* 23:00 */
//        ]
    }
    
    let datas: [GraphData]
    var property: ViewProperty
    lazy var _grapScale: GraphScaleData = self.makeGraphScaleData(rawDatas)
    
    var grapScale: GraphScaleData {
        get {
            var mutatingSelf = self
            return mutatingSelf._grapScale
        }
    }
    
    var rawDatas: [Int] {
        get {
            datas.map { d in d.value }
        }
    }
    
    init(_ datas: [GraphData], property: ViewProperty) {
        self.datas = datas
        self.property = property
        self.property.barAreaWidth = self.property.graphWidth / 24
        self.property.barWidth = self.property.barAreaWidth / 1.5
    }
    
    @ViewBuilder
    private func quadCurvedPath(plots: [GraphPlotSeries]) -> some View {

        ForEach(plots, id: \.id) { plot in
            switch plot.plotStyle {
            /** 線形で描画 */
            case .Path:
                let points = plot.points
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
                
            case .Dot:
            /** 単独プロットは点で描画 */
                Circle()
                    .fill()
                    .foregroundColor(.white)
                    .frame(width: 5, height: 5)
                    .position(plot.points[0])
            case .None:
            /** プロット対象なし */
                AnyView(_fromValue: 0)
            }
        }
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
    
    /**
    　連続なプロット群リストを作成する
     　　
     - note:
        `GraphPlotSeries.points`には連続な座標を登録し、座標が欠けた時点で別のプロット群を作成する
     */
    private func getPoints(_ datas: [GraphData], scale: GraphScaleData, barAreaWidth: CGFloat, graphHeight: CGFloat) -> [GraphPlotSeries] {
        let height: CGFloat = scale.topY - scale.bottomY
        let points: [CGPoint?] = datas.enumerated().map {
            guard ($0.element.value) > 30  else {
                return nil
            }
            let x: CGFloat = (CGFloat($0.offset) + 0.5) * (barAreaWidth / 2)
            let y: CGFloat = (1.0 - (CGFloat($0.element.value) - scale.bottomY) / height) * graphHeight
            return CGPoint(x: x, y: y)
        }
        
        var plots = [GraphPlotSeries]()
        for point in points{
            // 初回座標が見つかったらプロット群を作成
            guard plots.count > 0 else {
                if (point != nil) {
                    plots.append(GraphPlotSeries(points: [point!], index: 0))
                }
                continue
            }
            // nilな座標があればプロット群を区切る
            guard point != nil else {
                if (plots.last!.points.count > 0) {
                    plots.append(GraphPlotSeries(points: [], index: plots.count))
                }
                continue
            }
            
            // 座標追加
            plots[plots.count - 1].points.append(point!)
        }
        
        return plots
    }
    
    mutating private func makeGraphScaleData(_ datas: [Int]) -> GraphScaleData {
        let maxValue = CGFloat(datas.max() ?? 0)
        let minValue = CGFloat(datas.filter{ $0 > 30 }.min() ?? 0)
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
        let drawHeiht:CGFloat = self.property.graphHeight - (self.property.barWidth + self.property.barOffset)
        let graphPlots: [GraphPlotSeries] = self.getPoints(datas, scale: self.grapScale, barAreaWidth: self.property.barAreaWidth, graphHeight: drawHeiht)
        VStack(alignment: .center, spacing:0, content: {
            ZStack {
                self.quadCurvedPath(plots: graphPlots)
            }
        })
        .frame(height: self.property.graphHeight)
    }
}

struct LinerGraphView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            GraphView(LinerGraph.getDummyDatas(), graphType: .line)
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

