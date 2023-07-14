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

public class ConferenceDetailsViewController: ScreenViewTrackableViewController, ColoredNavViewProtocol {
    @IBOutlet weak var detailsHeadingLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var recordingsHeadingLabel: UILabel!
    @IBOutlet weak var recordingsView: UIView!
    let refreshControl = CircleRefreshControl()
    @IBOutlet weak var spinnerView: CircleProgressView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    public let titleSubtitleView = TitleSubtitleView.create()

    let env = AppEnvironment.shared
    public var color: UIColor?
    var conferenceID: String = ""
    var context = Context.currentUser
    public lazy var screenViewTrackingParameters = ScreenViewTrackingParameters(
        eventName: "\(context.pathComponent)/conferences/\(conferenceID)"
    )

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.updateNavBar()
    }
    var conference: Conference? { conferences.first(where: { $0.id == conferenceID }) }
    lazy var conferences = env.subscribe(GetConferences(context: context)) { [weak self] in
        self?.update()
    }
    lazy var course = env.subscribe(GetCourse(courseID: context.id)) { [weak self] in
        self?.updateNavBar()
    }
    lazy var group = env.subscribe(GetGroup(groupID: context.id)) { [weak self] in
        self?.updateNavBar()
    }

    lazy var formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()

    public static func create(context: Context, conferenceID: String) -> ConferenceDetailsViewController {
        let controller = loadFromStoryboard()
        controller.conferenceID = conferenceID
        controller.context = context
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        tableView.backgroundColor = .backgroundLightest

        setupTitleViewInNavbar(title: NSLocalizedString("Conference Details", bundle: .core, comment: ""))

        detailsHeadingLabel.text = NSLocalizedString("Description", bundle: .core, comment: "")

        joinButton.setTitle(NSLocalizedString("Join", bundle: .core, comment: ""), for: .normal)
        joinButton.isHidden = true
        joinButton.makeUnavailableInOfflineMode()

        recordingsHeadingLabel.text = NSLocalizedString("Recordings", bundle: .core, comment: "")
        recordingsView.isHidden = true

        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .primaryActionTriggered)
        tableView.refreshControl = refreshControl

        colors.refresh()
        if context.contextType == .course {
            course.refresh()
        } else {
            group.refresh()
        }
        refresh()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useContextColor(color)
    }

    func updateNavBar() {
        guard
            let name = context.contextType == .course ? course.first?.name : group.first?.name,
            let color = context.contextType == .course ? course.first?.color : group.first?.color
        else {
            return
        }
        spinnerView.color = color
        refreshControl.color = color
        updateNavBar(subtitle: name, color: color)
    }

    func update() {
        spinnerView.isHidden = !conferences.pending || refreshControl.isRefreshing
        let conference = self.conference
        titleLabel.text = conference?.title
        statusLabel.attributedText = conference?.statusLongText
        if let description = conference?.details, !description.isEmpty {
            detailsLabel.text = description
        } else {
            detailsLabel.text = NSLocalizedString("No description", bundle: .core, comment: "")
        }
        joinButton.isHidden = !(conference?.startedAt != nil && conference?.endedAt == nil)
        recordingsView.isHidden = conference?.recordings?.isEmpty != false
        headerView.frame.size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        tableView.tableHeaderView = headerView
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        tableView.reloadData()
    }

    @objc func refresh(_ sender: CircleRefreshControl? = nil) {
        conferences.exhaust(force: sender != nil) { [weak self] _ in
            if self?.conferences.hasNextPage == true, self?.conference == nil {
                return true
            }
            self?.refreshControl.endRefreshing()
            return false
        }
    }

    @IBAction func join() {
        let joinURL = "\(context.pathComponent)/conferences/\(conferenceID)/join"
        env.router.route(to: joinURL, from: self, options: .push)
    }
}

extension ConferenceDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conference?.recordings?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let recording = conference?.recordings?[indexPath.row]
        let cell: ConferenceRecordingCell = tableView.dequeue(for: indexPath)
        cell.backgroundColor = .backgroundLightest
        cell.titleLabel.text = recording?.title
        cell.dateLabel.text = recording?.createdAt.map {
            DateFormatter.localizedString(from: $0, dateStyle: .medium, timeStyle: .short)
        }
        cell.durationLabel.text = (recording?.duration).flatMap {
            formatter.string(from: $0 * 60)
        }
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let url = conference?.recordings?[indexPath.row].playbackURL else { return }
        env.router.route(to: url, from: self, options: .push)
    }
}

class ConferenceRecordingCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
}
