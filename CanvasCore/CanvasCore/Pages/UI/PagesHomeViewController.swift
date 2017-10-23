//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import Foundation
import UIKit




open class PagesHomeViewController: UIViewController {

    let refresher: Refresher
    let route: (UIViewController, URL) -> ()
    let observer: ManagedObjectObserver<Page>
    let contextID: ContextID
    let session: Session
    let listViewModelFactory: (Session, Page) -> ColorfulViewModel

    var innerControllerToggle: UIBarButtonItem?
    var innerController: InnerController = .none {
        didSet {
            embedViewController(innerController)
        }
    }

    let frontPageTitle = NSLocalizedString("Front Page", tableName: "Localizable", bundle: .core, value: "", comment: "front page segmented control title")
    let allPagesTitle = NSLocalizedString("All Pages", tableName: "Localizable", bundle: .core, value: "", comment: "all pages segmented control title")

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

    func initializeToggleButton() {
        innerControllerToggle = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(toggleInnerController))
        navigationItem.rightBarButtonItem = innerControllerToggle
    }

    func addSegmentedControl() {
        let control = UISegmentedControl(items: [frontPageTitle, allPagesTitle])
        control.sizeToFit()
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(toggleInnerController), for: .valueChanged)
        self.navigationItem.titleView = control
    }

    func toggleInnerController() {
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

        self.addChildViewController(innerViewController)
        self.view.addSubview(innerViewController.view)
        innerViewController.didMove(toParentViewController: self)

        addConstraints(innerViewController.view)
    }

    func addConstraints(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view])
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view])
        self.view.addConstraints(horizontalConstraints)
        self.view.addConstraints(verticalConstraints)
    }
}
