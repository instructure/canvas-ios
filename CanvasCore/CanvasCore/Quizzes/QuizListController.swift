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

open class QuizListController: UITableViewController, PageViewEventViewControllerLoggingProtocol {
    static open func create(contextID: ContextID, route: @escaping (UIViewController, URL) -> ()) -> QuizListController {
        let viewController = UIStoryboard(name: "QuizListController", bundle: .core).instantiateInitialViewController() as! QuizListController
        viewController.emptyView = Bundle.core.loadNibNamed("QuizListEmptyView", owner: self, options: nil)?.first as? UIView
        viewController.contextID = contextID
        viewController.route = route
        return viewController
    }

    // MARK: - Properties
    var contextID: ContextID!
    var data: QuizListData = QuizListData()
    var emptyView: UIView?
    var route: ((UIViewController, URL) -> ())?

    // MARK: - Lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = TitleSubtitleView.create(title: NSLocalizedString("Quizzes", comment: ""), subtitle: " ")
        refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        refresh()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startTrackingTimeOnViewController()
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTrackingTimeOnViewController(eventName: "\(contextID.htmlPath)/quizzes")
    }

    // MARK: - Table view data source

    @objc func refresh(_ control: UIRefreshControl? = nil) {
        let isHard = control != nil

        if !isHard && data.list.isEmpty {
            let loadingView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            loadingView.color = Brand.current.primaryBrandColor
            tableView.backgroundView = loadingView
            loadingView.startAnimating()
        }

        // TODO: Real data fetching
        let time = DispatchTime(uptimeNanoseconds: (1 * NSEC_PER_SEC) + DispatchTime.now().uptimeNanoseconds)
        DispatchQueue.main.asyncAfter(deadline: time) {
            if isHard && !self.data.list.isEmpty {
                self.data = QuizListData()
            } else {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let list = try? decoder.decode([QuizModel].self, from: """
                [{
                    "id": "671",
                    "title": "Super Awesome really long title of justice",
                    "html_url": "https://twilson.instructure.com/courses/167/quizzes/671",
                    "description": "",
                    "quiz_type": "assignment",
                    "shuffle_answers": false,
                    "one_time_results": false,
                    "one_question_at_a_time": false,
                    "question_count": 10000000,
                    "points_possible": 100000000,
                    "due_at": "\(Date().dateByAddingMinutes(-60)!.isoString())",
                    "published": true,
                    "unpublishable": false,
                    "locked_for_user": false
                }]
                """.data(using: .utf8)!)
                var fetched = QuizListData()
                fetched.list = list!
                fetched.courseColor = .blue
                fetched.courseName = "Some Course"
                self.data = fetched
            }
            self.reloadData()
        }
    }

    func reloadData() {
        navigationController?.navigationBar.barTintColor = data.courseColor
        if let titleView = navigationItem.titleView as? TitleSubtitleView {
            titleView.subtitleLabel?.text = data.courseName
        }
        tableView.backgroundView = data.list.isEmpty ? emptyView : nil
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }

    func quizAt(_ indexPath: IndexPath) -> QuizModel? {
        return indexPath.row < data.list.count ? data.list[indexPath.row] : nil
    }

    open override func numberOfSections(in tableView: UITableView) -> Int {
        return data.list.isEmpty ? 0 : 1
    }

    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.list.count
    }

    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuizListCell", for: indexPath) as! QuizListCell
        cell.iconImageView?.tintColor = data.courseColor
        cell.quiz = quizAt(indexPath)
        return cell
    }

    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = quizAt(indexPath)?.html_url {
            route?(self, url)
        }
    }
}

struct QuizListData {
    var list = [QuizModel]()
    var courseColor = UIColor.gray
    var courseName = " "
}
