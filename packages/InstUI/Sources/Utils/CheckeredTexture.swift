//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import SwiftUI
import UIKit

extension Image {
    static let checkeredTile: Image = {
        let tileSize: CGFloat = 6
        let size = CGSize(width: tileSize * 2, height: tileSize * 2)
        let uiImage = UIGraphicsImageRenderer(size: size).image { _ in
            UIColor.white.setFill()
            UIRectFill(CGRect(x: 0, y: 0, width: tileSize, height: tileSize))
            UIRectFill(CGRect(x: tileSize, y: tileSize, width: tileSize, height: tileSize))
            UIColor(white: 0.88, alpha: 1).setFill()
            UIRectFill(CGRect(x: tileSize, y: 0, width: tileSize, height: tileSize))
            UIRectFill(CGRect(x: 0, y: tileSize, width: tileSize, height: tileSize))
        }
        return Image(uiImage: uiImage)
    }()
}
