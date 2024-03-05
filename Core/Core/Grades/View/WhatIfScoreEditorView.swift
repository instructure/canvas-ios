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

    var body: some View {
        ZStack {
            Color.black
                .opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                titleLabel
                HStack(spacing: 0) {
                    labels
                    scoreTexts
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.textDark, lineWidth: 0.25)
                )
//                .padding(.vertical, 16)
                .padding(.bottom, 14)
                .padding(.horizontal, 24)

                Divider()
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 0.5)
                    .padding(.all, 0)

                HStack(spacing: 0) {
                    cancelButton
                    Divider()
                        .frame(minWidth: 0, maxWidth: 0.5, minHeight: 0, maxHeight: .infinity)
                    doneButton
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 44)
                .padding([.horizontal, .bottom], 0)
            }
            .background(.ultraThickMaterial)
            .cornerRadius(10)
            .padding(.horizontal, 48)
        }
    }

    private var labels: some View {
        VStack(alignment: .leading, spacing: 0) {
            whatIfLabel
            Divider()
            maximumLabel
        }
        .padding(.leading, 20)
        .frame(height: 89)
    }

    private var scoreTexts: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                whatIfScoreText
                Spacer()
                revertButton
            }
            Divider()
            maximumScoreText
        }
        .padding(.trailing, 20)
        .frame(height: 89)
    }

    private var revertButton: some View {
        Button {
            whatIfScore = ""
        } label: {
            Image(uiImage: .replyLine)
                .resizable()
                .frame(width: 14, height: 14)
                .foregroundColor(.textDark)
        }
        .frame(width: 44, height: 42)
        .padding(.trailing, -16)
        .accessibilityLabel(Text("Revert"))
        .accessibilityHint(Text("Double tap to remove what-if score"))
    }

    private var titleLabel: some View {
        Text("What-if Score")
            .font(.system(size: 17, weight: .semibold, design: .default))
//            .foregroundColor(.textDarkest)
            .multilineTextAlignment(.center)
            .frame(height: 25)
            .padding(.top, 16)
            .padding(.bottom, 12)
            .padding(.horizontal, 16)
    }

    private var whatIfLabel: some View {
        Text("What-if")
            .font(.system(size: 13, weight: .regular, design: .default))
//            .foregroundColor(.textDark)
            .padding(.vertical, 12)
            .padding(.trailing, 0)
            .accessibilityHidden(true)
    }

    private var maximumLabel: some View {
        Text("Maximum")
            .font(.system(size: 13, weight: .regular, design: .default))
//            .foregroundColor(.textDark)
            .padding(.vertical, 12)
            .padding(.trailing, 0)
            .accessibilityHidden(true)
    }

    private var whatIfScoreText: some View {
        TextField("44", text: $whatIfScore)
            .keyboardType(.decimalPad)
            .font(.system(size: 13, weight: .regular, design: .default))
//            .foregroundColor(.textDarkest)
            .frame(height: 19)
            .padding(.vertical, 12)
            .accessibilityLabel(Text("What-if score is \(whatIfScore)"))
    }

    private var maximumScoreText: some View {
        Text("100")
            .font(.system(size: 13, weight: .regular, design: .default))
//            .foregroundColor(.textDarkest)
            .frame(height: 19)
            .padding(.vertical, 12)
            .accessibilityLabel(Text("Maximum score is 100."))
    }

    private var cancelButton: some View {
        Button {
            isPresented = false
        } label: {
            Text("Cancel")
                .fontWeight(.semibold)
//                .font(.system(size: 16, weight: .bold))
//                .foregroundColor(.electric)
                .multilineTextAlignment(.center)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        }
    }

    private var doneButton: some View {
        Button {
            isPresented = false
            doneButtonDidTap?()
        } label: {
            Text("Done")
//                .font(.system(size: 16))
//                .foregroundColor(.electric)
                .multilineTextAlignment(.center)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
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
