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

protocol RubricCircleViewButtonDelegate: class {
    func didClickRating(atIndex: Int)
}

protocol RubricCircleViewWithDescriptionDelegate: class {
    func selectedRatingIndexDidChange(_ selectedRatingIndex: Int)
}

let rubricCircleViewAlphaColor: CGFloat = 0.07

class RubricCircleViewWithDescription: UIView, RubricCircleViewButtonDelegate {
    private var circleView: RubricCircleView?
    private var header: DynamicLabel?
    private var subHeader: DynamicLabel?
    private var headerContainer: UIView?
    private var circleViewHeightConstraint: NSLayoutConstraint?
    private var subHeaderHeightConstraint: NSLayoutConstraint?
    private var headerContainerHeightConstraint: NSLayoutConstraint?
    private static let subHeaderFont = UIFont.scaledNamedFont(.medium14)
    private static let margin: CGFloat = 8.0
    var selectedRatingIndex: Int = 0 {
        didSet {
            let blurb = ratingBlurb(selectedRatingIndex)
            header?.text = blurb.header
            subHeader?.text = blurb.subHeader
            updateHeights()
        }
    }
    var rubric: RubricViewModel? {
        didSet {
            circleView?.rubric = rubric
//            selectedRatingIndex = rubric?.selectedIndex ?? 0
        }
    }
    var courseColor: UIColor = UIColor.red
    weak var delegate: RubricCircleViewWithDescriptionDelegate?

    override func layoutSubviews() {
        super.layoutSubviews()
        setup()

        if let rubric = rubric {
            circleViewHeightConstraint?.constant = RubricCircleView.computedHeight(rubric: rubric, maxWidth: bounds.size.width)
        }
    }

    func setup() {
        if circleView == nil {
            circleView = RubricCircleView(frame: CGRect.zero)
            circleView?.rubric = rubric
            circleView?.courseColor = courseColor
            circleView?.buttonClickDelegate = self
            addSubview(circleView!)
            circleView?.pinToLeftAndRightOfSuperview()
            circleView?.addConstraintsWithVFL("V:|[view]", views: nil, metrics: nil)
            circleViewHeightConstraint = circleView?.addConstraintsWithVFL("V:[view(50)]", views: nil, metrics: nil)?.first
        }

        if headerContainer == nil {
            let margin = RubricCircleViewWithDescription.margin
            let verticalMarginMetrics = ["margin": margin / 2]
            let horizontalMarginMetrics = ["margin": margin]

            headerContainer = UIView(frame: CGRect.zero)
            addSubview(headerContainer!)
            headerContainer?.pinToLeftAndRightOfSuperview()
            guard let circleView = circleView else { return }
            headerContainer?.addConstraintsWithVFL("V:[circles]-(circleViewSpace)-[view]", views: ["circles": circleView], metrics: ["circleViewSpace": RubricCircleView.space])
            headerContainerHeightConstraint = headerContainer?.addConstraintsWithVFL("V:[view(70)]")?.first
            headerContainer?.layer.cornerRadius = 8
            headerContainer?.layer.masksToBounds = true

            guard let container = headerContainer else { return }

            header = DynamicLabel(frame: CGRect.zero)
            header?.font = UIFont.scaledNamedFont(.semibold14)
            container.addSubview(header!)
            header?.addConstraintsWithVFL("H:|-(margin)-[view]-(margin)-|", metrics: horizontalMarginMetrics)
            header?.addConstraintsWithVFL("V:|-(margin)-[view(21)]", metrics: verticalMarginMetrics)

            subHeader = DynamicLabel(frame: CGRect.zero)
            subHeader?.numberOfLines = 0
            subHeader?.font = RubricCircleViewWithDescription.subHeaderFont
            container.addSubview(subHeader!)
            subHeader?.addConstraintsWithVFL("H:|-(margin)-[view]-(margin)-|", metrics: horizontalMarginMetrics)
            subHeader?.addConstraintsWithVFL("V:[header]-(margin)-[view]", views: ["header": header!], metrics: ["margin": 1])
            subHeaderHeightConstraint = subHeader?.addConstraintsWithVFL("V:[view(21)]")?.first

            container.backgroundColor = courseColor.withAlphaComponent(rubricCircleViewAlphaColor)

            if let rubric = rubric {
                didClickRating(atIndex: rubric.selectedIndex)
            }
        }
    }

    func updateHeights() {
        guard let rubric = rubric else { return }
        if !rubricIsCustomGrade() && selectedRatingIndex >= rubric.rubricRatings.count { return }
        let subHeader = rubricIsCustomGrade() ? "" : ratingBlurb(selectedRatingIndex).subHeader
        let subHeaderHeight = ceil(RubricCircleViewWithDescription.subHeaderSize(text: subHeader, maxWidth: frame.size.width).height)
        subHeaderHeightConstraint?.constant = subHeaderHeight
        headerContainerHeightConstraint?.constant = ceil(RubricCircleViewWithDescription.computedTextContainerHeight(selectedRatingIndex: selectedRatingIndex,
                                                                                                                    rubric: rubric,
                                                                                                                     maxWidth: frame.size.width))
    }

    func didClickRating(atIndex: Int) {
        var newIndex = atIndex
        if selectedRatingIndex == atIndex {
            newIndex = rubric?.selectedIndex ?? 0
        }

        selectedRatingIndex = newIndex

        updateHeights()
        delegate?.selectedRatingIndexDidChange(newIndex)
    }

    // MARK: - Static measurment helpers

    static func computedHeight(rubric: RubricViewModel, selectedRatingIndex: Int, maxWidth: CGFloat) -> CGFloat {
        let circles = RubricCircleView.computedHeight(rubric: rubric, maxWidth: maxWidth)
        let space: CGFloat = 10
        let textContainerHeight = RubricCircleViewWithDescription.computedTextContainerHeight(selectedRatingIndex: selectedRatingIndex, rubric: rubric, maxWidth: maxWidth)
        let r = textContainerHeight + (space * 2) + circles
        return r
    }

    static func subHeaderSize(text: String?, maxWidth: CGFloat) -> CGSize {
        if let text = text, !text.isEmpty {
            let margin: CGFloat = 8
            let maxLabelHeight: CGFloat = 100.0
            let horizontalMargins: CGFloat = (margin * 2.0)
            let maxWidth: CGFloat = maxWidth - horizontalMargins
            let constraintRect = CGSize(width: maxWidth, height: maxLabelHeight)
            let size = text.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: subHeaderFont], context: nil)
            let h = ceil(size.height) //+ verticalMargins
            let computedSize = CGSize(width: size.width, height: h)
            return computedSize
        }
        return CGSize.zero
    }

    static func computedTextContainerHeight(selectedRatingIndex: Int, rubric: RubricViewModel, maxWidth: CGFloat) -> CGFloat {
        if selectedRatingIndex >= rubric.rubricRatings.count { return 0 }
        let rating = rubric.rubricRatings[selectedRatingIndex]
        let header = rating.desc
        let subHeader = rating.longDesc

        let headerHeight: CGFloat = header.isEmpty ? 0 : 21
        let subHeaderHeight = ceil(RubricCircleViewWithDescription.subHeaderSize(text: subHeader, maxWidth: maxWidth).height)
        var h = headerHeight + subHeaderHeight

        if h > 0 {
            if subHeaderHeight > 0 { h += (margin / 2) }
            h += (margin)
        }
        return h
    }

    // MARK: - Helpers

    func rubricIsCustomGrade() -> Bool {
        guard let rubric = rubric else { return false }
        return rubric.rubricRatings.count < rubric.ratings.count
    }

    func ratingBlurb(_ atIndex: Int) -> (header: String, subHeader: String) {
        guard let rubric = rubric else { return ("", "") }
        if atIndex >= rubric.rubricRatings.count { return ("", "") }
        let header = rubric.rubricRatings[atIndex].desc
        let subHeader = rubric.rubricRatings[atIndex].longDesc
        return (header, subHeader)
    }
}

class RubricCircleView: UIView {
    private static let w: CGFloat = 49
    fileprivate static let space: CGFloat = 10
    private var buttons: [UIButton] = []
    var rubric: RubricViewModel?
    weak var buttonClickDelegate: RubricCircleViewButtonDelegate?
    var courseColor: UIColor = UIColor.red
    private var currentlySelectedButton: UIButton?
    private var selectedButtonTransform = CGAffineTransform(scaleX: 1.135, y: 1.135)

    override func layoutSubviews() {
        super.layoutSubviews()
        if buttons.count == 0 {
            setupButtons()
        }
    }

    private static var formatter: NumberFormatter = {
        var formatter = NumberFormatter()
        formatter.roundingIncrement = 0.01
        formatter.numberStyle = .decimal
        return formatter
    }()

    func setupButtons() {
        //  remove old buttons
        buttons.forEach { $0.removeFromSuperview() }
        buttons = []

        let w = RubricCircleView.w
        let space: CGFloat = 10
        let ratings: [Double] = rubric?.ratings ?? []
        let descriptions: [String] = rubric?.descriptions ?? []
        let howManyCanFitInWidth = Int( floor( frame.size.width / (w + space) ) )
        let count = ratings.count

        var center = CGPoint(x: 0, y: 0)

        for i in 0..<count {
            let r = ratings[i]
            let description = descriptions[i]
            let selected = i == (rubric?.selectedIndex ?? 0)

            let button = DynamicButton(frame: CGRect(x: center.x, y: center.y, width: w, height: w))
            button.tag = i
            button.addTarget(self, action: #selector(actionButtonClicked(sender:)), for: .primaryActionTriggered)
            button.layer.cornerRadius = floor( w / 2 )
            button.layer.masksToBounds = true
            let title = RubricCircleView.formatter.string(for: r) ?? ""
            button.setTitle(title, for: .normal)

            let font: UIFont
            let color: UIColor
            let bgColor: UIColor
            let format = NSLocalizedString("g_points", bundle: .core, comment: "")
            var a11yLabel: String = String.localizedStringWithFormat(format, Int(r))
            a11yLabel += " " + description

            if selected {
                font = UIFont.scaledNamedFont(.semibold20)
                color = UIColor.white
                bgColor = courseColor
                button.isSelected = true
                currentlySelectedButton = button
            } else {
                font = UIFont.scaledNamedFont(.regular20Monodigit)
                color = UIColor.named(.borderDark)
                bgColor = UIColor.white
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

            center.x += w + space
            if i == howManyCanFitInWidth - 1 {
                center.y += w + space
                center.x = 0
            }
        }
    }

    @objc func actionButtonClicked(sender: DynamicButton) {
        animateButtonClick(sender: sender) {
            self.buttonClickDelegate?.didClickRating(atIndex: sender.tag)
        }
    }

    func animateButtonClick(sender: DynamicButton, completionHandler: @escaping () -> Void) {
        let delay = 0.0

        adjustButtonAppearance(showAsSelected: false, button: currentlySelectedButton)

        let sameButtonClicked: Bool = sender == currentlySelectedButton
        let buttonToAnimate = sameButtonClicked ? buttons[rubric?.selectedIndex ?? 0] : sender
        buttonToAnimate.transform = CGAffineTransform(scaleX: 0.877, y: 0.877)

        UIView.animate(withDuration: 0.2, delay: delay, options: [], animations: {
            self.adjustButtonAppearance(showAsSelected: true, button: buttonToAnimate)
        }, completion: nil)

        UIView.animate(withDuration: 0.2, delay: delay, usingSpringWithDamping: 0.25, initialSpringVelocity: 6.0, options: [.allowUserInteraction, .curveEaseInOut], animations: {
            buttonToAnimate.transform = self.selectedButtonTransform
        }, completion: { _ in
            self.currentlySelectedButton = buttonToAnimate
            completionHandler()
        })
    }

    func adjustButtonAppearance(showAsSelected: Bool, button: UIButton?) {
        guard let button = button else { return }
        let selected = button.tag == (rubric?.selectedIndex ?? 0)

        if !showAsSelected { button.transform = CGAffineTransform.identity }

        let bgColor = selected ? courseColor : showAsSelected ? courseColor.withAlphaComponent(rubricCircleViewAlphaColor) : UIColor.white
        let color = selected ?  UIColor.white : showAsSelected ? courseColor : UIColor.named(.borderDark)

        button.backgroundColor = bgColor
        button.setTitleColor(color, for: .normal)
        button.layer.borderColor = color.cgColor
    }

    static func computedHeight(rubric: RubricViewModel, maxWidth: CGFloat) -> CGFloat {
        let count = CGFloat(rubric.ratings.count)
        let howManyCanFitInWidth = CGFloat( floor( maxWidth / (w + space) ) )
        let rows = CGFloat(ceil(count / howManyCanFitInWidth))
        return (rows * w) + ((rows - 1) * space)
    }
}
