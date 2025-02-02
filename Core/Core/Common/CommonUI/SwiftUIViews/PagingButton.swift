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

public struct PagingButton: View {

    @Binding var endCursor: String?

    @State private var loadedCursor: String?
    @State private var isLoadingMore: Bool = false

    var loadNextPage: (String?, _ finished: @escaping () -> Void) -> Void

    public init(
        endCursor: Binding<String?>,
        loadNextPage: @escaping (String?, _: @escaping () -> Void) -> Void
    ) {
        self._endCursor = endCursor
        self.loadNextPage = loadNextPage
    }

    public var body: some View {
        if isLoadingMore {
            ProgressView()
                .progressViewStyle(.indeterminateCircle())
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowBackground(Color.clear)
        }

        if let cursor = endCursor, isLoadingMore == false {
            Button {
                loadMore(from: cursor)
            } label: {
                Text("Load More", bundle: .core)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .onAppear(perform: {
                if let loadedCursor, loadedCursor == cursor { return }
                loadMore(from: cursor)
            })
        }
    }

    private func loadMore(from cursor: String) {
        loadedCursor = cursor
        isLoadingMore = true
        loadNextPage(cursor) {
            isLoadingMore = false
        }
    }
}

#Preview {

    func probableTrue() -> Bool {
        return [true, true, false].randomElement() ?? false
    }

    struct PagingButtonPreview: View {
        @State private var count: Int = 50
        @State private var cursor: String? = "next"

        var body: some View {
            List {

                ForEach(0 ..< count, id: \.self) { i in
                    Text(verbatim: "Row \(i + 1)")
                }

                Section {
                    PagingButton(endCursor: $cursor) { _, finished in
                        loadNextPage(completion: finished)
                    }
                }
            }
        }

        func loadNextPage(completion: @escaping () -> Void) {
            DispatchQueue
                .main
                .asyncAfter(deadline: .now() + 1) {
                    defer { completion() }

                    guard probableTrue() else {
                        print("failure simulated!")
                        return
                    }

                    count += 50
                    cursor = probableTrue() ? ((cursor ?? "next") + "1") : nil

                    if let cursor {
                        print("next cursor: \(cursor)")
                    } else {
                        print("done!")
                    }
                }
        }
    }

    return PagingButtonPreview()
}
