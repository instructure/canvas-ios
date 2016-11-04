
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
    
    

import Foundation

import SoPersistent
import EnrollmentKit

struct CourseCellViewModel: TableViewCellViewModel {
    
    let course: Course
    let highlightColor: UIColor

    var gradeLabelText: String {
        let grades: String = [course.visibleGrade, course.visibleScore]
            .flatMap( { $0 } )
            .joinWithSeparator("   ")

        if grades != "" {
            return grades
        }

        return NSLocalizedString("No Grade", comment: "Title for label when no grade has been assigned to the course")
    }

    init(course: Course, highlightColor: UIColor) {
        self.course = course
        self.highlightColor = highlightColor
    }
    
    static func tableViewDidLoad(tableView: UITableView) {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 107
        tableView.registerNib(UINib(nibName: "CourseCell", bundle: NSBundle(forClass: AppDelegate.self)), forCellReuseIdentifier: "CourseCell")
    }
    
    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("CourseCell", forIndexPath: indexPath) as? CourseCell else {
            fatalError("Incorrect Cell Type Found Expected: CourseCell")
        }

        cell.titleLabel.accessibilityIdentifier = "course_title_\(indexPath.item)"
        cell.codeLabel.accessibilityIdentifier = "course_code_\(indexPath.item)"
        cell.gradeLabel.accessibilityIdentifier = "course_grade_\(indexPath.item)"

        cell.highlightColor = highlightColor
        cell.titleLabel.text = course.name
        cell.codeLabel.text = course.code
        cell.gradeLabel.text = gradeLabelText

        return cell
    }
}
