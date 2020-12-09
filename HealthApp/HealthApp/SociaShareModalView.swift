//
//  SociaShareModalView.swift
//  HealthApp
//
//  Created by 丸山大幸 on 2020/12/05.
//

import SwiftUI
import UIKit

let STR_SNS_SHARE_BUTTON = "投稿"

struct ShareCardData {
    var summaryTotalStep: Int
    var steps: [Int]
    var heartRates: [Int]
    var calories: [Int]
}

protocol SocialSharePost {
    
}

extension SocialSharePost {
    @ViewBuilder
    func postShare<Content: View>(@ViewBuilder content:()->Content, dismissAction: @escaping ()->Void) -> some View {
        ShareHost(content: content, dismissAction: dismissAction)
    }
}

struct SociaShareModalView: View, SocialSharePost {
    @EnvironmentObject var setting: SettingData
    @State var page: Int
    @State var tapped: Bool
    let cardData: ShareCardData
    let modalDismissAction: ()->Void
    init(cardData: ShareCardData, dismisssAction: @escaping ()->Void ) {
        _page = State(initialValue: 0)
        _tapped = State(initialValue: false)
        self.cardData = cardData
        self.modalDismissAction = dismisssAction
    }
    
    var body: some View {
        GeometryReader { geo in
            let caroucel: Carousel = Carousel(width: geo.size.width, height: 300, numOfPages: 4, cardData: cardData, page: self.$page)
            ZStack {
                Color.white
                    .frame(width: geo.size.width, height: geo.size.height)
                    .cornerRadius(25.0)
                VStack(alignment: .center, spacing: 0) {
                    caroucel
                        .frame(width: geo.size.width, height: 300)
                    PageViewControlView(page: self.$page, pageMax: 4)
                    Button(action: {
                        tapped.toggle()
                    }, label: {
                        Text(STR_SNS_SHARE_BUTTON)
                            .font(.system(size: 16.0))
                            .bold()
                    })
                    .frame(width: 100, height: 40, alignment: .center)
                    .foregroundColor(.white)
                    .background(pinkColor)
                    .cornerRadius(35.0)
                }
                if (tapped) {
                    self.postShare(content: {
                        caroucel.getPageContent().frame(width: 300, height: 200)
                    }, dismissAction: modalDismissAction)
                }
            }
        }
    }
}

struct ShareContent {
    var image: UIImage
    var text: String
}

class SnsShareViewController<Content>: UIViewController where Content: View {
    var hosting: UIHostingController<Content>
    var handler: UIActivityViewController.CompletionWithItemsHandler?
    init(content: Content) {
        self.hosting = UIHostingController(rootView: content)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isHidden = true
        
        addChild(hosting)
        hosting.view.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
        hosting.view.bounds = hosting.view.frame
        view.addSubview(hosting.view)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.isHidden = true
        share()
    }
    
    func share() {
        let shareActivity = UIActivityViewController(activityItems: [hosting.view.asImage(), "test"], applicationActivities: nil)
        shareActivity.completionWithItemsHandler = self.handler
        self.present(shareActivity, animated: true, completion: nil)
    }
}

struct ShareHost<Content>: UIViewControllerRepresentable where Content: View {
    var content: Content
    let action: ()->Void
    init (@ViewBuilder content: ()->Content, dismissAction: @escaping ()->Void) {
        self.content = content()
        self.action = dismissAction
    }
    
    func makeUIViewController(context: Context) -> SnsShareViewController<Content> {
        let controller = SnsShareViewController(content: content)
        controller.handler = { (activityType, completed, items, error) in
            action()
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: SnsShareViewController<Content>, context: Context) {
        
    }
}

struct Carousel: UIViewRepresentable {
    
    typealias UIViewType = UIScrollView
    
    var width: CGFloat
    var height: CGFloat
    var numOfPages: Int
    let cardData: ShareCardData
    var pages: PostContentList
    @Binding var page: Int
    
    init (width: CGFloat, height: CGFloat, numOfPages: Int, cardData: ShareCardData, page: Binding<Int>) {
        self.width = width
        self.height = height
        self.numOfPages = numOfPages
        self.cardData = cardData
        _page = page
        self.pages = PostContentList(shareCardData: cardData)
    }
    
    func makeCoordinator() -> Coordinator {
        Carousel.Coordinator(parent: self)
    }
    
    func getPageContent() -> some View {
        self.pages.getViewAt(page: page)
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.bounces = true
        scrollView.contentSize = CGSize(width: width * CGFloat(numOfPages), height: height)
        scrollView.frame = CGRect(origin:CGPoint(x: 0, y: 0), size: scrollView.contentSize)
        scrollView.delegate = context.coordinator
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        let view = UIHostingController(rootView: pages)
        view.view.frame = CGRect(x: 0, y: 0, width: width * CGFloat(numOfPages), height: height)
        view.view.backgroundColor = UIColor.clear
        scrollView.addSubview(view.view)
        scrollView.backgroundColor = UIColor.clear
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: Carousel
        
        init(parent: Carousel) {
            self.parent = parent
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            /** contentOffset が スクロール済みのページ数分ある */
            let page = Int(scrollView.contentOffset.x / parent.width)
            self.parent.page = page
        }
    }
}

struct PostContentList: View {
    @EnvironmentObject var setting: SettingData
    
    @ViewBuilder func getViewAt(page: Int) -> some View {
        switch page {
        case 0:
            DaySummaryCardView(stepValue: .constant(shareCardData.summaryTotalStep)).environmentObject(setting)
        case 1:
            CardFactory.StepCard(datas: .constant(shareCardData.steps))
        case 2:
            CardFactory.HeartRateCard(datas: .constant(shareCardData.heartRates))
        case 3:
            CardFactory.BurnCalorieCard(datas: .constant(shareCardData.calories))
            
        default:
            DaySummaryCardView(stepValue: .constant(shareCardData.summaryTotalStep)).environmentObject(setting)
        }
    }
    
    let shareCardData: ShareCardData
    
    var body: some View {
        let setting = SettingData()
        setting.goalValue = 10000
        
        return GeometryReader { geo in
            HStack(spacing: 0) {
                Group {
                    ForEach(0 ..< 4, content: { index in
                        getViewAt(page: index)
                    })
                }
                .padding(EdgeInsets(top: 50, leading: 50, bottom: 50, trailing: 50))
                .frame(width: geo.size.width / 4, height: geo.size.height, alignment: .center)
            }
            .background(Color.clear)
        }
    }
}

struct PageViewControlView: UIViewRepresentable {
    @Binding var page: Int
    var pageMax: Int
    
    func makeUIView(context: Context) -> UIPageControl {
        let pageControl = UIPageControl()
        pageControl.currentPage = page
        pageControl.numberOfPages = pageMax
        pageControl.pageIndicatorTintColor = .gray
        
        return pageControl
    }
    
    func updateUIView(_ uiView: UIPageControl, context: Context) {
        DispatchQueue.main.async {
            uiView.currentPage = page
        }
    }
    
    typealias UIViewType = UIPageControl
}

extension UIView {
    func asImage() -> UIImage {
        let render = UIGraphicsImageRenderer(bounds: self.frame)
        return render.image { contenxt in
            layer.render(in: contenxt.cgContext)
        }
    }
}

//struct SociaShareModalView_Previews: PreviewProvider {
//    static var previews: some View {
////        TestView()
////        SociaShareModalView()
//    }
//}
