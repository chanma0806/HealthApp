//
//  BarGraphView.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/11/03.
//

import SwiftUI

/**
    バーグラフビュー
 */
public struct BarGraphView: View {
    let rawDatas: [Int]
    
    init(_ datas: [Int]) {
        self.rawDatas = datas
    }
    
    public static func getDummyDatas() -> [Int] {
        return  [
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
    }
    
    public var body: some View {
        let maxValue = self.rawDatas.max() ?? 0
        let datas: [GraphData] = rawDatas.enumerated().map{
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

//struct BarGraphView_Previews: PreviewProvider {
//    static var previews: some View {
//        BarGraphView()
//    }
//}
