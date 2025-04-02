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

protocol RubricCircleViewButtonDelegate: AnyObject {
    func didClickRating(atIndex: Int, rubric: RubricViewModel)
}

let rubricCircleViewAlphaColor: CGFloat = 0.07

class RubricCircleView: UIView {
    private static let w: CGFloat = 49
    fileprivate static let space: CGFloat = 10
    fileprivate static let stringPadding = "      "
    private var buttons: [UIButton] = []
    var rubric: RubricViewModel?
    weak var buttonClickDelegate: RubricCircleViewButtonDelegate?
    var courseColor: UIColor = UIColor.red
    private var currentlySelectedButton: UIButton?
    private var selectedButtonTransform = CGAffineTransform(scaleX: 1.135, y: 1.135)
    var heightConstraint: NSLayoutConstraint?
    var buttonsDidLayout = false

    override func layoutSubviews() {
        super.layoutSubviews()
        if buttons.count == 0 {
            setupButtons()
            buttonsDidLayout = true
        }
    }

    private static var formatter: NumberFormatter = {
        var formatter = NumberFormatter()
        formatter.roundingIncrement = 0.01
        formatter.numberStyle = .decimal
        return formatter
    }()

    private func setupButtons() {
        //  remove old buttons
        buttons.forEach { $0.removeFromSuperview() }
        if rubric?.onlyShowComments == true { return }

        buttons = []

        let space: CGFloat = RubricCircleView.space
        let ratings: [Double] = rubric?.ratings ?? []
        let rubricID: String = rubric?.id ?? "0"
        let descriptions: [String] = rubric?.descriptions ?? []
        let count = ratings.count

        var center = CGPoint(x: 0, y: 0)
        var runningWidthTotal: CGFloat = 0.0
        var rows: CGFloat = 0.0

        for i in 0..<count {
            let r = ratings[i]
            let description = descriptions[i]

            var selected = false
            if let index = rubric?.selectedIndex, i == index { selected = true }

            let font: UIFont
            let color: UIColor
            let bgColor: UIColor
            let format = String(localized: "g_points", bundle: .core)
            var a11yLabel: String = String.localizedStringWithFormat(format, Double(Int(r)))
            a11yLabel += " " + description

            if selected {
                font = UIFont.scaledNamedFont(.semibold20)
                color = UIColor.backgroundLightest
                bgColor = courseColor
            } else {
                font = UIFont.scaledNamedFont(.regular20Monodigit)
                color = UIColor.borderDark
                bgColor = UIColor.backgroundLightest
            }

            let title = (rubric?.hideRubricPoints ?? false) ? (rubric?.rubricRatings[i].desc ?? "-") + RubricCircleView.stringPadding : RubricCircleView.formatter.string(for: r) ?? ""
            let size = title.size(withAttributes: [NSAttributedString.Key.font: UIFont.scaledNamedFont(.regular20Monodigit)])
            let circleWidth = ceil( max( RubricCircleView.w, size.width ) )

            runningWidthTotal += circleWidth + space
            if runningWidthTotal >= (frame.size.width - (space * 2) ) {
                rows += 1
                runningWidthTotal = 0
                center.y += RubricCircleView.w + space
                center.x = 0
            }
            let button = DynamicButton(frame: CGRect(x: center.x, y: center.y, width: circleWidth, height: RubricCircleView.w))
            button.tag = i
            button.isExclusiveTouch = true
            button.accessibilityIdentifier = "RubricCell.RatingButton.\(rubricID)-\(r)"
            button.addTarget(self, action: #selector(actionButtonClicked(sender:)), for: .primaryActionTriggered)
            button.layer.cornerRadius = floor( RubricCircleView.w / 2 )
            button.layer.masksToBounds = true
            button.setTitle(title, for: .normal)
            button.titleLabel?.textAlignment = .center

            if selected {
                button.isSelected = selected
                currentlySelectedButton = button
            }

            addSubview(button)
            buttons.append(button)

            // Pretend to be a label in VO
            button.accessibilityTraits = button.isSelected ? [.selected, .staticText] : .staticText

            button.backgroundColor = bgColor
            button.titleLabel?.font = font
            button.setTitleColor(color, for: .normal)
            button.layer.borderColor = color.cgColor
            button.layer.borderWidth = 1.0
            button.accessibilityLabel = a11yLabel
            if selected { button.transform = selectedButtonTransform }

            center.x += circleWidth + space
        }

        //  this is not the best form to have a view control it's own sizing,
        //  better for parent view to do this, but this view does not take advantage
        //  of autolayout constraints so.......😬 here goes anyway
        if let rubric = rubric, heightConstraint == nil {
            let h = RubricCircleView.computedHeight(rubric: rubric, maxWidth: frame.size.width)
            addConstraintsWithVFL("V:[view(h)]", metrics: ["h": h])
        }

        subscribeForTraitChanges()
    }

    var isAnimating = false
    @objc func actionButtonClicked(sender: DynamicButton) {
        if isAnimating { return }
        isAnimating = true
        animateButtonClick(sender: sender) { [weak self] in
            guard let rubric = self?.rubric else { return }
            self?.buttonClickDelegate?.didClickRating(atIndex: sender.tag, rubric: rubric)
            self?.isAnimating = false
        }
    }

    func animateButtonClick(sender: DynamicButton, completionHandler: @escaping () -> Void) {
        let delay = 0.05

        let sameButtonClicked: Bool = sender == currentlySelectedButton
        let buttonToAnimate: UIButton?
        if let defaultIndex = rubric?.selectedIndex {
            buttonToAnimate = sameButtonClicked ? buttons[defaultIndex] : sender
        } else {
            buttonToAnimate = sameButtonClicked ? nil : sender
        }

        buttonToAnimate?.transform = CGAffineTransform(scaleX: 0.877, y: 0.877)

        UIView.animate(withDuration: 0.2) {
            self.adjustButtonAppearance(showAsSelected: true, button: buttonToAnimate)
            self.adjustButtonAppearance(showAsSelected: false, button: self.currentlySelectedButton)
        }

        UIView.animate(withDuration: 0.2, delay: delay, usingSpringWithDamping: 0.25, initialSpringVelocity: 6.0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
            self.currentlySelectedButton?.transform = CGAffineTransform.identity
            buttonToAnimate?.transform = self.selectedButtonTransform
        }, completion: { _ in
            self.updateAccesibilityOnSelectedButton(previous: self.currentlySelectedButton, next: buttonToAnimate)
            self.currentlySelectedButton = buttonToAnimate
            completionHandler()
        })
    }

    func updateAccesibilityOnSelectedButton(previous: UIButton?, next: UIButton?) {
        var defaultSelectedButton: UIButton?
        if var defaultSelectedIndex = rubric?.selectedIndex {
            if rubric?.isCustomAssessment == true && buttons.count > 0 { defaultSelectedIndex = buttons.count - 1 }
            defaultSelectedButton = buttons[defaultSelectedIndex]
        }
        previous?.accessibilityTraits = previous == defaultSelectedButton ? [.selected, .staticText] : .staticText
        next?.accessibilityTraits = [.selected, .staticText]
    }

    func updateButtons(rubric: RubricViewModel) {
        self.rubric = rubric
        if rubric.isCustomAssessment {}
        if let defaultIndex = rubric.selectedIndex,
            defaultIndex < buttons.count,
            let button = buttons[defaultIndex] as? DynamicButton,
            currentlySelectedButton == nil {
            actionButtonClicked(sender: button)
        }
    }

    func adjustButtonAppearance(showAsSelected: Bool, button: UIButton?) {
        guard let button = button else { return }
        var selected = false
        if let assessmentIndex = rubric?.selectedIndex {
            selected = button.tag == assessmentIndex
        }

        if !showAsSelected { button.transform = CGAffineTransform.identity }

        let bgColor = selected ? courseColor : showAsSelected ? courseColor.withAlphaComponent(rubricCircleViewAlphaColor) : UIColor.backgroundLightest
        let color = selected ? UIColor.backgroundLightest : showAsSelected ? courseColor : UIColor.borderDark

        button.backgroundColor = bgColor
        button.setTitleColor(color, for: .normal)
        button.layer.borderColor = color.cgColor
    }

    private static func computedHeight(rubric: RubricViewModel, maxWidth: CGFloat) -> CGFloat {
        let count = CGFloat(rubric.ratings.count)
        let howManyCanFitInWidth = CGFloat( ceil( maxWidth / (w + space) ) )
        if howManyCanFitInWidth == 0 { return 0 }
        let rows = CGFloat(ceil(count / howManyCanFitInWidth))
        //  If both hideRubricPoints and freeFormCriterionComments are set,
        //  circle view should not be visible. Only comments should show of rubric.
        if rubric.onlyShowComments { return 0 }
        if rubric.hideRubricPoints { return hidePointsHeight(rubric: rubric, maxWidth: maxWidth) }
        return (rows * w) + ((rows - 1) * space)
    }

    /**
    When `hideRubricPoints` is set on the rubric view model, then we measure the each button circle by the size of the
    text vs a strict height of 49 ( private static let w: CGFloat = 49 ) which is used for a numeric score.
    - Parameter rubric: view model
    - Parameter maxWidth: max width
    - Returns: CGFloat  height of circlview to be used for all view height computation.
    */
    private static func hidePointsHeight(rubric: RubricViewModel, maxWidth: CGFloat) -> CGFloat {
        guard rubric.hideRubricPoints else { return 0.0 }
        var rows: CGFloat = 1
        var total: CGFloat = 0.0
        rubric.rubricRatings.forEach { r in
            let str = r.desc + stringPadding
            let fontAttributes = [NSAttributedString.Key.font: UIFont.scaledNamedFont(.regular20Monodigit)]
            let size = str.size(withAttributes: fontAttributes)
            let width = ceil( max(w, size.width) )
            total += ceil( width ) + space
            if total >= ( maxWidth - (space * 2) ) {
                rows += 1
                total = 0
            }
        }
        return (rows * w) + ((rows - 1) * space)
    }

    private func subscribeForTraitChanges() {
        let traits = [UITraitUserInterfaceStyle.self]
        registerForTraitChanges(traits) { (self: Self, _) in
            if self.buttonsDidLayout {
                self.setupButtons()
            }
        }
    }
}
