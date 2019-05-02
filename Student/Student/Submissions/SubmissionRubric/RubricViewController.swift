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
    var models: [RubricViewModel] = []
    var presenter: RubricPresenter!
    var cellHeightCache = [Int: CGFloat]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        presenter.viewIsReady()
    }

    func setupCollectionView() {
        let id = String(describing: RubricCollectionViewCell.self)
        let nib = UINib(nibName: id, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: id)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            self.cellHeightCache = [:]
            self.collectionView.reloadData()
        }
    }
}

extension RubricViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: RubricCollectionViewCell = collectionView.dequeue(for: indexPath)
        let r = models[indexPath.item]
        cell.update(r)
        cell.delegate = self
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat
        if let cached = cellHeightCache[indexPath.item] {
            height = cached
        } else {
            height = RubricCollectionViewCell.computedHeight(rubric: models[indexPath.item], containerFrame: collectionView.bounds)
        }
        return CGSize(width: view.bounds.size.width, height: height)
    }
}

extension RubricViewController: RubricViewProtocol {
    func update(_ rubric: [RubricViewModel]) {
        models = rubric
        cellHeightCache = [:]
        collectionView.reloadData()
    }

    func showEmptyState() {
        print("***** show empty state here *****")
    }
}

protocol RubricCellDelegate: class {
    func longDescriptionTapped(cell: RubricCollectionViewCell)
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
}

class RubricCollectionViewCell: UICollectionViewCell {

    weak var delegate: RubricCellDelegate?

    @IBOutlet weak var circleView: RubricCircleView!
    @IBOutlet weak var rubricTitle: DynamicLabel!
    @IBOutlet weak var selectedRatingTitle: DynamicLabel!
    @IBOutlet weak var borderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentView: ChatBubbleView!
    @IBOutlet weak var commentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentViewWidthConstraint: NSLayoutConstraint!
    private static var chatBubbleTextLabelFont = UIFont.scaledNamedFont(.regular14)
    @IBOutlet weak var circleViewHeightConstraint: NSLayoutConstraint!
    private static var margin: CGFloat = 16
    @IBOutlet weak var viewLongDescriptionButton: UIButton!
    @IBOutlet weak var viewLongDescriptionToCircleViewVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewLongDescriptionToCommentViewVerticalConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        borderHeightConstraint.constant = 1.0 / UIScreen.main.scale
        commentView.side = ChatBubbleView.Side.left
        commentView.textLabel.numberOfLines = 0
        commentView.textLabel.font = type(of: self).chatBubbleTextLabelFont
    }

    func update(_ rubric: RubricViewModel) {
        rubricTitle.text = rubric.title
        selectedRatingTitle.text = rubric.selectedDesc
        circleView.rubric = rubric
        circleViewHeightConstraint.constant = RubricCircleView.computedHeight(rubric: rubric, maxWidth: bounds.size.width - (RubricCollectionViewCell.margin * 2))
        updateComment(comment: rubric.comment)
        viewLongDescriptionButton.isHidden = rubric.longDescription.count == 0
    }

    func updateComment(comment: String?) {
        commentView.textLabel.text = comment
        let size = type(of: self).commentViewSize(comment: comment, containerFrame: bounds)
        commentViewHeightConstraint.constant = size.height
        commentViewWidthConstraint.constant = size.width

        if size.height == 0 {
            viewLongDescriptionToCircleViewVerticalConstraint.priority = UILayoutPriority.defaultHigh
            viewLongDescriptionToCommentViewVerticalConstraint.priority = UILayoutPriority.defaultLow
        } else {
            viewLongDescriptionToCircleViewVerticalConstraint.priority = UILayoutPriority.defaultLow
            viewLongDescriptionToCommentViewVerticalConstraint.priority = UILayoutPriority.defaultHigh
        }
    }

    static func computedHeight(rubric: RubricViewModel, containerFrame: CGRect) -> CGFloat {
        let spaceToCollapse: CGFloat = rubric.longDescription.count == 0 ? 16 : 0
        let otherViewHeights: CGFloat = 111 - spaceToCollapse

        let circles = RubricCircleView.computedHeight(rubric: rubric, maxWidth: containerFrame.size.width - (margin * 2.0))
        var comment = commentViewSize(comment: rubric.comment, containerFrame: containerFrame).height
        if comment > 0 { comment += 12.0 /* add extra vertical spacing for additional item */ }
        return otherViewHeights + circles + comment
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
        guard let delegate = self.delegate else {
            return
        }
        delegate.longDescriptionTapped(cell: self)
    }
}
