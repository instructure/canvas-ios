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

public final class HelmViewController: ScreenViewTrackableViewController, HelmScreen {

    @objc public let moduleName: String
    @objc let screenInstanceID: String
    @objc public var props: Props
    var screenConfig: HelmScreenConfig = HelmScreenConfig(config: [:]) {
        didSet {
            self.screenConfig.moduleName = self.moduleName
        }
    }
    private let titleSubtitleView = TitleSubtitleView.create()
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
    public lazy var screenViewTrackingParameters: ScreenViewTrackingParameters = {
        var attributes: [String: String] = [:]
        for (key, value) in props {
            attributes[key] = value as? String
        }
        if let customPageViewPath = screenConfig[PageViewEventController.Constants.customPageViewPath] as? String {
            attributes[PageViewEventController.Constants.customPageViewPath] = customPageViewPath
        }
        return ScreenViewTrackingParameters(eventName: moduleName, attributes: attributes)
    }()

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

    public convenience init(moduleName: String, url: URLComponents, params: [String: String], userInfo: [String: Any]?) {
        var props: Props = userInfo ?? [:]
        for (key, value) in params {
            props[key] = value
        }
        let location: [String: Any?] = [
            "hash": url.fragment.flatMap { "#\($0)" },
            "host": url.host.flatMap { host in
                url.port.flatMap { "\(host):\($0)" } ?? host
            },
            "hostname": url.host,
            "href": url.string,
            "pathname": url.path,
            "port": url.port.flatMap { String($0) },
            "protocol": url.scheme.flatMap { "\($0):" },
            "query": url.queryItems?.reduce(into: [String: String?]()) { query, item in
                props[item.name] = item.value
                query[item.name] = item.value
            },
            "search": url.query.flatMap { "?\($0)" },
        ]
        props["location"] = location
        self.init(moduleName: moduleName, props: props)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View lifecycle

    override public func loadView() {
        self.view = RCTRootView(bridge: HelmManager.shared.bridge, moduleName: moduleName, initialProperties: props)
        view.backgroundColor = .backgroundLightest
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
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleStyles()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isVisible = false
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
        if !screenConfig.config.isEmpty {
            switch screenConfig[PropKeys.navBarStyle] as? String {
            case "context":
                if #available(iOS 16, *) {
                    navigationController?.navigationBar.useContextColor(nil, isTranslucent: screenConfig.navBarTransparent)
                } else {
                    navigationController?.navigationBar.useContextColor(screenConfig.navBarColor, isTranslucent: screenConfig.navBarTransparent)
                }
            case "global":
                navigationController?.navigationBar.useGlobalNavStyle()
            default:
                navigationController?.navigationBar.useModalStyle()
            }
        }

        if let title = screenConfig[PropKeys.title] as? String {
            self.title = title
            navigationItem.title = title
            if let subtitle = screenConfig[PropKeys.subtitle] as? String, !subtitle.isEmpty {
                navigationItem.titleView = titleSubtitleView
                titleSubtitleView.title = title
                titleSubtitleView.subtitle = subtitle
                titleSubtitleView.accessibilityLabel = "\(title), \(subtitle)"
            } else {
                navigationItem.titleView = nil
            }
        }

        if screenConfig[PropKeys.navBarLogo] as? Bool == true {
            self.navigationItem.titleView = Core.Brand.shared.headerImageView()
        }

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
        } else {
            navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
            navigationController?.navigationBar.isTranslucent = false
        }

        let navBarHidden = screenConfig[PropKeys.navBarHidden] as? Bool ?? false
        if navigationController?.isNavigationBarHidden != navBarHidden {
            navigationController?.setNavigationBarHidden(navBarHidden, animated: true)
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
                        objc_setAssociatedObject(button, &Associated.barButtonAction, action, .OBJC_ASSOCIATION_RETAIN)
                    }
                    view.addSubview(button)
                    barButtonItem = UIBarButtonItem(customView: view)
                } else if let imageConfig = buttonConfig["image"], let image = RCTConvert.uiImage(imageConfig), let badgeConfig = buttonConfig["badge"] as? [String: Any] {
                    let frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
                    let button =  UIButton(type: .custom)
                    button.frame = frame
                    button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
                    button.addTarget(self, action: #selector(barButtonTapped(_:)), for: .touchUpInside)
                    if let action = buttonConfig["action"] as? NSString {
                        objc_setAssociatedObject(button, &Associated.barButtonAction, action, .OBJC_ASSOCIATION_RETAIN)
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
                } else if let imageConfig = buttonConfig["image"], let image = RCTConvert.uiImage(imageConfig) {
                    barButtonItem = UIBarButtonItem(image: image, style: style, target: self, action: #selector(barButtonTapped(_:)))
                } else if let title = buttonConfig["title"] as? String {
                    barButtonItem = UIBarButtonItem(title: title, style: style, target: self, action: #selector(barButtonTapped(_:)))
                } else {
                    continue
                }
                items.append(barButtonItem)

                if let action = buttonConfig["action"] as? NSString {
                    objc_setAssociatedObject(barButtonItem, &Associated.barButtonAction, action, .OBJC_ASSOCIATION_RETAIN)
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
            let dismissTitle = screenConfig[PropKeys.dismissButtonTitle] as? String ?? NSLocalizedString("Done", bundle: .canvas, comment: "")
            addModalDismissButton(buttonTitle: dismissTitle)
        }

        if let backButtonTitle = screenConfig[PropKeys.backButtonTitle] as? String {
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: backButtonTitle, style: .plain, target: nil, action: nil)
        }

        if let backgroundColor = screenConfig[PropKeys.backgroundColor] {
            view.backgroundColor = RCTConvert.uiColor(backgroundColor)
        }

        self.navigationController?.syncStyles()
    }

    @objc func barButtonTapped(_ barButton: UIBarButtonItem) {
        if let action = objc_getAssociatedObject(barButton, &Associated.barButtonAction) as? NSString {
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
        var dismissTitle = NSLocalizedString("Done", bundle: .canvas, comment: "")
        if let buttonTitle = buttonTitle {
            dismissTitle = buttonTitle
        }
        let button = UIBarButtonItem(title: dismissTitle, style: .plain, target: self, action:#selector(dismissModalWithAnimation))
        button.accessibilityIdentifier = "screen.dismiss"
        if navigationItem.rightBarButtonItems?.count ?? 0 == 0 {
            button.style = .done
            navigationItem.rightBarButtonItem = button
        } else if navigationItem.leftBarButtonItems?.count ?? 0 == 0 {
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
