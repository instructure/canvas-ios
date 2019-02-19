//
// Copyright (C) 2018-present Instructure, Inc.
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

public protocol ColoredNavViewProtocol: class {
    var color: UIColor? { get set }
    var navigationController: UINavigationController? { get }
    var titleSubtitleView: TitleSubtitleView { get set }
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
        self.color = color?.ensureContrast(against: .named(.white))
        titleSubtitleView.subtitle = subtitle
        navigationController?.navigationBar.useContextColor(color)
    }
}
