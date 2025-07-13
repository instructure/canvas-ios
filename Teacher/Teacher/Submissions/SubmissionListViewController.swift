//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import Core

class SubmissionListViewController: ScreenViewTrackableViewController, ColoredNavViewProtocol {
    @IBOutlet weak var emptyMessageLabel: UILabel!
    @IBOutlet weak var emptyTitleLabel: UILabel!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var errorView: ListErrorView!
    @IBOutlet weak var keyboardSpace: NSLayoutConstraint!
    @IBOutlet weak var loadingView: CircleProgressView!
    let refreshControl = CircleRefreshControl()
    @IBOutlet weak var tableView: UITableView!
    public var titleSubtitleView = TitleSubtitleView.create()

    lazy var messageUsersButton = UIBarButtonItem(image: .emailSolid, style: .plain, target: self, action: #selector(messageUsers))
    lazy var postPolicyButton = UIBarButtonItem(image: .eyeSolid, style: .plain, target: self, action: #selector(openPostPolicy))

    var assignmentID = ""
    public var color: UIColor?
    private var env: AppEnvironment = .defaultValue
    var context = Context.currentUser
    var filter: [GetSubmissions.Filter] = []
    lazy var screenViewTrackingParameters = ScreenViewTrackingParameters(
        eventName: "/\(context.pathComponent)/assignments/\(assignmentID)/submissions"
    )
    lazy var assignment = env.subscribe(GetAssignment(courseID: context.id, assignmentID: assignmentID)) { [weak self] in
        self?.updateNavBar()
        self?.update()
    }
    lazy var colors = env.root.subscribe(GetCustomColors()) { [weak self] in
        self?.updateNavBar()
    }
    lazy var course = env.root.subscribe(GetCourse(courseID: env.convertToRootID(context.id))) { [weak self] in
        self?.updateNavBar()
    }
    lazy var enrollments = env.subscribe(GetEnrollments(context: context)) { [weak self] in
        self?.update()
    }
    lazy var sections = env.subscribe(GetCourseSections(courseID: context.id)) { [weak self] in
        self?.update()
    }
    lazy var submissions = env.subscribe(GetSubmissions(context: context, assignmentID: assignmentID, filter: filter)) { [weak self] in
        self?.update()
    }

    public static func create(env: AppEnvironment, context: Context, assignmentID: String, filter: [GetSubmissions.Filter]) -> SubmissionListViewController {
        let controller = loadFromStoryboard()
        controller.env = env
        controller.assignmentID = assignmentID
        controller.context = context
        controller.filter = filter
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        setupTitleViewInNavbar(title: String(localized: "Submissions", bundle: .teacher))

        emptyMessageLabel.text = String(localized: "It seems there aren't any valid submissions to grade.", bundle: .teacher)
        emptyTitleLabel.text = String(localized: "No Submissions", bundle: .teacher)
        errorView.messageLabel.text = String(localized: "There was an error loading submissions. Pull to refresh to try again.", bundle: .teacher)
        errorView.retryButton.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)

        postPolicyButton.accessibilityIdentifier = "SubmissionsList.postPolicyButton"
        postPolicyButton.accessibilityLabel = String(localized: "Grade post policy", bundle: .teacher)
        messageUsersButton.accessibilityLabel = String(localized: "Send message to users", bundle: .teacher)

        tableView.backgroundColor = .backgroundLightest
        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        tableView.refreshControl = refreshControl
        tableView.registerHeaderFooterView(FilterHeaderView.self, fromNib: false)
        tableView.separatorColor = .borderMedium

        assignment.refresh { [weak self] _ in
            guard let self = self, self.assignment.first?.anonymizeStudents == true else { return }
            self.submissions.useCase.shuffled = true
            self.submissions.setScope(self.submissions.useCase.scope)
        }
        colors.refresh()
        course.refresh()
        enrollments.exhaust()
        sections.exhaust()
        submissions.exhaust()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.selectRow(at: nil, animated: true, scrollPosition: .none)
        navigationController?.navigationBar.useContextColor(color)
    }

    func updateNavBar() {
        guard let color = course.first?.color else { return }
        loadingView.color = color
        refreshControl.color = color
        updateNavBar(subtitle: assignment.first?.name, color: color)
    }

    func update() {
        navigationItem.rightBarButtonItems = [
            assignment.first?.anonymizeStudents == false && !submissions.isEmpty ? messageUsersButton : nil,
            postPolicyButton
        ].compactMap { $0 }
        loadingView.isHidden = submissions.state != .loading || refreshControl.isRefreshing
        emptyView.isHidden = submissions.state != .empty
        errorView.isHidden = submissions.state != .error
        if let error = submissions.error {
            print(error)
        }
        tableView.reloadData()
    }

    @objc func refresh() {
        submissions.exhaust(force: true) { [weak self] _ in
            guard self?.submissions.hasNextPage != true else { return true }
            self?.refreshControl.endRefreshing()
            return false
        }
    }

    @objc func openPostPolicy() {
        env.router.route(
            to: "/\(context.pathComponent)/assignments/\(assignmentID)/post_policy",
            from: self,
            options: .modal(embedInNav: true, addDoneButton: true)
        )
    }

    @objc func messageUsers() {
        guard var subject = assignment.first?.name else { return }
        let filter = ListFormatter.localizedString(from: self.filter.compactMap({ $0.name }))
        if !filter.isEmpty {
            subject = "\(filter) - \(subject)"
        }

        let composeMessageOptions = ComposeMessageOptions(
            disabledFields: .init(contextDisabled: true, recipientsDisabled: true, individualDisabled: true),
            fieldsContents: .init(
                selectedContext: .init(name: course.first?.name ?? "", context: context),
                selectedRecipients: submissions.compactMap { $0.user } .map { Recipient(id: $0.id, name: $0.name, avatarURL: $0.avatarURL) },
                subjectText: subject,
                individualSend: true
            )
        )

        var composeURL = URLComponents()
        composeURL.host = env.apiHost
        composeURL.path = "/conversations/compose"
        composeURL.queryItems = composeMessageOptions.queryItems

        env.router.route(
            to: composeURL,
            from: self,
            options: .modal(embedInNav: true)
        )
    }

    func setFilter(_ filter: [GetSubmissions.Filter]) {
        self.filter = filter
        submissions.useCase.filter = filter
        submissions.setScope(submissions.useCase.scope)
        submissions.exhaust()
    }

    @objc func showFilters() {
        env.router.show(
            SubmissionFilterPickerViewController
                .create(env: env, context: context, outOfText: assignment.first?.outOfText, filter: filter) { [weak self] in
                    self?.setFilter($0)
                },
            from: self,
            options: .modal(embedInNav: true)
        )
    }
}

extension SubmissionListViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header: FilterHeaderView = tableView.dequeueHeaderFooter()
        header.titleLabel.text = filter.isEmpty ? String(localized: "All submissions", bundle: .teacher) :
            filter.compactMap { $0.name } .joined(separator: " - ")
        header.filterButton.removeTarget(self, action: nil, for: .primaryActionTriggered)
        header.filterButton.addTarget(self, action: #selector(showFilters), for: .primaryActionTriggered)
        header.filterButton.setTitle(
            filter.isEmpty ? String(localized: "Filter", bundle: .teacher) :
                String.localizedStringWithFormat(String(localized: "Filter (%d)", bundle: .teacher), filter.count),
            for: .normal
        )
        header.filterButton.setTitleColor(Brand.shared.linkColor, for: .normal)
        return header
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return submissions.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SubmissionListCell = tableView.dequeue(for: indexPath)
        cell.update(assignment.first, submission: submissions[indexPath], row: indexPath.row + 1)
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let userID = submissions[indexPath]?.userID {
            let query = filter.isEmpty ? "" : "?filter=\(filter.map { $0.rawValue } .joined(separator: ","))"
            env.router.route(
                to: "/\(context.pathComponent)/assignments/\(assignmentID)/submissions/\(userID)\(query)",
                from: self,
                options: .modal(.fullScreen, isDismissable: false, embedInNav: true)
            )
        }
    }
}

class SubmissionListCell: UITableViewCell {
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusIconView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var hiddenView: UIImageView!
    @IBOutlet weak var needsGradingLabel: UILabel!
    @IBOutlet weak var needsGradingView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        needsGradingLabel.text = String(localized: "Needs Grading", bundle: .teacher).localizedUppercase
        needsGradingView.layer.borderColor = UIColor.borderInfo.cgColor
        needsGradingView.layer.borderWidth = 1
        needsGradingView.layer.cornerRadius = needsGradingView.frame.height / 2
    }

    func update(_ assignment: Assignment?, submission: Submission?, row: Int) {
        accessibilityTraits = .button
        accessibilityIdentifier = "SubmissionListCell.\(submission?.userID ?? "")"
        backgroundColor = .backgroundLightest
        if assignment?.anonymizeStudents != false {
            if submission?.groupID != nil {
                avatarView.icon = .groupLine
                nameLabel.text = String(localized: "Group \(row)", bundle: .teacher)
            } else {
                avatarView.icon = .userLine
                nameLabel.text = String(localized: "Student \(row)", bundle: .teacher)
            }
        } else if let name = submission?.groupName {
            avatarView.name = name
            avatarView.url = nil
            nameLabel.text = name
        } else {
            avatarView.name = submission?.user?.name ?? ""
            avatarView.url = submission?.user?.avatarURL
            nameLabel.text = submission?.user.flatMap {
                User.displayName($0.name, pronouns: $0.pronouns)
            }
        }
        statusIconView.image = submission?.status.icon
        statusIconView.tintColor = submission?.status.color
        statusLabel.text = submission?.status.text
        statusLabel.textColor = submission?.status.color
        needsGradingView.isHidden = submission?.needsGrading != true
        gradeLabel.text = GradeFormatter.shortString(for: assignment, submission: submission)
        hiddenView.isHidden = submission?.postedAt != nil || (submission?.score == nil && submission?.grade == nil)
    }
}
