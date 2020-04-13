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

public class ModuleItemDetailsViewController: UIViewController, ColoredNavViewProtocol {
    let env = AppEnvironment.shared
    var courseID: String!
    var moduleID: String!
    var itemID: String!

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var errorView: ListErrorView!
    @IBOutlet weak var emptyView: EmptyView!

    lazy var store = env.subscribe(GetModuleItem(courseID: courseID, moduleID: moduleID, itemID: itemID)) { [weak self] in
        self?.update()
    }

    public var color: UIColor?
    public var titleSubtitleView = TitleSubtitleView.create()
    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.updateNavBar()
    }
    lazy var course = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.updateNavBar()
    }

    var item: ModuleItem? { store.first }
    var observations: [NSKeyValueObservation]?

    public static func create(courseID: String, moduleID: String, itemID: String) -> Self {
        let controller = loadFromStoryboard()
        controller.courseID = courseID
        controller.moduleID = moduleID
        controller.itemID = itemID
        return controller
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        Analytics.shared.logEvent("module_item", parameters: ["moduleID": moduleID!, "itemID": itemID!])
        errorView.isHidden = true
        errorView.retryButton.addTarget(self, action: #selector(retryButtonPressed), for: .primaryActionTriggered)
        emptyView.isHidden = true
        store.refresh(force: true)
    }

    func update() {
        guard store.requested, !store.pending else { return }
        let itemViewController = self.itemViewController()
        let showLocked = item?.isAssignment != true && item?.lockedForUser == true
        emptyView.titleText = item?.title
        emptyView.isHidden = !showLocked
        errorView.isHidden = itemViewController != nil && store.error == nil
        children.forEach { $0.unembed() }
        if let viewController = itemViewController, emptyView.isHidden, errorView.isHidden {
            embed(viewController, in: container)
            observations = syncNavigationBar(with: viewController)
            NotificationCenter.default.post(name: .moduleItemViewDidLoad, object: nil, userInfo: [
                "moduleID": moduleID!,
                "itemID": itemID!,
            ])
        }
    }

    func updateNavBar() {
        updateNavBar(subtitle: course.first?.name, color: course.first?.color)
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

extension Notification.Name {
    static let moduleItemViewDidLoad = Notification.Name(rawValue: "com.instructure.core.notification.ModuleItemViewDidLoad")
}
