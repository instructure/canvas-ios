//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
