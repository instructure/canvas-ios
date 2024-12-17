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

public final class ModuleItemDetailsViewController: UIViewController, ColoredNavViewProtocol, ErrorViewController {

    var courseID: String!
    var moduleID: String!
    var itemID: String!

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var errorView: ListErrorView!
    @IBOutlet weak var lockedView: UIView!
    @IBOutlet weak var lockExplanation: CoreWebView!
    @IBOutlet weak var lockedTitleLabel: UILabel!
    @IBOutlet weak var spinnerView: CircleProgressView!

    private var env: AppEnvironment = .defaultValue

    private lazy var optionsButton = UIBarButtonItem(image: UIImage.moreLine, style: .plain, target: self, action: #selector(optionsButtonPressed))

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

    private var item: ModuleItem? { store.first }
    private var observations: [NSKeyValueObservation]?
    private var isMarkingModule = false

    public static func create(env: AppEnvironment, courseID: String, moduleID: String, itemID: String) -> Self {
        let controller = loadFromStoryboard()
        controller.env = env
        controller.courseID = courseID
        controller.moduleID = moduleID
        controller.itemID = itemID
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        setupTitleViewInNavbar(title: String(localized: "Module Item", bundle: .core))
        Analytics.shared.logEvent("module_item", parameters: ["moduleID": moduleID!, "itemID": itemID!])
        errorView.isHidden = true
        errorView.retryButton.addTarget(self, action: #selector(retryButtonPressed), for: .primaryActionTriggered)
        lockedView.isHidden = true
        lockExplanation.backgroundColor = .clear
        store.refresh(force: true)
        course.refresh()
        colors.refresh()
        spinnerView.isHidden = true
    }

    private func update() {
        guard store.requested, !store.pending, !isMarkingModule else { return }
        let itemViewController = self.itemViewController()
        let showLocked = env.app != .teacher && item?.visibleWhenLocked != true && item?.lockedForUser == true
        lockedView.isHidden = !showLocked
        lockedTitleLabel.text = item?.title
        if let lockExplanation = item?.lockExplanation {
            self.lockExplanation.loadHTMLString("<p class=\"lock-explanation\">\(lockExplanation)</p>")
        }
        errorView.isHidden = itemViewController != nil && store.error == nil
        container.isHidden = !lockedView.isHidden || !errorView.isHidden
        children.forEach { $0.unembed() }
        if let viewController = itemViewController, !container.isHidden {
            embed(viewController, in: container)
            navigationItem.rightBarButtonItems = []
            observations = syncNavigationBar(with: viewController)
            NotificationCenter.default.post(name: .moduleItemViewDidLoad, object: nil, userInfo: [
                "moduleID": moduleID!,
                "itemID": itemID!
            ])
            if item?.completionRequirementType == .must_view, item?.completed == false, item?.lockedForUser == false {
                markAsViewed()
            }
        }
        updateNavBar()
    }

    private func updateNavBar() {
        // When embedded view controllers adapt course color for their own spinner view,
        // we should enable this line below.
//        spinnerView.color = course.first?.color
        updateNavBar(subtitle: course.first?.name, color: course.first?.color)
        let title: String
        switch item?.type {
        case .assignment:
            title = String(localized: "Assignment Details", bundle: .core)
        case .discussion:
            title = String(localized: "Discussion Details", bundle: .core)
        case .externalTool:
            title = String(localized: "External Tool", bundle: .core)
        case .externalURL:
            title = String(localized: "External URL", bundle: .core)
        case .file:
            title = String(localized: "File Details", bundle: .core)
        case .quiz:
            title = String(localized: "Quiz Details", bundle: .core)
        case .page:
            title = String(localized: "Page Details", bundle: .core)
        case nil, .subHeader:
            title = String(localized: "Module Item", bundle: .core)
        }
        setupTitleViewInNavbar(title: title)
        if item?.completionRequirementType == .must_mark_done {
            navigationItem.rightBarButtonItems = []
            navigationItem.rightBarButtonItems?.append(optionsButton)
        }
    }

    private func itemViewController() -> UIViewController? {
        guard let item = item else { return nil }
        switch item.type {
        case .externalURL(let url):
            return ExternalURLViewController.create(env: env, name: item.title, url: url, courseID: item.courseID)
        case let .externalTool(toolID, url):
            let tools = LTITools(
                env: env,
                context: .course(courseID),
                id: toolID,
                url: url,
                launchType: .module_item,
                isQuizLTI: item.isQuizLTI,
                moduleID: moduleID,
                moduleItemID: itemID
            )
            return LTIViewController.create(env: env, tools: tools, name: item.title)
        default:
            guard let url = item.url else { return nil }
            let preparedURL = url.appendingOrigin("module_item_details")
            let itemViewController = env.router.match(preparedURL)

            if let itemViewController, let routeTemplate = env.router.template(for: preparedURL) {
                RemoteLogger.shared.logBreadcrumb(route: routeTemplate, viewController: itemViewController)
            }

            return itemViewController
        }
    }

    @objc private func retryButtonPressed() {
        store.refresh(force: true)
    }

    @objc private func optionsButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(AlertAction(
            item?.completed == true
                ? String(localized: "Mark as Undone", bundle: .core)
                : String(localized: "Mark as Done", bundle: .core),
            style: .default
        ) { [weak self] _ in
            self?.markAsDone()
        })
        alert.addAction(AlertAction(String(localized: "Cancel", bundle: .core), style: .cancel))
        alert.popoverPresentationController?.barButtonItem = sender
        env.router.show(alert, from: self, options: .modal())
    }

    private func markAsDone() {
        spinnerView.isHidden = false
        let request = PutMarkModuleItemDone(courseID: courseID, moduleID: moduleID, moduleItemID: itemID, done: item?.completed == false)
        env.api.makeRequest(request) { [weak self] _, _, error in performUIUpdate {
            self?.spinnerView.isHidden = true
            if let error = error {
                self?.showError(error)
                return
            }
            self?.isMarkingModule = true
            NotificationCenter.default.post(name: .moduleItemRequirementCompleted, object: nil)
        } }
    }

    private func markAsViewed() {
        let request = PostMarkModuleItemRead(courseID: courseID, moduleID: moduleID, moduleItemID: itemID)
        env.api.makeRequest(request) { [weak self] _, _, error in performUIUpdate {
            if error == nil {
                self?.isMarkingModule = true
                NotificationCenter.default.post(name: .moduleItemRequirementCompleted, object: nil)
            }
        } }
    }
}

extension Notification.Name {
    static let moduleItemViewDidLoad = Notification.Name(rawValue: "com.instructure.core.notification.ModuleItemViewDidLoad")
    public static let moduleItemRequirementCompleted = Notification.Name(rawValue: "com.instructure.core.notification.ModuleItemRequirementCompleted")
}
