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

public class CourseListViewController: UIViewController, ErrorViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    // TODO: @IBOutlet weak var emptyView: UIView!
    // TODO: @IBOutlet weak var errorView: UIView!
    // TODO: @IBOutlet weak var loadingView: CircleProgressView!

    let gutterWidth: CGFloat = 16
    let shadowMargin: CGFloat = 5
    let cardColumns: CGFloat = 2
    let cardHeight: CGFloat = 160
    var cellHeight: CGFloat { cardHeight + (shadowMargin * 2) }

    let env = AppEnvironment.shared
    let refreshControl = CircleRefreshControl()

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.update()
    }
    lazy var courses = env.subscribe(GetAllCourses()) { [weak self] in
        self?.update()
    }
    lazy var settings = env.subscribe(GetUserSettings(userID: "self")) { [weak self] in
        self?.update()
    }

    public static func create() -> CourseListViewController {
        return loadFromStoryboard()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("All Courses", bundle: .core, comment: "All Courses screen title")

        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        collectionView.refreshControl = refreshControl
        collectionView.registerCell(CourseCardCell.self)

        colors.refresh()
        courses.exhaust()
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
        env.pageViewLogger.stopTrackingTimeOnViewController(eventName: "/courses", attributes: [:])
    }

    @objc func refresh() {
        colors.refresh(force: true)
        courses.exhaust(force: true) { [weak self] _ in
            guard self?.courses.hasNextPage != true else { return true }
            self?.refreshControl.endRefreshing()
            return false
        }
        settings.refresh(force: true)
    }

    func update() {
        collectionView.reloadData()
    }
}

extension CourseListViewController: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return courses.sections?.count ?? 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return courses.sections?[section].numberOfObjects ?? 0
    }

    func isPastEnrollment(_ section: Int) -> Bool {
        courses.sections?[section].name == "1"
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header: CourseListSectionHeaderView = collectionView.dequeue(ofKind: kind, for: indexPath)
        header.titleLabel.text = NSLocalizedString("Past Enrollments", bundle: .core, comment: "")
        return header
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let course = courses[indexPath]
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
        guard let courseID = courses[indexPath]?.id else { return }
        env.router.route(to: "/courses/\(courseID)", from: self, options: .detail)
    }
}

extension CourseListViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - ((cardColumns+1) * gutterWidth)) / cardColumns + shadowMargin * 2, height: cellHeight)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let margin = gutterWidth - shadowMargin
        guard isPastEnrollment(section) else {
            return UIEdgeInsets(top: margin, left: margin, bottom: -shadowMargin, right: margin)
        }
        return UIEdgeInsets(top: -shadowMargin, left: margin, bottom: gutterWidth, right: margin)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return gutterWidth - (shadowMargin * 2)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return gutterWidth - (shadowMargin * 2)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard isPastEnrollment(section) else { return .zero }
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
}

class CourseListSectionHeaderView: UICollectionReusableView {
    @IBOutlet weak var titleLabel: UILabel!
}
