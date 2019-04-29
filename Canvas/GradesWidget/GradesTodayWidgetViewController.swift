//
// Copyright (C) 2019-present Instructure, Inc.
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

import UIKit
import NotificationCenter
import Core

let VERTICAL_PADDING = CGFloat(20)
let DEFAULT_ERROR_MESSAGE = NSLocalizedString("Failed to load grades", comment: "")

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

class GradesTodayWidgetViewController: UIViewController {

    lazy var presenter: GradesTodayWidgetPresenter = {
        return GradesTodayWidgetPresenter(view: self)
    }()

    var error: Error?
    var expanded: Bool = false

    @IBOutlet var tableView: UITableView!

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("Grades WIDGET MEMORY WARNING")
    }

    override func viewDidLoad() {
        view.backgroundColor = UIColor.clear
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded

        tableView.backgroundColor = UIColor.clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none

        let courseNib = UINib(nibName: String(describing: GradeWidgetCell.self), bundle: nil)
        tableView.register(courseNib, forCellReuseIdentifier: "course-cell")

        let assignmentNib = UINib(nibName: String(describing: GradedAssignmentCell.self), bundle: nil)
        tableView.register(assignmentNib, forCellReuseIdentifier: "assignment-cell")

        login()
    }

    func login() {
        if isDeviceLocked() {
            return showError(GradesWidgetError.deviceLocked)
        }

        guard let mostRecentKeyChain = Keychain.mostRecentSession else {
            return showError(GradesWidgetError.notLoggedIn)
        }
        AppEnvironment.shared.userDidLogin(session: mostRecentKeyChain)
        presenter.viewIsReady()
    }

    func reload() {
        showError(nil)

        if presenter.courses.error != nil {
            showError(presenter.courses.error)
        }

        if presenter.courses.count == 0 && presenter.courses.pending == false {
            showError(GradesWidgetError.noFavoritedCourses)
        }
        tableView.reloadData()
    }

    func showError(_ error: Error?) {
        extensionContext?.widgetLargestAvailableDisplayMode = error == nil ? .expanded : .compact
        self.error = error
        tableView.reloadData()
    }
}

extension GradesTodayWidgetViewController: UITableViewDataSource {
    var SECTION_HEADER_HEIGHT: CGFloat {
        return UIFont.scaledNamedFont(.bold20).lineHeight + VERTICAL_PADDING
    }

    var ASSIGNMENT_GRADE_ROW_HEIGHT: CGFloat {
        return UIFont.scaledNamedFont(.medium12).lineHeight + UIFont.scaledNamedFont(.semibold16).lineHeight + VERTICAL_PADDING
    }

    var COURSE_GRADE_ROW_HEIGHT: CGFloat {
        return UIFont.scaledNamedFont(.semibold16).lineHeight + VERTICAL_PADDING
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if expanded == false {
            return 0
        }

        return self.SECTION_HEADER_HEIGHT
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: self.SECTION_HEADER_HEIGHT))
        view.backgroundColor = .clear

        let sectionFont = UIFont.scaledNamedFont(.bold20)
        let title = UILabel(frame: CGRect(x: 16, y: 16, width: tableView.frame.size.width, height: sectionFont.lineHeight))
        title.font = sectionFont
        title.textColor = UIColor.named(.textDarkest)
        title.text = section == 0
            ? NSLocalizedString("Recently Graded Assignments", comment: "")
            : NSLocalizedString("Course Grades", comment: "")

        let bottomBorder = UIView()
        bottomBorder.backgroundColor = UIColor.named(.borderDark).withAlphaComponent(0.25)
        bottomBorder.frame = CGRect(x: 16, y: self.SECTION_HEADER_HEIGHT, width: tableView.frame.size.width - 32, height: 1)

        view.addSubview(title)
        view.addSubview(bottomBorder)

        return view
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if error != nil {
            return 1
        }
        if section == 0 {
            return presenter.submissions.count
        } else {
            return presenter.courses.count
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return self.ASSIGNMENT_GRADE_ROW_HEIGHT
        } else {
            return self.COURSE_GRADE_ROW_HEIGHT
        }
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "course-cell", for: indexPath) as? GradeWidgetCell else  {
            fatalError("Incorrect cell type found; expected: GradeWidgetCell")
        }

        guard let course = presenter.courses[indexPath.row] else {
            fatalError("Course failed to load")
        }

        cell.courseNameLabel?.text = course.name
        cell.gradeLabel?.text = course.displayGrade
        cell.dotView.layer.cornerRadius = cell.dotView.bounds.size.height / 2
        cell.dotView.backgroundColor = course.color
        return cell
    }

    func assignmentGradeCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "assignment-cell", for: indexPath) as? GradedAssignmentCell else {
            fatalError("Incorrect cel type found; expected: GradedAssignmentCell")
        }
        guard let submission = presenter.submissions[indexPath.row], let assignment = submission.assignment, let course = presenter.courses.first(where: { $0.id == assignment.courseID }) else {
            return cell
        }

        cell.courseNameLabel?.text = course.name
        cell.assignmentNameLabel?.text = assignment.name
        cell.gradeLabel?.text = assignment.gradeText
        cell.dotView.layer.cornerRadius = cell.dotView.bounds.size.height / 2
        cell.dotView.backgroundColor = course.color
        return cell
    }

    func errorCell(_ error: Error) -> UITableViewCell {
        let message = (error as? GradesWidgetError).flatMap { $0.localizedDescription } ?? DEFAULT_ERROR_MESSAGE

        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel!.text = message
        cell.textLabel!.textAlignment = .center
        cell.textLabel!.lineBreakMode = .byWordWrapping
        cell.textLabel!.numberOfLines = 0
        return cell
    }
}

extension GradesTodayWidgetViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let course = presenter.courses[indexPath.row], let host = AppEnvironment.shared.currentSession?.baseURL.host else {
            extensionContext?.open(URL(string: "canvas-courses://")!, completionHandler: nil)
            return
        }
        extensionContext?.open(URL(string: "canvas-courses://\(host)/courses/\(course.id)/grades")!, completionHandler: nil)
    }
}

extension GradesTodayWidgetViewController: NCWidgetProviding {
    func widgetPerformUpdate(completionHandler: @escaping (NCUpdateResult) -> Void) {
        completionHandler(.newData)
    }

    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        expanded = activeDisplayMode == .expanded
        let sectionsHeight = self.SECTION_HEADER_HEIGHT * CGFloat(2)
        let assignmentGradesHeight = self.ASSIGNMENT_GRADE_ROW_HEIGHT * CGFloat(presenter.submissions.count)
        let courseGradesHeight = self.COURSE_GRADE_ROW_HEIGHT * CGFloat(presenter.courses.count)
        let tableViewHeight = sectionsHeight + assignmentGradesHeight + courseGradesHeight
        preferredContentSize = CGSize(width: 0, height:
            expanded ? tableViewHeight : maxSize.height)
        self.tableView.reloadData()
    }
}

class GradeWidgetCell: UITableViewCell {
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var dotView: UIView!
}

class GradedAssignmentCell: UITableViewCell {
    @IBOutlet weak var dotView: UIView!
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var assignmentNameLabel: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!
}

class SectionHeaderLabel: UILabel {
    let padding = UIEdgeInsets(top: 16, left: 16, bottom: 12, right: 0)
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }

    override var intrinsicContentSize: CGSize {
        let superContentSize = super.intrinsicContentSize
        let width = superContentSize.width + padding.left + padding.right
        let height = superContentSize.height + padding.top + padding.bottom
        return CGSize(width: width, height: height)
    }
}
