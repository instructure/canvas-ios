//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

#if DEBUG

import SwiftUI

private func fontPreview() -> some View {
    VStack(alignment: .leading) {
        ForEach(UIFont.Name.allCases, id: \.rawValue) {
            Text($0.rawValue)
            Text(verbatim: "ABC Gg 123 Ű lM")
                .font(Font(UIFont.scaledNamedFont($0)))
                .padding(.bottom, 10)
        }
    }
    .previewLayout(.sizeThatFits)
}

struct BalsamiqFont_Previews: PreviewProvider {

    static var previews: some View {
        // swiftlint:disable:next redundant_discardable_let
        let _ = K5Preview.setupK5Mode()

        fontPreview()
    }
}

struct LatoFont_Previews: PreviewProvider {

    static var previews: some View {
        // swiftlint:disable:next redundant_discardable_let
        let _ = K5Preview.tearDownK5Mode()

        fontPreview()
    }
}

#endif
