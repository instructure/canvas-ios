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

import SwiftUI

extension Image {
    public static let defaultIconSize: CGFloat = 24

    public func size(_ size: CGFloat?, paddedTo boundingSize: CGFloat? = nil) -> some View {
        resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .frame(width: boundingSize, height: boundingSize)
    }

    public func scaledSize(_ size: CGFloat?, paddedTo boundingSize: CGFloat? = nil) -> some View {
        resizable()
            .scaledToFill()
            .scaledFrame(size: size, useIconScale: false)
            .scaledFrame(size: boundingSize, useIconScale: false)
    }

    public func scaledIcon(size: CGFloat? = Image.defaultIconSize, paddedTo boundingSize: CGFloat? = nil) -> some View {
        resizable()
            .scaledToFill()
            .scaledFrame(size: size, useIconScale: true)
            .scaledFrame(size: boundingSize, useIconScale: true)
    }
}
