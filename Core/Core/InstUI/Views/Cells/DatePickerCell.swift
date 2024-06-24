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

extension InstUI {

    public struct DatePickerCell<Label: View>: View {
        @Environment(\.dynamicTypeSize) private var dynamicTypeSize

        private let label: Label
        private let defaultDate: Date
        private let validFrom: Date
        private let validUntil: Date
        private let isClearable: Bool

        @Binding private var date: Date?

        public init(
            label: Label,
            date: Binding<Date?>,
            defaultDate: Date = .now,
            validFrom: Date = .distantPast,
            validUntil: Date = .distantFuture,
            isClearable: Bool
        ) {
            self.label = label
            self._date = date.animation()
            self.defaultDate = defaultDate
            self.validFrom = validFrom
            self.validUntil = validUntil
            self.isClearable = isClearable
        }

        public var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: InstUI.Styles.Padding.standard.rawValue) {
                    label
                        .textStyle(.cellLabel)

                    if date != nil {
                        datePicker
                    } else {
                        placeholderButtons
                    }

                    if isClearable {
                        clearButton
                    }
                }
                .frame(minHeight: 36) // To always have the same height despite datepicker visibility
            }
            .paddingStyle(.leading, .standard)
            .paddingStyle(.trailing, .standard)
            // best effort estimations to match the height of other cells, correcting for DatePicker
            .padding(.top, 5)
            .padding(.bottom, 7)

            InstUI.Divider()
        }

        @ViewBuilder
        private var datePicker: some View {
            let binding = Binding(
                get: { date ?? defaultDate },
                set: { newDate in date = newDate }
            )
            DatePicker(
                selection: binding,
                in: validFrom...validUntil,
                displayedComponents: [.date, .hourAndMinute],
                label: {}
            )
        }

        @ViewBuilder
        private var placeholderButtons: some View {
            HStack(spacing: 4) {
                placeholderButton(Text("Date", bundle: .core))
                placeholderButton(Text("Time", bundle: .core))
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }

        private func placeholderButton(_ buttonLabel: Text) -> some View {
            Button {
                date = defaultDate
            } label: {
                buttonLabel
                    .font(.regular17)
                    .padding(.horizontal, 20)
            }
            .buttonStyle(.bordered)
            .foregroundStyle(Color.textDarkest)
        }

        @ViewBuilder
        private var clearButton: some View {
            Button {
                date = nil
            } label: {
                Image.xLine
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .foregroundStyle(Color.textDarkest)
            .opacity(date == nil ? 0.3 : 1)
            .disabled(date == nil)
            .accessibilityLabel(String(localized: "Clear date", bundle: .core))
        }
    }
}

#if DEBUG

#Preview {
    VStack {
        InstUI.DatePickerCell(label: Text(verbatim: "Favorite Date"), date: .constant(nil), isClearable: true)
        InstUI.DatePickerCell(label: Text(verbatim: "Favorite Date"), date: .constant(.now), isClearable: true)
        InstUI.DatePickerCell(
            label: Text(verbatim: "Important Date").foregroundStyle(Color.red).textStyle(.heading),
            date: .constant(.now),
            isClearable: false
        )
    }
}

#endif
