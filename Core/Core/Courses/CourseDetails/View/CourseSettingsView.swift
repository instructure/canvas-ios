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

public struct CourseSettingsView: View {

    @ObservedObject private var viewModel: CourseSettingsViewModel
    @State var isLoading = true
    @State var isLoaded = false
    @State var isSaving = false
    public init(viewModel: CourseSettingsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        EditorForm(isSpinning: isLoading || isSaving) {
            EditorSection(label: Text("Name", bundle: .core)) {
                HStack {
                    Text("Name")
                }
                HStack {
                    Text("Set 'Home' to...")
                }

            }
        }
        .navigationBarItems(
            trailing:
            Button(action: save, label: {
                Text("Done", bundle: .core).font(.bold17)
            })
            .disabled(isLoading || isSaving)
            .identifier("CourseSettings.doneButton")
        )
    }

    private func save() {
    }
}

#if DEBUG
/*
struct CourseSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        CourseSettingsView()
    }
}
*/
#endif
