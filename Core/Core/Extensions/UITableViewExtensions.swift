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

extension UITableView {

    public static func setupDefaultSectionHeaderTopPadding() {
        UITableView.appearance().sectionHeaderTopPadding = 0.0
    }

    /// Returns a reusable table-view cell object of the specified type and adds it to the table.
    /// This can assume that the reuse identifier matches the type name.
    public func dequeue<T: UITableViewCell>(_ type: T.Type = T.self, withID identifier: String = String(describing: T.self), for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T else {
            fatalError("Could not dequeue \(identifier) as reusable cell.")
        }
        return cell
    }

    public func dequeueHeaderFooter<T: UITableViewHeaderFooterView>(_ type: T.Type = T.self) -> T {
        guard let headerFooter = dequeueReusableHeaderFooterView(withIdentifier: String(describing: T.self)) as? T else {
            fatalError("Could not dequeue \(String(describing: T.self)) as headerFooterView.")
        }
        return headerFooter
    }

    public func registerCell<T: UITableViewCell>(_ type: T.Type) {
        register(type, forCellReuseIdentifier: String(describing: T.self))
    }

    public func registerHeaderFooterView<T: UITableViewHeaderFooterView>(_ type: T.Type, fromNib: Bool = true, bundle: Bundle = .core) {
        if fromNib {
            let nib = UINib(nibName: String(describing: T.self), bundle: bundle)
            register(nib, forHeaderFooterViewReuseIdentifier: String(describing: T.self))
        } else {
            register(type, forHeaderFooterViewReuseIdentifier: String(describing: T.self))
        }
    }
}
