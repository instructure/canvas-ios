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

import Foundation

public class BookmarksViewModel: ObservableObject {
    public enum ViewModelState<T: Equatable>: Equatable {
        case loading
        case empty
        case data(T)
    }
    
    public init() {
        
    }
    
    @Published public private(set) var state: ViewModelState<[Bookmark]> = .loading
    
    public func viewDidAppear() {
        state = .data(createFakeBookmarks())
    }
    
    func createFakeBookmarks() -> [Bookmark] {
        return [
            Bookmark(name: "1.2",url: "https://tamaskozmer.instructure.com/api/v1/courses/20781/pages/1-dot-2-|-your-canvas-dashboard?module_item_id=158421"),
            Bookmark(name: "1.5",url: "https://tamaskozmer.instructure.com/courses/20781/assignments/63418"),
            Bookmark(name: "Assignment",url: "https://tamaskozmer.instructure.com/courses/20781/assignments/87794"),
            Bookmark(name: "Profile",url: "https://tamaskozmer.instructure.com/api/v1/courses/20781/pages/1-dot-3-|-your-profile-and-settings?module_item_id=158422"),
            Bookmark(name: "Grades",url: "https://tamaskozmer.instructure.com/courses/20781/grades"),
            Bookmark(name: "Modules",url: "https://tamaskozmer.instructure.com/courses/20781/modules"),
            Bookmark(name: "Discussion",url: "https://tamaskozmer.instructure.com/courses/20781/assignments/63415")
        ]
    }
    
#if DEBUG

    init(state: ViewModelState<[Bookmark]>) {
        self.state = state
    }

#endif
}
