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

struct EditEventFrequencyScreen: View, ScreenViewTrackable {
    @Environment(\.viewController) private var viewController
    @Environment(\.dismiss) private var dismiss

    @ObservedObject private var viewModel: EditEventFrequencyViewModel

    var screenViewTrackingParameters: ScreenViewTrackingParameters { viewModel.pageViewEvent }

    init(viewModel: EditEventFrequencyViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        InstUI.BaseScreen(state: viewModel.state, config: viewModel.screenConfig) { geometry in
            VStack(alignment: .leading, spacing: 0) {
                ForEach(viewModel.frequencyChoices) { choice in
                    ChoiceButton(
                        title: choice.title,
                        selected: viewModel.selection == choice.selectionCase) {
                            viewModel.selection = choice.selectionCase
                        }
                    InstUI.Divider()
                }

                ChoiceButton(
                    title: Text("Custom", bundle: .core),
                    selected: viewModel.selection.isCustom) {
                        viewModel.didSelectCustomFrequency.send(viewController)
                    }
                InstUI.Divider()

                Spacer()
            }
            .frame(minHeight: geometry.size.height)
        }
        .navigationTitle(viewModel.pageTitle)
        .navigationBarBackButtonHidden()
        .navBarItems(
            leading: .back {
                viewModel.didTapBack.send()
                dismiss()
            }
        )
    }
}

struct ChoiceButton: View {
    let title: Text
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(
            action: action,
            label: {
                HStack {
                    title
                        .font(.regular14, lineHeight: .fit)
                        .foregroundStyle(Color.textDarkest)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    InstUI.Icons.Checkmark()
                        .layoutPriority(1)
                        .opacity(selected ? 1 : 0)
                }
                .contentShape(Rectangle())
            })
        .buttonStyle(.plain)
        .paddingStyle(set: .standardCell)
    }
}

extension FrequencyChoice {

    var title: Text {
        switch selectionCase {
        case .noRepeat:
            return Text("Does Not Repeat", bundle: .core)
        case .daily:
            return Text("Daily", bundle: .core)
        case .weeklyOnThatDay:
            let string = String(format: "Weekly on %@".localized(), date.formatted(format: "EEEE"))
            return Text(string)
        case .monthlyOnThatWeekday:
            let weekday = date.monthWeekday
            let string = String(format: "Monthly on %@".localized(), weekday.middleText)
            return Text(string)
        case .yearlyOnThatMonth:
            let string = String(format: "Annually on %@".localized(), date.formatted(format: "MMMM d"))
            return Text(string)
        case .everyWeekday:
            return Text("Every Weekday (Monday to Friday)", bundle: .core)
        case .custom:
            return Text("Custom", bundle: .core) // Should not fall to this case
        }
    }
}

#if DEBUG

#Preview {
    EditEventFrequencyScreen(
        viewModel: EditEventFrequencyViewModel(
            eventDate: Date(),
            savedRule: nil,
            router: AppEnvironment.shared.router,
            completion: { _ in }
        )
    )
}

#endif
