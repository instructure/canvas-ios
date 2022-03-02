//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

struct AccessIcon: View {

    private var published: Bool?
    private var image: UIImage

    public init(image: UIImage, published: Bool?) {
        self.image = image
        self.published = published
    }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(uiImage: image).size(24)
            if let published = published {
                if published {
                    Image(uiImage: .publishSolid).size(16).offset(x: 4, y: 4)
                        .foregroundColor(Color.textSuccess)
                } else {
                    Image.noSolid.size(16).offset(x: 4, y: 4)
                        .foregroundColor(Color.textDark)
                        .background(Circle().fill(Color.backgroundLightest).frame(width: 12, height: 12).offset(x: 4, y: 4))
                }
            }
        }
    }
}

#if DEBUG
struct AccessIcon_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            AccessIcon(image: .assignmentLine, published: nil)
            AccessIcon(image: .discussionLine, published: true)
            AccessIcon(image: .quizLine, published: false)
        }
    }
}
#endif
