//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

public class ActivityIndicatorButton: DynamicButton {
    public var spinner: UIActivityIndicatorView = UIActivityIndicatorView(style: .white)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        addSubview(spinner)
        spinner.pinToTopAndBottomOfSuperview()
        spinner.widthAnchor.constraint(equalToConstant: 30).isActive = true
        spinner.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        spinner.isHidden = true
        spinner.hidesWhenStopped = true
        spinner.tintColor = .named(.backgroundLightest)
    }

    public func showSpinner(_ show: Bool) {
        titleLabel?.layer.opacity = show ? 0 : 1
        spinner.isHidden = !show
        if show {
            spinner.startAnimating()
        } else {
            spinner.stopAnimating()
        }
    }
}
