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

public class BookmarksViewModel: ObservableObject {
    public enum ViewModelState<T: Equatable>: Equatable {
        case loading
        case empty
        case data(T)
    }
    
    @Published public private(set) var state: ViewModelState<[BookmarkCellViewModel]> = .loading
    
    public lazy private (set) var bookmarks = env.subscribe(GetBookmarks()) { [weak self] in
        self?.bookmarksDidUpdate()
    }
    
    @Environment(\.appEnvironment) private var env
    
    public init() {}
    
    public func viewDidAppear() {
        state = .loading
        bookmarks.exhaust()
    }
    
    private func bookmarksDidUpdate() {
        let bookmarkCells = bookmarks.all.map { bookmarkModel in
            BookmarkCellViewModel(name: bookmarkModel.name!, url: bookmarkModel.url!)
        }
        if bookmarkCells.isEmpty {
            state = .empty
        } else {
            state = .data(bookmarkCells)
        }
    }
    
#if DEBUG

    init(state: ViewModelState<[BookmarkCellViewModel]>) {
        self.state = state
    }

#endif
}
