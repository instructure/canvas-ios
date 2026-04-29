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

public class ConferenceListViewController: ScreenViewTrackableViewController, ColoredNavViewProtocol {
    private enum ConferenceItem: Hashable {
        case conference(id: String)
        case loading
    }

    @IBOutlet weak var emptyMessageLabel: UILabel!
    @IBOutlet weak var emptyTitleLabel: UILabel!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var errorView: ListErrorView!
    let refreshControl = UIRefreshControl()
    @IBOutlet weak var spinnerView: CircleProgressView!
    @IBOutlet weak var tableView: UITableView!
    public let titleSubtitleView = TitleSubtitleView.create()

    public var color: UIColor?
    var context = Context.currentUser
    let env = AppEnvironment.shared
    private var dataSource: UITableViewDiffableDataSource<String, ConferenceItem>!
    public lazy var screenViewTrackingParameters = ScreenViewTrackingParameters(
        eventName: "\(context.pathComponent)/conferences"
    )

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.updateNavBar()
    }
    lazy var conferences = env.subscribe(GetConferences(context: context)) { [weak self] in
        self?.update()
    }
    lazy var course = env.subscribe(GetCourse(courseID: context.id)) { [weak self] in
        self?.updateNavBar()
    }
    lazy var group = env.subscribe(GetGroup(groupID: context.id)) { [weak self] in
        self?.updateNavBar()
    }

    public static func create(context: Context) -> ConferenceListViewController {
        let controller = loadFromStoryboard()
        controller.context = context
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest

        if #available(iOS 26, *) {
            navigationItem.title = String(localized: "Conferences", bundle: .core)
        } else {
            setupTitleViewInNavbar(title: String(localized: "Conferences", bundle: .core))
        }

        emptyMessageLabel.text = String(localized: "There are no conferences to display yet.", bundle: .core)
        emptyTitleLabel.text = String(localized: "No Conferences", bundle: .core)
        errorView.messageLabel.text = String(localized: "There was an error loading conferences. Pull to refresh to try again.", bundle: .core)
        errorView.retryButton.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)

        tableView.backgroundColor = .backgroundLightest
        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        tableView.refreshControl = refreshControl
        tableView.selectionFollowsFocus = false
        tableView.registerHeaderFooterView(SectionHeaderView.self)

        setupDataSource()

        colors.refresh()
        if context.contextType == .course {
            course.refresh()
        } else {
            group.refresh()
        }
        conferences.refresh()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selected, animated: animated)
        }
        if #unavailable(iOS 26) {
            navigationController?.navigationBar.useContextColor(color)
        }
    }

    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource(tableView: tableView) { [weak self] tableView, indexPath, item in
            guard let self else { return UITableViewCell() }
            switch item {
            case .conference(let id):
                let cell = tableView.dequeue(ConferenceListCell.self, for: indexPath)
                let conference = self.conferences.all.first(where: { $0.id == id })
                cell.update(conference, color: self.color)
                return cell
            case .loading:
                return LoadingCell(style: .default, reuseIdentifier: nil)
            }
        }
        tableView.delegate = self
    }

    func updateNavBar() {
        guard
            let name = context.contextType == .course ? course.first?.name : group.first?.name,
            let color = context.contextType == .course ? course.first?.color : group.first?.color
        else {
            return
        }
        view.tintColor = color
        spinnerView.color = color

        if #available(iOS 26, *) {
            navigationItem.subtitle = name
        } else {
            updateNavBar(subtitle: name, color: color)
        }
    }

    func update() {
        spinnerView.isHidden = !conferences.pending || !conferences.isEmpty || conferences.error != nil || refreshControl.isRefreshing
        emptyView.isHidden = conferences.pending || !conferences.isEmpty || conferences.error != nil
        errorView.isHidden = conferences.error == nil
        applySnapshot()
    }

    private func applySnapshot() {
        var snapshot = conferences.makeSnapshot(
            coreSectionID: { $0 },
            itemID: { ConferenceItem.conference(id: $0.id) }
        )

        if conferences.hasNextPage, let lastSection = snapshot.sectionIdentifiers.last {
            snapshot.appendItems([.loading], toSection: lastSection)
        }

        dataSource.applySnapshot(snapshot)
    }

    @objc func refresh() {
        conferences.refresh(force: true) { [weak self] _ in
            self?.refreshControl.endRefreshing()
        }
    }
}

extension ConferenceListViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueHeaderFooter(SectionHeaderView.self)
        let sectionIdentifiers = dataSource.snapshot().sectionIdentifiers
        let isConcluded = section < sectionIdentifiers.count && sectionIdentifiers[section] == "1"
        view.titleLabel?.text = isConcluded
            ? String(localized: "Concluded Conferences", bundle: .core)
            : String(localized: "New Conferences", bundle: .core)
        view.titleLabel?.accessibilityIdentifier = "ConferencesList.header-\(section)"
        return view
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell is LoadingCell {
            DispatchQueue.main.async { [weak self] in
                self?.conferences.getNextPage()
            }
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard case .conference(let id) = dataSource.itemIdentifier(for: indexPath) else { return }
        env.router.route(to: "/\(context.pathComponent)/conferences/\(id)", from: self, options: .detail)
    }
}

class ConferenceListCell: UITableViewCell {
    @IBOutlet weak var iconView: AccessIconView!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupInstDisclosureIndicator()
    }

    func update(_ conference: Conference?, color: UIColor?) {
        backgroundColor = .backgroundLightest
        iconView.icon = .conferences
        if Bundle.main.isTeacherApp {
            iconView.state = conference?.isConcluded == true ? .unpublished : .published
        }
        titleLabel.setText(conference?.title, style: .textCellTitle)
        titleLabel.accessibilityIdentifier = (conference?.id).map { "ConferencesList.cell-\($0).title" }
        statusLabel.setText(conference?.statusText, style: .textCellSupportingText)
        statusLabel.textColor = conference?.statusColor
        statusLabel.accessibilityIdentifier = (conference?.id).map { "ConferencesList.cell-\($0).status" }
        detailsLabel.setText(conference?.details, style: .textCellBottomLabel)
        detailsLabel.accessibilityIdentifier = (conference?.id).map { "ConferencesList.cell-\($0).details" }
        selectedBackgroundView = ContextCellBackgroundView.create(color: color)
    }
}
