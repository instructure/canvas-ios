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
        
        Helm.shared.register(screen: self)
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
        self.view = RCTRootView(bridge: Helm.shared.bridge, moduleName: moduleName, initialProperties: props)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        UIView.animate(withDuration: duration, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        })
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
    
    // MARK: - Styles
    
    open func handleStyles() {
        if let title = screenConfig[PropKeys.title] as? String {
            self.title = title
        }
        
        if let title = screenConfig[PropKeys.title] as? String, let subtitle = screenConfig[PropKeys.subtitle] as? String {
            self.navigationItem.titleView = titleView(with: title, and: subtitle, given: screenConfig)
        }
        
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
        
        if let navBarStyle = screenConfig[PropKeys.navBarStyle] as? String {
            switch navBarStyle {
            case "dark": navigationController?.navigationBar.barStyle = .black
            case "light": navigationController?.navigationBar.barStyle = .default
            default: navigationController?.navigationBar.barStyle = .default
            }
        }
       
        let navBarHidden = screenConfig[PropKeys.navBarHidden] as? Bool ?? false
        if navigationController?.isNavigationBarHidden != navBarHidden {
            navigationController?.setNavigationBarHidden(navBarHidden, animated: true)
        }
        
        if let navBarColor = screenConfig[PropKeys.navBarColor] ?? Helm.shared.defaultScreenConfiguration[moduleName]?[PropKeys.navBarColor] {
            if let navBarColorNone = navBarColor as? String, navBarColorNone == "none" {
                navigationController?.navigationBar.barTintColor = nil
            } else {
                navigationController?.navigationBar.barTintColor = RCTConvert.uiColor(navBarColor)
            }
        }
        
        if let navBarButtonColor = screenConfig[PropKeys.navBarButtonColor] ?? Helm.shared.defaultScreenConfiguration[moduleName]?[PropKeys.navBarButtonColor] {
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
        
        navigationController?.navigationBar.isTranslucent = screenConfig[PropKeys.navBarTranslucent] as? Bool ?? false

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
        
        func barButtonItems(forKey key: String) -> [UIBarButtonItem] {
            var items: [UIBarButtonItem] = []
            for buttonConfig in (screenConfig[key] as? [[String: Any]] ?? []) {
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
        
        navigationItem.leftBarButtonItems = barButtonItems(forKey: PropKeys.leftBarButtons)
        navigationItem.rightBarButtonItems = barButtonItems(forKey: PropKeys.rightBarButtons)
        
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
        
        let subtitleLabel = UILabel(frame: CGRect(x:0, y:18, width:0, height:0))
        subtitleLabel.backgroundColor = UIColor.clear
        subtitleLabel.textColor = subtitleColor
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.text = subtitle
        subtitleLabel.sizeToFit()
        
        let titleView = UIView(frame: CGRect(x:0, y:0, width:max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), height:30))
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
        
        return titleView
    }
    
    func barButtonTapped(_ barButton: UIBarButtonItem) {
        if let action: NSString = barButton.getAssociatedObject(&Associated.barButtonAction) {
            Helm.shared.bridge?.enqueueJSCall("RCTDeviceEventEmitter.emit", args: [action])
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
}

fileprivate struct Associated {
    static var barButtonAction = "barButtonAction"
}
