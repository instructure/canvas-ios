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
import HorizonUI

struct PageDetailsView: View {
    // MARK: - Private Properties

    @State private var isShowHeader: Bool = true

    // MARK: - Dependencies

    @Environment(\.viewController) private var viewController: WeakViewController
    @State private var viewModel: PageDetailsViewModel

    // MARK: - Init

    init(viewModel: PageDetailsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: .zero) {
            header
            ZStack(alignment: .top) {
                spinner
                locked
                page
                file
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .alert(isPresented: Binding(
            get: { viewModel.isErrorPresented },
            set: {
                viewModel.isErrorPresented = $0
                viewModel.close(viewController: viewController)
            }
        )) {
            Alert(
                title: Text(
                    viewModel.errorMessage ??
                    String(localized: "An error occurred while marking as done.")
                )
            )
        }
    }

    @ViewBuilder
    var file: some View {
        if let courseID = viewModel.courseID,
           let fileID = viewModel.fileID {
            FileDetailsAssembly.makeView(
                courseID: courseID,
                fileID: fileID,
                context: viewModel.context,
                fileName: ""
            )
            .id(fileID)
        }
    }

    @ViewBuilder
    var locked: some View {
        ModuleItemLockedView(
            title: String(localized: "Locked Content", bundle: .horizon),
            lockExplanation: String(localized: "This content is locked and cannot be accessed at this time.", bundle: .horizon)
        )
        .opacity(viewModel.lockedOpacity)
        .animation(.easeInOut, value: viewModel.lockedOpacity)
    }

    @ViewBuilder
    var page: some View {
        if let pageURL = viewModel.pageURL,
           let itemID = viewModel.itemID {
            ZStack(alignment: .bottomTrailing) {
                PageViewRepresentable(
                    isScrollTopReached: $isShowHeader,
                    context: viewModel.context,
                    pageURL: pageURL,
                    itemID: itemID
                )
                if let model = viewModel.markAsDoneViewModel, viewModel.isMarkedAsDoneButtonVisible {
                    MarkAsDoneButton(
                        isCompleted: model.isCompleted,
                        isLoading: model.isLoading
                    ) {
                        model.markAsDone()
                    }
                    .padding(.horizontal, .huiSpaces.space24)
                    .padding(.bottom, .huiSpaces.space16)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .preference(key: HeaderVisibilityKey.self, value: isShowHeader)
            .opacity(viewModel.bodyOpacity)
            .animation(.easeInOut, value: viewModel.bodyOpacity)
        }
    }

    @ViewBuilder
    var spinner: some View {
        HorizonUI.Spinner(size: .xSmall)
            .padding(.top, .huiSpaces.space24)
            .opacity(viewModel.loaderOpacity)
            .animation(.easeInOut, value: viewModel.loaderOpacity)
    }

    @ViewBuilder
    var header: some View {
        if viewModel.isHeaderVisible {
            VStack(alignment: .trailing, spacing: .zero) {
                HorizonUI.IconButton(
                    .huiIcons.close,
                    type: .white,
                    isSmall: true
                ) {
                    viewModel.close(viewController: viewController)
                }
            }
            .padding(.horizontal, .huiSpaces.space16)
            .padding(.vertical, .huiSpaces.space8)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.huiColors.surface.divider),
                alignment: .bottom
            )
        }
    }
}
