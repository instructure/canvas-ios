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

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var contentStackViewWidth: NSLayoutConstraint!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyViewLabel: UILabel!
    var models: [RubricViewModel] = []
    var presenter: RubricPresenter!
    var selectedRatingCache = [Int]()
    var collectionViewDidSetupCells = false
    var rubricCells: [UIView] = []
    let margin: CGFloat = 16
    var didLayoutRubrics = false

    override func viewDidLoad() {
        super.viewDidLoad()

        emptyViewLabel.text = NSLocalizedString("There is no rubric for this assignment", comment: "")

        presenter.viewIsReady()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        contentStackViewWidth.constant = view.bounds.width - (margin * 2)
    }

//    func setupCollectionViewHeader() {
//        let headerID = String(describing: GradeCircleReusableView.self)
//        collectionView.register(GradeCircleReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerID)
//    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
//            self.collectionView.reloadData()
        }
    }

    func layoutRubrics() {
        if didLayoutRubrics { return }
        didLayoutRubrics = true

        for m in models { addModelToStackView(m) }
    }

    func addModelToStackView(_ model: RubricViewModel) {
        let spacing: CGFloat = 16

        let title = DynamicLabel(frame: CGRect.zero)
        title.text = model.title
        title.font = UIFont.scaledNamedFont(.semibold16)
        contentStackView.addArrangedSubview(title)

        if !model.longDescription.isEmpty {
            let descButton = DynamicButton(frame: CGRect.zero)
            descButton.titleLabel?.font = UIFont.scaledNamedFont(.medium14)
            descButton.setTitle("Description", for: .normal)
            descButton.setTitleColor(.red, for: .normal)
            contentStackView.addArrangedSubview(descButton)
            contentStackView.setCustomSpacing(spacing, after: descButton)

            descButton.accessibilityIdentifier = "RubricCell.descButton.\(model.id)"
        }

        contentStackView.setCustomSpacing(model.longDescription.isEmpty ? spacing : spacing / 4, after: title)

        let cirView = RubricCircleView(frame: CGRect.zero)
        cirView.rubric = model
        contentStackView.addArrangedSubview(cirView)
        cirView.pinToLeftAndRightOfSuperview()
        cirView.buttonClickDelegate = self

        contentStackView.setCustomSpacing(spacing / 2, after: cirView)

        let container = UIView(frame: CGRect.zero)
        container.layer.cornerRadius = 8
        let ratingStack = UIStackView(frame: CGRect.zero)
        ratingStack.axis = .vertical
        ratingStack.distribution = .fill
        ratingStack.alignment = .leading
        ratingStack.spacing = 0
        container.addSubview(ratingStack)
        ratingStack.pin(inside: container, leading: spacing / 2, trailing: spacing / 2, top: spacing / 2, bottom: spacing / 2)
        contentStackView.addArrangedSubview(container)
        container.pinToLeftAndRightOfSuperview()

        let ratingTitle = DynamicLabel(frame: CGRect.zero)
        ratingTitle.font = .scaledNamedFont(.semibold14)
        let ratingDesc = DynamicLabel(frame: CGRect.zero)
        ratingDesc.numberOfLines = 0
        ratingDesc.font = .scaledNamedFont(.medium12)
        ratingDesc.lineBreakMode = .byWordWrapping
        ratingStack.addArrangedSubview(ratingTitle)
        ratingStack.addArrangedSubview(ratingDesc)
        ratingTitle.text = model.rubricRatings[model.selectedIndex].desc
        ratingDesc.text = model.rubricRatings[model.selectedIndex].longDesc
        container.backgroundColor = UIColor.red.withAlphaComponent(rubricCircleViewAlphaColor)

        if !(model.comment?.isEmpty ?? true) {
            let comment = ChatBubbleView(frame: CGRect.zero)
            comment.side = .left
            comment.textLabel.text = model.comment
            comment.textLabel.font = UIFont.scaledNamedFont(.regular14)
            contentStackView.addArrangedSubview(comment)
            contentStackView.setCustomSpacing(spacing, after: comment)

            comment.textLabel.accessibilityIdentifier = "RubricCell.comment.\(model.id)"
            comment.accessibilityIdentifier = "RubricCell.commentContainer.\(model.id)"

        } else {
            contentStackView.setCustomSpacing(spacing, after: container)
        }

        let divider = DividerView(frame: CGRect.zero)
        contentStackView.addArrangedSubview(divider)
        divider.backgroundColor = UIColor.named(.borderDark)
        divider.addConstraintsWithVFL("V:[view(1)]")
        divider.pinToLeftAndRightOfSuperview()

        contentStackView.setCustomSpacing(spacing, after: divider)

        //  accessibility
        title.accessibilityTraits = .header
        title.accessibilityIdentifier = "RubricCell.title.\(model.id)"

        ratingTitle.accessibilityIdentifier = "RubricCell.ratingTitle.\(model.id)"
        ratingDesc.accessibilityIdentifier = "RubricCell.ratingDesc.\(model.id)"
    }
}

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        if presenter.assignments.first?.useRubricForGrading ?? false {
//            return CGSize(width: collectionView.frame.width, height: 156)
//        } else {
//            return CGSize.zero
//        }
//    }

//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        switch kind {
//        case UICollectionView.elementKindSectionHeader:
//            guard let assignment = presenter.assignments.first else {
//                fatalError("Invalid view type")
//            }
//            let gradeView: GradeCircleReusableView = collectionView.dequeue(ofKind: kind, for: indexPath)
//            gradeView.gradeCircleView?.update(assignment)
//            return gradeView
//        default:
//            fatalError("Unexpected element kind")
//        }
//    }

extension RubricViewController: RubricViewProtocol {
    func update(_ rubric: [RubricViewModel]) {
        showEmptyState(false)
        models = rubric
        selectedRatingCache = models.map { $0.selectedIndex }
        layoutRubrics()
    }

    func showEmptyState(_ show: Bool) {
        emptyView?.isHidden = true
    }
}

//protocol RubricCellDelegate: class {
////    func longDescriptionTapped(cell: RubricCollectionViewCell)
////    func selectedRatingDidChange(ratingIndex: Int, cell: UICollectionViewCell)
//}

extension RubricViewController: RubricCircleViewButtonDelegate {
//    func longDescriptionTapped(cell: RubricCollectionViewCell) {
//        guard let indexPath = self.collectionView.indexPath(for: cell) else {
//            return
//        }
//        let r = models[indexPath.item]
//        let vc = UINavigationController(rootViewController: RubricLongDescriptionViewController(longDescription: r.longDescription, title: r.title))
//        self.present(vc, animated: true, completion: nil)
//    }

//    func selectedRatingDidChange(ratingIndex: Int, cell: UICollectionViewCell) {
//        guard let ip = collectionView.indexPath(for: cell) else { return }
//        selectedRatingCache[ip.item] = ratingIndex

//        UIView.transition(with: collectionView,
//                          duration: 0.2,
//                          options: .transitionCrossDissolve,
//                          animations: { self.collectionView.reloadData() })
//    }

    func didClickRating(atIndex: Int) {
        print("\(atIndex)")
    }
}

/*
class RubricCollectionViewCell: UICollectionViewCell, RubricCircleViewButtonDelegate {

    weak var delegate: RubricCellDelegate?

    @IBOutlet weak var circleView: RubricCircleView!
    @IBOutlet weak var rubricTitle: DynamicLabel!
    @IBOutlet weak var ratingContainer: UIStackView!
    @IBOutlet var ratingContainerBgView: UIView!
    @IBOutlet weak var ratingTitle: DynamicLabel!
    @IBOutlet weak var ratingDescription: DynamicLabel!
    @IBOutlet weak var borderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentView: ChatBubbleView!
    @IBOutlet weak var commentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentViewWidthConstraint: NSLayoutConstraint!
    private static var chatBubbleTextLabelFont = UIFont.scaledNamedFont(.regular14)
    @IBOutlet weak var circleViewHeightConstraint: NSLayoutConstraint!
    private static var margin: CGFloat = 16
    @IBOutlet weak var viewLongDescriptionButton: UIButton!
    @IBOutlet weak var rubricTitleToCircleViewVerticalConstraint: NSLayoutConstraint!
    lazy var cellWidthConstraint: NSLayoutConstraint = {
        let width = contentView.widthAnchor.constraint(equalToConstant: bounds.size.width)
        width.isActive = true
        return width
    }()
    private var rubric: RubricViewModel?
    private var courseColor: UIColor?
    private var selectedRatingIndex: Int = 0 {
        didSet {
            updateRatingText()
        }
    }

    override func awakeFromNib() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        borderHeightConstraint.constant = 1.0 / UIScreen.main.scale
        commentView.side = ChatBubbleView.Side.left
        commentView.textLabel.numberOfLines = 0
        commentView.textLabel.font = type(of: self).chatBubbleTextLabelFont
        circleView.buttonClickDelegate = self
        viewLongDescriptionButton.setTitleColor(Brand.shared.linkColor, for: .normal)
        ratingContainerBgView?.layer.cornerRadius = 8
        ratingContainerBgView?.layer.masksToBounds = true
        clipsToBounds = false
        contentView.clipsToBounds = false
    }

    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        cellWidthConstraint.constant = bounds.size.width
        return contentView.systemLayoutSizeFitting(CGSize(width: targetSize.width, height: 1))
    }

    func update(rubric: RubricViewModel, selectedRatingIndex: Int, courseColor: UIColor) {
        self.rubric = rubric
        rubricTitle.text = rubric.title
        rubricTitle.accessibilityTraits = .header
        rubricTitle.accessibilityIdentifier = "RubricCell.title.\(rubric.id)"
        commentView.textLabel.accessibilityIdentifier = "RubricCell.comment.\(rubric.id)"
        commentView.accessibilityIdentifier = "RubricCell.commentContainer.\(rubric.id)"
        viewLongDescriptionButton.accessibilityIdentifier = "RubricCell.descButton.\(rubric.id)"
        ratingTitle.accessibilityIdentifier = "RubricCell.ratingTitle.\(rubric.id)"
        ratingDescription.accessibilityIdentifier = "RubricCell.ratingDesc.\(rubric.id)"

        if circleView.rubric == nil {
            circleView.rubric = rubric
        }

        self.selectedRatingIndex = selectedRatingIndex
        circleView.courseColor = courseColor
        ratingContainerBgView.backgroundColor = courseColor.withAlphaComponent(rubricCircleViewAlphaColor)

        updateLongDescription(desc: rubric.longDescription)
        updateComment(comment: rubric.comment)
        viewLongDescriptionButton.isHidden = rubric.longDescription.count == 0
        circleViewHeightConstraint.constant = RubricCircleView.computedHeight(rubric: rubric, maxWidth: bounds.size.width)
    }

    func updateComment(comment: String?) {
        commentView.textLabel.text = comment
        commentView.isHidden = comment?.isEmpty ?? true
        let size = type(of: self).commentViewSize(comment: comment, maxWidth: bounds.size.width)
        commentViewWidthConstraint.constant = size.width
    }

    func updateLongDescription(desc: String?) {
        viewLongDescriptionButton.isHidden = desc?.isEmpty ?? true
    }

    func updateRatingText() {
        guard let rubric = rubric else { return }
        let rating = rubric.ratingBlurb(selectedRatingIndex)
        ratingTitle?.text = rating.header
        ratingDescription?.text = rating.subHeader
        ratingDescription.isHidden = rating.subHeader.isEmpty
    }

    static func commentViewSize(comment: String?, maxWidth: CGFloat) -> CGSize {
        if let comment = comment, !comment.isEmpty {
            let maxLabelHeight: CGFloat = 100.0
            let margin: CGFloat = 16.0
            let horizontalMargins: CGFloat = (margin * 2.0) + (margin * 2.0)
            let verticalMargins: CGFloat = 24    //  (top + bottom margins 16, 8)
            let adjustedMaxWidth: CGFloat = maxWidth - horizontalMargins
            let constraintRect = CGSize(width: adjustedMaxWidth, height: maxLabelHeight)
            let size = comment.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: chatBubbleTextLabelFont], context: nil)
            let w = min( size.width + (margin * 2.0) + margin /* 1 margin since we don't extend full width */, maxWidth)
            let h = ceil(size.height) + verticalMargins
            let computedSize = CGSize(width: w, height: h)
            return computedSize
        }
        return CGSize.zero
    }

    @IBAction func actionShowLongDescription(_ sender: Any) {
//        guard let delegate = self.delegate else { return }
//        delegate.longDescriptionTapped(cell: self)
    }

    func didClickRating(atIndex: Int) {
        var newIndex = atIndex
        if selectedRatingIndex == atIndex {
            newIndex = rubric?.selectedIndex ?? 0
        }
        print("newIndex: \(newIndex)")
//        delegate?.selectedRatingDidChange(ratingIndex: newIndex, cell: self)
    }
}
*/
