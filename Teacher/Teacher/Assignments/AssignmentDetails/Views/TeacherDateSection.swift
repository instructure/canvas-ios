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

import Core
import SwiftUI

struct TeacherDateSection<ViewModel: DateSectionViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    var body: some View {
        Button(action: buttonTapped) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Assignment Dates", bundle: .teacher)
                        .font(.regular14)
                        .foregroundColor(.textDark)

                    if viewModel.hasMultipleDueDates {
                        Text("Multiple Due Dates", bundle: .teacher)
                    } else {
                        if let dueAt = viewModel.dueAt {
                            Line(Text("Due:", bundle: .teacher), Text(dueAt.dateTimeString))
                        } else {
                            Line(Text("Due:", bundle: .teacher), Text(verbatim: "--"))
                                .accessibility(label: Text("No due date set.", bundle: .teacher))
                        }

                        Line(Text("For:", bundle: .teacher), Text(viewModel.forText))

                        let lockAt = viewModel.lockAt
                        if let to = lockAt, to < Clock.now {
                            Line(Text("Availability:", bundle: .teacher), Text("Closed", bundle: .teacher))
                        } else {
                            if let from = viewModel.unlockAt {
                                Line(Text("Available from:", bundle: .teacher), Text(from.dateTimeString))
                            } else {
                                Line(Text("Available from:", bundle: .teacher), Text(verbatim: "--"))
                                    .accessibility(label: Text("No available from date set.", bundle: .teacher))
                            }

                            if let to = lockAt {
                                Line(Text("Available until:", bundle: .teacher), Text(to.dateTimeString))
                            } else {
                                Line(Text("Available until:", bundle: .teacher), Text(verbatim: "--"))
                                    .accessibility(label: Text("No available until date set.", bundle: .teacher))
                            }
                        }
                    }
                }
                .font(.regular16)
                .foregroundColor(.textDarkest)
                .padding(16)

                if viewModel.isButton {
                    Spacer()
                    InstUI.DisclosureIndicator().padding(.trailing, 16)
                }
            }
        }
        .accessibility(hint: Text("Due Dates, Double tap for details.", bundle: .teacher))
    }

    @ViewBuilder
    private func Line(_ title: Text, _ value: Text) -> some View {
        HStack(spacing: 4) {
            title.font(.regular16).foregroundStyle(Color.textDark)
            value.font(.regular16).foregroundStyle(Color.textDarkest)
        }
    }

    private func buttonTapped() {
        viewModel.buttonTapped(router: env.router, viewController: controller)
    }
}

#if DEBUG

struct TeacherDateSection_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = PreviewDateSectionViewModel(
            dueAt: Date(),
            lockAt: Date(timeIntervalSinceNow: 100),
            unlockAt: Date(timeIntervalSinceNow: 200),
            forText: "Everybody")

        TeacherDateSection(viewModel: viewModel)
            .preferredColorScheme(.light)
            .previewLayout(.sizeThatFits)
        TeacherDateSection(viewModel: viewModel)
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}

#endif
