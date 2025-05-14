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

    private enum Spacing {
        static let horizontal: CGFloat = InstUI.Styles.Padding.standard.rawValue
        static let vertical: CGFloat = InstUI.Styles.Padding.textVertical.rawValue
        static let pickerHorizontal: CGFloat = 4
        static let pickerVertical: CGFloat = InstUI.Styles.Padding.textVertical.rawValue
        static let errorVertical: CGFloat = 8
    }

    public struct DatePickerCell<Label: View>: View {

        public enum Mode {
            case dateOnly
            case timeOnly
            case dateAndTime
        }

        @Environment(\.dynamicTypeSize) private var dynamicTypeSize

        private let label: Text
        private let labelModifiers: (Text) -> Label
        private let customAccessibilityLabel: Text?
        private let accessibilityIdPrefix: String?
        private let mode: Mode
        private let defaultDate: Date
        private let validFrom: Date
        private let validUntil: Date
        private let errorMessage: String?
        private let isClearable: Bool

        @Binding private var date: Date?

        public init(
            label: Text,
            labelModifiers: @escaping (Text) -> Label = { $0 },
            customAccessibilityLabel: Text? = nil,
            accessibilityIdPrefix: String? = nil,
            date: Binding<Date?>,
            mode: Mode = .dateAndTime,
            defaultDate: Date = .now,
            validFrom: Date = .distantPast,
            validUntil: Date = .distantFuture,
            errorMessage: String? = nil,
            isClearable: Bool = false
        ) {
            self.label = label
            self.labelModifiers = labelModifiers
            self.customAccessibilityLabel = customAccessibilityLabel
            self.accessibilityIdPrefix = accessibilityIdPrefix
            self._date = date
            self.mode = mode
            self.defaultDate = defaultDate
            self.validFrom = validFrom
            self.validUntil = validUntil
            self.errorMessage = errorMessage
            self.isClearable = isClearable
        }

        public var body: some View {
            VStack(spacing: 0) {
                VStack(spacing: Spacing.errorVertical) {
                    mainContent
                        .frame(minHeight: 36) // To always have the same height despite datepicker visibility

                    errorMessageView
                }
                .paddingStyle(.leading, .standard)
                .paddingStyle(.trailing, .standard)
                // best effort estimations to match the height of other cells, correcting for DatePicker
                .padding(.top, 5)
                .padding(.bottom, 7)

                InstUI.Divider()
            }
        }

        // MARK: - Main views

        private var mainContent: some View {
            // Prefer to fit the whole content in one line, but break subviews gradually if needed.
            // Using only one level of `ViewThatFits`, because nesting them is visibly less performant.
            ViewThatFits(in: .horizontal) {
                HStack(spacing: Spacing.horizontal) {
                    labelView
                    datePickerView(.horizontal)
                }
                HStack(spacing: Spacing.horizontal) {
                    labelView
                    datePickerView(.vertical)
                }
                VStack(alignment: .leading, spacing: Spacing.vertical) {
                    labelView
                    datePickerView(.horizontal)
                }
                VStack(alignment: .leading, spacing: Spacing.vertical) {
                    labelView
                    datePickerView(.vertical)
                }
            }
        }

        private var labelView: some View {
            labelModifiers(label)
                .textStyle(.cellLabel)
                .accessibilityHidden(true)
        }

        @ViewBuilder
        private func datePickerView(_ axis: Axis) -> some View {
            HStack(spacing: Spacing.horizontal) {
                if date != nil {
                    datePickerParts(axis)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                } else {
                    placeholderButtons(axis)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                if isClearable {
                    clearButton
                }
            }
        }

        @ViewBuilder
        private var errorMessageView: some View {
            if let errorMessage {
                Text(errorMessage)
                    .textStyle(.errorMessage)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .accessibilityHidden(true)
            }
        }

        // MARK: - Date picker

        @ViewBuilder
        private func datePickerParts(_ axis: Axis) -> some View {
            switch mode {
            case .dateOnly:
                datePicker(mode: .dateOnly)
            case .timeOnly:
                datePicker(mode: .timeOnly)
            case .dateAndTime:
                // Using separate date and time pickers because otherwise VoiceOver doesn't read
                // neither "Date Picker" nor "Time Picker" for them.
                let pickers = SwiftUI.Group {
                    datePicker(mode: .dateOnly)
                    datePicker(mode: .timeOnly)
                }

                switch axis {
                case .horizontal:
                    HStack(spacing: Spacing.pickerHorizontal) { pickers }
                case .vertical:
                    VStack(alignment: .trailing, spacing: Spacing.pickerVertical) { pickers }
                }
            }
        }

        @ViewBuilder
        private func datePicker(mode: Mode) -> some View {
            let binding = Binding(
                get: { date ?? defaultDate },
                set: { newDate in date = newDate }
            )

            let components: DatePickerComponents = switch mode {
            case .dateOnly: [.date]
            case .timeOnly: [.hourAndMinute]
            case .dateAndTime: [.date, .hourAndMinute]
            }

            let accessibilityId = switch mode {
            case .dateOnly: "date"
            case .timeOnly: "time"
            case .dateAndTime: "dateAndTime"
            }

            DatePicker(
                selection: binding,
                in: validFrom...validUntil,
                displayedComponents: components,
                label: {}
            )
            .labelsHidden() // This is needed to avoid the empty label filling up all the space
            .accessibilityLabel(customAccessibilityLabel ?? label)
            .accessibilityValue(String.localizedAccessibilityErrorMessage(errorMessage) ?? "") // Actual value is contained already
            .accessibilityIdentifier(accessibilityIdPrefix?.appending(".\(accessibilityId)"))
            .accessibilityRefocusingOnPopoverDismissal()
        }

        // MARK: - Placeholder

        @ViewBuilder
        private func placeholderButtons(_ axis: Axis) -> some View {
            switch mode {
            case .dateOnly:
                placeholderButton(Text("Date", bundle: .core))
            case .timeOnly:
                placeholderButton(Text("Time", bundle: .core))
            case .dateAndTime:
                let buttons = SwiftUI.Group {
                    placeholderButton(Text("Date", bundle: .core))
                    placeholderButton(Text("Time", bundle: .core))
                }

                switch axis {
                case .horizontal:
                    HStack(spacing: Spacing.pickerHorizontal) { buttons }
                case .vertical:
                    VStack(alignment: .trailing, spacing: Spacing.pickerVertical) { buttons }
                }
            }
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

        // MARK: - Clear button

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
        InstUI.DatePickerCell(label: Text(verbatim: "Favorite Date"), date: .constant(.now), isClearable: false)
        InstUI.DatePickerCell(label: Text(verbatim: "Favorite Date"), date: .constant(.now), errorMessage: "Someting is wrong here.")
        InstUI.DatePickerCell(label: Text(verbatim: "Just Date"), date: .constant(.now), mode: .dateOnly)
        InstUI.DatePickerCell(
            label: Text(verbatim: "Important Date"),
            labelModifiers: { $0.foregroundStyle(Color.red).textStyle(.heading) },
            date: .constant(.now)
        )
    }
}

#endif
