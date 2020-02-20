//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import UIKit
import React
import Core

public typealias Props = [String: Any]

protocol HelmScreen {
    var screenConfig: HelmScreenConfig { get set }
    var screenInstanceID: String { get }
    var screenConfigRendered: Bool { get set }
}

public class HelmNavigationItem: UINavigationItem {
    @objc var reactRightBarButtonItems: [UIBarButtonItem] = []
    @objc var nativeLeftBarButtonItems: [UIBarButtonItem] = []
    @objc var reactLeftBarButtonItems: [UIBarButtonItem] = [] {
        didSet {
            super.leftBarButtonItems = combinedLeftItems
        }
    }
    
    public override init(title: String) {
        super.init(title: title)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var combinedLeftItems: [UIBarButtonItem]? {
        get {
            return reactLeftBarButtonItems + nativeLeftBarButtonItems
        }
    }
    
    public override var leftBarButtonItem: UIBarButtonItem? {
        get {
            return super.leftBarButtonItems?.first
        }
        set {
            if let item = newValue {
                nativeLeftBarButtonItems = [item]
            }
            else {
                nativeLeftBarButtonItems = []
            }
            super.leftBarButtonItem = combinedLeftItems?.first
        }
    }
    
    public override var leftBarButtonItems: [UIBarButtonItem]? {
        get {
            return super.leftBarButtonItems
        }
        set {
            nativeLeftBarButtonItems = newValue ?? []
            super.leftBarButtonItems = combinedLeftItems
        }
    }
}

public final class HelmViewController: UIViewController, HelmScreen, PageViewEventViewControllerLoggingProtocol {
    
    @objc public let moduleName: String
    @objc let screenInstanceID: String
    @objc public var props: Props
    var screenConfig: HelmScreenConfig = HelmScreenConfig(config: [:]) {
        didSet {
            self.screenConfig.moduleName = self.moduleName
        }
    }
    fileprivate var twoLineTitleView: TitleSubtitleView?
    public override var title: String?  {
        didSet {
            navigationItem.title = title
        }
    }
    fileprivate var _navigationItem: HelmNavigationItem = HelmNavigationItem(title: "")
    override public var navigationItem: UINavigationItem {
        get {
            return _navigationItem
        }
    }
    
    @objc public var statusBarStyle: UIStatusBarStyle = .default {
        didSet {
            if (statusBarStyle != oldValue) {
                statusBarDirty = true
            }
        }
    }
    @objc public var statusBarHidden: Bool = false {
        didSet {
            if (statusBarHidden != oldValue) {
                statusBarDirty = true
            }
        }
    }
    @objc public var statusBarUpdateAnimation: UIStatusBarAnimation = .fade
    fileprivate var statusBarDirty: Bool = false
    
    @objc private(set) public var isVisible: Bool = false

    @objc var screenConfigRendered: Bool = false {
        didSet {
            if screenConfigRendered {
                screenDidRender()
                onReadyToPresent()
                onReadyToPresent = { }
            }
        }
    }
    @objc var onReadyToPresent: () -> Void = { }
    
    
    // MARK: - Initialization
    
    @objc public init(moduleName: String, props: Props) {
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
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View lifecycle
    
    override public func loadView() {
        self.view = RCTRootView(bridge: HelmManager.shared.bridge, moduleName: moduleName, initialProperties: props)
        view.backgroundColor = .named(.backgroundLightest)
    }
    
    // Do stuff that you'd usually do in viewDidLoad here, rather than there.
    // This is due to the way the Screen component works and it's flow with
    // setting the screenConfig and doing a prerender
    private var _screenDidRender = false
    private func screenDidRender() {
        if (_screenDidRender) { return }
        _screenDidRender = true
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isVisible = true
        handleStyles()
        startTrackingTimeOnViewController()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isVisible = false
        
        var attributes: [String: String] = [:]
        for (key, value) in props {
            attributes[key] = value as? String
        }
        if let customPageViewPath = screenConfig[PageViewEventController.Constants.customPageViewPath] as? String {
            attributes[PageViewEventController.Constants.customPageViewPath] = customPageViewPath
        }
        stopTrackingTimeOnViewController(eventName: moduleName, attributes: attributes)
    }
    
    // MARK: - Status bar
    
    @objc func updateStatusBarIfNeeded() {
        guard (statusBarDirty) else { return }
        defer { statusBarDirty = false }
        
        let duration = statusBarUpdateAnimation != .none ? 0.2 : 0
        UIView.animate(withDuration: duration) { [weak self] in
            self?.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override public var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return statusBarUpdateAnimation
    }
    
    override public var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    public override func accessibilityPerformEscape() -> Bool {
        if let presenting = self.presentingViewController {
            presenting.dismiss(animated: true, completion: nil)
            return true
        }
        return false
    }
    
    // MARK: - Orientation
    
    public override var shouldAutorotate: Bool {
        return super.shouldAutorotate
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let cantRotate = screenConfig[PropKeys.noRotationInVerticallyCompact] as? Bool, cantRotate, (self.traitCollection.verticalSizeClass == .compact || self.traitCollection.horizontalSizeClass == .compact) {
            return .portrait
        }
        
        return super.supportedInterfaceOrientations
    }
    
    // MARK: - Styles
    @objc public func handleStyles() {
        if let title = screenConfig[PropKeys.title] as? String {
            if let subtitle = screenConfig[PropKeys.subtitle] as? String, subtitle.count > 0 {
                if (twoLineTitleView == nil) {
                    twoLineTitleView = self.titleView(with: title, and: subtitle, given: screenConfig)
                    twoLineTitleView?.isAccessibilityElement = true
                    twoLineTitleView?.accessibilityTraits = UIAccessibilityTraits.header
                    navigationItem.titleView = twoLineTitleView
                    navigationItem.title = nil
                }
                
                if let titleView = twoLineTitleView, let titleLabel = titleView.titleLabel, let subtitleLabel = titleView.subtitleLabel {
                    styleTitleViewLabels(titleLabel: titleLabel, subtitleLabel: subtitleLabel)
                    titleLabel.text = title
                    subtitleLabel.text = subtitle
                    titleView.accessibilityLabel = "\(title), \(subtitle)"
                }
            }
            self.title = title
        }
        
        if let navBarImagePath = screenConfig[PropKeys.navBarImage] {
            self.navigationItem.titleView = HelmManager.narBarTitleViewFromImagePath(navBarImagePath)
        }
        
        if let backgroundColor = screenConfig[PropKeys.backgroundColor] {
            view.backgroundColor = RCTConvert.uiColor(backgroundColor)
        }
        
        // Nav bar props
        if (screenConfig.drawUnderNavigationBar) {
            edgesForExtendedLayout.insert(.top)
        } else {
            edgesForExtendedLayout.remove(.top)
        }
        
        if (screenConfig.drawUnderTabBar) {
            edgesForExtendedLayout.insert(.bottom)
        } else {
            edgesForExtendedLayout.remove(.bottom)
        }

        if screenConfig.navBarTransparent {
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.isTranslucent = true
            edgesForExtendedLayout.insert(.top)
        }
        else {
            navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
            navigationController?.navigationBar.isTranslucent = false
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
        
        if let tint = screenConfig.navBarColor {
            navigationController?.syncBarTintColor(tint)
        }
        
        if let navBarButtonColor = screenConfig[PropKeys.navBarButtonColor] ?? HelmManager.shared.defaultScreenConfiguration[moduleName]?[PropKeys.navBarButtonColor] {
            if let navBarButtonColorNone = navBarButtonColor as? String, navBarButtonColorNone == "none" {
                navigationController?.syncTintColor(nil)
            } else {
                navigationController?.syncTintColor(RCTConvert.uiColor(navBarButtonColor))
            }
        } else {
            if screenConfig[PropKeys.navBarStyle] as? String == "dark" {
                navigationController?.syncTintColor(.white)
            } else if screenConfig[PropKeys.navBarStyle] as? String == "light" {
                navigationController?.syncTintColor(Brand.current.linkColor)
            }
        }

        if let c = screenConfig["navBarTitleColor"], let titleColor = RCTConvert.uiColor(c) {
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: titleColor]
        } else {
            navigationController?.navigationBar.titleTextAttributes = nil
        }

        func barButtonItems(fromConfig config: [[String: Any]]) -> [UIBarButtonItem] {
            var items: [UIBarButtonItem] = []
            for buttonConfig in config {
                let styleConfig = buttonConfig["style"] as? String
                let style: UIBarButtonItem.Style = styleConfig == "done" ? .done : .plain
                let barButtonItem: UIBarButtonItem
                if let imageConfig = buttonConfig["image"] as? [String: Any],
                    let imageSource = RCTConvert.rctImageSource(imageConfig),
                    let url = imageSource.request.url, url.scheme?.lowercased() == "https" {
                    let button = UIButton(type: .custom)
                    let image = UIImageView()
                    button.addSubview(image)
                    image.pin(inside: button)
                    image.load(url: url)
                    image.contentMode = .scaleAspectFit
                    let view = UIView()
                    if let width = imageConfig["width"] as? CGFloat, let height = imageConfig["height"] as? CGFloat {
                        let frame = CGRect(x: 0, y: 0, width: width, height: height)
                        view.frame = frame
                        button.frame = frame
                    }
                    if let borderRadius = imageConfig["borderRadius"] as? CGFloat {
                        view.layer.cornerRadius = borderRadius
                        view.clipsToBounds = true
                    }
                    if let action = buttonConfig["action"] as? NSString {
                        button.addTarget(self, action: #selector(barButtonTapped(_:)), for: .touchUpInside)
                        button.setAssociatedObject(action, forKey: &Associated.barButtonAction)
                    }
                    view.addSubview(button)
                    barButtonItem = UIBarButtonItem(customView: view)
                } else if let imageConfig = buttonConfig["image"], let image = RCTConvert.uiImage(imageConfig), let simulateBackChevron = buttonConfig["simulateBackChevron"] as? Bool, simulateBackChevron {
                    let button =  UIButton(type: .custom)
                    button.setImage(image, for: .normal)
                    var width: CGFloat = 26
                    let height: CGFloat = 31
                    if let imageConfig = imageConfig as? [String: Any], let w = imageConfig["width"] as? CGFloat, let scale = imageConfig["scale"] as? CGFloat {
                        width = w * scale
                    }
                    button.frame = CGRect(x: 0, y: 0, width: width, height: height)
                    button.imageEdgeInsets = UIEdgeInsets.init(top: -1, left: -width, bottom: 1, right: 0)
                    button.addTarget(self, action: #selector(barButtonTapped(_:)), for: .touchUpInside)
                    if let action = buttonConfig["action"] as? NSString {
                        button.setAssociatedObject(action, forKey: &Associated.barButtonAction)
                    }

                    barButtonItem = UIBarButtonItem(customView: button)
                } else if let imageConfig = buttonConfig["image"], let image = RCTConvert.uiImage(imageConfig), let badgeConfig = buttonConfig["badge"] as? [String: Any] {
                    let frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
                    let button =  UIButton(type: .custom)
                    button.frame = frame
                    button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
                    button.addTarget(self, action: #selector(barButtonTapped(_:)), for: .touchUpInside)
                    if let action = buttonConfig["action"] as? NSString {
                        button.setAssociatedObject(action, forKey: &Associated.barButtonAction)
                    }
                    let badged = UIView(frame: frame)
                    badged.isAccessibilityElement = true
                    badged.accessibilityLabel = buttonConfig["accessibilityLabel"] as? String
                    let badgeLabel = UILabel()
                    if let backgroundColor = badgeConfig["backgroundColor"] {
                        badgeLabel.backgroundColor = RCTConvert.uiColor(backgroundColor)
                    }
                    if let textColor = badgeConfig["textColor"] {
                        badgeLabel.textColor = RCTConvert.uiColor(textColor)
                    }
                    if let text = badgeConfig["text"] as? String {
                        badgeLabel.text = text
                    }
                    badgeLabel.font = UIFont.systemFont(ofSize: 10)
                    badgeLabel.sizeToFit()
                    let size = max(badgeLabel.frame.size.width, badgeLabel.frame.size.height)

                    // put the badge in the top right corner
                    badgeLabel.frame = CGRect(x: image.size.width - size, y: -2, width: size, height: size)

                    badgeLabel.layer.masksToBounds = true
                    badgeLabel.layer.cornerRadius = size / 2
                    badgeLabel.textAlignment = .center
                    badged.addSubview(button)
                    badged.addSubview(badgeLabel)
                    barButtonItem = UIBarButtonItem(customView: badged)
                } else if let imageConfig = buttonConfig["image"],
                    let image = RCTConvert.uiImage(imageConfig),
                    let width = buttonConfig["width"] as? CGFloat,
                    let height = buttonConfig["height"] as? CGFloat
                {
                    let templateImage = image.scaleTo(CGSize(width: width, height: height)).withRenderingMode(.alwaysTemplate)
                    barButtonItem = UIBarButtonItem(image: templateImage, style: style, target: self, action: #selector(barButtonTapped(_:)))
                }
                else if let imageConfig = buttonConfig["image"], let image = RCTConvert.uiImage(imageConfig) {
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
        
        let leftBarButtonsConfig = screenConfig[PropKeys.leftBarButtons] as? [[String: Any]] ?? []
        let leftBarButtonItems = barButtonItems(fromConfig: leftBarButtonsConfig)
        (navigationItem as? HelmNavigationItem)?.reactLeftBarButtonItems = leftBarButtonItems
        
        let rightBarButtons = screenConfig[PropKeys.rightBarButtons] as? [[String: Any]] ?? []
        navigationItem.rightBarButtonItems = barButtonItems(fromConfig: rightBarButtons)
        
        // show the dismiss button when view controller is shown modally
        let navigatorOptions = props[PropKeys.navigatorOptions] as? [String: Any]
        if screenConfig[PropKeys.dismissButtonTitle] != nil || (navigatorOptions?["modal"] as? Bool == true && screenConfig[PropKeys.showDismissButton] as? Bool == true) {
            let dismissTitle = screenConfig[PropKeys.dismissButtonTitle] as? String ?? NSLocalizedString("Done", comment: "")
            addModalDismissButton(buttonTitle: dismissTitle)
        }
        
        // Status bar props
        if let style = screenConfig[PropKeys.statusBarStyle] as? String {
            if #available(iOS 13, *) {
                statusBarStyle = style == "light" ? .lightContent : .darkContent
            } else {
                statusBarStyle = style == "light" ? .lightContent : .default
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
        
        self.navigationController?.syncStyles()
    }
    
    private func titleView(with title: String, and subtitle: String, given config: HelmScreenConfig) -> TitleSubtitleView {
        let titleView = TitleSubtitleView.create()
        titleView.titleLabel?.text = title
        titleView.subtitleLabel?.text = subtitle
        if let testID = screenConfig["testID"] as? String {
            titleView.accessibilityIdentifier = testID + ".nav-bar-title-view"
        }
        return titleView
    }
    
    private func styleTitleViewLabels(titleLabel: UILabel, subtitleLabel: UILabel) {
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
        titleLabel.textAlignment = .center
        
        subtitleLabel.backgroundColor = UIColor.clear
        subtitleLabel.textColor = subtitleColor
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.textAlignment = .center
    }
    
    @objc func barButtonTapped(_ barButton: UIBarButtonItem) {
        if let action: NSString = barButton.getAssociatedObject(&Associated.barButtonAction) {
            HelmManager.shared.bridge.enqueueJSCall("RCTDeviceEventEmitter.emit", args: [action])
        }
    }
    
    @objc func dismissTapped(_ barButton: UIBarButtonItem) {
        HelmManager.shared.dismiss(["animated": true])
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if let onTraitCollectionChange = screenConfig["onTraitCollectionChange"] as? NSString {
            HelmManager.shared.bridge.enqueueJSCall("RCTDeviceEventEmitter.emit", args: [onTraitCollectionChange])
        }
    }
    
    override public func willMove(toParent parent: UIViewController?) {
        // setting these values in viewWillAppear and/or viewWillDisappear don't animate
        // This is the only place where they animate reliably
        if parent == nil {
            var translucent = false
            let viewControllers = navigationController?.viewControllers ?? []
            let count = viewControllers.count
            if count > 1, let nextViewController = viewControllers[count - 2] as? HelmViewController {
                if let tint = nextViewController.screenConfig.navBarColor {
                    navigationController?.syncBarTintColor(tint)
                }
                translucent = nextViewController.screenConfig.navBarTransparent
            }
            self.navigationController?.navigationBar.isTranslucent = translucent
        }
        super.willMove(toParent: parent)
    }
}

fileprivate struct Associated {
    static var barButtonAction = "barButtonAction"
}

extension UIViewController {
    @objc public func addModalDismissButton(buttonTitle: String?) {
        var dismissTitle = NSLocalizedString("Done", tableName: nil, bundle: .core, value: "Done", comment: "")
        if let buttonTitle = buttonTitle {
            dismissTitle = buttonTitle
        }
        let button = UIBarButtonItem(title: dismissTitle, style: .plain, target: self, action:#selector(dismissModalWithAnimation))
        button.accessibilityIdentifier = "screen.dismiss"
        if navigationItem.rightBarButtonItems?.count ?? 0 == 0 {
            button.style = .done
            navigationItem.rightBarButtonItem = button
        } else {
            navigationItem.leftBarButtonItem = button
        }
    }
    
    @objc func dismissModalWithAnimation() {
        dismissModal(animated: true)
    }
    
    @objc func dismissModal(animated: Bool) {
        dismiss(animated: animated, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
