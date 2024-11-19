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

struct AttachedFilesView: View {
    let files: [File]
    let onDeleteFile: (File) -> Void

    var body: some View {
        VStack(spacing: 5) {
            ForEach(files, id: \.self) { file in
                fileView(file)
                    .padding(5)
                    .background(Color.disabledGray.opacity(0.2))
                    .clipShape(.rect(cornerRadius: 8))
            }
        }
    }

    private func fileView(_ file: File) -> some View {
        HStack {
            Size16RegularTextDarkestTitle(title: file.filename)
            Spacer()
            Button {
                withAnimation {
                    onDeleteFile(file)
                }
            } label: {
                Image.troubleLine
                    .padding(5)
            }
        }
    }
}

#if DEBUG
#Preview {
    AttachedFilesView(files: [], onDeleteFile: { _ in })
}
#endif
