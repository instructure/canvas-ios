//
//  ModuleDetailsViewController.swift
//  Canvas
//
//  Created by Ben Kraus on 10/7/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import SoEdventurous
import TooLegit
import SoPersistent
import SoIconic
import SafariServices
import SoProgressive
import SoPretty
import ReactiveCocoa
import SoLazy
import ReactiveCocoa

class ModuleDetailsViewController: SoPersistent.TableViewController {
    let session: Session
    let courseID: String
    let viewModel: ModuleViewModel
    let route: (UIViewController, NSURL) -> Void
    let disposable = CompositeDisposable()

    init(session: Session, courseID: String, moduleID: String, route: (UIViewController, NSURL) -> Void) throws {
        self.session = session
        self.courseID = courseID
        self.route = route
        viewModel = try ModuleViewModel(session: session, courseID: courseID, moduleID: moduleID)
        super.init(style: .Grouped)

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
        
        // Fixes the big header when only has 1 section
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0.01))

        rac_title <~ viewModel.name.producer

        self.refresher = try Module.refresher(session, courseID: courseID, moduleID: moduleID)

        disposable += viewModel.prerequisiteModuleIDs.producer.skipRepeats({ $0 == $1 }).startWithNext { [weak self] in
            do {
                self?.dataSource = try ModuleDetailDataSource(session: session, courseID: courseID, moduleID: moduleID, prerequisiteModuleIDs: $0, moduleViewModelFactory: { try! ModuleViewModel(session: session, module: $0, prerequisite: true) }, itemViewModelFactory: { try! ModuleItemViewModel(session: session, moduleItem: $0) })
            } catch let error as NSError {
                self?.handleError(error)
            }
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        disposable.dispose()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let dataSource = dataSource as? ModuleDetailDataSource<ModuleViewModel, ModuleItemViewModel> else { fatalError("unexpected data source") }
        switch indexPath.section {
        case 0:
            let module = dataSource.prerequisiteModulesCollection[NSIndexPath(forRow: indexPath.row, inSection: 0)]
            let url = NSURL(string: ContextID(id: module.courseID, context: .Course).htmlPath / "modules" / module.id)!
            route(self, url)
        case 1:
            let moduleItem = dataSource.itemsCollection[NSIndexPath(forRow: indexPath.row, inSection: 0)]
            guard let content = moduleItem.content where content != .SubHeader else { return }
            let url = NSURL(string: ContextID(id: courseID, context: .Course).htmlPath/"modules"/moduleItem.moduleID/"items"/moduleItem.id)!
            route(self, url)
        default:
            return
        }
    }
}
