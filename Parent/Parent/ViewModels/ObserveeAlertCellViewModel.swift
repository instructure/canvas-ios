//
//  ObserveeAlertCellViewModel.swift
//  Parent
//
//  Created by Ben Kraus on 2/10/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation
import SoPersistent
import ObserverAlertKit

struct ObserveeAlertCellViewModel: TableViewCellViewModel {

    let alertObject: AlertProtocol

    static func tableViewDidLoad(tableView: UITableView) {
        tableView.estimatedRowHeight = 44
        tableView.registerClass(ObserveeAlertCell.self, forCellReuseIdentifier: "ObserveeAlertCell")
//        tableView.registerNib(UINib(nibName: "ObserveeCourseCell", bundle: NSBundle(forClass: ObserveeAlertCell.self)), forCellReuseIdentifier: "ObserveeAlertCell")
    }

    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("ObserveeAlertCell", forIndexPath: indexPath) as? ObserveeAlertCell else {
            fatalError("Incorrect cell type found. Expected: ObserveAlertCell")
        }

        cell.textLabel?.text = "Hi"
        cell.detailTextLabel?.text = "There"

        return cell
    }
}