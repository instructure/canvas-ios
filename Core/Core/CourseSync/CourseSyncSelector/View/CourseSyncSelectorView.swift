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

struct CourseSyncSelectorView: View {
    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var viewController
    @StateObject var viewModel: CourseSyncSelectorViewModel

    var body: some View {
        content
        .navigationBarTitleView(navBarTitleView)
        .navigationBarItems(leading: leftNavBarButton, trailing: cancelButton)
        .navigationBarStyle(.modal)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .error:
            InteractivePanda(scene: NoResultsPanda(),
                             title: Text("Something went wrong", bundle: .core),
                             subtitle: Text("There was an unexpected error.", bundle: .core))
        case .loading:
            ProgressView()
                .progressViewStyle(.indeterminateCircle())
        case .data:
            VStack(spacing: 0) {
                Text(viewModel.selectedItemCount)
                    .foregroundColor(.textDarkest)
                    .font(.semibold16, lineHeight: .fit)
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    .padding(.bottom, 28)
                    .frame(maxWidth: .infinity, alignment: .leading)
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.items) { item in
                            CellView(item: item)
                        }
                    }
                }
                syncButton
            }
        }
    }

    private var navBarTitleView: some View {
        VStack(spacing: 1) {
            Text("Offline Content", bundle: .core)
                .font(.semibold16)
                .foregroundColor(.textDarkest)
            Text("All Courses", bundle: .core)
                .font(.regular12)
                .foregroundColor(.textDark)
        }
    }

    private var cancelButton: some View {
        Button {
            env.router.dismiss(viewController)
        } label: {
            Text("Cancel", bundle: .core)
                .font(.regular16)
                .foregroundColor(.textDarkest)
        }
    }

    private var syncButton: some View {
        Button {
            env.router.dismiss(viewController)
        } label: {
            Text("Sync", bundle: .core)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .font(.regular16, lineHeight: .fit)
                .foregroundColor(.textLightest)
                .background(Color(Brand.shared.primary))
                .opacity(viewModel.syncButtonDisabled ? 0.42 : 1)
        }
        .disabled(viewModel.syncButtonDisabled)
    }

    @ViewBuilder
    private var leftNavBarButton: some View {
        if viewModel.leftNavBarButtonVisible {
            Button {
                viewModel.leftNavBarButtonPressed.accept()
            } label: {
                Text(viewModel.leftNavBarTitle)
                    .font(.regular16)
                    .foregroundColor(.textDarkest)
            }
        }
    }
}

struct CellView: View {
    let item: CourseSyncSelectorViewModel.Item

    var body: some View {
        HStack {
            Button {
                item.selectionDidToggle?()
            } label: {
                item.isSelected ? Image.emptySolid : Image.emptyLine
            }
            VStack(alignment: .leading) {
                Text(item.title)
                    .fontWeight(item.isSelected ? .bold : .regular)
                if let subtitle = item.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            switch item.trailingIcon {
            case .none:
                SwiftUI.EmptyView()
            case .opened:
                collapseButton(Image(systemName: "chevron.up"))
            case .closed:
                collapseButton(Image(systemName: "chevron.down"))
            }
        }
        .padding()
        .background(item.backgroundColor)
        .padding(.leading, item.isIndented ? 16 : 0)
    }

    @ViewBuilder
    private func collapseButton(_ image: Image) -> some View {
        Button {
            item.collapseDidToggle?()
        } label: {
            image
        }
    }
}

struct SeparatorView: View {
    let isLight: Bool
    let isIndented: Bool

    var body: some View {
        Rectangle()
            .fill(isLight ? Color.borderMedium : Color.borderDark)
            .frame(height: 1)
            .padding(.leading, isIndented ? 16 : 0)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CourseSyncSelectorAssembly.makePreview()
    }
}
