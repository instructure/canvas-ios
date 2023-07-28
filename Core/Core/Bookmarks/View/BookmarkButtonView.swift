//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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
import Combine

struct BookmarkButtonView: View {
    @StateObject private var viewModel: BookmarkButtonViewModel
    private let bookmarkTitle: String
    private let bookmarkContextName: String?

    var body: some View {
        Button {
            viewModel.bookmarkButtonDidTap(title: bookmarkTitle, contextName: bookmarkContextName)
        } label: {
            viewModel.isBookmarked ? Image.bookmarkSolid : Image.bookmarkLine
        }
        .frame(width: 44, height: 44)
        .foregroundColor(.textLightest)
        .confirmationAlert(isPresented: $viewModel.isShowingConfirmationDialog,
                           presenting: viewModel.confirmDialog)
        .animation(.default, value: viewModel.isBookmarked)
    }

    init(title: String, contextName: String?, viewModel: @escaping () -> BookmarkButtonViewModel) {
        self.bookmarkTitle = title
        self.bookmarkContextName = contextName
        self._viewModel = StateObject(wrappedValue: viewModel())
    }
}

public extension View {

    func bookmarkable(bookmarkTitle: String,
                      bookmarkContextName: String? = nil,
                      bookmarkRoute: String) -> some View {
        modifier(BookmarkButtonViewModifier(bookmarkTitle: bookmarkTitle,
                                            bookmarkContextName: bookmarkContextName,
                                            bookmarkRoute: bookmarkRoute))
    }
}

private struct BookmarkButtonViewModifier: ViewModifier {
    @StateObject private var snackBarViewModel = SnackBarViewModel()
    private let bookmarkTitle: String
    private let bookmarkContextName: String?
    private let bookmarkRoute: String

    init(bookmarkTitle: String,
         bookmarkContextName: String? = nil,
         bookmarkRoute: String) {
        self.bookmarkTitle = bookmarkTitle
        self.bookmarkContextName = bookmarkContextName
        self.bookmarkRoute = bookmarkRoute
    }

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    BookmarksAssembly.makeBookmarkButtonView(bookmarkTitle: bookmarkTitle,
                                                             bookmarkContextName: bookmarkContextName,
                                                             bookmarkRoute: bookmarkRoute,
                                                             snackBarViewModel: snackBarViewModel)
                }
            }
            .snackBar(viewModel: snackBarViewModel)
    }
}

#if DEBUG

@available(iOSApplicationExtension 16.0, *)
struct BookmarkButton_Previews: PreviewProvider {

    static var previews: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Divider().background(Color.backgroundDark)
                Spacer()
                Text(verbatim: "Content")
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .bookmarkable(bookmarkTitle: "Custom bookmark",
                          bookmarkContextName: "Course 1",
                          bookmarkRoute: "/route")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(verbatim: "Bookmarkable")
                        .foregroundColor(.textLightest)
                }
            }
        }
    }
}

#endif
