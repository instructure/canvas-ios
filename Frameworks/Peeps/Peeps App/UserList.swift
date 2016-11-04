
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
    
    

import Peeps
import SoPersistent
import TooLegit

struct UserViewModel: TableViewCellViewModel {

    static let reuseIdentifier = "UserCell"
    static let nibName = "UserCell"

    let name: String
    let subtitle: String

    static func tableViewDidLoad(tableView: UITableView) {
        tableView.registerNib(UINib(nibName: UserViewModel.nibName, bundle: NSBundle(forClass: AppDelegate.self)), forCellReuseIdentifier: UserViewModel.reuseIdentifier)
    }
    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(UserViewModel.reuseIdentifier, forIndexPath: indexPath)
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = subtitle
        return cell
    }

    init(user: User) {
        name = user.sortableName
        subtitle = user.avatarURL?.absoluteString ?? "No Avatar"
    }
}



class UserList: User.TableViewController {

    let session: Session

    init(session: Session) throws {
        self.session = session
        super.init()

        let collection = try User.collectionOfObservedUsers(session)
        let refresher = try User.observeesRefresher(session)
        prepare(collection, refresher: refresher, viewModelFactory: UserViewModel.init)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }


    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let user = collection[indexPath]
        do {
            let deets = try UserDeets(session: session, observeeID: "\(user.id)")
            navigationController?.pushViewController(deets, animated: true)
        } catch let e as NSError {
            e.presentAlertFromViewController(self)
        }
    }
}
