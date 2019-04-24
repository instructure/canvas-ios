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
    var rubric: RubricViewModel? {
        didSet {
            setNeedsDisplay()
        }
    }

    private static var formatter: NumberFormatter = {
        var formatter = NumberFormatter()
        formatter.roundingIncrement = 0.01
        formatter.numberStyle = .decimal
        return formatter
    }()

    static func computedHeight(rubric: RubricViewModel, maxWidth: CGFloat) -> CGFloat {
        let count = CGFloat(rubric.ratings.count)
        let howManyCanFitInWidth = CGFloat( floor( maxWidth / (w + space) ) )
        let rows = CGFloat(ceil(count / howManyCanFitInWidth))
        return (rows * w) + ((rows - 1) * space)
    }

    override func draw(_ rect: CGRect) {
        let w = RubricCircleView.w
        let space: CGFloat = 10
        let ratings: [Double] = rubric?.ratings ?? []
        let howManyCanFitInWidth = Int( floor( rect.size.width / (w + space) ) )
        let count = ratings.count

        let ctx = UIGraphicsGetCurrentContext()
        var center = CGPoint(x: w / 2, y: w / 2)

        for i in 0..<count {
            let r = ratings[i]
            let selected = i == (rubric?.selectedIndex ?? 0)

            let font: UIFont
            let color: UIColor
            let strokeColor: UIColor
            let bgColor: UIColor

            if selected {
                font = UIFont.scaledNamedFont(.semibold20)
                color = UIColor.white
                strokeColor = UIColor.blue
                bgColor = Brand.shared.buttonPrimaryBackground
            } else {
                font = UIFont.scaledNamedFont(.regular20Monodigit)
                color = UIColor.named(.borderDark)
                strokeColor = color
                bgColor = UIColor.white
            }

            ctx?.setLineWidth(1.0 / UIScreen.main.scale)
            ctx?.setStrokeColor(strokeColor.cgColor)
            ctx?.setFillColor(bgColor.cgColor)

            ctx?.addArc(center: center, radius: w / 2, startAngle: 0.0, endAngle: CGFloat(.pi * 2.0), clockwise: true)
            if selected {
                ctx?.drawPath(using: .fill)
            } else {
                ctx?.strokePath()
            }

            ctx?.saveGState()

            if let ctx = ctx {
                let half: CGFloat = (w / 2.0)
                let boundingRect = CGRect(x: center.x - half, y: center.y - half, width: w, height: w)
                let text = RubricCircleView.formatter.string(for: r) ?? ""
                let attr = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: UIColor.blue]
                let textRect = text.boundingRect(with: boundingRect.size, options: .usesLineFragmentOrigin, attributes: attr, context: nil)
                let string = NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: color])
                let textCenter = CGPoint(x: boundingRect.origin.x + ((boundingRect.size.width - textRect.size.width) / 2.0),
                                         y: boundingRect.origin.y + ((boundingRect.size.height - textRect.size.height) / 2.0))
                UIGraphicsPushContext(ctx)
                string.draw(at: textCenter)
                UIGraphicsPopContext()
            }

            center.x += w + space
            if i == howManyCanFitInWidth - 1 {
                center.y += w + space
                center.x = w / 2
            }
        }
    }
}
