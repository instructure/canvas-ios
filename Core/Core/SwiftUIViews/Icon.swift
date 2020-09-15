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

@available(iOS 13, *)
public struct Icon: View {
    public let image: Image
    public let size: CGFloat?

    public init(_ image: Image, size: CGFloat? = 24) {
        self.image = image
        self.size = size
    }

    public var body: some View {
        image
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
    }

    public func size(_ size: CGFloat?) -> Icon {
        Icon(image, size: size)
    }
}

#if DEBUG
@available(iOS 13, *)
struct Icon_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Icon.emailSolid
            Icon.emailSolid.size(50)
            Icon.emailSolid.size(nil)
        }.padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
