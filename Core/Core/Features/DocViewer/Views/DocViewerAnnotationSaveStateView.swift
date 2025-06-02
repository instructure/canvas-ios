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

struct DocViewerAnnotationSaveStateView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ObservedObject private var viewModel: DocViewerAnnotationToolbarViewModel

    init(
        viewModel: DocViewerAnnotationToolbarViewModel,
    ) {
        self.viewModel = viewModel
    }

    var body: some View {
        Button {
            if viewModel.saveState == .error {
                viewModel.didTapRetry.send(())
            }
        } label: {
            HStack(spacing: 0) {
                viewModel.saveState.icon
                    .scaledIcon(size: 12)
                    .padding(.trailing, 3)
                Text(viewModel.saveState.text)
                    .font(.regular12, lineHeight: .fit)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .id(viewModel.saveState) // This will trigger a transition animation when the state changes
            .transition(.push(from: .bottom))
        }
        .background(Color.backgroundLightest)
        .foregroundStyle(viewModel.saveState.foregroundColor)
        .clipped()
        .disabled(!viewModel.saveState.isTapToRetryActionEnabled)
        .animation(.default, value: viewModel.saveState)
        .accessibilityRepresentation {
            if viewModel.saveState.isTapToRetryActionEnabled {
                Button {
                    viewModel.didTapRetry.send(())
                } label: {
                    Text(viewModel.saveState.text)
                }
            } else {
                Text(viewModel.saveState.text)
            }
        }
    }
}

#if DEBUG

#Preview {
    @Previewable @State var changingViewModel = DocViewerAnnotationToolbarViewModel(state: .saving)

    VStack(spacing: 0) {
        DocViewerAnnotationSaveStateView(
            viewModel: DocViewerAnnotationToolbarViewModel(state: .saving)
        )
        DocViewerAnnotationSaveStateView(
            viewModel: DocViewerAnnotationToolbarViewModel(state: .error)
        )
        DocViewerAnnotationSaveStateView(
            viewModel: DocViewerAnnotationToolbarViewModel(state: .saved)
        )
        DocViewerAnnotationSaveStateView(
            viewModel: changingViewModel
        )
    }
    .onAppear {
        let timer = Timer.scheduledTimer(
            withTimeInterval: 2.0,
            repeats: true
        ) { _ in
            var possibleCases = DocViewerAnnotationToolbarViewModel.State.allCases
            possibleCases.removeAll(where: { $0 == changingViewModel.saveState })
            if let randomState = possibleCases.randomElement() {
                changingViewModel.saveState = randomState
            }
        }
        timer.fire() // Trigger once immediately
    }
}

#endif
