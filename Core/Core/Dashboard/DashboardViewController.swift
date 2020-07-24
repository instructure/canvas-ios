//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

public class DashboardViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    // TODO: @IBOutlet weak var emptyView: UIView!
    // TODO: @IBOutlet weak var errorView: UIView!
    // TODO: @IBOutlet weak var loadingView: CircleProgressView!
    let refreshControl = CircleRefreshControl()

    lazy var editFavoritesButton = UIBarButtonItem(title: NSLocalizedString("Edit", bundle: .core, comment: ""), style: .plain, target: self, action: #selector(editFavorites))
    lazy var openProfileButton = UIBarButtonItem(image: .icon(.hamburger, .solid), style: .plain, target: self, action: #selector(openProfile))

    let env = AppEnvironment.shared

    let gutterWidth: CGFloat = 16
    let shadowMargin: CGFloat = 5
    let coursesColumns: CGFloat = 2
    let groupsColumns: CGFloat = 1

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.update()
    }
    lazy var courses = env.subscribe(GetCourses(showFavorites: true)) { [weak self] in
        self?.update()
    }
    lazy var groups = env.subscribe(GetDashboardGroups()) { [weak self] in
        self?.update()
    }
    lazy var settings = env.subscribe(GetUserSettings(userID: "self")) { [weak self] in
        self?.update()
    }

    static func create() -> DashboardViewController {
        return loadFromStoryboard()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = openProfileButton
        openProfileButton.accessibilityIdentifier = "Dashboard.profileButton"
        navigationItem.titleView = Brand.shared.headerImageView()
        navigationItem.rightBarButtonItem = editFavoritesButton
        editFavoritesButton.accessibilityIdentifier = "Dashboard.editFavoritesButton"

        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        collectionView.refreshControl = refreshControl
        collectionView.registerCell(CourseCardCell.self)

        colors.refresh()
        courses.exhaust()
        groups.exhaust()
        settings.refresh()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        env.pageViewLogger.startTrackingTimeOnViewController()
        navigationController?.navigationBar.useGlobalNavStyle()
        for indexPath in collectionView.indexPathsForSelectedItems ?? [] {
            collectionView.deselectItem(at: indexPath, animated: animated)
        }
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        env.pageViewLogger.stopTrackingTimeOnViewController(eventName: "/", attributes: [:])
    }

    @objc func refresh() {
        colors.refresh(force: true)
        courses.exhaust(force: true) { [weak self] _ in
            guard self?.courses.hasNextPage == false else { return true }
            self?.refreshControl.endRefreshing()
            return false
        }
        groups.exhaust(force: true)
        settings.refresh(force: true)
    }

    func update() {
        collectionView.reloadData()
    }

    @objc func editFavorites() {
        env.router.route(to: "/course_favorites", from: self, options: .modal(embedInNav: true))
    }

    @objc func openProfile() {
        env.router.route(to: "/profile", from: self, options: .modal())
    }
}

extension DashboardViewController: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return courses.isEmpty && groups.isEmpty ? 0 : 2
    }

    func isGroup(_ section: Int) -> Bool {
        return section > 0
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isGroup(section) { return groups.count }
        return courses.count
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let header: DashboardSectionHeaderView = collectionView.dequeue(ofKind: kind, for: indexPath)
        if isGroup(indexPath.section) {
            header.update(title: NSLocalizedString("Groups", bundle: .core, comment: ""))
        } else {
            header.update(
                title: NSLocalizedString("Courses", bundle: .core, comment: ""),
                rightText: NSLocalizedString("See All", bundle: .core, comment: "")
            ) { [weak self] in
                guard let self = self else { return }
                self.env.router.route(to: "/courses", from: self, options: .push)
            }
        }
        header.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return header
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isGroup(indexPath.section) {
            let cell: DashboardGroupCell = collectionView.dequeue(for: indexPath)
            cell.update(groups[indexPath.item])
            return cell
        }
        let course = courses[indexPath.item]
        let courseID = course?.id
        let cell: CourseCardCell = collectionView.dequeue(for: indexPath)
        let hideColorOverlay = settings.first?.hideDashcardColorOverlays == true
        cell.update(course, hideColorOverlay: hideColorOverlay) { [weak self] in
            guard let courseID = courseID, let self = self else { return }
            self.env.router.route(to: "/courses/\(courseID)/user_preferences", from: self, options: .modal(embedInNav: true))
        }
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isGroup(indexPath.section) {
            guard let id = groups[indexPath.item]?.id else { return }
            env.router.route(to: "/groups/\(id)", from: self, options: .detail)
        } else {
            guard let id = courses[indexPath.item]?.id else { return }
            env.router.route(to: "/courses/\(id)", from: self, options: .detail)
        }
    }
}

extension DashboardViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isGroup(indexPath.section) {
            return CGSize(width: (collectionView.bounds.width - ((groupsColumns+1) * gutterWidth)) / groupsColumns + shadowMargin * 2, height: 92)
        } else {
            return CGSize(width: (collectionView.bounds.width - ((coursesColumns+1) * gutterWidth)) / coursesColumns + shadowMargin * 2, height: 173)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let margin = gutterWidth - shadowMargin
        if isGroup(section) {
            return UIEdgeInsets(top: -shadowMargin, left: margin, bottom: gutterWidth, right: margin)
        } else {
            return UIEdgeInsets(top: -shadowMargin, left: margin, bottom: 0, right: margin)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return gutterWidth - (shadowMargin * 2)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return gutterWidth - (shadowMargin * 2)
    }
}
