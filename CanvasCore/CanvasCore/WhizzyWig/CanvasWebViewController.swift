//
//  CanvasWebViewController.swift
//  CanvasCore
//
//  Created by Derrick Hathaway on 11/6/17.
//  Copyright © 2017 Instructure, Inc. All rights reserved.
//

import WebKit
import UIKit
import ReactiveSwift
import ReactiveCocoa

open class CanvasWebViewController: UIViewController, PageViewEventViewControllerLoggingProtocol {
    public let webView: CanvasWebView
    public var pageViewName: String?
    private let showDoneButton: Bool
    
    let canBack: DynamicProperty<Bool>
    let canForward: DynamicProperty<Bool>
    let isLoading: DynamicProperty<Bool>
    let webTitle: DynamicProperty<String>
    
    public init(webView: CanvasWebView = CanvasWebView(), showDoneButton: Bool = false) {
        self.webView = webView
        self.showDoneButton = showDoneButton
        
        canBack = DynamicProperty(object: webView, keyPath: "canGoBack")
        canForward = DynamicProperty(object: webView, keyPath: "canGoForward")
        isLoading = DynamicProperty(object: webView, keyPath: "loading")
        webTitle = DynamicProperty(object: webView, keyPath: "title")
        
        super.init(nibName: nil, bundle: nil)

        webView.requestClose = { [weak self] in self?.done() }
        webView.presentingViewController = self
        buildUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: animated)
        startTrackingTimeOnViewController()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: animated)
        if let pageViewName = pageViewName  {
            stopTrackingTimeOnViewController(eventName: pageViewName)
        }
    }
    
    // MARK: initialize UI
    
    func buildUI() {
        if self.showDoneButton {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        }
        
        navigationItem.reactive.title <~ webTitle
        updateToolbarItems()
    }
    
    func updateToolbarItems() {
        let back = UIBarButtonItem(image: .icon(.backward), style: .plain, target: webView, action: #selector(WKWebView.goBack))
        back.reactive.isEnabled <~ canBack.producer.skipNil()
        
        let forward = UIBarButtonItem(image: .icon(.forward), style: .plain, target: webView, action: #selector(WKWebView.goForward))
        forward.reactive.isEnabled <~ canForward.producer.skipNil()
        
        let loadingActivity = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        loadingActivity.reactive.isAnimating <~ isLoading.producer.skipNil()
        
        let loading = UIBarButtonItem(customView: loadingActivity)
        let space: () -> UIBarButtonItem = {
            let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            space.width = 8
            return space
        }
        
        let reload = UIBarButtonItem(image: .icon(.refresh), style: .plain, target: webView, action: #selector(WKWebView.reload))
        
        let barItems = [
            back,
            space(),
            forward,
            space(),
            reload,
            space(),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            loading,
        ]
        toolbarItems = barItems
    }

    // MARK: Actions
    @objc
    func done() {
        dismiss(animated: true, completion: nil)
    }
}
