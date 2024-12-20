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

struct WhatIfScoreEditorView: View {
    // MARK: - Dependencies

    @Binding var isPresented: Bool
    var doneButtonDidTap: (() -> Void)?

    // MARK: - Private properties

    @State private var whatIfScore = ""
    @State private var leftColumnWidth: CGFloat?
    @ScaledMetric private var uiScale: CGFloat = 1

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                    .opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 0) {
                    titleLabel
                    VStack(spacing: 0) {
                        whatIfRow(geometry: geometry).frame(minHeight: 30)
                        Divider()
                        maximumRow(geometry: geometry).frame(minHeight: 30)
                    }
                    .padding(.horizontal, 20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.textDark, lineWidth: 0.25)
                    )
                    .padding(.bottom, 14)
                    .padding(.horizontal, 24)

                    Divider()

                    HStack(spacing: 0) {
                        cancelButton
                        doneButton
                    }
                    .overlay(content: { HStack { Divider() } })
                }
                .background(.ultraThickMaterial)
                .cornerRadius(10)
                .frame(maxWidth: 0.7 * geometry.size.width)
            }
            .onPreferenceChange(ViewBoundsKey.self, perform: { value in
                leftColumnWidth = value.max { lh, rh in
                    lh.bounds.width < rh.bounds.width
                }?.bounds.width
            })
        }
        .animation(.none, value: leftColumnWidth)
    }

    private func whatIfRow(geometry: GeometryProxy) -> some View {
        HStack(alignment: .center, spacing: 0) {
            whatIfLabel
                .frame(minWidth: leftColumnWidth, alignment: .leading)
                .transformAnchorPreference(key: ViewBoundsKey.self, value: .bounds) { preferences, bounds in
                    preferences = [.init(viewId: 0, bounds: geometry[bounds])]
                }
            whatIfScoreText
                .padding(.leading, 8)
            revertButton
        }
    }

    private func maximumRow(geometry: GeometryProxy) -> some View {
        HStack(alignment: .center, spacing: 8) {
            maximumLabel
                .frame(minWidth: leftColumnWidth, alignment: .leading)
                .transformAnchorPreference(key: ViewBoundsKey.self, value: .bounds) { preferences, bounds in
                    preferences = [.init(viewId: 1, bounds: geometry[bounds])]
                }
            maximumScoreText
        }
        .frame(minHeight: 42)
    }

    private var revertButton: some View {
        Button {
            whatIfScore = ""
        } label: {
            Image(uiImage: .replyLine)
                .resizable()
                .frame(width: uiScale.iconScale * 14,
                       height: uiScale.iconScale * 14)
                .foregroundColor(.textDark)
        }
        .frame(width: 44)
        .frame(minHeight: 42)
        .padding(.trailing, -16)
        .accessibilityLabel(Text("Revert", bundle: .core))
        .accessibilityHint(Text("Double tap to remove what-if score", bundle: .core))
    }

    private var titleLabel: some View {
        Text("What-if Score", bundle: .core)
            .font(
                .system(
                    size: UIFontMetrics.default.scaledValue(for: 17),
                    weight: .semibold,
                    design: .default
                )
            )
            .multilineTextAlignment(.center)
            .padding(.top, 16)
            .padding(.bottom, 12)
            .padding(.horizontal, 16)
    }

    private var whatIfLabel: some View {
        Text("What-if", bundle: .core)
            .font(
                .system(
                    size: UIFontMetrics.default.scaledValue(for: 13),
                    weight: .regular,
                    design: .default
                )
            )
            .accessibilityHidden(true)
    }

    private var maximumLabel: some View {
        Text("Maximum", bundle: .core)
            .font(
                .system(
                    size: UIFontMetrics.default.scaledValue(for: 13),
                    weight: .regular,
                    design: .default
                )
            )
            .accessibilityHidden(true)
    }

    private var whatIfScoreText: some View {
        TextField("44", text: $whatIfScore)
            .keyboardType(.decimalPad)
            .font(
                .system(
                    size: UIFontMetrics.default.scaledValue(for: 13),
                    weight: .regular,
                    design: .default
                )
            )
            .accessibilityLabel(Text("What-if score is \(whatIfScore)", bundle: .core))
    }

    private var maximumScoreText: some View {
        Text(verbatim: "100")
            .font(
                .system(
                    size: UIFontMetrics.default.scaledValue(for: 13),
                    weight: .regular,
                    design: .default
                )
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityLabel(Text("Maximum score is 100.", bundle: .core))
    }

    private var cancelButton: some View {
        Button {
            isPresented = false
        } label: {
            Text("Cancel", bundle: .core)
                .fontWeight(.semibold)
                .foregroundStyle(Color.blue)
                .multilineTextAlignment(.center)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var doneButton: some View {
        Button {
            isPresented = false
            doneButtonDidTap?()
        } label: {
            Text("Done", bundle: .core)
                .foregroundStyle(Color.blue)
                .multilineTextAlignment(.center)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

#if DEBUG

struct WhatIfScoreEditorViewPreview: PreviewProvider {
    static var previews: some View {
        WhatIfScoreEditorView(
            isPresented: .constant(true),
            doneButtonDidTap: nil
        )
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.dark)
        WhatIfScoreEditorView(
            isPresented: .constant(true),
            doneButtonDidTap: nil
        )
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.light)
    }
}

#endif
