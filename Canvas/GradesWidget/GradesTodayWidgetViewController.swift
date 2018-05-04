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

import UIKit
import NotificationCenter
import Foundation
import CanvasKeymaster

let MAX_NUM_COURSES = 9
let MAX_NUM_RETRIES = 3
let COURSE_ROW_HEIGHT: CGFloat = 55
let DEFAULT_ERROR_MESSAGE = NSLocalizedString("Failed to load grades", comment: "")

private extension CanvasKeymaster {
    static func multipleClientsAreLoggedIn() -> Bool {
        return CanvasKeymaster.the().numberOfClients > 1
    }
}

enum GradesWidgetError: Error {
    case multipleClientsLoggedIn
    case notLoggedIn
    case noFavoritedCourses
    case deviceLocked

    var localizedDescription: String {
        switch self {
        case .multipleClientsLoggedIn:
            return NSLocalizedString("More than one user is logged into Canvas Student. To view your grades, launch the app.", comment: "")
        case .notLoggedIn:
            return NSLocalizedString("Log in with Canvas", comment: "")
        case .noFavoritedCourses:
            return NSLocalizedString("You have not set any favorite courses.", comment: "")
        case .deviceLocked:
            return NSLocalizedString("Unlock your device to view your grades.", comment: "")
        }
    }
}

func isRetryable(_ error: Error) -> Bool {
    return !(error is DecodingError) && !(error is NetworkError)
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

    var courses: [Course] = [] {
        didSet {
            if courses.count > 0 {
                preferredContentSize = CGSize(width: 0, height: CGFloat(courses.count) * tableView.estimatedRowHeight)
            } else {
                self.showError(GradesWidgetError.noFavoritedCourses)
                preferredContentSize = CGSize(width: 0, height: tableView.estimatedRowHeight)
            }
        }
    }
    var colors: CustomColors?
    var error: Error?
    var colorRetries: Int = 0
    var courseRetries: Int = 0

    var client: CKIClient?

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = UIColor.clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedRowHeight = COURSE_ROW_HEIGHT
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView(frame: .zero)

        // Cells
        let nib = UINib(nibName: String(describing: GradeWidgetCell.self), bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")

        return tableView
    }()

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("GRADES WIDGET MEMORY WARNING")
    }

    //  MARK: - view
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showError(nil)
        view.backgroundColor = UIColor.clear
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded

        layoutTableView()
        logIn()
    }

    func layoutTableView() {
        view.addSubview(tableView)
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[tableView]|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["tableView": tableView])
        )
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[tableView]|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["tableView": tableView])
        )
    }

    func logIn() {
        if isDeviceLocked() {
            return showError(GradesWidgetError.deviceLocked)
        }

        if CanvasKeymaster.multipleClientsAreLoggedIn() {
            return showError(GradesWidgetError.multipleClientsLoggedIn)
        }

        showError(GradesWidgetError.notLoggedIn)
        CanvasKeymaster.the().signalForLogin.take(1).subscribeNext { [weak self] (client) in
            guard let client = client else {
                return
            }
            self?.showError(nil)
            self?.reloadData(client)
        }
    }

    func reloadData(_ client: CKIClient) {
        reloadCourses(client)
        reloadColors(client)
    }

    func reloadCourses(_ client: CKIClient) {
        getCourses(client: client) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .completed(let courses):
                    self?.showError(nil)
                    self?.courses = Array(courses.prefix(MAX_NUM_COURSES))
                    self?.tableView.reloadData()
                case .failed(let error):
                    if isRetryable(error), let retries = self?.courseRetries, retries < MAX_NUM_RETRIES {
                        self?.courseRetries += 1
                        self?.reloadCourses(client)
                    } else {
                        self?.showError(error)
                    }
                }
            }
        }
    }

    func reloadColors(_ client: CKIClient) {
        getCourseColors(client: client) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .completed(let colors):
                    self?.colors = colors
                    self?.tableView.reloadData()
                case .failed(let error):
                    if isRetryable(error), let retries = self?.colorRetries, retries < MAX_NUM_RETRIES {
                        self?.colorRetries += 1
                        self?.reloadColors(client)
                    } else {
                        self?.showError(error)
                    }
                }
            }
        }
    }

    func showError(_ error: Error?) {
        extensionContext?.widgetLargestAvailableDisplayMode = error == nil ? .expanded : .compact
        self.error = error
        tableView.reloadData()
    }
}

extension GradesTodayWidgetViewController: NCWidgetProviding {
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
    }

    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        preferredContentSize = activeDisplayMode == .expanded ? CGSize(width: 0, height: CGFloat(courses.count) * tableView.estimatedRowHeight) : maxSize
    }
}

extension GradesTodayWidgetViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if error != nil {
            return 1
        }
        return courses.count
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

        let course = courses[indexPath.row]

        cell.courseNameLabel?.text = course.name
        cell.gradeLabel?.text = course.displayGrade
        cell.dotView.layer.cornerRadius = cell.dotView.bounds.size.height / 2
        cell.dotView.backgroundColor = color(for: course) ?? .gray
        return cell
    }

    func color(for course: Course) -> UIColor? {
        guard let colors = colors else { return nil }
        for color in colors.customColors {
            if color.context == Context.course && course.id == color.id {
                return UIColor.colorFromHexString(color.color)
            }
        }
        return nil
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
        guard error == nil else {
            extensionContext?.open(URL(string: "canvas-courses://")!, completionHandler: nil)
            return
        }

        guard let client = CanvasKeymaster.the().currentClient, let host = client.baseURL?.host else { return }
        let course = courses[indexPath.row]
        extensionContext?.open(URL(string: "canvas-courses://\(host)/courses/\(course.id)/grades")!, completionHandler: nil)
    }
}

class GradeWidgetCell: UITableViewCell {
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var dotView: UIView!
}
