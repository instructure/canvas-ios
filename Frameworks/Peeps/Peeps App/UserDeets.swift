//
//  PeepsDeets.swift
//  Peeps
//
//  Created by Brandon Pluim on 3/8/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
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
