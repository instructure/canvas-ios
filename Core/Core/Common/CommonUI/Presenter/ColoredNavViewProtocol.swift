//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

public protocol ColoredNavViewProtocol: AnyObject {
    var color: UIColor? { get set }
    var navigationController: UINavigationController? { get }
    var titleSubtitleView: TitleSubtitleView { get }
    var navigationItem: UINavigationItem { get }
    func updateNavBar(subtitle: String?, color: UIColor?)
    func setupTitleViewInNavbar(title: String)
}

extension ColoredNavViewProtocol {
    public func setupTitleViewInNavbar(title: String) {
        navigationItem.titleView = titleSubtitleView
        titleSubtitleView.title = title
    }

    public func updateNavBar(subtitle: String?, color: UIColor?) {
        self.color = color
        titleSubtitleView.subtitle = subtitle
        navigationController?.navigationBar.useContextColor(color)
    }
}
