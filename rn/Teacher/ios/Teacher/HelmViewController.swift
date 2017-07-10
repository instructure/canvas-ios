//
//  RNNViewController.swift
//  Teacher
//
//  Created by Garrett Richards on 4/27/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import UIKit
import SDWebImage
import PocketSVG

typealias Props = [String: Any]

protocol HelmScreen {
    var screenConfig: [String: Any] { get set }
    var screenInstanceID: String { get }
    var screenConfigRendered: Bool { get set }
}

final class HelmViewController: UIViewController, HelmScreen {
    
    let moduleName: String
    let screenInstanceID: String
    let props: Props
    var screenConfig: [String: Any] = [:]
    
    open var statusBarStyle: UIStatusBarStyle = .default {
        didSet {
            if (statusBarStyle != oldValue) {
                statusBarDirty = true
            }
        }
    }
    open var statusBarHidden: Bool = false {
        didSet {
            if (statusBarHidden != oldValue) {
                statusBarDirty = true
            }
        }
    }
    open var statusBarUpdateAnimation: UIStatusBarAnimation = .fade
    fileprivate var statusBarDirty: Bool = false
    
    private(set) open var isVisible: Bool = false

    var screenConfigRendered: Bool = false {
        didSet {
            if screenConfigRendered {
                screenDidRender()
                onReadyToPresent()
                onReadyToPresent = { }
            }
        }
    }
    var onReadyToPresent: () -> Void = { }
    
    
    // MARK: - Initialization
    
    public init(moduleName: String, props: Props) {
        self.moduleName = moduleName
        
        if let screenInstanceID = props["screenInstanceID"] as? String {
            self.screenInstanceID = screenInstanceID
            self.props = props
        } else {
            self.screenInstanceID = NSUUID().uuidString
            var propsFRD = props
            propsFRD["screenInstanceID"] = screenInstanceID
            self.props = propsFRD
        }
        
        super.init(nibName: nil, bundle: nil)
        
        HelmManager.shared.register(screen: self)
        setupSensibleDefaults()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSensibleDefaults() {
        automaticallyAdjustsScrollViewInsets = false
    }
    
    
    // MARK: - View lifecycle
    
    override open func loadView() {
        self.view = RCTRootView(bridge: HelmManager.shared.bridge, moduleName: moduleName, initialProperties: props)
    }
    
    // Do stuff that you'd usually do in viewDidLoad here, rather than there.
    // This is due to the way the Screen component works and it's flow with
    // setting the screenConfig and doing a prerender
    private var _screenDidRender = false
    private func screenDidRender() {
        if (_screenDidRender) { return }
        if let title = screenConfig[PropKeys.title] as? String {
            if let subtitle = screenConfig[PropKeys.subtitle] as? String, subtitle.characters.count > 0 {
                let titleView = self.titleView(with: title, and: subtitle, given: screenConfig)
                titleView.isAccessibilityElement = true
                titleView.accessibilityLabel = "\(title), \(subtitle)"
                titleView.accessibilityTraits = UIAccessibilityTraitHeader
                self.navigationItem.titleView = titleView
                self.navigationItem.title = nil
            }
            self.title = title
        }
        _screenDidRender = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isVisible = true
        handleStyles()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isVisible = false
    }
    
    
    // MARK: - Status bar
    
    func updateStatusBarIfNeeded() {
        guard (statusBarDirty) else { return }
        defer { statusBarDirty = false }
        
        let duration = statusBarUpdateAnimation != .none ? 0.2 : 0
        UIView.animate(withDuration: duration) { [weak self] in
            self?.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override open var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return statusBarUpdateAnimation
    }
    
    override open var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    
    // MARK: - Orientation
    
    override var shouldAutorotate: Bool {
        return super.shouldAutorotate
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let cantRotate = screenConfig[PropKeys.noRotationInVerticallyCompact] as? Bool, cantRotate, (self.traitCollection.verticalSizeClass == .compact || self.traitCollection.horizontalSizeClass == .compact) {
            return .portrait
        }
        
        return super.supportedInterfaceOrientations
    }
    
    
    // MARK: - Styles
    
    open func handleStyles() {
        // Nav bar props

        let drawUnderNavBar = screenConfig[PropKeys.drawUnderNavBar] as? Bool ?? false
        if (drawUnderNavBar) {
            edgesForExtendedLayout.insert(.top)
        } else {
            edgesForExtendedLayout.remove(.top)
        }
        
        let drawUnderTabBar = screenConfig[PropKeys.drawUnderTabBar] as? Bool ?? false
        if (drawUnderTabBar) {
            edgesForExtendedLayout.insert(.bottom)
        } else {
            edgesForExtendedLayout.remove(.bottom)
        }
        
        if let autoAdjustInsets = screenConfig[PropKeys.automaticallyAdjustsScrollViewInsets] as? Bool {
            automaticallyAdjustsScrollViewInsets = autoAdjustInsets
        }
        
        if screenConfig[PropKeys.navBarTransparent] as? Bool ?? false {
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.isTranslucent = true
            edgesForExtendedLayout.insert(.top)
            automaticallyAdjustsScrollViewInsets = false
        }
        else {
            navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
            navigationController?.navigationBar.isTranslucent = screenConfig[PropKeys.navBarTranslucent] as? Bool ?? false
        }
        
        if let navBarStyle = screenConfig[PropKeys.navBarStyle] as? String {
            switch navBarStyle {
            case "dark": navigationController?.navigationBar.barStyle = .black
            case "light": navigationController?.navigationBar.barStyle = .default
            default: navigationController?.navigationBar.barStyle = .default
            }
        }
        
        if screenConfig[PropKeys.hideNavBarShadowImage] as? Bool ?? false {
            navigationController?.navigationBar.shadowImage = UIImage()
        }

        let navBarHidden = screenConfig[PropKeys.navBarHidden] as? Bool ?? false
        if navigationController?.isNavigationBarHidden != navBarHidden {
            navigationController?.setNavigationBarHidden(navBarHidden, animated: true)
        }
        
        if let navBarColor = screenConfig[PropKeys.navBarColor] ?? HelmManager.shared.defaultScreenConfiguration[moduleName]?[PropKeys.navBarColor] {
            if let navBarColorNone = navBarColor as? String, navBarColorNone == "none" {
                navigationController?.navigationBar.barTintColor = nil
            } else {
                navigationController?.navigationBar.barTintColor = RCTConvert.uiColor(navBarColor)
            }
        }
        
        if let navBarButtonColor = screenConfig[PropKeys.navBarButtonColor] ?? HelmManager.shared.defaultScreenConfiguration[moduleName]?[PropKeys.navBarButtonColor] {
            if let navBarButtonColorNone = navBarButtonColor as? String, navBarButtonColorNone == "none" {
                navigationController?.navigationBar.tintColor = nil
            } else {
                navigationController?.navigationBar.tintColor = RCTConvert.uiColor(navBarButtonColor)
            }
        } else {
            if screenConfig[PropKeys.navBarStyle] as? String == "dark" {
                navigationController?.navigationBar.tintColor = .white
            }
        }
        
        if let navBarImagePath = screenConfig[PropKeys.navBarImage] {
            var titleView: UIView? = titleViewFromNavBarImagePath(navBarImagePath: navBarImagePath)
            titleView?.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
            titleView?.contentMode = .scaleAspectFit
            titleView?.autoresizingMask = navigationItem.titleView?.autoresizingMask ?? [.flexibleWidth, .flexibleHeight]
            navigationItem.titleView = titleView
        }
        
        if let c = screenConfig["navBarTitleColor"], let titleColor = RCTConvert.uiColor(c) {
            navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: titleColor]
        }
        
        func barButtonItems(fromConfig config: [[String: Any]]) -> [UIBarButtonItem] {
            var items: [UIBarButtonItem] = []
            for buttonConfig in config {
                let styleConfig = buttonConfig["style"] as? String
                let style: UIBarButtonItemStyle = styleConfig == "done" ? .done : .plain
                
                let barButtonItem: UIBarButtonItem
                if let imageConfig = buttonConfig["image"], let image = RCTConvert.uiImage(imageConfig) {
                    barButtonItem = UIBarButtonItem(image: image, style: style, target: self, action: #selector(barButtonTapped(_:)))
                } else if let title = buttonConfig["title"] as? String {
                    barButtonItem = UIBarButtonItem(title: title, style: style, target: self, action: #selector(barButtonTapped(_:)))
                } else {
                    continue
                }
                items.append(barButtonItem)
                
                if let action = buttonConfig["action"] as? NSString {
                    barButtonItem.setAssociatedObject(action, forKey: &Associated.barButtonAction)
                }
                
                let disabled = buttonConfig["disabled"] as? Bool ?? false
                barButtonItem.isEnabled = !disabled
                
                if let testID = buttonConfig["testID"] as? String {
                    barButtonItem.accessibilityIdentifier = testID
                }
                if let a11yLabel = buttonConfig["accessibilityLabel"] as? String {
                    barButtonItem.accessibilityLabel = a11yLabel
                }
            }
            return items
        }
        
        if let leftBarButtons = screenConfig[PropKeys.leftBarButtons] as? [[String: Any]] {
            navigationItem.leftBarButtonItems = barButtonItems(fromConfig: leftBarButtons)
        }
        
        if let rightBarButtons = screenConfig[PropKeys.rightBarButtons] as? [[String: Any]] {
            navigationItem.rightBarButtonItems = barButtonItems(fromConfig: rightBarButtons)
        }
        
        // Status bar props
        if let statusBarStyle = screenConfig[PropKeys.statusBarStyle] as? String {
            switch statusBarStyle {
            case "light":
                self.statusBarStyle = .lightContent
                self.navigationController?.navigationBar.barStyle = .black
            default:
                self.statusBarStyle = .default
                self.navigationController?.navigationBar.barStyle = .default
            }
        }
        // TODO: According to Wix's code, this can't be set on viewWillAppear, and they do it on initialization separately...
        statusBarHidden = screenConfig[PropKeys.statusBarHidden] as? Bool ?? false
        if let animation = screenConfig[PropKeys.statusBarUpdateAnimation] as? String {
            switch animation {
            case "none": self.statusBarUpdateAnimation = .none
            case "fade": self.statusBarUpdateAnimation = .fade
            case "slide": self.statusBarUpdateAnimation = .slide
            default: self.statusBarUpdateAnimation = .fade
            }
        }
        updateStatusBarIfNeeded()
        
        if let backButtonTitle = screenConfig[PropKeys.backButtonTitle] as? String {
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: backButtonTitle, style: .plain, target: nil, action: nil)
        }
    }
    
    private func titleView(with title: String, and subtitle: String, given config: [String: Any]) -> UIView {
        let titleLabel = UILabel(frame: CGRect(x:0, y:-2, width:0, height:0))
        
        // TODO: support custom fonts, sizes
        
        let titleColor: UIColor
        if let c = screenConfig["navBarTitleColor"] {
            titleColor = RCTConvert.uiColor(c)
        } else {
            if let style = screenConfig[PropKeys.navBarStyle] as? String {
                if style == "light" {
                    titleColor = .darkText
                } else {
                    titleColor = .white
                }
            } else {
                titleColor = .darkText
            }
        }
        
        let subtitleColor: UIColor
        if let c = screenConfig["navBarSubtitleColor"] {
            subtitleColor = RCTConvert.uiColor(c)
        } else {
            if let style = screenConfig[PropKeys.navBarStyle] as? String {
                if style == "light" {
                    subtitleColor = .darkText
                } else {
                    subtitleColor = .white
                }
            } else {
                subtitleColor = .darkText
            }
        }
        
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = titleColor
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.text = title
        titleLabel.sizeToFit()
        titleLabel.textAlignment = .center

        let subtitleLabel = UILabel(frame: CGRect(x:0, y:18, width:0, height:0))
        subtitleLabel.backgroundColor = UIColor.clear
        subtitleLabel.textColor = subtitleColor
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.text = subtitle
        subtitleLabel.sizeToFit()
        subtitleLabel.textAlignment = .center

        let maxWidth = max(titleLabel.frame.size.width, subtitleLabel.frame.size.width)
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: maxWidth, height: 30))
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)
        
        // Center title or subtitle on screen (depending on which is larger)
        if titleLabel.frame.width >= subtitleLabel.frame.width {
            var adjustment = subtitleLabel.frame
            adjustment.origin.x = titleView.frame.origin.x + (titleView.frame.width/2) - (subtitleLabel.frame.width/2)
            subtitleLabel.frame = adjustment
        } else {
            var adjustment = titleLabel.frame
            adjustment.origin.x = titleView.frame.origin.x + (titleView.frame.width/2) - (titleLabel.frame.width/2)
            titleLabel.frame = adjustment
        }
        
        if let testID = screenConfig["testID"] as? String {
            titleView.accessibilityIdentifier = testID + ".nav-bar-title-view"
        }

        return titleView
    }
    
    func barButtonTapped(_ barButton: UIBarButtonItem) {
        if let action: NSString = barButton.getAssociatedObject(&Associated.barButtonAction) {
            HelmManager.shared.bridge.enqueueJSCall("RCTDeviceEventEmitter.emit", args: [action])
        }
    }
    
    func titleViewFromNavBarImagePath(navBarImagePath: Any) -> UIView? {
        var titleView: UIView? = nil
        switch (navBarImagePath) {
        case is String:
            if let path = navBarImagePath as? String {
                if (path as NSString).pathExtension == "svg" {
                    titleView = SVGImageView(contentsOf: URL(string: path)!)
                } else {
                    let imageView = UIImageView()
                    imageView.sd_setImage(with: URL(string: path))
                    titleView = imageView
                }
            }
        case is [String: Any]:
            let image = RCTConvert.uiImage(navBarImagePath)
            let imageView = UIImageView(image: image)
            titleView = imageView
            break
        default: break
        }
        return titleView
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if let onTraitCollectionChange = screenConfig["onTraitCollectionChange"] as? NSString {
            HelmManager.shared.bridge.enqueueJSCall("RCTDeviceEventEmitter.emit", args: [onTraitCollectionChange])
        }
    }
}

fileprivate struct Associated {
    static var barButtonAction = "barButtonAction"
}
