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

    @ObservedObject private var viewModel: EditCustomFrequencyViewModel

    var screenViewTrackingParameters: ScreenViewTrackingParameters { viewModel.pageViewEvent }

    @State var selection: [Int] = [0, 0]

    @State var weekDayDropDownState = DropDownButtonState()

    @State var weekDays: [Weekday] = []

    init(viewModel: EditCustomFrequencyViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        InstUI.BaseScreen(state: viewModel.state, config: viewModel.screenConfig) { geometry in
            VStack(alignment: .leading, spacing: 0) {

                MultiPickerView(
                    content: [
                        (1 ... 400).map({ String($0) }),
                        ["Daily", "Weekly", "Monthly", "Yearly"]
                    ],
                    widths: [3, 7],
                    alignments: [.right, .left],
                    selections: $selection
                )
                .frame(maxWidth: .infinity)

                InstUI.DropDownCell(
                    label: Text("Repeats On"),
                    state: $weekDayDropDownState) {

                        if weekDays.isEmpty {
                            HStack(spacing: 10) {
                                Text("Select")
                                    .font(.regular14).foregroundStyle(Color.textDark)
                                SelectIcon()
                            }
                        } else {

                            HStack(spacing: 8) {

                                ForEach(weekDays.selectionTexts, id: \.self) { day in
                                    Text(day)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                        .font(.regular14)
                                        .foregroundStyle(Color.textDarkest)
                                        .padding(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                                        .background(Color.backgroundLight)
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                }
                            }
                        }
                    }
            }
        }
        .navigationTitle(viewModel.pageTitle)
        .navBarItems(
            leading: .cancel {
                viewModel.didTapCancel.send()
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
            WeekDaysSelectionListView(selection: $weekDays)
        }
    }

    struct SelectIcon: View {
        static let leadingPadding: CGFloat = 12

        @ScaledMetric private var uiScale: CGFloat = 1

        public var body: some View {
            Image.arrowUpDownLine
                .resizable()
                .scaledToFit()
                .frame(width: uiScale.iconScale * 16,
                       height: uiScale.iconScale * 16)
                .foregroundStyle(Color.textDark)
        }
    }
}

struct WeekDaysSelectionListView: View {

    @Binding var selection: [Weekday]

    var body: some View {
        ScrollView {
            VStack {
                ForEach(Weekday.allCases, id: \.rawValue) { weekDay in

                    Button(
                        action: {
                            selection.toggleInsert(with: weekDay)
                        },
                        label: {
                            HStack {
                                Text(weekDay.text)
                                    .font(.medium16)
                                    .foregroundStyle(Color.textDarkest)
                                Spacer()
                                if selection.contains(weekDay) {
                                    CheckMark()
                                }
                            }
                            .contentShape(Rectangle())
                        })
                    .buttonStyle(.plain)

                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                    InstUI.Divider()
                }
            }
        }
        .preferredHeightAsDropDownDetails(
            CGFloat(Weekday.allCases.count) * 45)
    }

    struct CheckMark: View {
        @ScaledMetric private var uiScale: CGFloat = 1

        public var body: some View {
            Image.checkLine
                .resizable()
                .scaledToFit()
                .frame(width: uiScale.iconScale * 18,
                       height: uiScale.iconScale * 18)
                .foregroundStyle(Color.textDarkest)
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
