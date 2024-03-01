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
    @Binding var isPresented: Bool

    var doneButtonDidTap: (() -> Void)?

    @State private var whatIfScore = ""
    @State private var maximumScore = ""

    var body: some View {
        ZStack {
            Color.black
                .opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                titleLabel
                HStack(spacing: 0) {
                    labels
                    scoreTexts
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.borderMedium, lineWidth: 1)
                )
                .padding(.vertical, 16)
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
            .background(Color.backgroundLight)
            .cornerRadius(6)
            .padding(.horizontal, 48)
        }
        .zIndex(2)
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
                Button {
                    whatIfScore = ""
                } label: {
                    Image(uiImage: .replyLine)
                        .resizable()
                        .frame(width: 14, height: 14)
                }
                .frame(width: 44, height: 42)
                .padding(.trailing, -16)
            }
            Divider()
            maximumScoreText
        }
        .padding(.trailing, 20)
        .frame(height: 89)
    }

    private var titleLabel: some View {
        Text("What-if Score")
            .font(.semibold16)
            .foregroundColor(.textDarkest)
            .multilineTextAlignment(.center)
            .frame(height: 25)
            .padding(.top, 16)
            .padding(.bottom, 8)
            .padding(.horizontal, 16)
    }

    private var whatIfLabel: some View {
        Text("What-if")
            .font(.regular14)
            .foregroundColor(.textDark)
            .padding(.vertical, 12)
            .padding(.trailing, 0)
    }

    private var maximumLabel: some View {
        Text("Maximum")
            .font(.regular14)
            .foregroundColor(.textDark)
            .padding(.vertical, 12)
            .padding(.trailing, 0)
    }

    private var whatIfScoreText: some View {
        TextField("86", text: $whatIfScore)
            .font(.regular14)
            .foregroundColor(.textDarkest)
            .padding(.vertical, 12)
    }

    private var maximumScoreText: some View {
        TextField("100", text: $maximumScore)
            .font(.regular14)
            .foregroundColor(.textDarkest)
            .padding(.vertical, 12)
    }

    private var cancelButton: some View {
        Button {
            isPresented = false
        } label: {
            Text("Cancel")
                .font(.semibold14)
                .foregroundColor(.electric)
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
                .font(.regular14)
                .foregroundColor(.electric)
                .multilineTextAlignment(.center)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        }
    }
}
