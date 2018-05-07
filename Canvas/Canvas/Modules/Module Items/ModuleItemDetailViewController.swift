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

import CanvasCore
import ReactiveSwift
import ReactiveCocoa
import Result
import Cartography
import TechDebt


class ModuleItemDetailViewController: UIViewController {
    let session: Session
    let courseID: String
    let viewModel: ModuleItemViewModel
    let refresher: Refresher
    let route: (UIViewController, URL) -> Void
    var embeddedVC: UIViewController?

    lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(toolbar)
        self.view.addConstraint(NSLayoutConstraint(item: toolbar, attribute: .bottom, relatedBy: .equal, toItem: self.bottomLayoutGuide, attribute: .top, multiplier: 1, constant: 0))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[toolbar]|", options: [], metrics: nil, views: ["toolbar": toolbar]))
        return toolbar
    }()
    lazy var nextButton: UIBarButtonItem = {
        let title = NSLocalizedString("Next", comment: "Button title for next module item.")
        let btn = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
        btn.accessibilityIdentifier = "next_module_item_button"

        let nextAction = self.viewModel.nextAction
        btn.reactive.pressed = CocoaAction(nextAction)
        btn.reactive.isEnabled <~ nextAction.isEnabled
        
        return btn
    }()
    lazy var previousButton: UIBarButtonItem = {
        let title = NSLocalizedString("Previous", comment: "Button title for previous module item.")
        let btn = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
        btn.accessibilityIdentifier = "previous_module_item_button"
        
        let previousAction = self.viewModel.previousAction
        btn.reactive.pressed = CocoaAction(previousAction)
        btn.reactive.isEnabled <~ previousAction.isEnabled
        
        return btn
    }()
    lazy var markDoneButton: UIBarButtonItem = {
        let title = NSLocalizedString("Mark as Done", comment: "Button title for mark as done.")
        let btn = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
        btn.accessibilityIdentifier = "mark_module_item_done_button"
        
        let markAsDone = self.viewModel.markAsDoneAction
        btn.reactive.pressed = CocoaAction(markAsDone)
        btn.reactive.isEnabled <~ markAsDone.isEnabled
        
        return btn
    }()


    init(session: Session, courseID: String, moduleItemID: String, route: @escaping (UIViewController, URL) -> Void) throws {
        self.session = session
        viewModel = try ModuleItemViewModel(session: session, moduleItemID: moduleItemID)
        refresher = try ModuleItem.refresher(session: session, courseID: courseID, moduleItemID: moduleItemID)
        self.route = route
        self.courseID = courseID
        super.init(nibName: nil, bundle: nil)

        refresher.refreshingCompleted.observeValues { [weak self] error in
            guard let me = self else { return }
            ErrorReporter.reportError(error, from: me)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(handleBarButtonsChange), name: NSNotification.Name(rawValue: "FileViewControllerBarButtonItemsDidChange"), object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        refresher.refresh(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        automaticallyAdjustsScrollViewInsets = false
        rac_title <~ viewModel.title

        /// toolbar
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [previousButton, space, nextButton]

        /// embed item view controller
        SignalProducer.combineLatest(viewModel.moduleItemID.producer, viewModel.markAsDoneAction.isEnabled.producer, viewModel.embeddedViewController)
            .map { _, _, embeddedViewController in embeddedViewController }
            .combinePrevious(nil)
            .observe(on: UIScheduler())
            .startWithValues(embed)

        /// handle errors
        viewModel.errorSignal.observeValues { [weak self] error in
            ErrorReporter.reportError(error, from: self)
        }
    }

    func embed(_ old: UIViewController?, _ new: UIViewController?) {
        if let current = old {
            current.willMove(toParentViewController: nil)
            current.view.removeFromSuperview()
            current.removeFromParentViewController()
        }

        if let vc = new {
            vc.willMove(toParentViewController: self)
            addChildViewController(vc)
            view.insertSubview(vc.view, belowSubview: toolbar)
            vc.didMove(toParentViewController: self)

            vc.view.translatesAutoresizingMaskIntoConstraints = false
            view.addConstraint(NSLayoutConstraint(item: vc.view, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: vc.view, attribute: .bottom, relatedBy: .equal, toItem: toolbar, attribute: .top, multiplier: 1, constant: 0))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[childView]|", options: [], metrics: nil, views: ["childView": vc.view]))

            if let moduleProtocol = vc as? ModuleItemEmbeddedProtocol {
                moduleProtocol.moduleItemID = self.viewModel.moduleItemID.value
            }
            
            viewModel.moduleItemBecameActive()
            updateNavigationBarButtonItems(vc)
            toolbarItems = vc.toolbarItems

            embeddedVC = vc
        }
    }

    func updateNavigationBarButtonItems(_ embeddedViewController: UIViewController) {
        var items = embeddedViewController.navigationItem.rightBarButtonItems ?? []
        if let rightButtons = navigationItem.rightBarButtonItems, rightButtons.count > 0 {
            items = items + rightButtons
        }

        if viewModel.completionRequirement.value == .markDone {
            items = items + [markDoneButton]
        }
        
        navigationItem.rightBarButtonItems = items
    }

    func handleBarButtonsChange(sender: Any) {
        if let current = embeddedVC {
            updateNavigationBarButtonItems(current)
        }
    }
}
