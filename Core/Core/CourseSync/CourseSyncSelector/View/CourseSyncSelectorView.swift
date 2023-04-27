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
    @StateObject private var viewModel: CourseSyncSelectorViewModel

    init(viewModel: CourseSyncSelectorViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.items, id: \.self) { item in
                    CellView(item: item)
                }
            }
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
