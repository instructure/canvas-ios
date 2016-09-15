//
//  SettingsObserveeCellViewModel.swift
//  Parent
//
//  Created by Brandon Pluim on 2/11/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation

import SoPersistent
import EnrollmentKit
import Airwolf

struct SettingsObserveeCellViewModel: TableViewCellViewModel {
    let name: String
    let studentID: String
    let avatarURL: NSURL?
    let highlightColor: UIColor

    init(student: Student, highlightColor: UIColor) {
        name = student.sortableName
        avatarURL = student.avatarURL
        studentID = student.id
        self.highlightColor = highlightColor
    }

    static func tableViewDidLoad(tableView: UITableView) {
        tableView.estimatedRowHeight = 64
        tableView.registerNib(UINib(nibName: "SettingsObserveeCell", bundle: NSBundle(forClass: SettingsObserveeCell.self)), forCellReuseIdentifier: "SettingsObserveeCell")
    }

    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("SettingsObserveeCell", forIndexPath: indexPath) as? SettingsObserveeCell else {
            fatalError("Incorrect cell type found. Expected: SettingsObserveeCell")
        }

        cell.highlightColor = highlightColor
        cell.nameLabel?.text = name

        if let avatarURL = avatarURL {
            cell.avatarImageView?.kf_setImageWithURL(avatarURL, placeholderImage: DefaultAvatarCoordinator.defaultAvatarForStudentID(studentID))
        }

        return cell
    }

}