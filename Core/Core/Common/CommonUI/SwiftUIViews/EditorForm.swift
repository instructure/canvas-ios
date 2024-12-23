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

public struct EditorForm<Content: View>: View {
    public let content: Content
    public let isSpinning: Bool

    public init(isSpinning: Bool, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.isSpinning = isSpinning
    }

    public var body: some View {
        ZStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        content.frame(width: geometry.size.width)
                    }
                }.disabled(isSpinning)
            }

            if isSpinning {
                VStack {
                    HStack { Spacer() }
                    Spacer()
                    ProgressView()
                        .progressViewStyle(.indeterminateCircle())
                    Spacer()
                }
                    .background(Color.backgroundGrouped.opacity(0.5).edgesIgnoringSafeArea(.all))
            }
        }
            .background(Color.backgroundGrouped.edgesIgnoringSafeArea(.all))
            .navigationBarStyle(.modal)
    }
}

public struct EditorSection<Label: View, Content: View>: View {
    public let content: Content
    public let label: Label
    private var hasLabel = true

    public init(label: Label, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.label = label
    }

    public init(@ViewBuilder content: () -> Content) where Label == Text {
        self.content = content()
        self.label = Text(verbatim: "")
        self.hasLabel = false
    }

    public var body: some View { SwiftUI.Group {
        HStack {
            label
                .font(.semibold14).foregroundColor(.textDark)
                .padding(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16))
                .accessibility(hidden: !hasLabel)
                .accessibility(addTraits: .isHeader)
            Spacer()
        }
        Divider()
        content.background(Color.backgroundLightest)
        Divider()
    } }
}

public struct EditorRow<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        HStack(spacing: 0) { content }
            .font(.semibold16).foregroundColor(.textDarkest)
            .padding(.horizontal, 16).padding(.vertical, 12)
            .frame(minHeight: 52)
            .background(Color.backgroundLightest)
    }
}

public struct ButtonRow<Content: View>: View {
    public let action: () -> Void
    public let content: Content

    public init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
    }

    public var body: some View {
        Button(action: action, label: {
            EditorRow { content }
        })
    }
}

public struct TextFieldRow: View {
    public let label: Text
    public let placeholder: String
    @Binding public var text: String

    public init(label: Text, placeholder: String, text: Binding<String>) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
    }

    public var body: some View {
        EditorRow {
            label
                .accessibility(hidden: true)
            Spacer()
            TextField(placeholder, text: $text)
                .multilineTextAlignment(.trailing)
                .font(.regular16).foregroundColor(.textDarkest)
                .accessibility(label: label)
        }
    }
}

public struct DoubleFieldRow: View {
    public let label: Text
    public let placeholder: String
    @Binding public var value: Double?

    public init(label: Text, placeholder: String, value: Binding<Double?>) {
        self.label = label
        self.placeholder = placeholder
        self._value = value
    }

    public var body: some View {
        TextFieldRow(label: label, placeholder: placeholder, text: Binding(
            get: { value.flatMap { DoubleFieldRow.formatter.string(from: NSNumber(value: $0)) } ?? "" },
            set: { value = DoubleFieldRow.formatter.number(from: $0)?.doubleValue }
        ))
            .keyboardType(.decimalPad)
    }

    public static var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.isLenient = true
        formatter.numberStyle = .decimal
        return formatter
    }()
}

public struct IntFieldRow: View {
    public let label: Text
    public let placeholder: String
    @Binding public var value: Int?

    public init(label: Text, placeholder: String, value: Binding<Int?>) {
        self.label = label
        self.placeholder = placeholder
        self._value = value
    }

    public var body: some View {
        TextFieldRow(label: label, placeholder: placeholder, text: Binding(
            get: { value.flatMap { IntFieldRow.formatter.string(from: NSNumber(value: $0)) } ?? "" },
            set: { value = IntFieldRow.formatter.number(from: $0)?.intValue }
        ))
            .keyboardType(.numberPad)
    }

    public static var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.allowsFloats = false
        formatter.isLenient = true
        formatter.numberStyle = .decimal
        return formatter
    }()
}

public struct ToggleRow: View {
    public let label: Text
    @Binding public var value: Bool

    public init(label: Text, value: Binding<Bool>) {
        self.label = label
        self._value = value.animation()
    }

    public var body: some View {
        Toggle(isOn: $value) { label }
            .font(.semibold16).foregroundColor(.textDarkest)
            .padding(16)
            .background(Color.backgroundLightest)
    }

    public static var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.isLenient = true
        formatter.numberStyle = .decimal
        return formatter
    }()
}

public struct CheckmarkRow<Label: View>: View {
    @Binding public var isChecked: Bool
    private let label: Label

    public init(isChecked: Binding<Bool>, label: Label) {
        self._isChecked = isChecked.animation()
        self.label = label
    }

    public var body: some View {
        ButtonRow {
            isChecked.toggle()
        } content: {
            HStack(spacing: 16) {
                label.frame(maxWidth: .infinity, alignment: .leading)
                if isChecked {
                    Image.checkLine
                }
            }
        }
        .accessibilityAddTraits(isChecked ? [.isSelected] : [])
    }
}

public struct DatePickerRow<Label: View>: View {
    @Binding public var date: Date?
    private let label: Label
    private let defaultDate: Date
    private let validFrom: Date
    private let validUntil: Date

    public init(
        date: Binding<Date?>,
        defaultDate: Date = .now,
        validFrom: Date = .distantPast,
        validUntil: Date = .distantFuture,
        label: Label
    ) {
        self._date = date.animation()
        self.defaultDate = defaultDate
        self.validFrom = validFrom
        self.validUntil = validUntil
        self.label = label
    }

    public var body: some View {
        EditorRow {
            HStack(spacing: 16) {
                label

                if date != nil {
                    let binding = Binding(get: { date ?? defaultDate },
                                          set: { newDate in date = newDate })
                    DatePicker(selection: binding,
                               in: validFrom...validUntil,
                               displayedComponents: [.date, .hourAndMinute],
                               label: {})
                } else {
                    HStack(spacing: 4) {
                        Button {
                            date = defaultDate
                        } label: {
                            Text("Date", bundle: .core)
                                .font(.regular17)
                                .padding(.horizontal, 20)
                        }
                        .buttonStyle(.bordered)
                        Button {
                            date = defaultDate
                        } label: {
                            Text("Time", bundle: .core)
                                .font(.regular17)
                                .padding(.horizontal, 20)
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }

                Button {
                    date = nil
                } label: {
                    Image.xLine
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .opacity(date == nil ? 0.3 : 1)
                .disabled(date == nil)
                .accessibilityLabel(String(localized: "Clear date", bundle: .core))
            }
            .frame(minHeight: 36) // To always have the same height despite datepicker visibility
        }

    }
}

#if DEBUG

struct EditorForm_Previews: PreviewProvider {

    static var previews: some View {
        InnerView()
    }

    struct InnerView: View {
        @State var isChecked = true
        @State var isSpinning = false
        @State var date: Date?

        var body: some View {
            EditorForm(isSpinning: isSpinning) {
                EditorSection(label: Text(verbatim: "Section 1")) {
                    CheckmarkRow(isChecked: $isChecked, label: Text(verbatim: "CheckmarkRow"))
                    DatePickerRow(date: $date, label: Text(verbatim: "From"))
                    ButtonRow {
                        isSpinning = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            isSpinning = false
                        }
                    } content: {
                        Text(verbatim: "Loading Toggle Button")
                    }
                }
            }
        }
    }
}

#endif
