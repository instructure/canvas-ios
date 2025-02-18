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

import SwiftUI
import Core

public struct ParentInboxCoursePickerView: View {
    @ObservedObject private var viewModel: ParentInboxCoursePickerViewModel
    @Environment(\.viewController) private var controller

    init(viewModel: ParentInboxCoursePickerViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Choose a course to message", bundle: .core)
                    .font(.regular16)
                    .foregroundColor(.textDark)

                switch(viewModel.state) {
                case .data:
                    contentView
                case .empty:
                    emptyView
                case .error:
                    errorView
                case .loading:
                    loadingView
                }

            }
            .frame(maxWidth: .infinity)
            .padding(.all, 12)
        }
    }

    private var contentView: some View {
        ForEach(viewModel.items, id: \.self) { item in
            Button {
                viewModel.didTapContext.accept((controller, item))
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.course.name ?? "")
                            .font(.regular16)
                            .foregroundColor(.textDarkest)

                        Text(item.studentDisplayName)
                            .font(.regular14)
                            .foregroundColor(.textDark)

                    }
                    Spacer()
                }
            }
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity)
        }
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
            Spacer()
        }.frame(maxWidth: .infinity)
    }

    private var errorView: some View {
        VStack {
            Spacer()
            Text("Failed to load courses", bundle: .core)
            Button {
                viewModel.didTapRefresh.accept(())
            } label: {
                Text("Retry", bundle: .core)
                    .foregroundColor(.textInfo)
            }
            Spacer()
        }.frame(maxWidth: .infinity)
    }

    private var emptyView: some View {
        VStack {
            Spacer()
            Text("No courses found", bundle: .core)
            Button {
                viewModel.didTapRefresh.accept(())
            } label: {
                Text("Retry", bundle: .core)
                    .foregroundColor(.textInfo)
            }
            Spacer()
        }.frame(maxWidth: .infinity)
    }
}

#if DEBUG

struct ParentInboxCoursePickerView_Previews: PreviewProvider {
    static let env = PreviewEnvironment()

    static var previews: some View {
        ParentInboxCoursePickerAssembly.makePreview(env: env)
    }
}

#endif
