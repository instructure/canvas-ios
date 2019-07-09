//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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




open class PagesHomeViewController: UIViewController {

    let refresher: Refresher
    @objc let route: (UIViewController, URL) -> ()
    let observer: ManagedObjectObserver<Page>
    let contextID: ContextID
    @objc let session: Session
    let listViewModelFactory: (Session, Page) -> ColorfulViewModel

    @objc var innerControllerToggle: UIBarButtonItem?
    var innerController: InnerController = .none {
        didSet {
            embedViewController(innerController)
        }
    }

    @objc let frontPageTitle = NSLocalizedString("Front Page", tableName: "Localizable", bundle: .core, value: "", comment: "front page segmented control title")
    @objc let allPagesTitle = NSLocalizedString("All Pages", tableName: "Localizable", bundle: .core, value: "", comment: "all pages segmented control title")

    enum InnerController {
        case list
        case frontPage
        case none
    }

    public init(session: Session, contextID: ContextID, listViewModelFactory: @escaping (Session, Page) -> ColorfulViewModel, route: @escaping (UIViewController, URL) -> ()) throws {
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

    override open func viewDidLoad() {
        super.viewDidLoad()

        // Make background white while making network request
        self.view.backgroundColor = UIColor.white

        refresher.refreshingCompleted.observeValues { [weak self] error in
            if let me = self, let e = error {
                if e.code == 404 {
                    self?.innerController = .list
                } else {
                    ErrorReporter.reportError(e, from: me)
                }
            } else {
                self?.innerController = .frontPage
            }
        }

        refresher.refresh(false)

        if !refresher.isRefreshing && observer.object == nil {
            self.innerController = .list
        } else if !refresher.isRefreshing {
            self.innerController = .frontPage
        }

        // Prevent view from hiding under navbar
        self.automaticallyAdjustsScrollViewInsets = false
        self.edgesForExtendedLayout = UIRectEdge()
    }

    // MARK: - Helpers

    @objc func initializeToggleButton() {
        innerControllerToggle = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(toggleInnerController))
        navigationItem.rightBarButtonItem = innerControllerToggle
    }

    @objc func addSegmentedControl() {
        let control = UISegmentedControl(items: [frontPageTitle, allPagesTitle])
        control.sizeToFit()
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(toggleInnerController), for: .valueChanged)
        self.navigationItem.titleView = control
    }

    @objc func toggleInnerController() {
        switch innerController {
        case .frontPage: innerController = .list
        case .list: innerController = .frontPage
        default: break
        }
    }

    func embedViewController(_ type: InnerController) {
        var innerViewController = UIViewController()

        do {
            switch type {
            case .frontPage:
                innerViewController = try Page.FrontPageDetailViewController(session: session, contextID: contextID, route: route)

                if UI_USER_INTERFACE_IDIOM() == .phone {
                    addSegmentedControl()
                } else if UI_USER_INTERFACE_IDIOM() == .pad {
                    initializeToggleButton()
                }

                innerControllerToggle?.title = allPagesTitle
            case .list:
                innerViewController = try Page.TableViewController(session: session, contextID: contextID, viewModelFactory: listViewModelFactory, route: route)
                innerControllerToggle?.title = frontPageTitle
            default: return
            }
        } catch let e as NSError {
            ErrorReporter.reportError(e, from: self)
        }

        self.addChild(innerViewController)
        self.view.addSubview(innerViewController.view)
        innerViewController.didMove(toParent: self)

        addConstraints(innerViewController.view)
    }

    @objc func addConstraints(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["view": view])
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-[view]-0-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["view": view])
        self.view.addConstraints(horizontalConstraints)
        self.view.addConstraints(verticalConstraints)
    }
}
