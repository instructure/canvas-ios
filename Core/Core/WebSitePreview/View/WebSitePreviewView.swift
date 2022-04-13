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
    @StateObject private var viewModel = WebSitePreviewViewModel()

    public var body: some View {
        EditorForm(isSpinning: false) {
            locationSection
            headersSection
            launchButton
        }
    }

    private var locationSection: some View {
        EditorSection(label: Text(viewModel.texts.locationSectionTitle)) {
            TextFieldRow(label: Text(viewModel.texts.url), placeholder: "", text: .constant(viewModel.baseURL))
            Divider()
            TextFieldRow(label: Text(viewModel.texts.path), placeholder: "", text: .constant(viewModel.baseURL))
        }
    }

    private var headersSection: some View {
        EditorSection(label: Text(verbatim: viewModel.texts.headerSectionTitle)) {
            ButtonRow(action: viewModel.addNewHeaderTapped) {
                Image.addSolid.size(18)
                    .padding(.trailing, 12)
                    .foregroundColor(Color(Brand.shared.linkColor))
                Text(viewModel.texts.addHeaderButton)
                    .foregroundColor(Color(Brand.shared.linkColor))
                Spacer()
            }
        }
    }

    private var launchButton: some View {
        EditorSection {
            ButtonRow(action: viewModel.launchSessionTapped) {
                Text(viewModel.texts.launchButton)
                    .foregroundColor(Color(Brand.shared.linkColor))
                Spacer()
            }
        }
    }
}

struct WebSitePreviewView_Previews: PreviewProvider {
    static var previews: some View {
        WebSitePreviewView()
    }
}
