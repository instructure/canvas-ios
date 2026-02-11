//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import Combine
import UIKit

class OfflineBannerView: UIView {

    @IBOutlet private unowned var separatorHeight: NSLayoutConstraint!
    @IBOutlet private unowned var offlineIconCenter: NSLayoutConstraint!

    @IBOutlet weak var separator: UIView!

    @IBOutlet weak var offlineContainer: UIView!
    @IBOutlet weak var offlineIcon: UIImageView!
    @IBOutlet weak var offlineLabel: DynamicLabel!

    @IBOutlet weak var onlineContainer: UIView!

    private weak var containerController: UIViewController?
    private var bottomConstraint: NSLayoutConstraint?
    private var contentHeight: CGFloat = 0
    private var containerBounds: CGRect = .zero

    private var viewModel: OfflineBannerViewModel! {
        didSet {
            setup()
        }
    }
    private var subscriptions = Set<AnyCancellable>()

    public static func create(viewModel: OfflineBannerViewModel) -> Self {
        let view = loadFromXib()
        view.viewModel = viewModel
        return view
    }

    public func embed(into viewController: UIViewController) {
        self.containerController = viewController

        if #available(iOS 26, *) {
            separator.isHidden = true
            backgroundColor = .backgroundDark
            offlineIcon.tintColor = .textLightest
            offlineLabel.textColor = .textLightest
        } else {
            backgroundColor = .backgroundLightest
            offlineIcon.tintColor = .textDarkest
            offlineLabel.textColor = .textDarkest
        }

        viewController.view.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor)
        ])

        bottomConstraint = offlineContainer.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor)
        bottomConstraint?.isActive = true

        if #unavailable(iOS 26) {
            separatorHeight.constant = 1 / UIScreen.main.scale
            offlineIconCenter.constant = 1 / UIScreen.main.scale
        }
    }

    private func setup() {
        subscriptions.removeAll()

        viewModel
            .$isOffline
            .sink { [onlineContainer, offlineContainer] isOffline in
                UIView.animate(withDuration: isOffline ? 0 : 0.3) {
                    onlineContainer?.alpha = isOffline ? 0 : 1
                    offlineContainer?.alpha = isOffline ? 1 : 0
                }
            }
            .store(in: &subscriptions)

        viewModel
            .$isVisible
            .sink { [weak self] isVisible in
                guard let self else { return }

                UIView.animate(withDuration: isVisible ? 0 : 0.3) {
                    self.alpha = isVisible ? 1 : 0
                }

                accessibilityElementsHidden = !isVisible

                updateContentLayout(isVisible: isVisible, animated: !isVisible)
            }
            .store(in: &subscriptions)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Covers the use case where app is background then put back to foreground
        if contentHeight != offlineContainer.bounds.height {
            contentHeight = offlineContainer.bounds.height
            updateContainerAdditionalInsets(isVisible: viewModel.isVisible)
            return
        }

        // Covers the use case of window re-size on iPadOS 26
        if let viewBounds = containerController?.view.bounds,
           containerBounds != viewBounds,
           viewModel.isVisible {
            containerBounds = viewBounds
            updateContentLayout(isVisible: true)
        }
    }

    private func updateContentLayout(isVisible: Bool, animated: Bool = false) {

        let bottomOffset = containerController?.defaultSafeAreaBottomInset ?? 0
        let resetLayout = {
            self.bottomConstraint?.constant = -1 * bottomOffset
            self.containerController?.view.layoutIfNeeded()
            self.updateContainerAdditionalInsets(isVisible: isVisible)
        }

        if animated {
            UIView.animate(withDuration: 0.3, animations: resetLayout)
        } else {
            resetLayout()
        }
    }

    private func updateContainerAdditionalInsets(isVisible: Bool) {
        containerController?.additionalSafeAreaInsets = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: isVisible ? contentHeight : 0,
            right: 0
        )
    }
}

public extension UIViewController {

    func embedOfflineBanner() {
        let bannerViewModel = OfflineModeAssembly.make(parent: self)
        let view = OfflineBannerView.create(viewModel: bannerViewModel)
        view.embed(into: self)
    }
}

private extension UIViewController {
    var defaultSafeAreaBottomInset: CGFloat {
        return view.safeAreaInsets.bottom - additionalSafeAreaInsets.bottom
    }
}
