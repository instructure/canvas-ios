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

import Foundation

@IBDesignable
class CollapsableIndicator: UIControl {
    @IBInspectable
    public var backgroundColorName: String = "backgroundDarkest" {
        didSet {
            backgroundColor = Brand.shared.color(backgroundColorName) ?? .named(.backgroundDarkest)
        }
    }

    public var isCollapsed: Bool = false {
        didSet {
            let angle: CGFloat = isCollapsed ? .pi : 0
            layer.transform = CATransform3DMakeRotation(angle, 0, 0, 1.0)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.minX, y: bounds.maxY))
        path.addLine(to: CGPoint(x: bounds.midX, y: bounds.minY))
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
        path.addLine(to: CGPoint(x: bounds.minX, y: bounds.maxY))
        path.close()

        let layer = CAShapeLayer()
        layer.path = path.cgPath

        self.layer.mask = layer
    }

    func setCollapsed(_ collapsed: Bool, animated: Bool) {
        guard animated else {
            isCollapsed = collapsed
            return
        }
        UIView.animate(withDuration: 0.5) {
            self.isCollapsed = collapsed
        }
    }
}

class ModuleSectionHeaderView: UITableViewHeaderFooterView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var publishedIconView: PublishedIconView!
    @IBOutlet weak var collapsableIndicator: CollapsableIndicator!
    @IBOutlet weak var tapGestureRecognizer: UITapGestureRecognizer!

    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }

    var published: Bool? {
        get { return publishedIconView.published }
        set { publishedIconView.published = newValue }
    }

    var onTap: (() -> Void)?

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        loadFromXib().backgroundColor = .named(.backgroundLightest)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXib().backgroundColor = .named(.backgroundLightest)
    }

    @IBAction
    func handleTap(_ sender: UITapGestureRecognizer) {
        onTap?()
    }
}
