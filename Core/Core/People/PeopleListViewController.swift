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

public class PeopleListViewController: UIViewController, ColoredNavViewProtocol {
    @IBOutlet weak var emptyMessageLabel: UILabel!
    @IBOutlet weak var emptyTitleLabel: UILabel!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var errorView: ListErrorView!
    @IBOutlet weak var keyboardSpace: NSLayoutConstraint!
    let refreshControl = CircleRefreshControl()
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var spinnerView: CircleProgressView!
    @IBOutlet weak var tableView: UITableView!

    public var color: UIColor?
    let env = AppEnvironment.shared
    public var titleSubtitleView = TitleSubtitleView.create()
    var context = Context.currentUser
    var enrollmentType: BaseEnrollmentType?
    var enrollmentTypes = BaseEnrollmentType.allCases.sorted {
        $0.name.localizedStandardCompare($1.name) == .orderedAscending
    }
    var keyboard: KeyboardTransitioning?
    var search: String?

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.updateNavBar()
    }
    lazy var course = env.subscribe(GetCourse(courseID: context.id)) { [weak self] in
        self?.updateNavBar()
    }
    lazy var group = env.subscribe(GetGroup(groupID: context.id)) { [weak self] in
        self?.updateNavBar()
    }
    lazy var users = env.subscribe(GetContextUsers(context: context)) { [weak self] in
        self?.update()
    }

    public static func create(context: Context) -> PeopleListViewController {
        let controller = loadFromStoryboard()
        controller.context = context
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .named(.backgroundLightest)
        setupTitleViewInNavbar(title: NSLocalizedString("People", bundle: .core, comment: ""))

        emptyMessageLabel.text = NSLocalizedString("We couldn’t find somebody like that.", bundle: .core, comment: "")
        emptyTitleLabel.text = NSLocalizedString("No Results", bundle: .core, comment: "")
        errorView.messageLabel.text = NSLocalizedString("There was an error loading people. Pull to refresh to try again.", bundle: .core, comment: "")
        errorView.retryButton.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)

        searchBar.placeholder = NSLocalizedString("Search", bundle: .core, comment: "")
        searchBar.backgroundColor = .named(.backgroundLightest)

        tableView.backgroundColor = .named(.backgroundLightest)
        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        tableView.refreshControl = refreshControl
        tableView.registerHeaderFooterView(FilterHeaderView.self, fromNib: false)
        tableView.separatorColor = .named(.borderMedium)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.tableView.contentOffset.y = self.searchBar.frame.height
        }

        colors.refresh()
        if context.contextType == .course {
            course.refresh()
        } else {
            group.refresh()
        }
        users.refresh()

        if context.contextType == .course {
            env.api.makeRequest(GetSearchRecipientsRequest(context: context, includeContexts: true)) { [weak self] recipients, _, _ in
                guard let recipients = recipients else { return }
                self?.enrollmentTypes = BaseEnrollmentType.allCases
                    .filter { type in recipients.contains {
                        $0.id.value.hasSuffix("_\(type)s")
                    } }
                    .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
            }
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboard = KeyboardTransitioning(view: view, space: keyboardSpace)
        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selected, animated: true)
        }
        if let color = color {
            navigationController?.navigationBar.useContextColor(color)
        }
        env.pageViewLogger.startTrackingTimeOnViewController()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        env.pageViewLogger.stopTrackingTimeOnViewController(eventName: "\(context.pathComponent)/users", attributes: [:])
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
        spinnerView.isHidden = !users.pending || !users.isEmpty || users.error != nil || refreshControl.isRefreshing
        emptyView.isHidden = users.pending || !users.isEmpty || users.error != nil
        errorView.isHidden = users.error == nil
        tableView.reloadData()
    }

    @objc func refresh() {
        users.refresh(force: true) { [weak self] _ in
            self?.refreshControl.endRefreshing()
        }
    }

    @objc func filter(_ sender: UIButton) {
        guard enrollmentType == nil else {
            enrollmentType = nil
            return updateUsers()
        }
        let alert = UIAlertController(title: NSLocalizedString("Filter by:", bundle: .core, comment: ""), message: nil, preferredStyle: .actionSheet)
        for type in enrollmentTypes {
            alert.addAction(AlertAction(type.name, style: .default) { _ in
                self.enrollmentType = type
                self.updateUsers()
            })
        }
        alert.addAction(AlertAction(NSLocalizedString("Cancel", bundle: .core, comment: ""), style: .cancel))
        alert.popoverPresentationController?.sourceView = sender
        alert.popoverPresentationController?.sourceRect = sender.bounds
        env.router.show(alert, from: self, options: .modal())
    }
}

extension PeopleListViewController: UISearchBarDelegate {
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }

    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        self.searchBar(searchBar, textDidChange: "")
        searchBarSearchButtonClicked(searchBar)
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        tableView.setContentOffset(CGPoint(x: 0, y: searchBar.frame.height), animated: true)
    }

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let newSearch = searchText.count >= 3 ? searchText : nil
        tableView.setContentOffset(.zero, animated: true)
        guard newSearch != search else { return }
        search = newSearch
        updateUsers()
    }

    func updateUsers() {
        users = env.subscribe(GetContextUsers(context: context, type: enrollmentType, search: search)) { [weak self] in
            self?.update()
        }
        users.refresh()
    }
}

extension PeopleListViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard context.contextType == .course else { return 0 }
        return 16 + UIFont.scaledNamedFont(.heavy24).lineHeight + 8
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard context.contextType == .course else { return nil }
        let header: FilterHeaderView = tableView.dequeueHeaderFooter()
        header.titleLabel.text = enrollmentType?.name ?? NSLocalizedString("All People", bundle: .core, comment: "")
        header.filterButton.removeTarget(self, action: nil, for: .primaryActionTriggered)
        header.filterButton.addTarget(self, action: #selector(filter(_:)), for: .primaryActionTriggered)
        header.filterButton.setTitle(enrollmentType == nil
            ? NSLocalizedString("Filter", bundle: .core, comment: "")
            : NSLocalizedString("Clear filter", bundle: .core, comment: ""), for: .normal)
        header.filterButton.setTitleColor(Brand.shared.linkColor, for: .normal)
        return header
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.hasNextPage ? users.count + 1 : users.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if users.hasNextPage && indexPath.row == users.count {
            users.getNextPage()
            return LoadingCell(style: .default, reuseIdentifier: nil)
        }
        let cell = tableView.dequeue(PeopleListCell.self, for: indexPath)
        cell.update(user: users[indexPath.row])
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let user = users[indexPath.row] else { return }
        env.router.route(to: "/\(context.pathComponent)/users/\(user.id)", from: self, options: .detail)
    }
}

class PeopleListCell: UITableViewCell {
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rolesLabel: UILabel!

    func update(user: User?) {
        backgroundColor = .named(.backgroundLightest)
        avatarView.name = user?.name ?? ""
        avatarView.url = user?.avatarURL
        nameLabel.text = user.flatMap { User.displayName($0.name, pronouns: $0.pronouns) }
        let roles = user?.enrollments?.compactMap { $0.formattedRole }.sorted() ?? []
        rolesLabel.text = ListFormatter.localizedString(from: roles)
        rolesLabel.isHidden = roles.isEmpty
    }
}
