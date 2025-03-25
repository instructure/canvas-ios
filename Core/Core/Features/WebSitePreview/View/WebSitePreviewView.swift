//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

public struct WebSitePreviewView: View {
    @Environment(\.viewController) var controller
    @StateObject private var viewModel = WebSitePreviewViewModel()

    public init() {
    }

    public var body: some View {
        EditorForm(isSpinning: viewModel.isLoading) {
            locationSection
            headersSection
            launchButton
        }
        .navigationBarTitleView("WebSite Preview")
        .navigationBarStyle(.modal)
        .onAppear {
            viewModel.viewController = controller
        }
    }

    private var locationSection: some View {
        EditorSection(label: Text(verbatim: "Website Location")) {
            TextFieldRow(label: Text(verbatim: "Base URL"),
                         placeholder: "",
                         text: .constant(viewModel.baseURL))
                .disabled(true)
            Divider()
            TextFieldRow(label: Text(verbatim: "Path"),
                         placeholder: "Enter Path",
                         text: $viewModel.path)
        }
    }

    private var headersSection: some View {
        EditorSection(label: Text(verbatim: "Header Fields")) {
            ForEach(viewModel.headerKeys, id: \.self) { key in
                let value = viewModel.headers[key]!
                ButtonRow(action: { showEditHeaderAlert(key: key, value: value) }) {
                    Text(verbatim: "\(key): \(viewModel.headers[key]!)")
                        .foregroundColor(Color(Brand.shared.linkColor))
                    Spacer()
                }
                Divider()
            }
            ButtonRow(action: showAddHeaderAlert) {
                Image.addSolid.size(18)
                    .padding(.trailing, 12)
                    .foregroundColor(Color(Brand.shared.linkColor))
                Text(verbatim: "Add New Header")
                    .foregroundColor(Color(Brand.shared.linkColor))
                Spacer()
            }
        }
    }

    private var launchButton: some View {
        EditorSection {
            ButtonRow(action: viewModel.launchSessionTapped) {
                Text(verbatim: "Launch Session")
                    .foregroundColor(Color(Brand.shared.linkColor))
                Spacer()
                InstDisclosureIndicator()
            }
        }
    }

    private func showAddHeaderAlert() {
        let alert = UIAlertController(title: "Add New Header Field", message: "", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Key"
        }
        alert.addTextField { textField in
            textField.placeholder = "Value"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            let enteredKey = alert.textFields?[0].text ?? ""
            let enteredValue = alert.textFields?[1].text ?? ""

            if !enteredKey.isEmpty {
                withAnimation {
                    viewModel.setHeader(key: enteredKey, value: enteredValue)
                }
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        controller.value.present(alert, animated: true)
    }

    private func showEditHeaderAlert(key: String, value: String) {
        let alert = UIAlertController(title: "Edit \(key)", message: "", preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "Value"
            textField.text = value
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            let enteredValue = alert.textFields?[0].text ?? ""
            withAnimation {
                viewModel.setHeader(key: key, value: enteredValue)
            }
        })
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            withAnimation {
                viewModel.deleteKey(key)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        controller.value.present(alert, animated: true)
    }
}

struct WebSitePreviewView_Previews: PreviewProvider {
    static var previews: some View {
        setupPreview()
        return WebSitePreviewView()
    }

    private static func setupPreview() {
        AppEnvironment.shared.currentSession = LoginSession(baseURL: URL(string: "https://websitepreview.instructure.com")!, userID: "", userName: "")
    }
}
