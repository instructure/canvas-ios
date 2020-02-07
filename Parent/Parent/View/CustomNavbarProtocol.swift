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

@objc protocol CustomNavbarActionDelegate: class {
    func didClickNavbarNameButton(sender: UIButton)
}

protocol CustomNavbarProtocol: class {
    var customNavBarContainer: UIView! { get }
    var view: UIView! { get }
    var customNavBarColor: UIColor? { get }
    var navbarAvatar: AvatarView? { get set }
    var navbarContentContainer: UIView! { get set }
    var navbarMenu: UIView! { get set }
    var navbarMenuStackView: HorizontalScrollingStackview! { get set }
    var navbarMenuHeightConstraint: NSLayoutConstraint! { get set }
    var navbarNameButton: DynamicButton! { get set }
    var navbarActionButton: UIButton! { get set }
    var customNavbarDelegate: CustomNavbarActionDelegate? { get set }
    var navbarMenuIsHidden: Bool { get }

    func showCustomNavbarMenu(_ show: Bool, completion: (() -> Void)?)
    func setupCustomNavbar()
}

extension CustomNavbarProtocol {

    var navbarMenuIsHidden: Bool {  navbarMenuHeightConstraint.constant == 0 }

    func setupCustomNavbar() {
        refreshNavbarColor()
        configureButtonNameContainer()
        configureAvatar()
        configureNameButton()
        configureMenu()
        configureActionButton()
    }

    func configureMenu() {
        navbarMenu = UIView()
        let v: UIView = navbarMenu
        v.backgroundColor = .named(.backgroundLightest)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.alpha = 0
        view.addSubview(v)
        navbarMenuHeightConstraint = v.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            v.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            v.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            v.topAnchor.constraint(equalTo: customNavBarContainer.bottomAnchor),
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
        navbarNameButton.adjustsImageWhenHighlighted = false
        navbarNameButton.semanticContentAttribute = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        let img = UIImage(named: "icon_down_arrow")?.withRenderingMode(.alwaysTemplate)
        navbarNameButton.setImage(img, for: .normal)
        navbarNameButton.imageView?.transform = CGAffineTransform(rotationAngle: CGFloat(180.0 * .pi))
        navbarNameButton.imageView?.contentMode = .scaleAspectFit
        navbarNameButton.tintColor = .white
        navbarNameButton.adjustsImageWhenHighlighted = false
        navbarNameButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        navbarNameButton.titleLabel?.font = .scaledNamedFont(.semibold16)
        navbarNameButton.setTitleColor(.white, for: .normal)
        navbarNameButton.titleLabel?.textAlignment = .center

        navbarNameButton.translatesAutoresizingMaskIntoConstraints = false
        navbarContentContainer.addSubview(navbarNameButton)

        guard let avatar = navbarAvatar else { return }
        NSLayoutConstraint.activate([
            navbarNameButton.leadingAnchor.constraint(equalTo: navbarContentContainer.leadingAnchor),
            navbarNameButton.trailingAnchor.constraint(equalTo: navbarContentContainer.trailingAnchor),
            navbarNameButton.heightAnchor.constraint(equalToConstant: 21),
            navbarNameButton.topAnchor.constraint(equalTo: avatar.bottomAnchor, constant: 8),
        ])

        if let customNavbarDelegate = customNavbarDelegate {
            navbarNameButton.addTarget(customNavbarDelegate, action: #selector(CustomNavbarActionDelegate.didClickNavbarNameButton(sender:)), for: .primaryActionTriggered)
        }
    }

    func configureAvatar() {
        let avatarSize: CGFloat =  44
        let avatarRect = CGRect(x: 0, y: 0, width: avatarSize, height: avatarSize)
        let avatar = AvatarView(frame: avatarRect)
        navbarAvatar = avatar
        navbarContentContainer.addSubview(avatar)
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.heightAnchor.constraint(equalToConstant: avatarSize).isActive = true
        avatar.widthAnchor.constraint(equalToConstant: avatarSize).isActive = true
        NSLayoutConstraint.activate([
            avatar.topAnchor.constraint(equalToSystemSpacingBelow: navbarContentContainer.topAnchor, multiplier: 0),
            avatar.centerXAnchor.constraint(equalTo: navbarContentContainer.centerXAnchor),
        ])
        navbarAvatar?.addDropShadow(size: avatarSize)
    }

    func configureButtonNameContainer(height: CGFloat = 75) {
        navbarContentContainer = UIView()
        let v: UIView = navbarContentContainer
        v.translatesAutoresizingMaskIntoConstraints = false
        customNavBarContainer.addSubview(v)
        NSLayoutConstraint.activate([
            v.heightAnchor.constraint(equalToConstant: height),
            v.widthAnchor.constraint(equalTo: customNavBarContainer.widthAnchor, multiplier: 0.7, constant: 1),
            v.centerXAnchor.constraint(equalTo: customNavBarContainer.centerXAnchor),
            v.bottomAnchor.constraint(equalTo: customNavBarContainer.bottomAnchor, constant: -18),
        ])
    }

    func configureActionButton() {
        let button = UIButton()
        navbarContentContainer.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.pinToAllSidesOfSuperview()

        if let customNavbarDelegate = customNavbarDelegate {
            button.addTarget(customNavbarDelegate, action: #selector(CustomNavbarActionDelegate.didClickNavbarNameButton(sender:)), for: .primaryActionTriggered)
        }
        navbarActionButton = button
    }

    func hookupRootViewToMenu(_ view: UIView) {
        if let top = view.constraintsAffectingLayout(for: .vertical).first(where: { ($0.firstItem as? UIView) == view }) {
            view.superview?.removeConstraint(top)
        }
        view.topAnchor.constraint(equalTo: navbarMenu.bottomAnchor, constant: 0).isActive = true
    }

    func showCustomNavbarMenu(_ show: Bool = true, completion: (() -> Void)? = nil) {
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
            navbarNameButton.imageView?.transform = CGAffineTransform(rotationAngle: CGFloat(180.0 * .pi))
        }
    }

    func customNavbarBringSubviewsToFront() {
        view.bringSubviewToFront(navbarMenu)
        view.bringSubviewToFront(navbarContentContainer)
    }

    func refreshNavbarColor() {
        customNavBarContainer?.backgroundColor = customNavBarColor?.ensureContrast(against: .white)
    }
}

extension AvatarView {
    func addDropShadow(size: CGFloat? = nil) {
        layer.cornerRadius = ceil( size ?? bounds.size.width / 2.0 )
        layer.shadowOffset = CGSize(width: 0, height: 4.0)
        layer.shadowColor =  UIColor(white: 0, alpha: 1).cgColor
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 8
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}
