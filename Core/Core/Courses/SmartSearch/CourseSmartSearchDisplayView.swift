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

public struct CourseSmartSearchDisplayView: View {

    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var controller
    @Environment(\.searchContext) private var searchContext

    @Binding public var phase: SearchPhase
    @Binding public var isFiltersPresented: Bool

    public init(phase: Binding<SearchPhase>, filters: Binding<Bool>) {
        self._phase = phase
        self._isFiltersPresented = filters
    }

    public var body: some View {
        ZStack {
            switch phase {
            case .loading, .start:
                SearchLoadingView()
            case .noMatch:
                SearchNoMatchView()
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
        .ignoresSafeArea()
        .background(Color.backgroundLight)
        .sheet(isPresented: $isFiltersPresented, content: {
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

#Preview {
    CourseSmartSearchDisplayView(
        phase: .constant(.results),
        filters: .constant(false)
    )
}
