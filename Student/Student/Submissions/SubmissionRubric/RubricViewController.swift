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
import Core

class RubricViewController: UIViewController {

    let ratingContainerTag = 100
    let ratingTitleTag = 200
    let ratingDescTag = 300
    let circleViewTag = 400

    static func create(env: AppEnvironment = .shared, courseID: String, assignmentID: String, userID: String) -> RubricViewController {
        let controller = loadFromStoryboard()
        controller.presenter = RubricPresenter(env: env, view: controller, courseID: courseID, assignmentID: assignmentID, userID: userID)
        return controller
    }

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyViewLabel: UILabel!
    @IBOutlet weak var emptyImageView: IconView!
    var models: [RubricViewModel] = []
    var presenter: RubricPresenter!
    var collectionViewDidSetupCells = false
    var rubricCells: [UIView] = []
    let margin: CGFloat = 16
    var didLayoutRubrics = false
    var ratingViewRetrievalIndexMap: [String: Int] = [:]
    var selectedRatingCache: [String: Int] = [:]
    private let spacing: CGFloat = 16

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest

        emptyViewLabel.text = String(localized: "There is no rubric for this assignment", bundle: .student)

        emptyImageView.image = UIImage(named: Panda.NoRubric.name, in: .core, compatibleWith: nil)
        presenter.viewIsReady()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
        }
    }

    func layoutRubrics() {
        if !didLayoutRubrics {
            didLayoutRubrics = true
            addGradeHeader()
            for (i, m) in models.enumerated() { addModelToStackView(i, m) }
        } else {
            for (i, m) in models.enumerated() { updateViewsToLatestModel(i, m) }
        }
    }

    func addGradeHeader() {
        if let assignment = presenter.assignments.first, showGradeHeader() {
            let gradeCircleView = GradeCircleView(frame: CGRect.zero)
            gradeCircleView.update(assignment, submission: assignment.submission)
            contentStackView.addArrangedSubview(gradeCircleView)
            gradeCircleView.heightAnchor.constraint(equalToConstant: 156).isActive = true

            let divider = DividerView(frame: CGRect.zero)
            contentStackView.addArrangedSubview(divider)
            divider.tintColor = UIColor.borderDark
            divider.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale).isActive = true

            contentStackView.setCustomSpacing(spacing, after: divider)
        }
    }

    func showGradeHeader() -> Bool {
        if let assignment = presenter.assignments.first, assignment.useRubricForGrading {
            return assignment.useRubricForGrading
        }
        return false
    }

    func updateViewsToLatestModel(_ index: Int, _ model: RubricViewModel) {
        if let circles = view.viewWithTag(circleViewTag + index) as? RubricCircleView {
            circles.updateButtons(rubric: model)
        }
    }

    func addModelToStackView(_ index: Int, _ model: RubricViewModel) {
        let courseColor = presenter.courses.first?.color ?? Brand.shared.primary

        if !showGradeHeader() && index == 0 {
            let spacerView = UIView(frame: CGRect.zero)
            contentStackView.addArrangedSubview(spacerView)
        }

        let title = DynamicLabel(frame: CGRect.zero)
        title.text = model.title
        title.font = UIFont.scaledNamedFont(.semibold16)
        contentStackView.addArrangedSubview(title)

        if !model.longDescription.isEmpty {
            let descButton = DynamicButton(frame: CGRect.zero)
            descButton.titleLabel?.font = UIFont.scaledNamedFont(.medium14)
            descButton.setTitle("Description", for: .normal)
            descButton.setTitleColor(Brand.shared.linkColor, for: .normal)
            descButton.tag = index
            contentStackView.addArrangedSubview(descButton)
            contentStackView.setCustomSpacing(spacing, after: descButton)
            descButton.addTarget(self, action: #selector(actionDescButtonTapped(sender:)), for: .primaryActionTriggered)

            descButton.accessibilityIdentifier = "RubricCell.descButton.\(model.id)"
        }

        contentStackView.setCustomSpacing(model.longDescription.isEmpty ? spacing : spacing / 4, after: title)

        let circles = RubricCircleView(frame: CGRect.zero)
        circles.tag = circleViewTag + index
        circles.rubric = model
        circles.courseColor = courseColor
        contentStackView.addArrangedSubview(circles)
        circles.buttonClickDelegate = self

        contentStackView.setCustomSpacing(spacing / 2, after: circles)

        let container = UIView(frame: CGRect.zero)
        container.layer.cornerRadius = 8
        container.tag = ratingContainerTag + index
        let ratingStack = UIStackView(frame: CGRect.zero)
        ratingStack.axis = .vertical
        ratingStack.distribution = .fill
        ratingStack.alignment = .leading
        ratingStack.spacing = 0
        container.addSubview(ratingStack)
        ratingStack.pin(inside: container, leading: spacing / 2, trailing: spacing / 2, top: spacing / 2, bottom: spacing / 2)
        contentStackView.addArrangedSubview(container)

        ratingViewRetrievalIndexMap[model.id] = index
        let ratingTitle = DynamicLabel(frame: CGRect.zero)
        ratingTitle.tag = ratingTitleTag + index
        ratingTitle.font = .scaledNamedFont(.semibold14)
        let ratingDesc = DynamicLabel(frame: CGRect.zero)
        ratingDesc.tag = ratingDescTag + index
        ratingDesc.numberOfLines = 0
        ratingDesc.font = .scaledNamedFont(.medium12)
        ratingDesc.lineBreakMode = .byWordWrapping
        ratingStack.addArrangedSubview(ratingTitle)
        ratingStack.addArrangedSubview(ratingDesc)
        if model.onlyShowComments {
            container.isHidden = true
        } else if let index = model.selectedIndex {
            let ratingInfo = model.ratingBlurb(index)
            ratingTitle.text = ratingInfo.header
            ratingDesc.text = ratingInfo.subHeader
        } else {
            //  TODO: - hide rating blurb here
            container.isHidden = true
        }
        container.backgroundColor = courseColor.withAlphaComponent(.RubricCircle.courseColorAlpha)

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
        divider.tintColor = UIColor.borderDark
        divider.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale).isActive = true

        contentStackView.setCustomSpacing(spacing, after: divider)

        //  accessibility
        title.accessibilityTraits = .header
        title.accessibilityIdentifier = "RubricCell.title.\(model.id)"

        ratingTitle.accessibilityIdentifier = "RubricCell.ratingTitle.\(model.id)"
        ratingDesc.accessibilityIdentifier = "RubricCell.ratingDesc.\(model.id)"
    }

    @objc func actionDescButtonTapped(sender: UIButton) {
        let model = models[sender.tag]
        let descriptionViewController = RubricLongDescriptionViewController(longDescription: model.longDescription, title: model.title)
        descriptionViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: descriptionViewController)
        navigationController.modalPresentationStyle = .formSheet
        self.present(navigationController, animated: true, completion: nil)
    }
}

extension RubricViewController: CoreWebViewLinkDelegate {
    public func handleLink(_ url: URL) -> Bool {
        self.dismiss(animated: true) { [weak self] in
            guard let vc = self else {
                return
            }
            vc.presenter.show(url, from: vc)
        }
        return true
    }
}

extension RubricViewController: RubricViewProtocol {
    func update(_ rubric: [RubricViewModel]) {
        showEmptyState(false)
        models = rubric
        models.forEach { m in
            if let index = m.selectedIndex {
                selectedRatingCache[m.id] = index
            }
        }
        layoutRubrics()
    }

    func showEmptyState(_ show: Bool) {
        emptyView?.isHidden = !show
    }
}

extension RubricViewController: RubricCircleViewButtonDelegate {
    func didClickRating(atIndex: Int, rubric: RubricViewModel) {
        let i = ratingViewRetrievalIndexMap[rubric.id] ?? -1

        var newIndex: Int? = atIndex
        if let selectedRatingIndex = selectedRatingCache[rubric.id], selectedRatingIndex == atIndex {
            newIndex = rubric.selectedIndex
        }

        let container = view.viewWithTag(100 + i)
        let titleLabel = view.viewWithTag(200 + i) as? UILabel
        let descLabel = view.viewWithTag(300 + i) as? UILabel
        var titleValue: String?
        var descValue: String?

        var containerIsHidden = false

        if let newIndex = newIndex {
            selectedRatingCache[rubric.id] = newIndex

            let ratingInfo = rubric.ratingBlurb(newIndex)
            titleValue = ratingInfo.header
            descValue = ratingInfo.subHeader
            containerIsHidden = false
        } else {
            selectedRatingCache.removeValue(forKey: rubric.id)
            containerIsHidden = true
        }

        if containerIsHidden != container?.isHidden ?? true {
            UIView.animate(withDuration: 0.1675) {
                container?.isHidden = containerIsHidden
            }
        }

        titleLabel?.text = titleValue
        descLabel?.text = descValue
    }
}
