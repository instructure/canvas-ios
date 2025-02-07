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

public extension HorizonUI {
    struct FileUploadSheet: View {
        // MARK: - Private Properties

        private let files = FileType.allCases
        @Environment(\.dismiss) private var dismiss

        // MARK: - Dependencies

        private let onTapChoosePhoto: () -> Void
        private let onTapOpenCamera: () -> Void
        private let onTapChooseFile: () -> Void

        // MARK: - Init

        init(
            onTapChoosePhoto: @escaping () -> Void,
            onTapOpenCamera: @escaping () -> Void,
            onTapChooseFile: @escaping () -> Void
        ) {
            self.onTapChoosePhoto = onTapChoosePhoto
            self.onTapOpenCamera = onTapOpenCamera
            self.onTapChooseFile = onTapChooseFile
        }

        public var body: some View {
            VStack(spacing: .huiSpaces.primitives.medium) {
                headerView
                listFiles
                    .background(Color.huiColors.surface.cardPrimary)
                    .huiCornerRadius(level: .level3)
                    .padding(.horizontal, .huiSpaces.primitives.mediumSmall)
            }
            .padding(.vertical, .huiSpaces.primitives.medium)
            .padding(.horizontal, .huiSpaces.primitives.mediumSmall)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.huiColors.primitives.beige11)
        }

        private var headerView: some View {
            ZStack(alignment: .trailing) {
                Text("Upload File")
                    .foregroundStyle(Color.huiColors.primitives.grey125)
                    .huiTypography(.h3)
                    .frame(maxWidth: .infinity)
                HorizonUI.IconButton(HorizonUI.icons.close, type: .white) {
                    dismiss()
                }
                .huiElevation(level: .level2)
            }
            .padding(.horizontal, .huiSpaces.primitives.mediumSmall)
        }

        private var listFiles: some View {
            VStack(spacing: .zero) {
                ForEach(files, id: \.self) { file in
                    Button {
                        switch file {
                        case .choosePhoto: onTapChoosePhoto()
                        case .takePhoto: onTapOpenCamera()
                        case .chooseFile: onTapChooseFile()
                        }
                    } label: {
                        fileRow(type: file)
                    }
                    Divider()
                        .opacity(file == files.last ? 0 : 1)
                }
            }
        }

        private func fileRow(type: FileType) -> some View {
            HStack {
                Text(type.name)
                    .huiTypography(.p1)
                Spacer()
                type.image
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .padding(.horizontal, .huiSpaces.primitives.mediumSmall)
            .foregroundStyle(Color.huiColors.text.body)
            .padding(.vertical, .huiSpaces.primitives.mediumSmall)

        }
    }
}

extension HorizonUI.FileUploadSheet {
    enum FileType: CaseIterable {
        case choosePhoto
        case takePhoto
        case chooseFile

        var name: String {
            switch self {
            case .choosePhoto: String(localized: "Choose Photo or Video")
            case .takePhoto: String(localized: "Take Photo or Video")
            case .chooseFile: String(localized: "Choose File")
            }
        }

        var image: Image {
            switch self {
            case .choosePhoto: Image.huiIcons.image
            case .takePhoto: Image.huiIcons.camera
            case .chooseFile: Image.huiIcons.folder
            }
        }
    }
}

#Preview {
    HorizonUI.FileUploadSheet(onTapChoosePhoto: {}, onTapOpenCamera: {}, onTapChooseFile: {})
}
