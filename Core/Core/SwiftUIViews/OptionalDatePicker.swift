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

public struct OptionalDatePicker<Label: View>: View {
    let initial: Date
    let label: Label
    let min: Date
    let max: Date
    let placeholder: Text

    @Binding var selection: Date?

    @State var showDatePicker = false

    public init(
        placeholder: Text = Text("--", bundle: .core),
        selection: Binding<Date?>,
        min: Date? = nil,
        max: Date? = nil,
        initial: Date,
        @ViewBuilder label: () -> Label
    ) {
        self.label = label()
        self.min = min ?? .distantPast
        self.max = max ?? .distantFuture
        self.initial = Swift.min(self.max, Swift.max(self.min, initial))
        self.placeholder = placeholder
        self._selection = selection
    }

    public var body: some View {
        if #available(iOSApplicationExtension 14, *) {
            compact
        } else {
            wheel
        }
    }

    @ViewBuilder
    var compact: some View {
        if let current = selection {
            HStack(spacing: 0) {
                DatePicker(
                    selection: Binding(get: { current }, set: { selection = $0 }),
                    in: min...max
                ) {
                    label
                }
                    .padding(.vertical, -4)
                Button(action: { withAnimation(.default) {
                    showDatePicker = false
                    selection = nil
                } }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.textDark)
                })
                    .accessibility(label: Text("Remove date", bundle: .core))
                    .padding(.leading, 12)
            }
                .font(.semibold16).foregroundColor(.textDarkest)
                .padding(.horizontal, 16).padding(.vertical, 12)
                .frame(minHeight: 52)
        } else {
            ButtonRow(action: {
                withAnimation(.default) { selection = initial }
            }, content: {
                label
                Spacer()
                placeholder
                    .font(.medium16).foregroundColor(.textDark)
            })
        }
    }

    public var wheel: some View {
        VStack(spacing: 0) {
            ButtonRow(action: {
                if showDatePicker == false, selection == nil {
                    selection = initial
                }
                withAnimation(.default) { showDatePicker.toggle() }
            }, content: {
                label
                Spacer()
                (selection.map { Text($0.dateTimeString) } ?? placeholder)
                    .font(.regular14)
                if selection != nil {
                    Button(action: { withAnimation(.default) {
                        showDatePicker = false
                        selection = nil
                    } }, label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.textDark)
                    })
                        .accessibility(label: Text("Remove date", bundle: .core))
                        .padding(.leading, 12)
                }
            })

            if showDatePicker {
                Divider()
                DatePicker(
                    selection: Binding(get: { selection ?? initial }, set: { selection = $0 }),
                    in: min...max
                ) {
                    label
                }
                    .labelsHidden()
            }
        }
    }
}
