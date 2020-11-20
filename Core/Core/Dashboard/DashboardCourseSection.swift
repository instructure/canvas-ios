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

class DashboardCourseSection: DashboardSection, DashboardSectionDelegate {
    let env = AppEnvironment.shared

    let spacing: CGFloat = 16
    let shadowMargin: CGFloat = 5
    let cardMinWidth: CGFloat = 150

    var needsRefresh = false

    lazy var cards = env.subscribe(GetDashboardCards()) { [weak self] in
        self?.controller?.update()
    }
    lazy var courses = env.subscribe(GetCourses()) { [weak self] in
        self?.controller?.update()
    }
    lazy var settings = env.subscribe(GetUserSettings(userID: "self")) { [weak self] in
        self?.controller?.update()
    }

    override init(_ controller: DashboardCardViewController) {
        super.init(controller)
        NotificationCenter.default.addObserver(self, selector: #selector(showGradesChanged(_:)), name: .showGradesOnDashboardDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(favoritesChanged(_:)), name: .favoritesDidChange, object: nil)
    }

    @objc func showGradesChanged(_ notification: Notification) {
        controller?.update()
    }

    @objc func favoritesChanged(_ notification: Notification) {
        if cards.pending {
            needsRefresh = true
        } else {
            refreshCards()
        }
    }

    func refreshCards() {
        needsRefresh = false
        cards.refresh(force: true) { [weak self] _ in
            if self?.needsRefresh == true {
                self?.refreshCards()
            }
        }
    }

    func refresh(force: Bool) {
        cards.refresh(force: force) { [weak self] _ in
            self?.controller?.refreshControl.endRefreshing()
            if self?.needsRefresh == true {
                self?.refreshCards()
            }
        }
        courses.exhaust(force: force)
        settings.refresh(force: force)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header: DashboardSectionHeaderView = collectionView.dequeue(ofKind: kind, for: indexPath)
        header.update(
            title: NSLocalizedString("Courses", comment: ""),
            rightText: NSLocalizedString("All Courses", comment: "")
        ) { [weak self] in
            guard let self = self, let from = self.controller else { return }
            self.env.router.route(to: "/courses", from: from, options: .push)
        }
        return header
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // prevent center aligned single card
        cards.count == 1 ? 2 : cards.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let card = cards[indexPath.item]
        let cell: DashboardCourseCell = collectionView.dequeue(for: indexPath)
        let hideColorOverlay = settings.first?.hideDashcardColorOverlays == true
        let showGrade = env.userDefaults?.showGradesOnDashboard == true
        cell.update(card, hideColorOverlay: hideColorOverlay, showGrade: showGrade) { [weak self] in
            guard let course = card?.getCourse(), let self = self, let from = self.controller  else { return }
            self.env.router.show(
                CoreHostingController(CustomizeCourseView(course: course, hideColorOverlay: hideColorOverlay)),
                from: from,
                options: .modal(isDismissable: false, embedInNav: true)
            )
        }

        let width = collectionView.bounds.width
        let columns = max(1, floor(width / cardMinWidth))
        cell.cardWidth.constant = ((width - ((columns+1) * spacing)) / columns)
        cell.isHidden = indexPath.item >= cards.count
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let id = cards[indexPath.item]?.id, let from = controller else { return }
        env.router.route(to: "/courses/\(id)", from: from, options: .detail)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let margin = spacing - shadowMargin
        return UIEdgeInsets(top: -shadowMargin, left: margin, bottom: spacing, right: margin)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing - (shadowMargin * 2)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing - (shadowMargin * 2) - 1 // ensure no extra wrapping
    }
}

class DashboardCourseCell: UICollectionViewCell {
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var cardWidth: NSLayoutConstraint!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var gradeIcon: UIImageView!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var gradePill: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topView: UIView!

    var optionsCallback: (() -> Void)?
    let optionsCircle = CALayer()

    func update(_ card: DashboardCard?, hideColorOverlay: Bool, showGrade: Bool, optionsCallback: @escaping () -> Void) {
        let id = card?.id ?? ""
        accessibilityElements = [ cardView as Any, gradePill as Any, optionsButton as Any ]
        cardView.accessibilityIdentifier = "DashboardCourseCell.\(id)"
        cardView.accessibilityLabel = card?.shortName
        optionsButton.accessibilityIdentifier = "DashboardCourseCell.\(id).optionsButton"
        optionsButton.accessibilityLabel = String.localizedStringWithFormat(
            NSLocalizedString("Open %@ user preferences", comment: ""),
            card?.shortName ?? ""
        )

        let color = card?.color.ensureContrast(against: .white)

        let course = card?.getCourse()
        let hideTotalGrade = course?.hideTotalGrade != false
        gradeIcon.isHidden = !hideTotalGrade
        gradeIcon.tintColor = color
        gradeLabel.isHidden = hideTotalGrade
        gradeLabel.text = hideTotalGrade ? nil : course?.displayGrade
        gradeLabel.textColor = color
        gradePill.isHidden = !showGrade

        titleLabel.text = card?.shortName
        titleLabel.textColor = color
        codeLabel.text = card?.courseCode

        topView.backgroundColor = color
        imageView.load(url: card?.imageURL)
        if card?.imageURL == nil || !hideColorOverlay {
            imageView.alpha = 0.4
            optionsCircle.removeFromSuperlayer()
        } else {
            imageView.alpha = 1
            optionsCircle.frame = CGRect(x: 8, y: 8, width: optionsButton.bounds.width - 16, height: optionsButton.bounds.height - 16)
            optionsCircle.backgroundColor = color?.cgColor
            optionsCircle.cornerRadius = optionsCircle.frame.width / 2
            optionsButton.layer.insertSublayer(optionsCircle, below: optionsButton.imageView?.layer)
        }
        self.optionsCallback = optionsCallback
    }

    @IBAction func showOptions() {
        optionsCallback?()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.load(url: nil)
    }
}
