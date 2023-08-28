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

class OfflineBannerView: UIView {
    @IBOutlet private unowned var onlineContainer: UIView!
    @IBOutlet private unowned var offlineContainer: UIView!
    @IBOutlet private unowned var separatorHeight: NSLayoutConstraint!
    @IBOutlet private unowned var offlineIconCenter: NSLayoutConstraint!
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
        viewController.view.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor).isActive = true
        topAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        heightAnchor.constraint(equalToConstant: 32).isActive = true
        offlineIconCenter.constant = 1 / UIScreen.main.scale
        separatorHeight.constant = 1 / UIScreen.main.scale
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
            .map { !$0 }
            .assign(to: \.accessibilityElementsHidden, on: self, ownership: .weak)
            .store(in: &subscriptions)
    }
}

public extension UIViewController {

    func embedOfflineBanner() {
        let bannerViewModel = OfflineModeAssembly.make(parent: self)
        let view = OfflineBannerView.create(viewModel: bannerViewModel)
        view.embed(into: self)
    }
}
