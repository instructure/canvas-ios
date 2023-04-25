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
    let items: [CourseSyncSelectorViewModel.Item] = [
        .cell(.init(
            isSelected: false,
            backgroundColor: .backgroundLightest,
            title: "Item 1",
            subtitle: "Subtitle for Item 1",
            trailingIcon: .none,
            isIndented: false
        )),
        .separator(isLight: true, isIndented: true),
        .cell(.init(
            isSelected: true,
            backgroundColor: .backgroundLightest,
            title: "Item 2",
            subtitle: nil,
            trailingIcon: .opened,
            isIndented: false
        )),
        .separator(isLight: false, isIndented: false),
        .cell(.init(
            isSelected: false,
            backgroundColor: .backgroundLightest,
            title: "Item 3",
            subtitle: "Subtitle for Item 3",
            trailingIcon: .closed,
            isIndented: true
        )),
    ]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(items, id: \.self) { item in
                    switch item {
                    case .separator(let isLight, let isIndented):
                        SeparatorView(isLight: isLight, isIndented: isIndented)
                    case .cell(let cell):
                        CellView(cell: cell)
                    }
                }
            }
        }
    }
}

struct CellView: View {
    let cell: CourseSyncSelectorViewModel.Item.Cell

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(cell.title)
                    .fontWeight(cell.isSelected ? .bold : .regular)
                if let subtitle = cell.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            switch cell.trailingIcon {
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
        .background(cell.backgroundColor)
        .padding(.leading, cell.isIndented ? 16 : 0)
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
        CourseSyncSelectorView()
    }
}
