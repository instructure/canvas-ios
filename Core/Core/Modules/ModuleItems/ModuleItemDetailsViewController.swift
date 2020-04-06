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
import UIKit

public class ModuleItemSequenceViewController: UIViewController {
    public typealias AssetType = GetModuleItemSequenceRequest.AssetType

    @IBOutlet weak var pagesContainer: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint?
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var spinnerView: UIView!

    let env = AppEnvironment.shared
    var courseID: String!
    var assetType: AssetType!
    var assetID: String!
    var url: URLComponents!

    var observations: [NSKeyValueObservation]?

    lazy var store = env.subscribe(GetModuleItemSequence(courseID: courseID, assetType: assetType, assetID: assetID)) { [weak self] in
        self?.update()
    }
    var sequence: ModuleItemSequence? { store.first }

    let pages = PagesViewController()

    public static func create(courseID: String, assetType: AssetType, assetID: String, url: URLComponents) -> Self {
        let controller = loadFromStoryboard()
        controller.courseID = courseID
        controller.assetType = assetType
        controller.assetID = assetID
        controller.url = url
        return controller
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        pages.scrollView.isScrollEnabled = false
        embed(pages, in: pagesContainer)
        store.refresh()
    }

    func update(direction: PagesViewController.Direction? = nil) {
        if store.requested, store.pending {
            spinnerView.isHidden = false
            return
        }
        spinnerView.isHidden = true
        guard let url = url.url else { return }
        if let current = sequence?.current {
            let details = ModuleItemDetailsViewController.create(courseID: courseID, moduleID: current.moduleID, itemID: current.id)
            setCurrentPage(details, direction: direction)
        } else if let viewController = env.router.match(.parse(url.appendingOrigin("module_item_details"))) {
            setCurrentPage(viewController)
        } else {
            env.loginDelegate?.openExternalURL(url) // TODO: show a button that does this
        }
        bottomConstraint?.isActive = sequence?.prev != nil || sequence?.next != nil
        previousButton.isHidden = sequence?.prev == nil
        nextButton.isHidden = sequence?.next == nil
    }

    func update(item: ModuleItem, direction: PagesViewController.Direction? = nil) {
        store = env.subscribe(GetModuleItemSequence(courseID: courseID, assetType: .moduleItem, assetID: item.id)) { [weak self] in
            self?.update(direction: direction)
        }
        store.refresh()
    }

    func setCurrentPage(_ page: UIViewController, direction: PagesViewController.Direction? = nil) {
        pages.setCurrentPage(page, direction: direction)
        observations = syncNavigationBar(with: page)
    }

    @IBAction func goPrevious() {
        guard let prev = sequence?.prev else { return }
        update(item: prev, direction: .reverse)
    }

    @IBAction func goNext() {
        guard let next = sequence?.next else { return }
        update(item: next, direction: .forward)
    }
}

class ModuleItemDetailsViewController: UIViewController {
    let env = AppEnvironment.shared
    var courseID: String!
    var moduleID: String!
    var itemID: String!

    let container = UIView()
    let errorView = ListErrorView()

    lazy var store = env.subscribe(GetModuleItem(courseID: courseID, moduleID: moduleID, itemID: itemID)) { [weak self] in
        self?.update()
    }

    var item: ModuleItem? { store.first }
    var observations: [NSKeyValueObservation]?

    static func create(courseID: String, moduleID: String, itemID: String) -> Self {
        let controller = Self()
        controller.courseID = courseID
        controller.moduleID = moduleID
        controller.itemID = itemID
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Analytics.shared.logEvent("module_item", parameters: ["moduleID": moduleID!, "itemID": itemID!])
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        container.pin(inside: view)
        errorView.isHidden = true
        errorView.retryButton.addTarget(self, action: #selector(retryButtonPressed), for: .primaryActionTriggered)
        errorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorView)
        errorView.pin(inside: view)
        store.refresh()
    }

    func update() {
        guard store.requested, !store.pending else { return }
        errorView.isHidden = store.error == nil
        if let viewController = itemViewController() {
            children.forEach { $0.unembed() }
            embed(viewController, in: container)
            observations = syncNavigationBar(with: viewController)
        }
    }

    func itemViewController() -> UIViewController? {
        guard let item = item else { return nil }
        switch item.type {
        case .externalURL(let url):
            return ExternalURLViewController.create(name: item.title, url: url, courseID: item.courseID)
        case let .externalTool(toolID, url):
            let tools = LTITools(
                context: ContextModel(.course, id: courseID),
                id: toolID,
                url: url,
                launchType: .module_item,
                moduleID: moduleID,
                moduleItemID: itemID
            )
            return LTIViewController.create(tools: tools, name: item.title)
        default:
            guard let url = item.url else { return nil }
            return env.router.match(.parse(url.appendingOrigin("module_item_details")))
        }
    }

    @objc func retryButtonPressed() {
        store.refresh(force: true)
    }
}
