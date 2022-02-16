//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import UIKit
import NotificationCenter
import Core

let verticalPadding: CGFloat = 20
let defaultErrorMessage = NSLocalizedString("Failed to load grades", comment: "")

enum GradesWidgetError: Error {
    case notLoggedIn
    case noFavoritedCourses
    case deviceLocked

    var localizedDescription: String {
        switch self {
        case .notLoggedIn:
            return NSLocalizedString("Log in with Canvas", comment: "")
        case .noFavoritedCourses:
            return NSLocalizedString("You have not set any favorite courses.", comment: "")
        case .deviceLocked:
            return NSLocalizedString("Unlock your device to view your grades.", comment: "")
        }
    }
}

func isDeviceLocked() -> Bool {
    guard let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
        return true
    }
    let documentsURL = URL(fileURLWithPath: documentsPath)
    let fileURL = documentsURL.appendingPathComponent("lock-screen-text.txt")
    if FileManager.default.fileExists(atPath: fileURL.path) {
        do {
            _ = try Data(contentsOf: fileURL)
            return false
        } catch {
            return true // read failed, must be locked
        }
    }

    do {
        guard let data = "Lock screen test".data(using: .utf8) else { return true }
        try data.write(to: fileURL, options: .completeFileProtection)
        return isDeviceLocked()
    } catch {
        return true // default to locked to be safe
    }
}

class GradesWidgetViewController: UIViewController {
    let env = AppEnvironment.shared
    var error: Error?

    var sectionHeaderHeight: CGFloat {
        return UIFont.scaledNamedFont(.bold20).lineHeight + verticalPadding
    }

    var rowHeight: CGFloat {
        return UIFont.scaledNamedFont(.medium12).lineHeight + UIFont.scaledNamedFont(.semibold16).lineHeight + verticalPadding
    }

    // The ROW_HEIGHT is designed around the size of the collapsed widget height on a mobile device
    // But on ipad the collapsed widget height is slightly larger than on mobile and thus just using
    // the ROW_HEIGHT would show a little bit of the third row thus we have a COMPACT_ROW_HEIGHT
    var compactRowHeight: CGFloat = 0

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewMoreButton: UIButton?

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.reload()
    }
    lazy var courses: Store<LocalUseCase<Course>> = env.subscribe(scope: .all(orderBy: #keyPath(Course.id))) { [weak self] in
        self?.reload()
    }
    lazy var favorites = env.subscribe(GetCourses(showFavorites: true, perPage: 100)) { [weak self] in
        self?.reload()
    }
    lazy var submissionList = env.subscribe(GetRecentlyGradedSubmissions(userID: "self")) { [weak self] in
        self?.reload()
    }
    var submissions: [Submission] { submissionList.first?.submissions ?? [] }

    override func viewDidLoad() {
        UITableView.setupDefaultSectionHeaderTopPadding()
        view.backgroundColor = UIColor.clear
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.showsVerticalScrollIndicator = false

        viewMoreButton?.setTitle(NSLocalizedString("View more", comment: ""), for: .normal)

        compactRowHeight = self.rowHeight

        login()
    }

    func login() {
        if isDeviceLocked() {
            return showError(GradesWidgetError.deviceLocked)
        }

        guard let mostRecentKeyChain = LoginSession.mostRecent else {
            return showError(GradesWidgetError.notLoggedIn)
        }
        env.window = view.window
        env.userDidLogin(session: mostRecentKeyChain)

        colors.refresh()
        favorites.refresh(force: true)
        submissionList.refresh(force: true)
    }

    func reload() {
        if let error = favorites.error {
            showError(error)
        } else if favorites.isEmpty && !favorites.pending {
            showError(GradesWidgetError.noFavoritedCourses)
        } else {
            showError(nil)
        }
    }

    func showError(_ error: Error?) {
        extensionContext?.widgetLargestAvailableDisplayMode = error == nil ? .expanded : .compact
        self.error = error
        tableView.reloadData()
    }

    @IBAction func openApp(_ sender: UIButton) {
        extensionContext?.open(URL(string: "canvas-student://")!)
    }
}

extension GradesWidgetViewController: UITableViewDataSource {
    func maxNumCourseRows() -> Int {
        let totalHeight = extensionContext?.widgetMaximumSize(for: .expanded).height ?? 0
        let assignmentSectionHeight = self.tableView(self.tableView, heightForHeaderInSection: 0) + (CGFloat(submissions.count) * self.rowHeight)
        let maxCourseRowsHeight = totalHeight - assignmentSectionHeight - self.sectionHeaderHeight
        return Int(floor(maxCourseRowsHeight / self.rowHeight))
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if error != nil {
            return 1
        }
        return 2
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if extensionContext?.widgetActiveDisplayMode == .compact {
            return 0
        }

        if section == 0 && submissions.count == 0 {
            return 0
        }

        return self.sectionHeaderHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: self.sectionHeaderHeight))
        view.backgroundColor = .clear

        let sectionFont = UIFont.scaledNamedFont(.bold20)
        let title = UILabel(frame: CGRect(x: 16, y: 16, width: tableView.frame.size.width - 32, height: sectionFont.lineHeight))
        title.font = sectionFont
        title.textColor = UIColor.textDarkest
        title.allowsDefaultTighteningForTruncation = true
        title.text = section == 0
            ? NSLocalizedString("Recently Graded Assignments", comment: "")
            : NSLocalizedString("Course Grades", comment: "")

        let bottomBorder = UIView()
        bottomBorder.backgroundColor = UIColor.borderDark.withAlphaComponent(0.25)
        bottomBorder.frame = CGRect(x: 16, y: self.sectionHeaderHeight, width: tableView.frame.size.width - 32, height: 1)

        view.addSubview(title)
        view.addSubview(bottomBorder)

        return view
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if error != nil {
            return 1
        }

        if section == 0 {
            return submissions.count
        }

        let maxRows = maxNumCourseRows()

        // We have the same number of courses as the max we can show
        if maxRows == favorites.count {
            return favorites.count
        }

        // we either have more or less than the maxRows count
        let rowsToShow = min(favorites.count, maxRows - 1)
        return rowsToShow
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return extensionContext?.widgetActiveDisplayMode == .compact ? compactRowHeight : rowHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let error = error {
            return errorCell(error)
        }

        if indexPath.section == 0 {
            return assignmentGradeCell(indexPath: indexPath)
        } else {
            return courseGradeCell(indexPath: indexPath)
        }
    }

    func courseGradeCell(indexPath: IndexPath) -> UITableViewCell {
        let course = favorites[indexPath.row]

        let cell = tableView.dequeue(for: indexPath) as GradesWidgetCourseCell
        cell.courseNameLabel?.text = course?.name
        cell.gradeLabel?.text = course?.displayGrade
        cell.dotView?.backgroundColor = course?.color
        return cell
    }

    func assignmentGradeCell(indexPath: IndexPath) -> UITableViewCell {
        let submission = submissions[indexPath.row]
        let assignment = submission.assignment
        let course = courses.first(where: { $0.id == assignment?.courseID })

        let cell = tableView.dequeue(for: indexPath) as GradesWidgetAssignmentCell
        cell.courseNameLabel?.text = course?.name
        cell.assignmentNameLabel?.text = assignment?.name
        cell.gradeLabel?.text = assignment.flatMap { GradeFormatter.string(from: $0, style: .medium) }
        cell.dotView?.backgroundColor = course?.color
        return cell
    }

    func errorCell(_ error: Error) -> UITableViewCell {
        let message = (error as? GradesWidgetError).flatMap { $0.localizedDescription } ?? defaultErrorMessage

        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.text = message
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.textLabel?.numberOfLines = 0
        return cell
    }
}

extension GradesWidgetViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let host = AppEnvironment.shared.currentSession?.baseURL.host else {
            extensionContext?.open(URL(string: "canvas-courses://")!)
            return
        }

        if indexPath.section == 0 {
            openAssignment(indexPath: indexPath, host: host)
        } else {
            openCourse(indexPath: indexPath, host: host)
        }
    }

    func openAssignment(indexPath: IndexPath, host: String) {
        guard let assignment = submissions[indexPath.row].assignment else {
            extensionContext?.open(URL(string: "canvas-courses://\(host)")!)
            return
        }

        extensionContext?.open(URL(string: "canvas-courses://\(host)/courses/\(assignment.courseID)/assignments/\(assignment.id)")!)
    }

    func openCourse(indexPath: IndexPath, host: String) {
        guard let course = favorites[indexPath.row] else {
            extensionContext?.open(URL(string: "canvas-courses://\(host)")!)
            return
        }
        extensionContext?.open(URL(string: "canvas-courses://\(host)/courses/\(course.id)/grades")!)
    }
}

extension GradesWidgetViewController: NCWidgetProviding {
    func widgetPerformUpdate(completionHandler: @escaping (NCUpdateResult) -> Void) {
        completionHandler(.newData)
    }

    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {
            // on iPad the maxSize is also the minSize so when collapsed we can't make it any smaller
            // so update the COMPACT_ROW_HEIGHT to ensure we only show two rows regardless of the size
            if maxSize.height > (2 * compactRowHeight) {
                compactRowHeight = maxSize.height / 2
            }
            viewMoreButton?.isHidden = true
            preferredContentSize = maxSize
            tableView.reloadData()
            return
        }

        let numSections = submissions.count > 0 ? 2 : 1
        let sectionsHeight = self.sectionHeaderHeight * CGFloat(numSections)
        let assignmentGradesHeight = self.rowHeight * CGFloat(submissions.count)
        let courseGradesHeight = self.rowHeight * CGFloat(favorites.count)
        let tableViewHeight = sectionsHeight + assignmentGradesHeight + courseGradesHeight
        let maxHeight = min(maxSize.height, tableViewHeight)

        viewMoreButton?.isHidden = maxNumCourseRows() >= favorites.count

        preferredContentSize = CGSize(width: 0, height: maxHeight)
        tableView.reloadData()
    }
}

class GradesWidgetCourseCell: UITableViewCell {
    @IBOutlet weak var courseNameLabel: UILabel?
    @IBOutlet weak var dotView: UIView?
    @IBOutlet weak var gradeLabel: UILabel?
}

class GradesWidgetAssignmentCell: UITableViewCell {
    @IBOutlet weak var assignmentNameLabel: UILabel?
    @IBOutlet weak var courseNameLabel: UILabel?
    @IBOutlet weak var dotView: UIView?
    @IBOutlet weak var gradeLabel: UILabel?
}
