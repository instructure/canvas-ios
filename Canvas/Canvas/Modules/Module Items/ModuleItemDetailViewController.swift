//
//  ModuleItemDetailViewController.swift
//  Canvas
//
//  Created by Nathan Armstrong on 9/22/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import SoEdventurous
import SoPersistent
import TooLegit
import ReactiveCocoa
import Result
import Cartography
import SoLazy
import TechDebt


class ModuleItemDetailViewController: UIViewController {
    let session: Session
    let courseID: String
    let viewModel: ModuleItemViewModel
    let refresher: Refresher
    let route: (UIViewController, NSURL) -> Void

    lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(toolbar)
        self.view.addConstraint(NSLayoutConstraint(item: toolbar, attribute: .Bottom, relatedBy: .Equal, toItem: self.bottomLayoutGuide, attribute: .Top, multiplier: 1, constant: 0))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[toolbar]|", options: [], metrics: nil, views: ["toolbar": toolbar]))
        return toolbar
    }()
    lazy var nextButton: UIBarButtonItem = {
        let title = NSLocalizedString("Next", comment: "Button title for next module item.")
        let btn = UIBarButtonItem(title: title, style: .Plain, target: self.viewModel.nextCocoaAction, action: CocoaAction.selector)
        btn.accessibilityIdentifier = "next_module_item_button"
        btn.rac_enabled <~ self.viewModel.nextAction.enabled
        return btn
    }()
    lazy var previousButton: UIBarButtonItem = {
        let title = NSLocalizedString("Previous", comment: "Button title for previous module item.")
        let btn = UIBarButtonItem(title: title, style: .Plain, target: self.viewModel.previousCocoaAction, action: CocoaAction.selector)
        btn.accessibilityIdentifier = "previous_module_item_button"
        btn.rac_enabled <~ self.viewModel.previousAction.enabled
        return btn
    }()
    lazy var markDoneButton: UIBarButtonItem = {
        let title = NSLocalizedString("Mark as Done", comment: "Button title for mark as done.")
        let btn = UIBarButtonItem(title: title, style: .Plain, target: self.viewModel.markAsDoneCocoaAction, action: CocoaAction.selector)
        btn.accessibilityIdentifier = "mark_module_item_done_button"
        btn.rac_enabled <~ self.viewModel.markAsDoneAction.enabled
        return btn
    }()


    init(session: Session, courseID: String, moduleID: String, moduleItemID: String, route: (UIViewController, NSURL) -> Void) throws {
        self.session = session
        viewModel = try ModuleItemViewModel(session: session, moduleID: moduleID, moduleItemID: moduleItemID)
        refresher = try Module.refresher(session, courseID: courseID)
        self.route = route
        self.courseID = courseID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        refresher.refresh(false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whiteColor()
        rac_title <~ viewModel.title

        /// toolbar
        let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        toolbar.items = [previousButton, space, nextButton]

        /// embed item view controller
        viewModel.embeddedViewController
            .combinePrevious(nil)
            .observeOn(UIScheduler())
            .startWithNext(embed)

        /// handle errors
        viewModel.errorSignal.observeNext {
            $0.presentAlertFromViewController(self)
        }
    }

    func embed(old: UIViewController?, _ new: UIViewController?) {
        if let current = old {
            current.willMoveToParentViewController(nil)
            current.view.removeFromSuperview()
            current.removeFromParentViewController()
        }

        if let vc = new {
            vc.willMoveToParentViewController(self)
            addChildViewController(vc)
            view.insertSubview(vc.view, belowSubview: toolbar)
            vc.didMoveToParentViewController(self)

            vc.view.translatesAutoresizingMaskIntoConstraints = false
            view.addConstraint(NSLayoutConstraint(item: vc.view, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: vc.view, attribute: .Bottom, relatedBy: .Equal, toItem: toolbar, attribute: .Top, multiplier: 1, constant: 0))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[childView]|", options: [], metrics: nil, views: ["childView": vc.view]))

            viewModel.moduleItemBecameActive()
            updateNavigationBarButtonItems(vc)
        }
    }

    func updateNavigationBarButtonItems(embeddedViewController: UIViewController) {
        var items = embeddedViewController.navigationItem.rightBarButtonItems ?? []

        if viewModel.completionRequirement.value == .MarkDone {
            items = items + [markDoneButton]
        }

        navigationItem.rightBarButtonItems = items
    }
}
