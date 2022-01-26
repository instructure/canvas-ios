//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

public struct K5ImportantDatesView: View {
    @ObservedObject var viewModel: K5ImportantDatesViewModel

    public init(viewModel: K5ImportantDatesViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack {
            if UIDevice.current.userInterfaceIdiom == .pad {
                HStack(spacing: 0) {
                    Text("Important Dates", bundle: .core)
                        .font(.bold22)
                        .foregroundColor(.textDarkest)
                        .padding(EdgeInsets(top: 28, leading: 16, bottom: 9, trailing: 24))
                    Spacer()
                }
            }
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        CircleRefresh { endRefreshing in
                            viewModel.refresh(completion: endRefreshing)
                        }
                        if viewModel.importantDates.isEmpty {
                            EmptyPanda(.NoImportantDates, message: Text("Waiting for important things to happen.", bundle: .core)).frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
                        } else {
                            ForEach(viewModel.importantDates, id: \.self) { importantDate in
                                HStack {
                                    Text(importantDate.title)
                                        .font(.bold17)
                                        .foregroundColor(.textDarkest)
                                    Spacer()
                                }
                                .padding(EdgeInsets(top: 9, leading: 16, bottom: 0, trailing: 16))

                                ForEach(Array(importantDate.events), id: \.self) { event in
                                    K5ImportantDateCell(item: event)
                                        .padding(EdgeInsets(top: 12, leading: 16, bottom: 16, trailing: 16))
                                }
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}

#if DEBUG

struct K5ImportantDates_Previews: PreviewProvider {

    static var model: K5ImportantDatesViewModel {
        let viewModel = K5ImportantDatesViewModel()
        let event = CalendarEvent()
        event.startAt = Date()
        event.title = "Subject name"
        event.contextName = "This important date event"
        event.type = .event
        viewModel.addImportantDate(from: event)
        return viewModel
    }

    static var previews: some View {
        // swiftlint:disable:next redundant_discardable_let
        let _ = K5Preview.setupK5Mode()

        K5ImportantDatesView(viewModel: model)
    }
}

#endif
