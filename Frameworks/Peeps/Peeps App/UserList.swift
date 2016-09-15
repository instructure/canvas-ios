//
//  PeepsList.swift
//  Peeps
//
//  Created by Brandon Pluim on 3/8/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
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
