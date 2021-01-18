//
//  ColorDefine.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/11/01.
//

import SwiftUI

extension Color {
    init(rgb: Int) {
        self.init(red: Double((rgb >> 16) & 0xFF) / 255, green: Double((rgb >> 8) & 0xFF)/255, blue: Double(rgb & (0xFF))/255)
    }
}

let greenGradient: LinearGradient = LinearGradient(gradient: Gradient(colors: [Color(rgb: 0x81FBB8), Color(rgb: 0x28C76F)]), startPoint: .topLeading, endPoint: .bottomTrailing)

let redGradient: LinearGradient = LinearGradient(gradient: Gradient(colors: [Color(rgb: 0xFEB692), Color(rgb: 0xEA5455)]), startPoint: .topLeading, endPoint: .bottomTrailing)

let orangeGradient: LinearGradient = LinearGradient(gradient: Gradient(colors: [Color(rgb: 0xFEC163), Color(rgb: 0xDE4313)]), startPoint: .topLeading, endPoint: .bottomTrailing)

let pinkGradient: LinearGradient = LinearGradient(gradient: Gradient(colors: [Color(rgb: 0xFFE064), Color(rgb: 0xFF52E5)]), startPoint: .topLeading, endPoint: .bottomTrailing)

let dashbordBackColor = Color(rgb: 0xF5F0F4)

let commonTextColor: Color = Color(rgb: 0x606B6E)

let noDataColor: Color = Color(rgb: 0xDDDDDD)

let pinkColor: Color = Color(rgb: 0xFF52E5)
