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

struct SearchTextField: View {

    @State private var minWidth = DeferredValue<CGFloat?>(value: nil)
    @Binding private var text: String

    private let prompt: String
    private let clearButtonColor: Color
    private let onSubmit: () -> Void

    init(
        text: Binding<String>,
        prompt: String,
        clearButtonColor clearColor: Color = .secondary,
        onSubmit: @escaping () -> Void
    ) {
        self._text = text
        self.prompt = prompt
        self.onSubmit = onSubmit
        self.clearButtonColor = clearColor
    }

    var body: some View {
        HStack(spacing: 0) {
            Image
                .smartSearchSmallLine
                .foregroundStyle(.secondary)
                .fixedSize()
                .accessibilityHidden(true)

            Spacer(minLength: 5)

            TextField("", text: $text, prompt: Text(prompt))
                .textInputAutocapitalization(.never)
                .labelsHidden()
                .submitLabel(.search)
                .font(.regular14)
                .foregroundStyle(Color.textDarkest)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .onSubmit {
                    minWidth.update()
                    onSubmit()
                }

            if text.isNotEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(clearButtonColor)
                }
                .fixedSize()
                .accessibilityLabel(Text("Clear text", bundle: .core))
            }
        }
        .padding(.leading, 10)
        .padding(.trailing, text.isEmpty ? 10 : 3)
        .background(Color.backgroundLightest)
        .clipShape(Capsule())
        .shadow(radius: 2, y: 2)
        .frame(idealWidth: minWidth.value, maxWidth: .infinity)
        .measuringSize { size in
            minWidth.deferred = size.width
        }
        .onDisappear {
            // This is to resolve issue of field size when pushing to result details
            minWidth.update()
        }
    }
}

#Preview {
    SearchTextField(text: .constant(""), prompt: "Search", onSubmit: { })
}
