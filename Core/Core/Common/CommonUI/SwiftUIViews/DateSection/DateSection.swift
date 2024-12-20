//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

struct DateSection<ViewModel: DateSectionViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    var body: some View {
        Button(action: buttonTapped, label: { HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image.calendarClockLine
                    Text("Due", bundle: .core)
                        .font(.medium16)
                    Spacer()
                }
                    .foregroundColor(.textDark)
                if viewModel.hasMultipleDueDates {
                    Text("Multiple Due Dates", bundle: .core)
                } else {
                    if let dueAt = viewModel.dueAt {
                        Line(Text("Due:", bundle: .core), Text(dueAt.dateTimeString))
                    } else {
                        Line(Text("Due:", bundle: .core), Text(verbatim: "--"))
                            .accessibility(label: Text("No due date set.", bundle: .core))
                    }

                    Line(Text("For:", bundle: .core), Text(viewModel.forText))

                    let lockAt = viewModel.lockAt
                    if let to = lockAt, to < Clock.now {
                        Line(Text("Availability:", bundle: .core), Text("Closed", bundle: .core))
                    } else {
                        if let from = viewModel.unlockAt {
                            Line(Text("Available From:", bundle: .core), Text(from.dateTimeString))
                        } else {
                            Line(Text("Available From:", bundle: .core), Text(verbatim: "--"))
                                .accessibility(label: Text("No available from date set.", bundle: .core))
                        }

                        if let to = lockAt {
                            Line(Text("Available Until:", bundle: .core), Text(to.dateTimeString))
                        } else {
                            Line(Text("Available Until:", bundle: .core), Text(verbatim: "--"))
                                .accessibility(label: Text("No available until date set.", bundle: .core))
                        }
                    }
                }
            }
                .font(.regular16).foregroundColor(.textDarkest)
                .padding(16)
            if viewModel.isButton {
                DisclosureIndicator().padding(.trailing, 16)
            }
        } })
            .accessibility(hint: Text("Due Dates, Double tap for details.", bundle: .core))
    }

    @ViewBuilder
    func Line(_ title: Text, _ value: Text) -> some View {
        HStack(spacing: 4) {
            title.font(.semibold16)
            value
        }
    }

    func buttonTapped() {
        viewModel.buttonTapped(router: env.router, viewController: controller)
    }
}

#if DEBUG

struct DateSection_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = PreviewDateSectionViewModel(
            dueAt: Date(),
            lockAt: Date(timeIntervalSinceNow: 100),
            unlockAt: Date(timeIntervalSinceNow: 200),
            forText: "Everybody")

        DateSection(viewModel: viewModel)
            .preferredColorScheme(.light)
            .previewLayout(.sizeThatFits)
        DateSection(viewModel: viewModel)
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}

#endif
