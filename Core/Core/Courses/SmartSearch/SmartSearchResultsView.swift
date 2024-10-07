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

struct SmartSearchResultsView: View {

    enum Phase {
        case loading
        case noMatch
        case results
    }

    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var controller
    @Environment(\.smartSearchContext) var searchContext

    @State var phase: Phase = .loading

    var body: some View {
        ZStack {
            switch phase {
            case .loading:
                VStack {
                    Spacer()
                    ProgressView()
                    VStack {
                        Text("Hang Tight, We're Fetching Your Results!").lineLimit(2)
                        Text("We’re working hard to find the best matches for your search. This won't take long! Thank you for your patience.").lineLimit(0)
                    }
                    Spacer()
                }

            case .noMatch:
                VStack {
                    Spacer()
                    VStack {
                        Text("No Perfect Match").lineLimit(2)
                        Text("We didn’t find exactly what you’re looking for. Maybe try searching for something else?").lineLimit(0)
                    }
                    Spacer()
                }
            case .results:

                List {
                    ForEach(1 ... 12, id: \.self) { i in
                        Text("Result \(i)")
                    }
                }
            }
        }
        .onAppear {
            startLoading()
        }
        .onReceive(searchContext.didSubmit) { term in
            startLoading(with: term)
        }
    }

    func startLoading(with term: String? = nil) {
        searchContext.mode = .loading
        phase = .loading

        let searchTerm = term ?? searchContext.searchTerm

        print("Searching `\(searchTerm)` ..")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            finishLoading(noMatch: .random())
        }
    }

    func finishLoading(noMatch: Bool) {
        searchContext.mode = noMatch ? .noMatch : .results
        phase = noMatch ? .noMatch : .results
    }
}

#Preview {
    SmartSearchResultsView()
}
