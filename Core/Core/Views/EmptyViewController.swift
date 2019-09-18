//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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

public class EmptyViewController: UIViewController {
    var showLogo: Bool = true
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        if(showLogo) { addLogo() }
    }

    func addLogo() {
        let image = UIImage(named: "EmptyViewControllerLogo", in: .core, compatibleWith: nil)
        let logoImageview = UIImageView(image: image)

        logoImageview.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageview)

        logoImageview.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageview.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        let width = NSLayoutConstraint(item: logoImageview, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: logoImageview.superview, attribute: NSLayoutConstraint.Attribute.width, multiplier: 0.1, constant: 1.0)
        let height = NSLayoutConstraint(item: logoImageview, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: logoImageview, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 0)
        logoImageview.superview?.addConstraints([width, height])
    }
}
