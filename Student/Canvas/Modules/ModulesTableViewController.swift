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

import UIKit
import CanvasCore
import Core
import class CanvasCore.Module

class ModulesTableViewController: FetchedTableViewController<Module>, PageViewEventViewControllerLoggingProtocol {
    @objc let courseID: String
    let session: Session

    @objc init(session: Session, courseID: String) throws {
        self.session = session
        self.courseID = courseID
        super.init()

        let collection: FetchedCollection<Module> = try Module.collection(session: session, courseID: courseID)
        let refresher = try Module.refresher(session: session, courseID: courseID)
        prepare(collection, refresher: refresher) { try! ModuleViewModel(session: session, module: $0) }

        title = NSLocalizedString("Modules", comment: "Modules title")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startTrackingTimeOnViewController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTrackingTimeOnViewController(eventName: "/courses/" + courseID + "/modules")
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Analytics.shared.logEvent("module_item_selected")
        let module = collection[indexPath]
        router.route(to: "/courses/\(courseID)/modules/\(module.id)", from: self)
    }
}
