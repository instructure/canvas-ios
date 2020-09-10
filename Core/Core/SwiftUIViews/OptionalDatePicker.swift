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

@available(iOSApplicationExtension 13.0, *)
public struct OptionalDatePicker<Label: View>: View {
    let label: Label
    let min: Date
    let max: Date
    let initial: Date
    @Binding var selection: Date?
    @State var showDatePicker = false

    public init(selection: Binding<Date?>, min: Date? = nil, max: Date? = nil, initial: Date, @ViewBuilder label: () -> Label) {
        self.label = label()
        self.min = min ?? .distantPast
        self.max = max ?? .distantFuture
        self.initial = initial
        self._selection = selection
    }

    public var body: some View { VStack(alignment: .center, spacing: 0) {
        Button(action: { self.showDatePicker.toggle() }, label: {
            label.font(.semibold16)
            Spacer()
            Text(selection?.dateTimeString ?? NSLocalizedString("--", bundle: .core, comment: ""))
                .font(.regular14)
            if selection != nil {
                Button(action: { self.selection = nil }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .accentColor(.textDark)
                })
            }
        })
            .padding(16)
            .accentColor(.textDarkest)

        if showDatePicker {
            Divider()
            DatePicker(selection: Binding(get: { self.selection ?? self.initial }, set: { self.selection = $0 }), in: self.min...self.max) {
                self.label
            }
                .labelsHidden()
        }
    } }
}
