//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

public struct SmartSearchDisplayView: View {
    public init() {}

    enum Phase {
        case start
        case loading
        case noMatch
        case results
    }

    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var controller
    @Environment(\.smartSearchContext) private var searchContext

    @State private var phase: Phase = .start
    @State private var isHelpPresented: Bool = false
    @State private var isFilterPresented: Bool = false

    public var body: some View {
        ZStack {
            switch phase {
            case .loading, .start:
                LoadingView()
            case .noMatch:
                NoMatchView()
            case .results:

                List {
                    ForEach(1 ... 12, id: \.self) { i in
                        Button {
                            let content = CoreHostingController(
                                Text("Result \(i) / \(12)")
                            )
                            env.router.show(content, from: controller, options: .detail)
                        } label: {
                            Text("Result \(i)")
                        }
                    }
                }
            }
        }
        .toolbar {

            if phase != .loading {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isFilterPresented = true
                    } label: {
                        Image(systemName: "camera.filters")
                    }
                    .tint(.white)
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isHelpPresented = true
                } label: {
                    Image(systemName: "questionmark.circle")
                }
                .tint(.white)
            }
        }
        .sheet(isPresented: $isHelpPresented, content: {
            SmartSearchHelpView()
        })
        .sheet(isPresented: $isFilterPresented, content: {
            SmartSearchFiltersView()
        })
        .onAppear {
            guard case .start = phase else { return }
            startLoading()
        }
        .onReceive(searchContext.didSubmit, perform: { newTerm in
            startLoading(with: newTerm)
        })
    }

    func startLoading(with term: String? = nil) {
        let searchTerm = term ?? searchContext.searchTerm.value
        phase = .loading

        print("Searching `\(searchTerm)` ..")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            phase = Bool.random() ? .noMatch : .results
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack {
            Spacer()
            ProgressView()
            VStack {
                Text("Hang Tight, We're Fetching Your Results!").lineLimit(2)
                Text("We’re working hard to find the best matches for your search. This won't take long! Thank you for your patience.").lineLimit(0)
            }
            Spacer()
        }
        .padding()
    }
}

struct NoMatchView: View {
    var body: some View {
        VStack {
            Spacer()
            VStack {
                Text("No Perfect Match").lineLimit(2)
                Text("We didn’t find exactly what you’re looking for. Maybe try searching for something else?").lineLimit(0)
            }
            Spacer()
        }
        .padding()
    }
}
