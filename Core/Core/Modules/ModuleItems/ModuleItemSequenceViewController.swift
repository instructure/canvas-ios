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

import Foundation
import SwiftUI
import UIKit

public final class ModuleItemSequenceViewController: UIViewController {
    public typealias AssetType = GetModuleItemSequenceRequest.AssetType

    @IBOutlet weak var pagesContainer: UIView!
    @IBOutlet weak var buttonsContainer: UIView!
    @IBOutlet weak var buttonsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pagesContainerBottomConstraint: NSLayoutConstraint!
    

    /// These should get set only once in viewDidLoad
    private var leftBarButtonItems: [UIBarButtonItem]?
    private var rightBarButtonItems: [UIBarButtonItem]?

    private let env = AppEnvironment.shared
    private lazy var isHorizon = env.app == .horizon
    private var courseID: String!
    private var assetType: AssetType!
    private var assetID: String!
    private var url: URLComponents!
    private var offlineModeInteractor: OfflineModeInteractor!

    let pages = PagesViewController()
    private var observations: [NSKeyValueObservation]?

    private lazy var store = env.subscribe(GetModuleItemSequence(courseID: courseID, assetType: assetType, assetID: assetID)) { [weak self] in
        self?.update(embed: true)
    }

    private var sequence: ModuleItemSequence? { store.first }

    private lazy var moduleNavigationViewModel = ModuleBottomNavBarViewModel(
        didTapPreviousButton: { [weak self] in
            self?.goPrevious()
        },
        didTapNextButton: { [weak self] in
            self?.goNext()
        },
        router: AppEnvironment.shared.router,
        hostingViewController: self
    )

    public static func create(
        courseID: String,
        assetType: AssetType,
        assetID: String,
        url: URLComponents,
        offlineModeInteractor: OfflineModeInteractor = OfflineModeAssembly.make()
    ) -> Self {
        let controller = loadFromStoryboard()
        controller.courseID = courseID
        controller.assetType = assetType
        controller.assetID = assetID
        controller.url = url
        controller.offlineModeInteractor = offlineModeInteractor
        return controller
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        leftBarButtonItems = navigationItem.leftBarButtonItems
        rightBarButtonItems = navigationItem.rightBarButtonItems

        showSequenceButtons(prev: false, next: false)
        pages.scrollView.isScrollEnabled = false
        embed(pages, in: pagesContainer)

        if isHorizon {
            setupModuleNavigationBarForHorizon()
        } else {
            setupModuleNavigationBarForCanvas()
        }

        // Sometimes module links within Pages are referenced by their pageId ("/pages/my-module") instead of their id.
        // When downloading module item sequences for offline usage, we always download with the id field so we need to
        // find the matching `ModuleItem` and replace the assetID for the `GetModuleItemSequence` request.
        if offlineModeInteractor.isOfflineModeEnabled() {
            if Int(assetID) == nil, let model: ModuleItem = env.database.viewContext.fetch(scope: .where(#keyPath(ModuleItem.pageId), equals: assetID)).first {
                store = env.subscribe(GetModuleItemSequence(courseID: courseID, assetType: .moduleItem, assetID: model.id)) { [weak self] in
                    self?.update(embed: true)
                }
            }
        }

        // force refresh because we don't provide a refresh control
        store.refresh(force: true)
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard isHorizon else { return }
        env.tabBar(isVisible: true)
    }

    private func setupModuleNavigationBarForHorizon() {
        AppEnvironment.shared.tabBar(isVisible: false)
        pagesContainerBottomConstraint.isActive = false
        buttonsContainer.removeFromSuperview()

        let hostingVC = UIHostingController(rootView: ModuleNavBarView(viewModel: moduleNavigationViewModel))

        hostingVC.view.translatesAutoresizingMaskIntoConstraints = false
        hostingVC.view.backgroundColor = UIColor(hexString: "#FBF5ED")
        addChild(hostingVC)
        view.addSubview(hostingVC.view)
        view.backgroundColor = UIColor(hexString: "#FBF5ED")
        NSLayoutConstraint.activate([
            hostingVC.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            hostingVC.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            hostingVC.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            pagesContainer.bottomAnchor.constraint(equalTo: hostingVC.view.topAnchor)

        ])
        hostingVC.didMove(toParent: self)
    }

    private func setupModuleNavigationBarForCanvas() {
        // places the next arrow on the opposite side
        let transform = CGAffineTransform(scaleX: -1, y: 1)
        nextButton.transform = transform
        nextButton.titleLabel?.transform = transform
        nextButton.imageView?.transform = transform
    }

    private func update(embed: Bool) {
        if store.requested, store.pending {
            return
        }
        if embed, let viewController = createCurrentViewController() {
            setCurrentPage(viewController)
        }
        showSequenceButtons(prev: sequence?.prev != nil, next: sequence?.next != nil)
    }

    private func createCurrentViewController() -> UIViewController? {
        guard let url = url.url else { return nil }
        if let current = sequence?.current {
            return ModuleItemDetailsViewController.create(courseID: courseID, moduleID: current.moduleID, itemID: current.id)
        } else if assetType != .moduleItem, let match = env.router.match(url.appendingOrigin("module_item_details")) {
            return match
        } else {
            let external = ExternalURLViewController.create(
                name: String(localized: "Unsupported Item", bundle: .core),
                url: url,
                courseID: courseID
            )
            external.authenticate = true
            return external
        }
    }

    private func showSequenceButtons(prev: Bool, next: Bool) {
        if isHorizon {
            moduleNavigationViewModel.isPreviousButtonEnabled = prev
            moduleNavigationViewModel.isNextButtonEnabled = next
        } else {
            let show = prev || next
            buttonsContainer.isHidden = show == false
            buttonsHeightConstraint.constant = show ? 56 : 0
            previousButton.isHidden = prev == false
            nextButton.isHidden = next == false
        }

        view.layoutIfNeeded()
    }

    private func show(item: ModuleItemSequenceNode, direction: PagesViewController.Direction? = nil) {
        let details = ModuleItemDetailsViewController.create(courseID: courseID, moduleID: item.moduleID, itemID: item.id)
        setCurrentPage(details, direction: direction)
        store = env.subscribe(GetModuleItemSequence(courseID: courseID, assetType: .moduleItem, assetID: item.id)) { [weak self] in
            self?.update(embed: false)
        }
        store.refresh(force: true)
    }

    private func setCurrentPage(_ page: UIViewController, direction: PagesViewController.Direction? = nil) {
        pages.setCurrentPage(page, direction: direction)
        navigationItem.rightBarButtonItems = rightBarButtonItems
        navigationItem.leftBarButtonItems = leftBarButtonItems
        observations = syncNavigationBar(with: page)
    }

    @IBAction private func goPrevious() {
        guard let prev = sequence?.prev else { return }
        show(item: prev, direction: .reverse)
    }

    @IBAction private func goNext() {
        guard let next = sequence?.next else { return }
        show(item: next, direction: .forward)
    }
}
