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

let rubricCircleViewAlphaColor: CGFloat = 0.07

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
                color = UIColor.named(.backgroundLightest)
                bgColor = courseColor
                button.isSelected = true
                currentlySelectedButton = button
            } else {
                font = UIFont.scaledNamedFont(.regular20Monodigit)
                color = UIColor.named(.borderDark)
                bgColor = UIColor.named(.backgroundLightest)
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

        let sameButtonClicked: Bool = sender == currentlySelectedButton
        let buttonToAnimate = sameButtonClicked ? buttons[rubric?.selectedIndex ?? 0] : sender
        buttonToAnimate.transform = CGAffineTransform(scaleX: 0.877, y: 0.877)

        UIView.animate(withDuration: 0.2) {
            self.adjustButtonAppearance(showAsSelected: true, button: buttonToAnimate)
            self.adjustButtonAppearance(showAsSelected: false, button: self.currentlySelectedButton)
        }

        UIView.animate(withDuration: 0.2, delay: delay, usingSpringWithDamping: 0.25, initialSpringVelocity: 6.0, options: [.allowUserInteraction, .curveEaseInOut], animations: {
            self.currentlySelectedButton?.transform = CGAffineTransform.identity
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

        let bgColor = selected ? courseColor : showAsSelected ? courseColor.withAlphaComponent(rubricCircleViewAlphaColor) : UIColor.named(.backgroundLightest)
        let color = selected ? UIColor.named(.backgroundLightest) : showAsSelected ? courseColor : UIColor.named(.borderDark)

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
