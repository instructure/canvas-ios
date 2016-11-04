
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
    
    


import UIKit
import Peeps
import WhizzyWig
import SoPersistent
import TooLegit

enum UserDetailViewModel: TableViewCellViewModel {

    case Title(String)
    case Email(String?)

    static func tableViewDidLoad(tableView: UITableView) {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.separatorStyle = .None
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "TitleCell")
    }

    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        switch self {
        case .Title(let name):
            let cell = tableView.dequeueReusableCellWithIdentifier("TitleCell", forIndexPath: indexPath)
            cell.textLabel?.text = name
            return cell

        case .Email(let email):
            let cell = tableView.dequeueReusableCellWithIdentifier("TitleCell", forIndexPath: indexPath)
            cell.textLabel?.text = email
            return cell
        }
    }


    static func detailsForObservee(baseURL: NSURL)(user: User) -> [UserDetailViewModel] {
        return [
            .Title(user.sortableName),
            .Email(user.email)
        ]
    }
}

extension UserDetailViewModel: Equatable { }
func ==(lhs: UserDetailViewModel, rhs: UserDetailViewModel) -> Bool {
    switch (lhs, rhs) {
    case let (.Title(leftTitle), .Title(rightTitle)):
        return leftTitle == rightTitle
    case let (.Email(leftEmail), .Email(rightEmail)):
        return leftEmail == rightEmail
    default:
        return false
    }
}

import ReactiveCocoa

class UserDeets: User.DetailViewController {
    var disposable: Disposable?

    init(session: Session, observeeID: String) throws {
        super.init()
        let observer = try User.observer(session, observeeID: observeeID)
        let refresher = try User.refresher(session, observeeID: observeeID)

        prepare(observer, refresher: refresher, detailsFactory: UserDetailViewModel.detailsForObservee(session.baseURL))

        disposable = observer.signal.map { $0.1 }
            .observeNext { user in
                print(user?.sortableName)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
