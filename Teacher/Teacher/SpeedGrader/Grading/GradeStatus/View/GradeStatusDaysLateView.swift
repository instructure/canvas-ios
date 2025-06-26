//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Core
import SwiftUI

struct GradeStatusDaysLateView: View {
    @Environment(\.viewController) private var viewController
    let daysLate: String
    let dueDate: String
    let isLoading: Bool
    let accessibilityLabel: String
    let accessibilityHint: String
    let onEdit: (Int) -> Void
    @AccessibilityFocusState private var isA11yFocused: Bool

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Days late", bundle: .teacher)
                    .font(.semibold16)
                    .foregroundColor(.textDarkest)
                Text("Due \(dueDate)", bundle: .teacher)
                    .font(.regular14)
                    .foregroundColor(.textDark)
            }
            Spacer()
            if isLoading {
                ProgressView()
                    .tint(nil)
            } else {
                Button(action: presentNumberInputDialog) {
                    HStack(spacing: 17) {
                        Text(daysLate)
                            .font(.semibold16)
                        Image.editLine
                            .scaledIcon(size: 18)
                    }
                    .padding(.leading, 10)
                    .padding(.trailing, 18)
                    .padding(.top, 7)
                    .padding(.bottom, 9)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(.tint, lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundStyle(.tint)
            }
        }
        .paddingStyle(.top, .cellTop)
        .paddingStyle(.bottom, .cellBottom)
        .paddingStyle(.horizontal, .standard)
        .background(Color.backgroundLightest)
        .accessibilityElement()
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { presentNumberInputDialog() }
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .accessibilityFocused($isA11yFocused)
        .identifier("SpeedGrader.DaysLateButton")
    }

    private func presentNumberInputDialog() {
        let alert = UIAlertController(
            title: String(localized: "Enter days late", bundle: .teacher),
            message: nil,
            preferredStyle: .alert
        )
        alert.addTextField { textField in
            textField.placeholder = String(localized: "Days late", bundle: .teacher)
            textField.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(
            title: String(localized: "Cancel", bundle: .teacher),
            style: .cancel,
            handler: nil
        ))
        alert.addAction(UIAlertAction(
            title: String(localized: "OK", bundle: .teacher),
            style: .default
        ) { _ in
            if let text = alert.textFields?.first?.text, let value = Int(text) {
                onEdit(value)
            }
            isA11yFocused = true
        })
        viewController.value.present(alert, animated: true)
    }
}

#if DEBUG

import UIKit

struct GradeStatusDaysLateView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            CoreHostingControllerPreview {
                GradeStatusDaysLateView(
                    daysLate: "4",
                    dueDate: "2025-02-02 23:59:00",
                    isLoading: false,
                    accessibilityLabel: "",
                    accessibilityHint: "",
                    onEdit: { _ in }
                )
                .tint(Color.red)
            }
            CoreHostingControllerPreview {
                GradeStatusDaysLateView(
                    daysLate: "4",
                    dueDate: "2025-02-02 23:59:00",
                    isLoading: true,
                    accessibilityLabel: "",
                    accessibilityHint: "",
                    onEdit: { _ in }
                )
                .tint(Color.red)
            }
        }
        .previewLayout(.sizeThatFits)
    }
}

struct CoreHostingControllerPreview<Content: View>: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController

    let content: () -> Content
    func makeUIViewController(context: Self.Context) -> UIViewController {
        CoreHostingController(content())
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Self.Context) {}
}

#endif
