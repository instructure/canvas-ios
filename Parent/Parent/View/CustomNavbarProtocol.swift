//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import Core

extension UINavigationBar {
    func styleOpaque() {
        let img = UIImage()
        shadowImage = img
        setBackgroundImage(img, for: .default)
        isTranslucent = false
    }
}

@objc protocol CustomNavbarActionDelegate: class {
    func didClickNavbarNameButton(sender: UIButton)
}

protocol CustomNavbarProtocol: class {
    var navigationController: UINavigationController? { get }
    var navigationItem: UINavigationItem { get }
    var view: UIView! { get }
    var customNavBarColor: UIColor? { get }
    var navbarAvatar: AvatarView? { get set }
    var navbarBottomViewContainer: UIView! { get set }
    var navbarMenu: UIView! { get set }
    var navbarMenuStackView: HorizontalScrollingStackview! { get set }
    var navbarMenuHeightConstraint: NSLayoutConstraint! { get set }
    var navbarNameButton: DynamicButton! { get set }
    var customNavbarDelegate: CustomNavbarActionDelegate? { get set }
    var navbarMenuIsHidden: Bool { get }

    func showCustomNavbarMenu(_ show: Bool, completion: (() -> Void)?)
    func setupCustomNavbar()
}

extension CustomNavbarProtocol {

    var navbarMenuIsHidden: Bool {  navbarMenuHeightConstraint.constant == 0 }

    func setupCustomNavbar() {
        navigationController?.navigationBar.barTintColor = customNavBarColor
        navigationController?.navigationBar.styleOpaque()
        navigationController?.navigationBar.barStyle = .black
        addNavbarBottomView()
        configureAvatar()
        configureNameButton()
        configureMenu()
    }

    func configureMenu() {
        navbarMenu = UIView()
        let v: UIView = navbarMenu
        v.backgroundColor = .white
        v.translatesAutoresizingMaskIntoConstraints = false
        v.alpha = 0
        view.addSubview(v)
        navbarMenuHeightConstraint = v.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            v.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            v.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            v.topAnchor.constraint(equalTo: navbarBottomViewContainer.bottomAnchor),
            navbarMenuHeightConstraint,
        ])

        let border = UIView()
        border.backgroundColor = .named(.borderMedium)
        border.translatesAutoresizingMaskIntoConstraints = false
        navbarMenu.addSubview(border)
        NSLayoutConstraint.activate([
            border.leadingAnchor.constraint(equalTo: navbarMenu.leadingAnchor),
            border.trailingAnchor.constraint(equalTo: navbarMenu.trailingAnchor),
            border.bottomAnchor.constraint(equalTo: navbarMenu.bottomAnchor),
            border.heightAnchor.constraint(equalToConstant: 1),
        ])

        navbarMenuStackView = HorizontalScrollingStackview()
        navbarMenuStackView.scrollView.showsHorizontalScrollIndicator = false
        navbarMenuStackView.scrollView.contentInset.left = 24
        navbarMenu.addSubview(navbarMenuStackView)
        navbarMenuStackView.pin(inside: navbarMenu)
        navbarMenuStackView.spacing = 20
    }

    func configureNameButton() {
        navbarNameButton = DynamicButton()
        navbarNameButton.semanticContentAttribute = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        let img = UIImage.icon(.arrowOpenDown, .solid).scaleTo(CGSize(width: 15, height: 15)).withRenderingMode(.alwaysTemplate)
        navbarNameButton.setImage(img, for: .normal)
        navbarNameButton.imageView?.contentMode = .scaleAspectFit
        navbarNameButton.tintColor = .white
        navbarNameButton.imageEdgeInsets = UIEdgeInsets(top: 2, left: 10, bottom: 0, right: 0)
        navbarNameButton.adjustsImageWhenHighlighted = false
        navbarNameButton.titleLabel?.font = .scaledNamedFont(.semibold16)
        navbarNameButton.setTitleColor(.white, for: .normal)
        navbarNameButton.titleLabel?.textAlignment = .center

        navbarNameButton.translatesAutoresizingMaskIntoConstraints = false
        navbarBottomViewContainer.addSubview(navbarNameButton)

        NSLayoutConstraint.activate([
            navbarNameButton.leadingAnchor.constraint(equalTo: navbarBottomViewContainer.leadingAnchor),
            navbarNameButton.trailingAnchor.constraint(equalTo: navbarBottomViewContainer.trailingAnchor),
            navbarNameButton.heightAnchor.constraint(equalToConstant: 21),
            navbarNameButton.topAnchor.constraint(equalTo: navbarBottomViewContainer.topAnchor, constant: 8),
        ])

        if let customNavbarDelegate = customNavbarDelegate {
            navbarNameButton.addTarget(customNavbarDelegate, action: #selector(CustomNavbarActionDelegate.didClickNavbarNameButton(sender:)), for: .primaryActionTriggered)
        }
    }

    func configureAvatar() {
        let avatarSize: CGFloat =  44
        let container = UIView()
        container.heightAnchor.constraint(equalToConstant: avatarSize).isActive = true
        container.widthAnchor.constraint(equalToConstant: avatarSize).isActive = true

        let avatarRect = CGRect(x: 0, y: 0, width: avatarSize, height: avatarSize)
        let avatar = AvatarView(frame: avatarRect)
        navbarAvatar = avatar
        navbarAvatar?.heightAnchor.constraint(equalToConstant: avatarSize).isActive = true
        navbarAvatar?.widthAnchor.constraint(equalToConstant: avatarSize).isActive = true
        container.addSubview(avatar)
        NSLayoutConstraint.activate([
            avatar.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            avatar.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        ])
        let button = UIButton()
        container.addSubview(button)
        button.pinToAllSidesOfSuperview()
        button.addTarget(customNavbarDelegate, action: #selector(CustomNavbarActionDelegate.didClickNavbarNameButton(sender:)), for: .primaryActionTriggered)
        navigationItem.titleView = container
    }

    func addNavbarBottomView(height: CGFloat = 45) {
        navbarBottomViewContainer = UIView()
        let v: UIView = navbarBottomViewContainer
        v.backgroundColor = customNavBarColor
        v.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(v)
        NSLayoutConstraint.activate([
            v.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            v.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            v.heightAnchor.constraint(equalToConstant: height),
            v.topAnchor.constraint(equalTo: view.topAnchor),
        ])
    }

    func hookupRootViewToMenu(_ view: UIView) {
        if let top = view.constraintsAffectingLayout(for: .vertical).first(where: { ($0.firstItem as? UIView) == view }) {
            view.superview?.removeConstraint(top)
        }
        view.topAnchor.constraint(equalTo: navbarMenu.bottomAnchor, constant: 0).isActive = true
    }

    func showCustomNavbarMenu(_ show: Bool = true, completion: (() -> Void)? = nil) {
        if !isCustomNavMenuEnabled && show { return }
        let menuHeight: CGFloat = show ? 105 : 0
        let duration: Double = show ? 0.3 : 0.3

        if show { navbarMenu.alpha = 1 }
        self.navbarMenuHeightConstraint.constant = menuHeight
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
            self.navbarMenu.superview?.layoutIfNeeded()
            self.showNameButtonOpen(show)
        }, completion: { _ in
            self.navbarMenu.alpha = show ? 1 : 0
            completion?()
        })
    }

    func showNameButtonOpen( _ open: Bool) {
        if open {
            navbarNameButton.imageView?.transform = CGAffineTransform(rotationAngle: .pi)
        } else {
            navbarNameButton.imageView?.transform = CGAffineTransform.identity
        }
    }

    func customNavbarBringSubviewsToFront() {
        view.bringSubviewToFront(navbarMenu)
        view.bringSubviewToFront(navbarBottomViewContainer)
    }

    func refreshNavbarColor() {
        navigationController?.navigationBar.barTintColor = customNavBarColor
        navbarBottomViewContainer.backgroundColor = customNavBarColor
    }
    
    var isCustomNavMenuEnabled: Bool {
        get {
            let enabled = objc_getAssociatedObject(self, &customNavBarMenuEnabledKey) as? Bool
            return enabled ?? true
        }
        set {
            objc_setAssociatedObject(self, &customNavBarMenuEnabledKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}
private var customNavBarMenuEnabledKey: UInt8 = 0
