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


import CanvasCore

struct CourseCellViewModel: TableViewCellViewModel {
    
    let course: Course
    let highlightColor: UIColor

    var gradeLabelText: String {
        let grades: String = [course.visibleGrade, course.visibleScore]
            .flatMap( { $0 } )
            .joined(separator: "   ")

        if grades != "" {
            return grades
        }

        return NSLocalizedString("No Grade", comment: "Title for label when no grade has been assigned to the course")
    }

    init(course: Course, highlightColor: UIColor) {
        self.course = course
        self.highlightColor = highlightColor
    }
    
    static func tableViewDidLoad(_ tableView: UITableView) {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 107
        tableView.register(UINib(nibName: "CourseCell", bundle: Bundle(for: AppDelegate.self)), forCellReuseIdentifier: "CourseCell")
    }
    
    func cellForTableView(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath) as? CourseCell else {
            fatalError("Incorrect Cell Type Found Expected: CourseCell")
        }

        cell.accessibilityIdentifier = "course_cell_\(indexPath.row)"
        cell.titleLabel.accessibilityIdentifier = "course_title_\(indexPath.row)"
        cell.codeLabel.accessibilityIdentifier = "course_code_\(indexPath.row)"
        cell.gradeLabel.accessibilityIdentifier = "course_grade_\(indexPath.row)"

        cell.highlightColor = highlightColor
        cell.titleLabel.text = course.name
        cell.codeLabel.text = course.code
        cell.gradeLabel.text = gradeLabelText

        return cell
    }
}
