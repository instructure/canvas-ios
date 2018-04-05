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

import UIKit
import CanvasCore

class ModulesTableViewController: FetchedTableViewController<Module>, PageViewEventViewControllerLoggingProtocol {
    let courseID: String
    let route: (UIViewController, URL) -> Void

    init(session: Session, courseID: String, route: @escaping (UIViewController, URL) -> Void) throws {
        self.courseID = courseID
        self.route = route
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
        tableView.rowHeight = UITableViewAutomaticDimension
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
        let module = collection[indexPath]
        let url = URL(string: ContextID(id: courseID, context: .course).htmlPath / "modules" / module.id)!
        route(self, url)
    }
}
