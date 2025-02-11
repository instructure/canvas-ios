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

import SwiftUI

public extension HorizonUI.FileUploadSheet {
    struct Storybook: View {
        @State var present: Bool = false

        public var body: some View {
            VStack {
                Button("Present File Sheet") { present.toggle() }
            }
            .sheet(isPresented: $present){
                HorizonUI.FileUploadSheet(onTapChoosePhoto: {},
                                          onTapOpenCamera: {},
                                          onTapChooseFile: {})
                    .presentationCompactAdaptation(.sheet)
                    .presentationCornerRadius(32)
                    .interactiveDismissDisabled()
                    .presentationDetents([.height(300)])
                    .background(.red)
            }
            .navigationTitle("File Upload Sheet")
        }
    }
}

#Preview {
    HorizonUI.FileUploadSheet.Storybook()
}
