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

public class ModuleItemDetailsViewController: DownloadableViewController, ColoredNavViewProtocol {
    var onEmbedContainer: ((UIViewController) -> Void)?

    let env = AppEnvironment.shared
    var courseID: String!
    var moduleID: String!
    var itemID: String!

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var errorView: ListErrorView!
    @IBOutlet weak var lockedView: UIView!
    @IBOutlet weak var lockExplanation: CoreWebView!
    @IBOutlet weak var lockedTitleLabel: UILabel!
    @IBOutlet weak var spinnerView: CircleProgressView!

    lazy var optionsButton = UIBarButtonItem(image: UIImage.moreLine, style: .plain, target: self, action: #selector(optionsButtonPressed))

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
    private var isMarkingModule = false

    public static func create(courseID: String, moduleID: String, itemID: String) -> Self {
        let controller = loadFromStoryboard()
        controller.courseID = courseID
        controller.moduleID = moduleID
        controller.itemID = itemID
        return controller
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        setupTitleViewInNavbar(title: NSLocalizedString("Module Item", bundle: .core, comment: ""))
        Analytics.shared.logEvent("module_item", parameters: ["moduleID": moduleID!, "itemID": itemID!])
        errorView.isHidden = true
        errorView.retryButton.addTarget(self, action: #selector(retryButtonPressed), for: .primaryActionTriggered)
        lockedView.isHidden = true
        lockExplanation.backgroundColor = .clear
        store.refresh(force: true)
        course.refresh()
        colors.refresh()
    }

    func update() {
        guard store.requested, !store.pending, !isMarkingModule else { return }
        let itemViewController = self.itemViewController()
        let showLocked = env.app != .teacher && item?.visibleWhenLocked != true && item?.lockedForUser == true
        lockedView.isHidden = !showLocked
        lockedTitleLabel.text = item?.title
        if let lockExplanation = item?.lockExplanation {
            self.lockExplanation.loadHTMLString("<p class=\"lock-explanation\">\(lockExplanation)</p>")
        }
        spinnerView.isHidden = true
        errorView.isHidden = itemViewController != nil && store.error == nil
        container.isHidden = !lockedView.isHidden || !errorView.isHidden
        children.forEach { $0.unembed() }
        if let viewController = itemViewController, !container.isHidden {
            embed(viewController, in: container)
            onEmbedContainer?(viewController)
            navigationItem.rightBarButtonItems = []
            observations = syncNavigationBar(with: viewController)
            NotificationCenter.default.post(name: .moduleItemViewDidLoad, object: nil, userInfo: [
                "moduleID": moduleID!,
                "itemID": itemID!,
            ])
            if item?.completionRequirementType == .must_view, item?.completed == false, item?.lockedForUser == false {
                markAsViewed()
            }
        }
        updateNavBar()
    }

    func updateNavBar() {
        spinnerView.color = course.first?.color
        updateNavBar(subtitle: course.first?.name, color: course.first?.color)
        let title: String
        switch item?.type {
        case .assignment:
            title = NSLocalizedString("Assignment Details", bundle: .core, comment: "")
        case .discussion:
            title = NSLocalizedString("Discussion Details", bundle: .core, comment: "")
        case .externalTool:
            title = NSLocalizedString("External Tool", bundle: .core, comment: "")
        case .externalURL:
            title = NSLocalizedString("External URL", bundle: .core, comment: "")
        case .file:
            title = NSLocalizedString("File Details", bundle: .core, comment: "")
        case .quiz:
            title = NSLocalizedString("Quiz Details", bundle: .core, comment: "")
        case .page:
            title = NSLocalizedString("Page Details", bundle: .core, comment: "")
        case nil, .subHeader:
            title = NSLocalizedString("Module Item", bundle: .core, comment: "")
        }
        setupTitleViewInNavbar(title: title)
        addDownloadBarButtonItem()
    }

    private func addDownloadBarButtonItem() {
        navigationItem.rightBarButtonItems = []
        if item?.completionRequirementType == .must_mark_done {
            navigationItem.rightBarButtonItems?.append(optionsButton)
        }
        guard reachability.isConnected else {
            return
        }
        switch item?.type {
        case .externalTool, .page, .file:
            navigationItem.rightBarButtonItems?.append(downloadBarButtonItem)
            downloadButton.isHidden = false
        default:
            break
        }
    }

    func itemViewController() -> UIViewController? {
        guard let item = item else { return nil }
        switch item.type {
        case .externalURL(let url):
            return ExternalURLViewController.create(name: item.title, url: url, courseID: item.courseID)
        case let .externalTool(toolID, url):
            let tools = LTITools(
                context: .course(courseID),
                id: toolID,
                url: url,
                launchType: .module_item,
                moduleID: moduleID,
                moduleItemID: itemID
            )
            return LTIWebViewController.create(tools: tools, moduleItem: item)
        default:
            guard let url = item.url else { return nil }
            let preparedURL = url.appendingOrigin("module_item_details")
            let itemViewController = env.router.match(preparedURL)

            if let itemViewController, let routeTemplate = env.router.template(for: preparedURL) {
                Analytics.shared.logScreenView(route: routeTemplate, viewController: itemViewController)
            }

            return itemViewController
        }
    }

    @objc func retryButtonPressed() {
        store.refresh(force: true)
    }

    @objc func optionsButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(AlertAction(
            item?.completed == true
                ? NSLocalizedString("Mark as Undone", bundle: .core, comment: "")
                : NSLocalizedString("Mark as Done", bundle: .core, comment: ""),
            style: .default
        ) { [weak self] _ in
            self?.markAsDone()
        })
        alert.addAction(AlertAction(NSLocalizedString("Cancel", bundle: .core, comment: ""), style: .cancel))
        alert.popoverPresentationController?.barButtonItem = sender
        env.router.show(alert, from: self, options: .modal())
    }

    func markAsDone() {
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

    func markAsViewed() {
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
