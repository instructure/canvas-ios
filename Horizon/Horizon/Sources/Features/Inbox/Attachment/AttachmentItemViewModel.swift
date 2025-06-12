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
import Foundation

struct AttachmentItemViewModel: Identifiable {
    typealias OnCancel = () -> Void
    typealias OnDelete = (File) -> Void

    var cancelOpacity: Double {
        isLoading ? 1.0 : 0.0
    }
    var checkmarkOpacity: Double {
        isLoading ? 0.0 : 1.0
    }
    var deleteOpacity: Double {
        isLoading ? 0.0 : 1.0
    }
    var spinnerOpacity: Double {
        isLoading ? 1.0 : 0.0
    }
    var isLoading: Bool {
        !file.isUploaded
    }
    var filename: String {
        file.filename
    }
    let id: String = UUID().uuidString
    private let onCancel: OnCancel
    private let onDelete: OnDelete

    private let file: File

    init(_ file: File, onCancel: @escaping OnCancel, onDelete: @escaping OnDelete) {
        self.file = file
        self.onCancel = onCancel
        self.onDelete = onDelete
    }

    func cancel() {
        onCancel()
    }
    func delete() {
        onDelete(file)
    }
}
