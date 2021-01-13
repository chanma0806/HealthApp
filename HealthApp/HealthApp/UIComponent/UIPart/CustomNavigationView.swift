//
//  CustomNavigationView.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/12/04.
//

import Foundation
import SwiftUI
import UIKit

/**
   遷移アニメーションをカスタマイズしたNavigationView
    
    - note:
        rootのラッピングがイマイチ、要改善
 */

/**
 root -> CustomNavigationViewの遷移リクエスト
 */
protocol NavigateReuest {
    var delegate: NavigateReuestDelegate? {get set}
}
extension NavigateReuest {
    func requestNavigation() {
        self.delegate?.navigation()
    }
}

/**
 root -> CustomNavigationViewの遷移リクエストハンドラー
 */
protocol NavigateReuestDelegate {
    func navigation()
}

/**
 CustomNavigationViewに保持するUINavigationControllerのコンテキスト
 */
class NavigationItem: ObservableObject {
    var navigator: UINavigationController?
}

/**
  ナビゲーションのカスタマイズ
 */
class CustomUINavigationController: UINavigationController, UINavigationControllerDelegate {
    
    let DURATION = 0.3
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        guard self.children.count > 0 else {
            return super.pushViewController(viewController, animated: false)
        }
        let transition = CATransition()
        transition.duration = DURATION
        transition.timingFunction = CAMediaTimingFunction(name: .easeIn)
        transition.type = .moveIn
        transition.subtype = .fromTop
        self.view.layer.add(transition, forKey: nil)
        
        super.pushViewController(viewController, animated: false)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        if self.children.count <= 2  {
            self.navigationBar.isHidden = true
        }
        let transition = CATransition()
        transition.duration = DURATION
        transition.timingFunction = CAMediaTimingFunction(name: .easeIn)
        transition.type = .reveal
        transition.subtype = .fromBottom
        self.view.layer.add(transition, forKey: nil)
        
        return super.popViewController(animated: false)
    }
}

/**
    ナビゲーションビュー
 */
struct CustomNavigationView<Content, Target>: UIViewControllerRepresentable, NavigateReuestDelegate
                                                where Content: View, Content: NavigateReuest, Target: View {
    
    typealias UIViewControllerType = UINavigationController
    @ObservedObject private var item: NavigationItem
    
    func navigation() {
        let controller = UIHostingController(rootView: target)
        self.item.navigator?.navigationBar.isHidden = false
        item.navigator?.pushViewController(controller, animated: true)
    }
    
    init(content: Content, to target: Target) {
        _item = ObservedObject(initialValue: NavigationItem())
        self.target = target
        self.childView = content
        self.childView.delegate = self
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        
    }
    
    var childView: Content
    var target: Target

    func makeUIViewController(context: Context) -> UINavigationController {
        let child = UIHostingController(rootView: childView)
        let navigation = CustomUINavigationController(rootViewController: child)
        navigation.navigationBar.isHidden = true
        item.navigator = navigation
        
        return navigation
    }
}
