//
//  ObserveeCourseCellViewModel.swift
//  Parent
//
//  Created by Brandon Pluim on 1/22/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation

import SoPersistent
import EnrollmentKit

struct ObserveeCourseCellViewModel: TableViewCellViewModel {
    
    let courseObject: CourseProtocol
    
    static func tableViewDidLoad(tableView: UITableView) {
        tableView.estimatedRowHeight = 60
        tableView.registerNib(UINib(nibName: "ObserveeCourseCell", bundle: NSBundle(forClass: AppDelegate.self)), forCellReuseIdentifier: "ObserveeCourseCellViewModel")
    }
    
    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("ObserveeCourseCellViewModel", forIndexPath: indexPath) as? ObserveeCourseCell else {
            fatalError("Incorrect Cell Type Found Expected: CourseGradesTableViewCell")
        }
        
        cell.titleLabel.text = courseObject.name
        if let score = courseObject.grade?.finalScore {
            cell.currentScoreLabel.text = "\(score)"
        } else {
            cell.currentScoreLabel.text = " "
        }
        if let grade = courseObject.grade?.finalGrade {
            cell.currentGradeLabel.text = grade
        } else {
            cell.currentGradeLabel.text = " "
        }
        
        return cell
    }
}