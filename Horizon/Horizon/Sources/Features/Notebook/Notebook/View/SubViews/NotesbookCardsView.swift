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

import HorizonUI
import SwiftUI

struct NotesbookCardsView: View {
    enum ScreenType {
        case list
        case  moduleItem
        case course
        var isShowCourseNameVisible: Bool {
            switch self {
            case .list: return true
            case .course, .moduleItem: return false
            }
        }
    }
    // MARK: - Dependencies

    private let notes: [CourseNotebookNote]
    private let selectedNote: CourseNotebookNote?
    private let showDeleteLoader: Bool
    private let isSeeMoreButtonVisible: Bool
    private let screenType: ScreenType
    private let focusedID: AccessibilityFocusState<String?>.Binding
    private let onTapNote: (CourseNotebookNote) -> Void
    private let onTapDeleteNote: (CourseNotebookNote) -> Void
    private let onTapSeeMore: () -> Void

    // MARK: - Init
    init(
        notes: [CourseNotebookNote],
        selectedNote: CourseNotebookNote?,
        showDeleteLoader: Bool,
        isSeeMoreButtonVisible: Bool,
        screenType: ScreenType,
        focusedID: AccessibilityFocusState<String?>.Binding,
        onTapNote: @escaping (CourseNotebookNote) -> Void,
        onTapDeleteNote: @escaping (CourseNotebookNote) -> Void,
        onTapSeeMore: @escaping () -> Void
    ) {
        self.notes = notes
        self.selectedNote = selectedNote
        self.showDeleteLoader = showDeleteLoader
        self.isSeeMoreButtonVisible = isSeeMoreButtonVisible
        self.screenType = screenType
        self.focusedID = focusedID
        self.onTapNote = onTapNote
        self.onTapDeleteNote = onTapDeleteNote
        self.onTapSeeMore = onTapSeeMore
    }

    var body: some View {
        VStack(spacing: .huiSpaces.space16) {
            ForEach(notes) { note in
                Button {
                    onTapNote(note)
                } label: {
                    NoteCardsView(
                        note: note,
                        isLoading: note == selectedNote ? showDeleteLoader : false,
                        showCourseName: screenType.isShowCourseNameVisible
                    ) { deletedNote in
                        onTapDeleteNote(deletedNote)
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityRemoveTraits(.isButton)
                .accessibilityLabel(note.getAccessliblityLabel(isCourseNameVisible: screenType.isShowCourseNameVisible))
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .accessibilityFocused(focusedID, equals: note.id)
                .scrollTransition(.animated) { content, phase in
                    content
                        .scaleEffect(phase.isIdentity ? 1 : 0.9)
                }
                .accessibilityActions {
                    Button(screenType == .moduleItem ? String(localized: "Edit note") : String(localized: "Open page")) {
                        onTapNote(note)
                    }

                    Button(String(localized: "Delete note")) {
                        onTapDeleteNote(note)
                    }
                }
            }

            if isSeeMoreButtonVisible {
                seeMoreButton
            }
        }
        .padding(.bottom, .huiSpaces.space16)
    }

    private var seeMoreButton: some View {
        HorizonUI.PrimaryButton(
            String(localized: "Show more", bundle: .horizon),
            type: .whiteGrayOutline,
            isSmall: true,
            fillsWidth: true
        ) {
            onTapSeeMore()
        }
        .accessibilityLabel(String(localized: "Show more"))
        .accessibilityHint( String(localized: "Double tap to load more notes"))
    }
}
