//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit
import CanvasKeymaster
import Kingfisher

let masqueradeColor = UIColor.colorFromHexString("#BE32A3")!

public class MasqueradableWindow: UIWindow {
    @objc lazy var overlay: MasqueradeOverlay = {
        let view = MasqueradeOverlay(frame: self.bounds)
        view.backgroundColor = .clear
        view.layer.borderColor = masqueradeColor.cgColor
        view.layer.borderWidth = 2
        view.alpha = 0.0
        return view
    }()
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        overlay.frame = self.bounds
        self.bringSubviewToFront(overlay)
        self.overlay.setNeedsLayout()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.registerObservers()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate var masquerading = true {
        didSet {
            
            if overlay.superview == nil, masquerading == true {
                self.addSubview(overlay)
            }
            
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                guard let me = self else { return }
                me.overlay.alpha = me.masquerading ? 1.0 : 0.0
            }) { [weak self] completed in
                guard let me = self else { return }
                if me.masquerading == false {
                    me.overlay.removeFromSuperview()
                }
            }
        }
    }
    private func registerObservers() {
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "MasqueradeDidStart"), object: nil, queue: nil) { [weak self] (_) in
            self?.masquerading = true
            self?.overlay.beginMasquerade()
        }
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "MasqueradeDidEnd"), object: nil, queue: nil) { [weak self] (_) in
            self?.masquerading = false
        }
    }
}

class MasqueradeOverlay: UIView {
    
    @objc lazy var button: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(endMasquerade), for: .touchUpInside)
        button.backgroundColor = .white
        button.clipsToBounds = true
        button.accessibilityLabel = NSLocalizedString("End Act as User", tableName: nil, bundle: .core, value: "End Act as User", comment: "")
        return button
    }()
    
    @objc lazy var buttonContainer: UIView = {
        let view = UIView()
        view.backgroundColor = masqueradeColor
        view.layer.cornerRadius = 48 / 2
        view.frame = CGRect(x: 0, y: 0, width: 48, height: 48)
        let buttonSuperview = UIView()
        buttonSuperview.backgroundColor = .white
        buttonSuperview.frame = CGRect(x: 4, y: 4, width: 40, height: 40)
        buttonSuperview.layer.cornerRadius = 40 / 2
        view.addSubview(buttonSuperview)
        let button = self.button
        button.frame = CGRect(x: 2, y: 2, width: 36, height: 36)
        button.layer.cornerRadius = 36 / 2
        buttonSuperview.addSubview(button)
        
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var shouldAnimate = true
        if buttonContainer.superview == nil {
            self.addSubview(buttonContainer)
            shouldAnimate = false
        }
        var bottomMargin: CGFloat = 10.0
        
        if let tabBarController = UIApplication.shared.delegate?.topViewController as? UITabBarController {
            bottomMargin += tabBarController.tabBar.frame.size.height
        }
        
        var frame = buttonContainer.frame
        frame.origin.x = self.bounds.size.width - frame.size.width - 10.0
        frame.origin.y = self.bounds.size.height - frame.size.height - bottomMargin
        
        if shouldAnimate {
            UIView.animate(withDuration: 0.25) {
                self.buttonContainer.frame = frame
            }
        } else {
            self.buttonContainer.frame = frame
        }
    }
    
    @objc func beginMasquerade() {
        let placeholderImage = UIImage(named: "icon_user", in: .core, compatibleWith: nil)
        if let avatarURL = CanvasKeymaster.the().currentClient?.currentUser?.avatarURL {
            button.kf.setImage(with: avatarURL, for: .normal, placeholder: placeholderImage)
        } else {
            button.setImage(placeholderImage, for: .normal)
        }
    }
    
    @objc func endMasquerade() {
        guard let viewController = UIApplication.shared.delegate?.topViewController else { return }
        var message = NSLocalizedString("You will stop acting as this user and return to your account.", tableName: nil, bundle: .core, value: "You will stop acting as this user and return to your account.", comment: "")
        if let name = CanvasKeymaster.the().currentClient?.currentUser?.name {
            let template = NSLocalizedString("You will stop acting as %@ and return to your account.", tableName: nil, bundle: .core, value: "You will stop acting as %@ and return to your account.", comment: "")
            message = String.localizedStringWithFormat(template, name)
        }
        let title = NSLocalizedString("Stop acting as...", tableName: nil, bundle: .core, value: "Stop acting as...", comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: NSLocalizedString("OK", tableName: nil, bundle: .core, value: "OK", comment: ""), style: .default) { _ in
            // Parent no longer has a RNBridge so the old method doesn't work
            NativeLoginManager.shared().shouldCleanupOnNextLogoutEvent = true
            CanvasKeymaster.the().stopMasquerading()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "MasqueradeDidEnd"), object: nil)
        }
        let cancelTitle = NSLocalizedString("Cancel", tableName: nil, bundle: .core, value: "Cancel", comment: "")
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
