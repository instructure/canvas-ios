//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Combine

struct NoteCardListState {
    // Loader
    var isLoaderVisible = true
    var isDeletedNoteLoaderVisible: Bool = true
    // Visiablity
    var isSeeMoreButtonVisible: Bool = false
    var isShowfilterView: Bool = true
    var isPresentedErrorToast: Bool = false
    var isPresentedSuccessToast: Bool = false
    // When dismiss the edit note view, we need to restore the accessibility focus to the note card list.
    var restoreAccessibility = PassthroughSubject<Void, Never>()
    /// This flag determines whether pagination should be reset when fetching notes after deleting a note.
    /// We set `keepObserving = true` to observe changes in real time. Without this flag,
    /// deleting a note would reset the pagination unexpectedly.
    var shouldReset = true
    // Animations
    var isNoteDeleted: Bool = true
    // Values
    var errorMessage = ""
    var successMessage = ""
    var selectedCourse: DropdownMenuItem?
    var selectedLable: DropdownMenuItem?
}
