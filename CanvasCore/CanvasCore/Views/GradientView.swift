//
// Copyright (C) 2017-present Instructure, Inc.
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

public class GradientView: UIView {
    public var colors: [UIColor] = [] {
        didSet {
            gradient.colors = colors.map { $0.cgColor }
        }
    }

    public var direction: (start: CGPoint, end: CGPoint) = (.zero, .zero) {
        didSet {
            gradient.startPoint = self.direction.start
            gradient.endPoint = self.direction.end
        }
    }

    fileprivate lazy var gradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        self.layer.addSublayer(gradient)

        return gradient
    }()

    override public func layoutSubviews() {
        super.layoutSubviews()

        gradient.frame = bounds
    }
}
