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
    typealias EndMode = EditCustomFrequencyViewModel.EndMode

    @Environment(\.viewController) private var viewController

    @ObservedObject private var viewModel: EditCustomFrequencyViewModel

    var screenViewTrackingParameters: ScreenViewTrackingParameters { viewModel.pageViewEvent }

    @State private var weekDayDropDownState = DropDownButtonState()
    @State private var isOccurrencesDialogPresented: Bool = false

    init(viewModel: EditCustomFrequencyViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        InstUI.BaseScreen(state: viewModel.state, config: viewModel.screenConfig) { _ in
            VStack(alignment: .leading, spacing: 0) {
                InstUI.LabelCell(
                    label: Text("Repeats every", bundle: .core)
                )

                InstUI.MultiPickerView(
                    content1: FrequencyInterval.options,
                    titleKey1: \.title,
                    selection1: $viewModel.interval,
                    content2: RecurrenceFrequency.allCases,
                    titleKey2: \.selectionText,
                    title2GivenSelected1: { freq, interval in
                        return freq.unitText(given: interval.value)
                    },
                    selection2: $viewModel.frequency,
                    widths: [4, 6],
                    alignments: [.trailing, .leading])
                .frame(maxWidth: .infinity)

                InstUI.Divider()

                if case .weekly = viewModel.frequency {
                    weekDaysCell
                } else if case .monthly = viewModel.frequency {
                    monthDaysCell
                } else if case .yearly = viewModel.frequency {
                    yearDayCell
                }

                endModeCell

                if let endMode = viewModel.endMode {
                    endModeDetailsCell(endMode)
                }
            }
        }
        .navigationTitle(viewModel.pageTitle)
        .navBarItems(
            trailing: .init(
                isEnabled: viewModel.isSaveButtonEnabled,
                isAvailableOffline: false,
                title: viewModel.doneButtonTitle,
                action: {
                    viewModel.didTapDone.send(viewController)
                }
            )
        )
        .dropDownDetailsContainer(state: $weekDayDropDownState) {
            WeekDaysSelectionListView(selection: $viewModel.daysOfTheWeek)
        }
        .occurrencesCountInputDialog(isPresented: $isOccurrencesDialogPresented,
                                     value: $viewModel.occurrenceCount)
    }

    private var monthDaysCell: some View {
        return InstUI.SelectionMenuCell(
            label: Text("On", bundle: .core),
            options: viewModel.dayOfMonthOptions(for: viewModel.proposedDate),
            text: \.title,
            defaultValue: viewModel.proposedDayOfMonth,
            selection: $viewModel.dayOfMonth
        )
    }

    @ViewBuilder
    private var yearDayCell: some View {
        InstUI.LabelValueCell(
            label: Text("On", bundle: .core),
            value: viewModel.dayOfYear.title
        )
    }

    private var weekDaysCell: some View {
        InstUI.DropDownCell(
            label: Text("On", bundle: .core),
            state: $weekDayDropDownState) {

                if viewModel.daysOfTheWeek.isEmpty {
                    WeekdaysDropDownPromptLabel()
                } else {
                    HStack(spacing: 8) {
                        ForEach(viewModel.selectedWeekdaysTexts, id: \.self) { day in
                            WeekdaysDropDownSelectedLabel(text: day)
                        }
                    }
                }
            }
    }

    private var endModeCell: some View {
        InstUI.SelectionMenuCell(
            label: Text("Ends", bundle: .core),
            options: EndMode.allCases,
            id: \.self,
            text: \.title,
            selection: $viewModel.endMode
        )
    }

    @ViewBuilder
    private func endModeDetailsCell(_ endMode: EndMode) -> some View {
        switch endMode {
        case .onDate:
            endDateCell
        case .afterOccurrences:
            endOccurrencesCountCell
        }
    }

    private var endDateCell: some View {
        InstUI.DatePickerCell(
            label: Text("End date", bundle: .core),
            date: $viewModel.endDate,
            mode: .dateOnly,
            defaultDate: Clock.now.addYears(1),
            validFrom: viewModel.proposedDate,
            isClearable: false
        )
    }

    private var endOccurrencesCountCell: some View {
        InstUI.LabelValueCell(
            label: Text("Number of Occurrences", bundle: .core),
            value: viewModel.occurrenceCount.formatted(.number)
        ) {
            isOccurrencesDialogPresented = true
        }
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
                            router: AppEnvironment.shared.router,
                            completion: { rule in
                                print("Selected rule:")
                                print(rule.rruleDescription)
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
                router: AppEnvironment.shared.router,
                completion: { rule in
                    print("Selected rule:")
                    print(rule.rruleDescription)
                })
    )
}

#endif
