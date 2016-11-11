//
//  ModulesTableViewController.swift
//  Canvas
//
//  Created by Nathan Armstrong on 9/9/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import SoEdventurous
import TooLegit
import SoPersistent

class ModulesTableViewController: Module.TableViewController {
    let courseID: String
    let route: (UIViewController, NSURL) -> Void

    init(session: Session, courseID: String, route: (UIViewController, NSURL) -> Void) throws {
        self.courseID = courseID
        self.route = route
        super.init()

        let collection: FetchedCollection<Module> = try Module.collection(session, courseID: courseID)
        let refresher = try Module.refresher(session, courseID: courseID)
        prepare(collection, refresher: refresher) { try! ModuleViewModel(session: session, module: $0) }

        title = NSLocalizedString("Modules", comment: "Modules title")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let module = collection[indexPath]
        let url = NSURL(string: ContextID(id: courseID, context: .Course).htmlPath / "modules" / module.id)!
        route(self, url)
    }
}
