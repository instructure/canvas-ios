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

public class DashboardCardViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    let refreshControl = CircleRefreshControl()

    lazy var profileButton = UIBarButtonItem(image: .hamburgerSolid, style: .plain, target: self, action: #selector(openProfile))

    let env = AppEnvironment.shared

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.update()
    }

    public static func create() -> DashboardCardViewController {
        return loadFromStoryboard()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = profileButton
        profileButton.accessibilityIdentifier = "Dashboard.profileButton"
        profileButton.accessibilityLabel = NSLocalizedString("Profile Menu")
        navigationItem.titleView = Brand.shared.headerImageView()

        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        collectionView.refreshControl = refreshControl
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        env.pageViewLogger.startTrackingTimeOnViewController()
        navigationController?.navigationBar.useGlobalNavStyle()
        for section in Section.allCases {
            delegate(section.rawValue).refresh(force: false)
        }
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        env.pageViewLogger.stopTrackingTimeOnViewController(eventName: "/", attributes: [:])
    }

    @objc func refresh() {
        colors.refresh(force: true)
        for section in Section.allCases {
            delegate(section.rawValue).refresh(force: true)
        }
    }

    func update() {
        collectionView.reloadData()
    }

    @objc func openProfile() {
        env.router.route(to: "/profile", from: self, options: .modal())
    }

    lazy var conferenceSection = DashboardConferenceSection(self)
    lazy var inviteSection = DashboardInviteSection(self)
    lazy var announcementSection = DashboardAnnouncementSection(self)
    lazy var courseSection = DashboardCourseSection(self)
    lazy var groupSection = DashboardGroupSection(self)
}

protocol DashboardSectionDelegate: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func refresh(force: Bool)
}

class DashboardSection: NSObject {
    weak var controller: DashboardCardViewController?

    init(_ controller: DashboardCardViewController) {
        self.controller = controller
    }
}

extension DashboardCardViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    enum Section: Int, CaseIterable {
        case /*conferences, invites, announcements,*/ courses, groups
    }
    func delegate(_ section: Int) -> DashboardSectionDelegate {
        switch Section(rawValue: section) {
        /*
        case .conferences:
            return conferenceSection
        case .invites:
            return inviteSection
        case .announcements:
            return announcementSection
        */
        case .courses:
            return courseSection
        case .groups, nil:
            return groupSection
        }
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        delegate(section).collectionView(collectionView, numberOfItemsInSection: section)
    }
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        delegate(indexPath.section).collectionView?(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath) ??
            collectionView.dequeue(ofKind: kind, for: indexPath)
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        delegate(indexPath.section).collectionView(collectionView, cellForItemAt: indexPath)
    }
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        delegate(indexPath.section).collectionView?(collectionView, didSelectItemAt: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        delegate(indexPath.section).collectionView?(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath) ?? .zero
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        delegate(section).collectionView?(collectionView, layout: collectionViewLayout, insetForSectionAt: section) ?? .zero
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        delegate(section).collectionView?(collectionView, layout: collectionViewLayout, minimumLineSpacingForSectionAt: section) ?? .zero
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        delegate(section).collectionView?(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: section) ?? .zero
    }
}

class DashboardSectionHeaderView: UICollectionReusableView {
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!

    var rightActionCallback: (() -> Void)?

    func update(title: String, rightText: String? = nil, rightAction: (() -> Void)? = nil) {
        titleLabel.text = title
        rightButton.setTitle(rightText, for: .normal)
        rightActionCallback = rightAction
        rightButton.isHidden = rightAction == nil
    }

    @IBAction func rightButtonTapped() {
        rightActionCallback?()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        isHidden = false
    }
}
