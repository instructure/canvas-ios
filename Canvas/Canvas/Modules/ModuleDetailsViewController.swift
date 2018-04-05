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
import SafariServices
import ReactiveSwift

class ModuleDetailsViewController: CanvasCore.TableViewController, PageViewEventViewControllerLoggingProtocol {
    let session: Session
    let courseID: String
    let viewModel: ModuleViewModel
    let route: (UIViewController, URL) -> Void
    let disposable = CompositeDisposable()

    init(session: Session, courseID: String, moduleID: String, route: @escaping (UIViewController, URL) -> Void) throws {
        self.session = session
        self.courseID = courseID
        self.route = route
        viewModel = try ModuleViewModel(session: session, courseID: courseID, moduleID: moduleID)
        super.init(style: .grouped)

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
        
        // Fixes the big header when only has 1 section
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0.01))

        rac_title <~ viewModel.name.producer

        self.refresher = try Module.refresher(session: session, courseID: courseID, moduleID: moduleID)

        disposable += viewModel.prerequisiteModuleIDs.producer.skipRepeats({ $0 == $1 }).startWithValues { [weak self] in
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startTrackingTimeOnViewController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        stopTrackingTimeOnViewController(eventName: "/courses/" + courseID + "/modules/" + viewModel.moduleID)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let dataSource = dataSource as? ModuleDetailDataSource<ModuleViewModel, ModuleItemViewModel> else { fatalError("unexpected data source") }
        switch indexPath.section {
        case 0:
            let module = dataSource.prerequisiteModulesCollection[IndexPath(row: indexPath.row, section: 0)]
            let url = URL(string: ContextID.course(withID: courseID).htmlPath / "modules" / module.id)!
            route(self, url)
        case 1:
            let moduleItem = dataSource.itemsCollection[IndexPath(row: indexPath.row, section: 0)]
            guard let content = moduleItem.content, content != .subHeader else { return }
            let url = URL(string: ContextID(id: courseID, context: .course).htmlPath/"modules"/moduleItem.moduleID/"items"/moduleItem.id)!
            route(self, url)
        default:
            return
        }
    }
}
