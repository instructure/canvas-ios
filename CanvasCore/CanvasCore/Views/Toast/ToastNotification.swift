//
// Copyright (C) 2016-present Instructure, Inc.
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

private let verticalPadding = CGFloat(4)
private let defaultDuration = TimeInterval(1.65)

fileprivate class ToastView: UIView {
    let label = UILabel()
    var heightConstraint: NSLayoutConstraint!
    var hideConstraint: NSLayoutConstraint!

    init(message: String, color: UIColor) {
        super.init(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = color
        clipsToBounds = true
        label.text = message
        label.textColor = .white
        label.font = .preferredFont(forTextStyle: .caption1)
        label.sizeToFit()
        
        addSubview(label)
        
        heightConstraint = heightAnchor.constraint(equalTo: label.heightAnchor, constant: verticalPadding + verticalPadding)
        hideConstraint = heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            hideConstraint,
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -verticalPadding),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor),
            label.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func attach(to navigationBar: UINavigationBar) {
        navigationBar.addSubview(self)
        var toastFrame = navigationBar.bounds
        toastFrame.origin.y = toastFrame.height
        toastFrame.size.height = 0
        frame = toastFrame
    }
    
    func present() {
        hideConstraint.isActive = false
        heightConstraint.isActive = true
        
        UIView.animate(withDuration: 0.16, delay: 0.0, options: .curveEaseOut, animations: {
            self.superview?.layoutIfNeeded()
        }, completion: { _ in
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, self.label.text)
        })
    }
    
    func dismiss() {
        heightConstraint.isActive = false
        hideConstraint.isActive = true
        
        UIView.animate(withDuration: 0.16, delay: 0.0, options: .curveEaseIn, animations: {
            self.superview?.layoutIfNeeded()
        }, completion: { _ in
            // For some reason iPads think that removing the toast view from the superview modifies some constraints that shouldn't be modified
            // This error: Cannot modify constraints for UINavigationBar managed by a controller
            // So, instead of removing the toast view, just setting it's alpha to nothing so it will never be seen again
            // Weird iOS, weird.
            // This will leak the toast view, but that felt better than crashing the app to me
            // And, I don't feel like rewriting how the toast attaches to navigation bars
            self.alpha = 0.0
        })
    }
}

public class ToastManager : NSObject {
    
    let defaultToastDuration = 2.5
    let navigationBar: UINavigationBar?
    fileprivate var toastView: ToastView?
    
    public init(navigationBar: UINavigationBar) {
        self.navigationBar = navigationBar
        super.init()
    }
    
    // ---------------------------------------------
    // MARK: - Default Duration
    // ---------------------------------------------
    
    /// Shows success toast with message *does not autodismiss*
    public func beginToastSuccess(_ message: String) {
        toast(message, color: .toastSuccess, dismissAfter: nil)
    }
    /// Shows and autodismisses success toast with message
    public func toastSuccess(_ message: String) {
        toast(message, color: .toastSuccess, dismissAfter: defaultDuration)
    }

    /// Shows info toast with message *does not autodismiss*
    public func beginToastInfo(_ message: String) {
        toast(message, color: .toastInfo, dismissAfter: nil)
    }
    /// Shows and autodismisses info toast with message
    public func toastInfo(_ message: String) {
        toast(message, color: .toastInfo, dismissAfter: defaultDuration)
    }
    
    /// Shows failure toast with message *does not autodismiss*
    public func beginToastFailure(_ message: String) {
        toast(message, color: UIColor.toastFailure, dismissAfter: nil)
    }
    /// Shows and autodismisses failure toast with message
    public func toastFailure(_ message: String) {
        toast(message, color: .toastFailure, dismissAfter: defaultDuration)
    }
    
    func toast(_ message: String, color: UIColor, dismissAfter duration: TimeInterval?) {
        guard toastView == nil else {
            return
        }
        let toast = ToastView(message: message, color: color)
        
        guard let navigationBar = self.navigationBar else {
            return
        }
        
        toast.attach(to: navigationBar)

        NSLayoutConstraint.activate([
            toast.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            toast.leftAnchor.constraint(equalTo: navigationBar.leftAnchor),
            toast.rightAnchor.constraint(equalTo: navigationBar.rightAnchor),
        ])
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            toast.present()
            if let duration = duration {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: self.endToast)
            }
        }
        toastView = toast
    }
    
    public func endToast() {
        toastView?.dismiss()
        toastView = nil
    }
}
