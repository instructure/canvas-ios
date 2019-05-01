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

class RubricCircleView: UIView {
    private static let w: CGFloat = 49
    private static let space: CGFloat = 10
    private var buttons: [UIButton] = []
    var rubric: RubricViewModel? {
        didSet {
            if rubric != oldValue {
                setupButtons()
            }
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
        let howManyCanFitInWidth = Int( floor( frame.size.width / (w + space) ) )
        let count = ratings.count

        var center = CGPoint(x: 0, y: 0)

        for i in 0..<count {
            let r = ratings[i]
            let selected = i == (rubric?.selectedIndex ?? 0)

            let button = DynamicButton(frame: CGRect(x: center.x, y: center.y, width: w, height: w))
            button.tag = i
            button.addTarget(self, action: #selector(actionButtonClicked(sender:)), for: .touchUpInside)
            button.layer.cornerRadius = floor( w / 2 )
            button.layer.masksToBounds = true
            let title = RubricCircleView.formatter.string(for: r) ?? ""
            button.setTitle(title, for: .normal)

            let font: UIFont
            let color: UIColor
            let bgColor: UIColor

            if selected {
                font = UIFont.scaledNamedFont(.semibold20)
                color = UIColor.white
                bgColor = Brand.shared.primary
            } else {
                font = UIFont.scaledNamedFont(.regular20Monodigit)
                color = UIColor.named(.borderDark)
                bgColor = UIColor.white
            }

            addSubview(button)
            buttons.append(button)

            button.backgroundColor = bgColor
            button.titleLabel?.font = font
            button.setTitleColor(color, for: .normal)
            button.layer.borderColor = color.cgColor
            button.layer.borderWidth = 1.0 / UIScreen.main.scale

            center.x += w + space
            if i == howManyCanFitInWidth - 1 {
                center.y += w + space
                center.x = 0
            }
        }

    }

    @objc func actionButtonClicked(sender: DynamicButton) {
        let index = sender.tag
        print("button \(index) clicked")
    }

    static func computedHeight(rubric: RubricViewModel, maxWidth: CGFloat) -> CGFloat {
        let count = CGFloat(rubric.ratings.count)
        let howManyCanFitInWidth = CGFloat( floor( maxWidth / (w + space) ) )
        let rows = CGFloat(ceil(count / howManyCanFitInWidth))
        return (rows * w) + ((rows - 1) * space)
    }
}
