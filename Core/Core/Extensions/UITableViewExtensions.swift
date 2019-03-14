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

extension UITableView {
    /// Returns a reusable table-view cell object of the specified type and adds it to the table.
    /// This can assume that the reuse identifier matches the type name.
    public func dequeue<T: UITableViewCell>(_ type: T.Type = T.self, withID identifier: String = String(describing: T.self), for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T else {
            fatalError("Could not dequeue \(identifier) as reusable cell.")
        }
        return cell
    }
}
