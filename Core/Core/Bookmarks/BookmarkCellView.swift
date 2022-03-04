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
        Button(action: {
            env.router.route(to: bookmark.url, from: controller)
        }, label: {
            HStack(spacing: 12) {
                Image("bookmarkLine", bundle: .core)
                Text(bookmark.name)
            }
            .padding(.vertical, 13)
            .padding(.horizontal, 0)
            .fixedSize(horizontal: false, vertical: true)
            .contentShape(Rectangle())
        })
    }
}

struct BookmarkCellView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkCellView(bookmark: BookmarkCellViewModel(name: "Test", url: "url"))
    }
}
