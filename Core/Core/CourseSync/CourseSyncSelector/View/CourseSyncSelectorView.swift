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
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.items) { item in
                        CellView(item: item)
                    }
                }
            }
            syncButton
        }
        .navigationBarTitleView(navBarTitleView)
        .navigationBarItems(leading: leftNavBarButton, trailing: cancelButton)
        .navigationBarStyle(.modal)
    }

    private var navBarTitleView: some View {
        VStack(spacing: 0) {
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

    private var leftNavBarButton: some View {
        Button {
            viewModel.leftNavBarButtonPressed.accept()
        } label: {
            Text(viewModel.leftNavBarTitle)
                .font(.regular16)
                .foregroundColor(.textDarkest)
        }
    }
}

struct CellView: View {
    let item: CourseSyncSelectorViewModel.Item

    var body: some View {
        HStack {
            Button {
                item.selectionToggled()
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
                Image(systemName: "chevron.up")
                    .foregroundColor(.blue)
            case .closed:
                Image(systemName: "chevron.down")
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(item.backgroundColor)
        .padding(.leading, item.isIndented ? 16 : 0)
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
