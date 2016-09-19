//
//  PagesHomeViewController.swift
//  Pages
//
//  Created by Joseph Davison on 6/8/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import UIKit
import TooLegit
import SoPersistent

public class PagesHomeViewController: UIViewController {

    let refresher: Refresher
    let route: (UIViewController, NSURL) -> ()
    let observer: ManagedObjectObserver<Page>
    let contextID: ContextID
    let session: Session
    let listViewModelFactory: (Session, Page) -> ColorfulViewModel

    var innerControllerToggle: UIBarButtonItem?
    var innerController: InnerController = .None {
        didSet {
            embedViewController(innerController)
        }
    }

    let frontPageTitle = NSLocalizedString("Front Page", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.PageKit")!, value: "", comment: "front page segmented control title")
    let allPagesTitle = NSLocalizedString("All Pages", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.PageKit")!, value: "", comment: "all pages segmented control title")

    enum InnerController {
        case List
        case FrontPage
        case None
    }

    public init(session: Session, contextID: ContextID, listViewModelFactory: (Session, Page) -> ColorfulViewModel, route: (UIViewController, NSURL) -> ()) throws {
        self.session = session
        self.contextID = contextID
        self.route = route
        self.refresher = try Page.frontPageRefresher(session, contextID: contextID)
        self.observer = try Page.frontPageObserver(session, contextID: contextID)
        self.listViewModelFactory = listViewModelFactory

        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - View Controller Life Cycle

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Make background white while making network request
        self.view.backgroundColor = UIColor.whiteColor()

        refresher.refreshingCompleted.observeNext { [weak self] error in
            if let me = self, e = error {
                if e.code == 404 {
                    self?.innerController = .List
                } else {
                    e.presentAlertFromViewController(me)
                }
            } else {
                self?.innerController = .FrontPage
            }
        }

        refresher.refresh(false)

        if !refresher.isRefreshing && observer.object == nil {
            self.innerController = .List
        } else if !refresher.isRefreshing {
            self.innerController = .FrontPage
        }

        // Prevent view from hiding under navbar
        self.automaticallyAdjustsScrollViewInsets = false
        self.edgesForExtendedLayout = .None
    }

    // MARK: - Helpers

    func initializeToggleButton() {
        innerControllerToggle = UIBarButtonItem(title: "", style: .Plain, target: self, action: #selector(toggleInnerController))
        navigationItem.rightBarButtonItem = innerControllerToggle
    }

    func addSegmentedControl() {
        let control = UISegmentedControl(items: [frontPageTitle, allPagesTitle])
        control.sizeToFit()
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(toggleInnerController), forControlEvents: .ValueChanged)
        self.navigationItem.titleView = control
    }

    func toggleInnerController() {
        switch innerController {
        case .FrontPage: innerController = .List
        case .List: innerController = .FrontPage
        default: break
        }
    }

    func embedViewController(type: InnerController) {
        var innerViewController = UIViewController()

        do {
            switch type {
            case .FrontPage:
                innerViewController = try Page.FrontPageDetailViewController(session: session, contextID: contextID, route: route)

                if UI_USER_INTERFACE_IDIOM() == .Phone {
                    addSegmentedControl()
                } else if UI_USER_INTERFACE_IDIOM() == .Pad {
                    initializeToggleButton()
                }

                innerControllerToggle?.title = allPagesTitle
            case .List:
                innerViewController = try Page.TableViewController(session: session, contextID: contextID, viewModelFactory: listViewModelFactory, route: route)
                innerControllerToggle?.title = frontPageTitle
            default: return
            }
        } catch let e as NSError {
            e.presentAlertFromViewController(self)
        }

        self.addChildViewController(innerViewController)
        self.view.addSubview(innerViewController.view)
        innerViewController.didMoveToParentViewController(self)

        addConstraints(innerViewController.view)
    }

    func addConstraints(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view])
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view])
        self.view.addConstraints(horizontalConstraints)
        self.view.addConstraints(verticalConstraints)
    }
}
