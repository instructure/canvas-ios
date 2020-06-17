//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import Foundation
import UIKit

public class ActAsUserWindow: UIWindow {
    weak var loginDelegate: LoginDelegate?

    lazy var overlay = ActAsUserOverlay(frame: bounds, loginDelegate: loginDelegate)
    public var uiTestHelper: UIButton?

    override public func layoutSubviews() {
        isActing = (
            !(rootViewController is LoadingViewController) &&
            !(rootViewController is LoginNavigationController) &&
            AppEnvironment.shared.currentSession?.actAsUserID != nil
        )

        super.layoutSubviews()
        overlay.frame = bounds
        bringSubviewToFront(overlay)
        if let button = uiTestHelper {
            bringSubviewToFront(button)
        }
        overlay.setNeedsLayout()
    }

    public convenience init(frame: CGRect, loginDelegate: LoginDelegate) {
        self.init(frame: frame)
        self.loginDelegate = loginDelegate
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var isActing = false {
        didSet {
            guard oldValue != isActing else { return }

            if overlay.superview == nil, isActing {
                addSubview(overlay)
            } else if !isActing {
                overlay.removeFromSuperview()
            }

            if isActing, let session = AppEnvironment.shared.currentSession {
                overlay.avatarView.name = session.userName
                overlay.avatarView.url = session.userAvatarURL
            }
        }
    }
}

class ActAsUserOverlay: UIView {
    weak var loginDelegate: LoginDelegate?

    convenience init(frame: CGRect, loginDelegate: LoginDelegate?) {
        self.init(frame: frame)
        self.loginDelegate = loginDelegate

        backgroundColor = .clear
        layer.borderColor = UIColor.named(.borderAlert).cgColor
        layer.borderWidth = 2
        addSubview(buttonContainer)
    }

    lazy var button: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(stopActing), for: .primaryActionTriggered)
        button.accessibilityIdentifier = "ActAsUser.endActAsUserButton"
        button.accessibilityLabel = NSLocalizedString("End Act as User", bundle: .core, comment: "")
        return button
    }()

    lazy var avatarView = AvatarView()

    lazy var buttonContainer: UIView = {
        let container = UIView()
        container.backgroundColor = UIColor.named(.backgroundLightest)
        container.layer.borderColor = UIColor.named(.borderAlert).cgColor
        container.layer.borderWidth = 4
        container.layer.cornerRadius = 48 / 2
        container.frame = CGRect(x: bounds.width - 58, y: bounds.height - 58, width: 48, height: 48)

        avatarView.frame = CGRect(x: 6, y: 6, width: 36, height: 36)
        container.addSubview(avatarView)

        button.frame = container.bounds
        container.addSubview(button)

        return container
    }()

    var tabBarController: UITabBarController? {
        var top = window?.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top as? UITabBarController
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        var bottomMargin: CGFloat = 10
        if let tabBarController = tabBarController {
            bottomMargin += tabBarController.tabBar.frame.height
        }
        var frame = buttonContainer.frame
        let previousY = frame.origin.y
        frame.origin.x = bounds.width - frame.width - 10
        frame.origin.y = bounds.height - frame.height - bottomMargin
        if previousY != frame.origin.y {
            UIView.animate(withDuration: 0.25) {
                self.buttonContainer.frame = frame
            }
        } else {
            buttonContainer.frame = frame
        }
        // Make the button go last in order, but still activate correctly
        button.accessibilityActivationPoint = CGPoint(x: frame.midX, y: frame.midY)
        frame.origin.y = UIScreen.main.bounds.maxY - frame.height
        button.accessibilityFrame = frame
    }

    @objc func stopActing() {
        guard let viewController = window?.rootViewController?.topMostViewController() else { return }
        let session = AppEnvironment.shared.currentSession
        var message: String? = NSLocalizedString("You will stop acting as this user and return to your account.", bundle: .core, comment: "")
        if let name = session?.userName, session?.isFakeStudent != true {
            let template = NSLocalizedString("You will stop acting as %@ and return to your account.", bundle: .core, comment: "")
            message = String.localizedStringWithFormat(template, name)
        }
        var title = NSLocalizedString("Stop acting as...", bundle: .core, comment: "")
        if session?.isFakeStudent == true {
            title = NSLocalizedString("Leave Student View", bundle: .core, comment: "")
            message = NSLocalizedString("Are you sure you want to exit Student View?", bundle: .core, comment: "")
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: NSLocalizedString("OK", bundle: .core, comment: ""), style: .default) { _ in
            if let loginDelegate = self.loginDelegate, let session = AppEnvironment.shared.currentSession {
                loginDelegate.stopActing(as: session)
            }
        }
        let cancelTitle = NSLocalizedString("Cancel", bundle: .core, comment: "")
        let cancel = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
        alert.addAction(ok)
        alert.addAction(cancel)
        viewController.present(alert, animated: true)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if buttonContainer.frame.contains(point) {
            return button
        }
        return nil
    }
}
