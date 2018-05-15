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
    private let showShareButton: Bool
    
    let canBack: DynamicProperty<Bool>
    let canForward: DynamicProperty<Bool>
    let isLoading: DynamicProperty<Bool>
    let webTitle: DynamicProperty<String>
    
    public init(webView: CanvasWebView = CanvasWebView(), showDoneButton: Bool = false, showShareButton: Bool = false) {
        self.webView = webView
        self.showDoneButton = showDoneButton
        self.showShareButton = showShareButton
        
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
            return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        }
        
        let reload = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(WKWebView.reload))

        var share: UIBarButtonItem?
        if showShareButton {
            share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapShareButton))
        }
        
        let barItems = [
            back,
            space(),
            forward,
            space(),
            reload,
            space(),
            share,
            space(),
            loading
        ]
        toolbarItems = barItems.flatMap { $0 }
    }

    // MARK: Actions
    @objc
    func done() {
        dismiss(animated: true, completion: nil)
    }

    @objc
    func didTapShareButton(sender: UIBarButtonItem) {
        guard let url = webView.url, let presentingViewController = webView.presentingViewController else {
            return
        }
        let safariActivity = SafariActivity()
        let viewController = UIActivityViewController(activityItems: [url], applicationActivities: [safariActivity])
        viewController.popoverPresentationController?.barButtonItem = sender
        presentingViewController.present(viewController, animated: true, completion: nil)
    }
}
