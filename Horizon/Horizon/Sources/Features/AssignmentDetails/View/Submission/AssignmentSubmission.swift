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
import Core

struct AssignmentSubmission: View {
    // MARK: - Private Properties
    @State private var textEntry: String = ""
    @State private var isShowSubmissionTypes = false
    @State private var selectedSubmission: AssignmentType?
    @FocusState private var isFocused: Bool
    @Environment(\.viewController) private var controller
    private let keyboardObserveID = "keyboardObserveID"

    // MARK: - Dependence Properties
    let submissionButtonTitle: String
    let geometry: GeometryProxy
    let submissions: [AssignmentType]
    var onSelectSubmissionType: ((Events) -> Void)? = { _ in}
    var onStartTyping: (() -> Void)? = { }

    var body: some View {
        VStack(spacing: 5) {
            if isShowSubmissionTypes {
                submissionTypes

                if let selectedSubmission, selectedSubmission == .textEntry {
                    textEntry(geometry: geometry)
                    submissionButton
                }
            } else {
                showSubmissionTypesButton
            }
            Rectangle()
                .fill(.clear)
                .frame(height: 150)
                .id(keyboardObserveID)

        }
        .onChange(of: isFocused) {
            if isFocused { onStartTyping?() }
        }
    }
}

// MARK: - Custom Views
extension AssignmentSubmission {

    private var showSubmissionTypesButton: some View {
        Button {
            withAnimation {
                isShowSubmissionTypes = true
            }
        } label: {
            Text(submissionButtonTitle)
                .font(.regular14)
                .foregroundStyle(Color.textDarkest)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color.borderMedium.opacity(0.2))
                .clipShape(.rect(cornerRadius: 8))
        }
    }

    private var submissionTypes: some View {
        ForEach(submissions, id: \.self) { item in
            Button {
                selectedSubmission = item
                isFocused = item == .textEntry
            } label: {
                HAssignmentButton(isSelected: selectedSubmission ==  item, assignment: item)
            }
        }
    }

    private func textEntry(geometry: GeometryProxy) -> some View {
        UITextViewWrapper(text: $textEntry) {
            let tv = UITextView()
            tv.isScrollEnabled = false
            tv.textContainer.widthTracksTextView = true
            tv.textContainer.lineBreakMode = .byWordWrapping
            tv.font = UIFont.scaledNamedFont(.regular16)
            tv.translatesAutoresizingMaskIntoConstraints = false
            tv.widthAnchor.constraint(equalToConstant: geometry.frame(in: .global).width - (2 * 16)).isActive = true
            tv.backgroundColor = .backgroundLightest
            tv.layer.cornerRadius = 8
            tv.layer.borderWidth = 1
            tv.layer.borderColor = UIColor.disabledGray.cgColor
            return tv
        }
        .font(.regular16, lineHeight: .condensed)
        .textInputAutocapitalization(.sentences)
        .focused($isFocused)
        .foregroundColor(.textDarkest)
        .frame(minHeight: 100)
    }

    private var submissionButton: some View {
        Button {
            let selectedSubmission = selectedSubmission ?? .textEntry
            switch selectedSubmission {
            case .textEntry:
                onSelectSubmissionType?(.onTextEntry(text: textEntry, controller: controller))
            case .uploadFile:
                break
            }
        } label: {
            Text("Submit Assignment")
                .font(.bold14)
                .foregroundStyle(Color.textLightest)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color.backgroundInfo)
                .cornerRadius(8)
                .opacity(textEntry.isEmpty  ? 0.3 : 1)
                .disabled(textEntry.isEmpty)
        }
    }
}

// MARK: - Events
extension AssignmentSubmission {
    enum Events {
        case onTextEntry(text: String, controller: WeakViewController)
    }
}

#if DEBUG
#Preview {
    GeometryReader { geometry in
        ScrollView {
            AssignmentSubmission(
                submissionButtonTitle: "Submit Assignment",
                geometry: geometry,
                submissions: [.textEntry]
            )
            .padding()
        }
    }
}
#endif
