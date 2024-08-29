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

struct EditCustomFrequencyScreen: View, ScreenViewTrackable {
    private enum FocusedInput {
        case frequencyInterval
        case repeatsOn
        case endRepeat
    }
    @FocusState private var focusedInput: FocusedInput?

    @Environment(\.viewController) private var viewController
    @Environment(\.dismiss) private var dismiss

    @ObservedObject private var viewModel: EditCustomFrequencyViewModel

    var screenViewTrackingParameters: ScreenViewTrackingParameters { viewModel.pageViewEvent }

    @State private var weekDayDropDownState = DropDownButtonState()
    @State private var isOccurrencesDialogPresented: Bool = false

    @State var selection: [Int] = [0, 0]

    private var selectedFrequency: RecurrenceFrequency {
        return RecurrenceFrequency.allCases[selection[1]]
    }

    init(viewModel: EditCustomFrequencyViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        InstUI.BaseScreen(state: viewModel.state, config: viewModel.screenConfig) { geometry in
            VStack(alignment: .leading, spacing: 0) {

                MultiPickerView(
                    content: [
                        (1 ... 400).map({ String($0) }),
                        RecurrenceFrequency.allCases.map { $0.selectionText }
                    ],
                    widths: [3, 7],
                    alignments: [.right, .left],
                    selections: $selection
                )
                .frame(maxWidth: .infinity)

                if case .weekly = selectedFrequency {
                    weekDaysCell
                } else if case .monthly = selectedFrequency {
                    monthDaysCell
                } else if case .yearly = selectedFrequency {
                    yearDayCell
                }

                endModeCell

                if let endMode = viewModel.endMode {
                    cellForEndMode(endMode)
                }
            }
        }
        .navigationTitle(viewModel.pageTitle)
        .navigationBarBackButtonHidden()
        .navBarItems(
            leading: .back {
                dismiss()
            },
            trailing: .init(
                isAvailableOffline: false,
                title: viewModel.doneButtonTitle,
                action: {
                    viewModel.didTapDone.send()
                }
            )
        )
        .dropDownDetails(state: $weekDayDropDownState) {
            WeekDaysSelectionListView(selection: $viewModel.daysOfTheWeek)
        }
        .occurrencesCountInputDialog(isPresented: $isOccurrencesDialogPresented,
                                     value: $viewModel.occurrenceCount)
    }

    private var monthDaysCell: some View {
        return InstUI.SelectionMenuCell(
            label: Text("Repeats on", bundle: .core),
            options: [DayOfMonth].options(for: viewModel.proposedDate),
            id: \.id,
            text: \.title,
            selection: $viewModel.dayOfMonth
        )
    }

    private var yearDayCell: some View {
        InstUI.LabelValueCell(
            label: Text("Repeats on", bundle: .core),
            value: proposedDay.title(as: .yearDay),
            equalWidth: false,
            action: {}
        )
    }

    private var weekDaysCell: some View {
        InstUI.DropDownCell(
            label: Text("Repeats on", bundle: .core),
            state: $weekDayDropDownState) {

                if viewModel.daysOfTheWeek.isEmpty {
                    DropDownPromptLabel()
                } else {

                    HStack(spacing: 8) {
                        ForEach(viewModel.daysOfTheWeek.selectionTexts, id: \.self) { day in
                            DropDownSelectedValueView(text: day)
                        }
                    }
                }
            }
    }

    private var endModeCell: some View {
        InstUI.SelectionMenuCell(
            label: Text("End Repeat", bundle: .core),
            options: RecurrenceEndMode.allCases,
            id: \.self,
            text: \.title,
            selection: $viewModel.endMode
        )
    }

    private var endDateCell: some View {
        InstUI.DatePickerCell(
            label: Text("End date", bundle: .core),
            date: $viewModel.endDate,
            mode: .dateOnly,
            defaultDate: .now,
            validFrom: viewModel.endDate.flatMap({ min($0, .now) }) ?? .now,
            isClearable: false
        )
    }

    private var endOccurrencesCountCell: some View {
        InstUI.LabelValueCell(
            label: Text("Number of Occurrences", bundle: .core),
            value: viewModel.occurrenceCount.formatted(.number),
            equalWidth: false) {
                isOccurrencesDialogPresented = true
            }
    }

    @ViewBuilder
    private func cellForEndMode(_ endMode: RecurrenceEndMode) -> some View {
        switch endMode {
        case .onDate:
            endDateCell
        case .afterOccurrences:
            endOccurrencesCountCell
        }
    }
}

enum RecurrenceEndMode: Equatable, CaseIterable {
    case onDate
    case afterOccurrences

    var title: String {
        switch self {
        case .onDate:
            return "On date".localized()
        case .afterOccurrences:
            return "After Occurrences".localized()
        }
    }
}

struct MonthOption: Equatable {
    let eventDay: ProposedEventDay
    let representation: ProposedEventDay.Representation

    var title: String {
        return eventDay.title(as: representation)
    }
}

#if DEBUG

#Preview {

    Rectangle()
        .sheet(isPresented: .constant(true), content: {
            NavigationView {
                EditCustomFrequencyScreen(
                    viewModel:
                        EditCustomFrequencyViewModel(
                            rule: nil,
                            proposedDate: Date(),
                            completion: { rule in
                                print("Selected rule:")
                                print(rule?.rruleDescription)
                            })
                )
                .navigationBarTitleDisplayMode(.inline)
            }
        })
}

#Preview {

    EditCustomFrequencyScreen(
        viewModel:
            EditCustomFrequencyViewModel(
                rule: nil,
                proposedDate: Date(),
                completion: { rule in
                    print("Selected rule:")
                    print(rule?.rruleDescription)
                })
    )
}

#endif
