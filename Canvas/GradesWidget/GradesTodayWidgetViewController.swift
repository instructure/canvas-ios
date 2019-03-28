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

let COURSE_ROW_HEIGHT: CGFloat = 55
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
        tableView.estimatedRowHeight = COURSE_ROW_HEIGHT
        tableView.rowHeight = UITableView.automaticDimension

        let nib = UINib(nibName: String(describing: GradeWidgetCell.self), bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")

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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if error != nil {
            return 1
        }
        return presenter.courses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let error = error {
            return errorCell(error)
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? GradeWidgetCell else  {
            fatalError("Incorrect cell type found; expected: GradeWidgetCell")
        }

        cell.courseNameLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        cell.gradeLabel?.font = UIFont.preferredFont(forTextStyle: .body)

        guard let course = presenter.courses[indexPath.row] else {
            fatalError("Course failed to load")
        }

        cell.courseNameLabel?.text = course.name
        cell.gradeLabel?.text = course.displayGrade
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
        preferredContentSize = activeDisplayMode == .expanded ? CGSize(width: 0, height: CGFloat(presenter.courses.count) * tableView.estimatedRowHeight) : maxSize
    }
}

class GradeWidgetCell: UITableViewCell {
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var dotView: UIView!
}
