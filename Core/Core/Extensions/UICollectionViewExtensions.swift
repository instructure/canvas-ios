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

extension UICollectionView {
    public func dequeue<T: UICollectionViewCell>(_ type: T.Type, for indexPath: IndexPath) -> T {
        let name = String(describing: T.self)
        guard let cell = dequeueReusableCell(withReuseIdentifier: name, for: indexPath) as? T else {
            fatalError("Could not dequeue \(name) as reusable cell.")
        }
        return cell
    }

    public func dequeue<T: UICollectionReusableView>(_ type: T.Type, ofKind: String, for indexPath: IndexPath) -> T {
        let name = String(describing: T.self)
        guard let view = dequeueReusableSupplementaryView(ofKind: ofKind, withReuseIdentifier: name, for: indexPath) as? T else {
            fatalError("Could not dequeue \(name) as reusable view.")
        }
        return view
    }
}
