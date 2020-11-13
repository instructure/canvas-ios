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

class DashboardGroupSection: DashboardSection, DashboardSectionDelegate {
    let env = AppEnvironment.shared
    let spacing: CGFloat = 16
    let shadowMargin: CGFloat = 5

    lazy var groups = env.subscribe(GetDashboardGroups()) { [weak self] in
        self?.controller?.update()
    }

    func refresh(force: Bool) {
        groups.exhaust(force: force)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        groups.count
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header: DashboardSectionHeaderView = collectionView.dequeue(ofKind: kind, for: indexPath)
        header.update(title: NSLocalizedString("Groups"))
        header.isHidden = groups.isEmpty
        return header
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: DashboardGroupCell = collectionView.dequeue(for: indexPath)
        cell.update(groups[indexPath.item])
        cell.cardWidth.constant = collectionView.bounds.width - (2 * spacing)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let id = groups[indexPath.item]?.id, let from = controller else { return }
        env.router.route(to: "/groups/\(id)", from: from, options: .detail)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let margin = spacing - shadowMargin
        return UIEdgeInsets(top: -shadowMargin, left: margin, bottom: spacing, right: margin)

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing - (shadowMargin * 2)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing - (shadowMargin * 2)
    }
}

class DashboardGroupCell: UICollectionViewCell {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var cardWidth: NSLayoutConstraint!
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var leftColorView: UIView!
    @IBOutlet weak var termLabel: UILabel!

    func update(_ group: Group?) {
        accessibilityElements = [ cardView as Any ]
        cardView.accessibilityIdentifier = "DashboardGroupCell.\(group?.id ?? "")"
        cardView.accessibilityLabel = group?.name
        let color = group?.color.ensureContrast(against: .white)
        let course = group?.getCourse()
        courseNameLabel.text = course?.name ?? NSLocalizedString("Account Group")
        courseNameLabel.textColor = color
        groupNameLabel.text = group?.name
        leftColorView?.backgroundColor = color
        termLabel.text = course?.termName?.localizedUppercase
    }
}
