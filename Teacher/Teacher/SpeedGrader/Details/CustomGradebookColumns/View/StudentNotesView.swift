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

import Core
import SwiftUI

struct StudentNotesView: View {

    @ObservedObject private var viewModel: StudentNotesViewModel

    init(viewModel: StudentNotesViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        let title = String(localized: "Student Notes", bundle: .teacher)
        let itemCount = viewModel.entries.count > 1 ? viewModel.entries.count : nil
        InstUI.CollapsibleListSection(title: title, itemCount: itemCount) {
            VStack(spacing: InstUI.Styles.Padding.standard.rawValue) {
                ForEach(viewModel.entries) { entry in
                    StudentNotesEntryView(title: entry.title, content: entry.content)
                }
            }
            .paddingStyle(.standard)
        }
    }
}

// MARK: - Student Notes Entry

struct StudentNotesEntryView: View {
    private let title: String
    private let content: String

    init(title: String, content: String) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: InstUI.Styles.Padding.textVertical.rawValue) {
            Text(title)
                .font(.semibold16, lineHeight: .fit)
                .foregroundStyle(Color.textDarkest)
            Text(content)
                .font(.regular16, lineHeight: .fit)
                .foregroundStyle(Color.textDarkest)
        }
        .paddingStyle(.standard)
        .elevation(.cardLarge, background: .backgroundLight)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Previews

#if DEBUG

#Preview {
    InstUI.BaseScreen(state: .data) { _ in
        let interactor = CustomGradebookColumnsInteractorPreview()
        return StudentNotesView(viewModel: .init(userId: "1", interactor: interactor))
    }
}

#endif
