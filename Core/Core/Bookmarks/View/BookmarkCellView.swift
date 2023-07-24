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

import SwiftUI

struct BookmarkCellView: View {
    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var controller

    private var bookmark: BookmarkCellViewModel

    init(bookmark: BookmarkCellViewModel) {
        self.bookmark = bookmark
    }

    public var body: some View {
        Button {
            env.router.route(to: bookmark.url, from: controller)
        } label: {
            HStack(spacing: 0) {
                Image.bookmarkLine
                    .padding(.leading, 22)
                Text(bookmark.name)
                    .font(.semibold16)
                    .padding(.leading, 12)
                Spacer(minLength: 12)
                InstDisclosureIndicator()
                    .padding(.trailing, 17)
            }
            .frame(height: 52)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(.textDarkest)
            .contentShape(Rectangle())
        }
        .buttonStyle(ContextButton(contextColor: Brand.shared.primary))
    }
}

#if DEBUG

struct BookmarkCellView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.backgroundLightest
            BookmarkCellView(bookmark: BookmarkCellViewModel(name: "Test", url: "url"))
        }
    }
}

#endif
