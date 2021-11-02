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

extension UICollectionView {

    public func dequeue<T: UICollectionReusableView>(_ type: T.Type = T.self, ofKind: String, for indexPath: IndexPath) -> T {
        let name = String(describing: T.self)
        guard let view = dequeueReusableSupplementaryView(ofKind: ofKind, withReuseIdentifier: name, for: indexPath) as? T else {
            fatalError("Could not dequeue \(name) as reusable view.")
        }
        return view
    }

    /// Returns a reusable cell object.
    /// This can assume that the reuse identifier matches the type name.
    public func dequeue<T: UICollectionViewCell>(withReuseIdentifier identifier: String = String(describing: T.self), for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? T else {
            fatalError("Could not dequeue \(identifier) as reusable cell.")
        }
        return cell
    }
}
