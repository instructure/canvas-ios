import UIKit
import WebKit

public class SUToolbarWebView: UIView {

    private(set) var webView: WKWebView!
    private var toolbar: UIToolbar = UIToolbar(frame: .zero)
    private lazy var leftButton: UIBarButtonItem = {
        UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(pressedLeft)
        )
    }()
    private lazy var rightButton: UIBarButtonItem = {
        UIBarButtonItem(
            image: UIImage(systemName: "chevron.right"),
            style: .plain,
            target: self,
            action: #selector(pressedRight)
        )
    }()
    private lazy var shareButton: UIBarButtonItem = {
        UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(SUToolbarWebView.pressedShare)
        )
    }()
    private var isToolbarVisible: Bool = false
    private var timer: Timer?

    public init(
        frame: CGRect,
        configuration: WKWebViewConfiguration?,
        isToolbarVisible: Bool
    ) {
        super.init(frame: frame)
        self.isToolbarVisible = isToolbarVisible
        initializeSubviews(configuration: configuration)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeSubviews()
    }

    override public func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview != nil {
            setupTimer()
        }
    }

    override public func removeFromSuperview() {
        super.removeFromSuperview()
        removeTimer()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        let toolbarHeight: CGFloat = isToolbarVisible ? 44 : 0
        toolbar.alpha = isToolbarVisible ? 1 : 0
        toolbar.frame = CGRect(x: 0, y: bounds.height - toolbarHeight, width: bounds.width, height: toolbarHeight)
        webView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - toolbarHeight)
    }

    private func initializeSubviews(configuration: WKWebViewConfiguration? = nil) {
        if let configuration = configuration {
            webView = .init(frame: frame, configuration: configuration)
        } else {
            webView = .init(frame: frame)
        }
        addSubview(webView)
        toolbar.barTintColor = UIColor.secondarySystemBackground
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            leftButton,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            rightButton,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            shareButton,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        ]
        addSubview(toolbar)
    }

    private func updateNavigationButtons() {
        leftButton.isEnabled = webView.canGoBack
        rightButton.isEnabled = webView.canGoForward
    }

    @objc
    private func pressedLeft() {
        guard webView.canGoBack else { return }
        webView.goBack()
    }

    @objc
    private func pressedRight() {
        guard webView.canGoForward else { return }
        webView.goForward()
    }

    @objc
    private func pressedShare() {}
}

// MARK: - Timer
extension SUToolbarWebView {
    private func setupTimer() {
        removeTimer()
        timer = Timer.scheduledTimer(
            timeInterval: 0.3,
            target: self,
            selector: #selector(handleTimer),
            userInfo: nil,
            repeats: true)
        timer?.fire()
    }

    @objc
    private func handleTimer() {
        updateNavigationButtons()
    }

    private func removeTimer() {
        timer?.invalidate()
        timer = nil
    }
}
