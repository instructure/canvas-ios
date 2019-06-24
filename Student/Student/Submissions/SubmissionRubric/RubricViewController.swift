//
// Copyright (C) 2019-present Instructure, Inc.
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
import Core

class RubricViewController: UIViewController {

    static func create(env: AppEnvironment = .shared, courseID: String, assignmentID: String, userID: String) -> RubricViewController {
        let controller = loadFromStoryboard()
        controller.presenter = RubricPresenter(env: env, view: controller, courseID: courseID, assignmentID: assignmentID, userID: userID)
        return controller
    }

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyViewLabel: UILabel!
    var models: [RubricViewModel] = []
    var presenter: RubricPresenter!
    var selectedRatingCache = [Int]()
    var collectionViewDidSetupCells = false

    override func viewDidLoad() {
        super.viewDidLoad()

        emptyViewLabel.text = NSLocalizedString("There is no rubric for this assignment", comment: "")

        setupCollectionViewHeader()
        presenter.viewIsReady()
    }

    func setupCollectionViewHeader() {
        let headerID = String(describing: GradeCircleReusableView.self)
        collectionView.register(GradeCircleReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerID)
    }

    func setupCollectionViewCells() {
        collectionViewDidSetupCells = true
        let count = models.count
        for i in 0..<count {
            let id = String(describing: RubricCollectionViewCell.self)
            let nib = UINib(nibName: id, bundle: Bundle(for: type(of: self)))
            let cellID = "\(id)_\(i)"
            collectionView.register(nib, forCellWithReuseIdentifier: cellID)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            self.collectionView.reloadData()
        }
    }
}

extension RubricViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if presenter.assignments.first?.useRubricForGrading ?? false {
            return CGSize(width: collectionView.frame.width, height: 156)
        } else {
            return CGSize.zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let assignment = presenter.assignments.first else {
                fatalError("Invalid view type")
            }
            let gradeView: GradeCircleReusableView = collectionView.dequeue(ofKind: kind, for: indexPath)
            gradeView.gradeCircleView?.update(assignment)
            return gradeView
        default:
            fatalError("Unexpected element kind")
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellType = String(describing: RubricCollectionViewCell.self)
        let cellID = "\(cellType)_\(indexPath.item)"
        guard let cell = collectionView.dequeue(withReuseIdentifier: cellID, for: indexPath) as? RubricCollectionViewCell else { fatalError("expecting cell of type \(cellType)") }
        let r = models[indexPath.item]
        cell.update(rubric: r, selectedRatingIndex: selectedRatingCache[indexPath.item], courseColor: presenter.courses.first?.color ?? Brand.shared.primary)
        cell.delegate = self
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let height = RubricCollectionViewCell.computedHeight(rubric: models[indexPath.item], selectedRatingIndex: selectedRatingCache[indexPath.item], containerFrame: collectionView.bounds)
        return CGSize(width: view.bounds.size.width, height: height)
    }
}

extension RubricViewController: RubricViewProtocol {
    func update(_ rubric: [RubricViewModel]) {
        models = rubric
        if !collectionViewDidSetupCells { setupCollectionViewCells() }
        selectedRatingCache = models.map { $0.selectedIndex }
        collectionView.reloadData()
    }

    func showEmptyState() {
        emptyView?.isHidden = false
    }
}

protocol RubricCellDelegate: class {
    func longDescriptionTapped(cell: RubricCollectionViewCell)
    func selectedRatingDidChange(ratingIndex: Int, cell: UICollectionViewCell)
}

extension RubricViewController: RubricCellDelegate {
    func longDescriptionTapped(cell: RubricCollectionViewCell) {
        guard let indexPath = self.collectionView.indexPath(for: cell) else {
            return
        }
        let r = models[indexPath.item]
        let vc = UINavigationController(rootViewController: RubricLongDescriptionViewController(longDescription: r.longDescription, title: r.title))
        self.present(vc, animated: true, completion: nil)
    }

    func selectedRatingDidChange(ratingIndex: Int, cell: UICollectionViewCell) {
        guard let ip = collectionView.indexPath(for: cell) else { return }
        selectedRatingCache[ip.item] = ratingIndex

        UIView.transition(with: collectionView,
                          duration: 0.2,
                          options: .transitionCrossDissolve,
                          animations: { self.collectionView.reloadData() })
    }
}

class RubricCollectionViewCell: UICollectionViewCell, RubricCircleViewWithDescriptionDelegate {

    weak var delegate: RubricCellDelegate?

    @IBOutlet weak var circleView: RubricCircleViewWithDescription!
    @IBOutlet weak var rubricTitle: DynamicLabel!
    @IBOutlet weak var borderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentView: ChatBubbleView!
    @IBOutlet weak var commentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentViewWidthConstraint: NSLayoutConstraint!
    private static var chatBubbleTextLabelFont = UIFont.scaledNamedFont(.regular14)
    @IBOutlet weak var circleViewHeightConstraint: NSLayoutConstraint!
    private static var margin: CGFloat = 16
    @IBOutlet weak var viewLongDescriptionButton: UIButton!
    @IBOutlet weak var rubricTitleToCircleViewVerticalConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        borderHeightConstraint.constant = 1.0 / UIScreen.main.scale
        commentView.side = ChatBubbleView.Side.left
        commentView.textLabel.numberOfLines = 0
        commentView.textLabel.font = type(of: self).chatBubbleTextLabelFont
        circleView.delegate = self
    }

    func update(rubric: RubricViewModel, selectedRatingIndex: Int, courseColor: UIColor) {
        rubricTitle.text = rubric.title
        rubricTitle.accessibilityTraits = .header
        if circleView.rubric == nil {
            circleView.rubric = rubric
        }
        circleView.selectedRatingIndex = selectedRatingIndex
        circleView.courseColor = courseColor
        circleViewHeightConstraint.constant = RubricCircleViewWithDescription.computedHeight(rubric: rubric,
                                                                                             selectedRatingIndex: selectedRatingIndex,
                                                                                             maxWidth: bounds.size.width - (RubricCollectionViewCell.margin * 2)
        )
        updateLongDescription(desc: rubric.longDescription)
        updateComment(comment: rubric.comment)
        viewLongDescriptionButton.isHidden = rubric.longDescription.count == 0
    }

    func updateComment(comment: String?) {
        commentView.textLabel.text = comment
        let size = type(of: self).commentViewSize(comment: comment, containerFrame: bounds)
        commentViewHeightConstraint.constant = size.height
        commentViewWidthConstraint.constant = size.width
    }

    func updateLongDescription(desc: String?) {
        let noRubricLongDescriptionConstant: CGFloat = 10.0
        let longDescriptionExistsConstant: CGFloat = 30.0
        rubricTitleToCircleViewVerticalConstraint.constant = desc?.isEmpty ?? true ? noRubricLongDescriptionConstant : longDescriptionExistsConstant
    }

    static func computedHeight(rubric: RubricViewModel, selectedRatingIndex: Int, containerFrame: CGRect) -> CGFloat {
        let otherViewHeights: CGFloat = 80

        let circles = RubricCircleViewWithDescription.computedHeight(rubric: rubric, selectedRatingIndex: selectedRatingIndex, maxWidth: containerFrame.size.width - (margin * 2.0))
        let comment = commentViewSize(comment: rubric.comment, containerFrame: containerFrame).height
        let longDescription: CGFloat = rubric.longDescription.count == 0 ? -17 : 0
        return otherViewHeights + circles + comment + longDescription
    }

    static func commentViewSize(comment: String?, containerFrame: CGRect) -> CGSize {
        if let comment = comment, !comment.isEmpty {
            let maxLabelHeight: CGFloat = 100.0
            let margin: CGFloat = 16.0
            let horizontalMargins: CGFloat = (margin * 2.0) + (margin * 2.0)
            let verticalMargins: CGFloat = 24    //  (top + bottom margins 16, 8)
            let maxWidth: CGFloat = containerFrame.size.width - horizontalMargins
            let constraintRect = CGSize(width: maxWidth, height: maxLabelHeight)
            let size = comment.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: chatBubbleTextLabelFont], context: nil)
            let w = min( size.width + (margin * 2.0) + margin /* 1 margin since we don't extend full width */, maxWidth)
            let h = ceil(size.height) + verticalMargins
            let computedSize = CGSize(width: w, height: h)
            return computedSize
        }
        return CGSize.zero
    }

    @IBAction func actionShowLongDescription(_ sender: Any) {
        guard let delegate = self.delegate else { return }
        delegate.longDescriptionTapped(cell: self)
    }

    func selectedRatingIndexDidChange(_ selectedRatingIndex: Int) {
        delegate?.selectedRatingDidChange(ratingIndex: selectedRatingIndex, cell: self)
    }
}
