//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
import CoreData

struct FileUploadProgressWidgetView: View {
    @State var model: FileUploadProgressWidgetViewModel

    var body: some View {
        if model.state != .empty {
            VStack(spacing: 16) {
                ForEach(model.uploadCards) { card in
                    FileUploadProgressCardView(
                        card: card,
                        onDismiss: { model.dismiss(uploadId: card.id) }
                    )
                }
            }
        }
    }
}

#if DEBUG

#Preview("Multiple States") {
    let env = PreviewEnvironment()
    let context = env.globalDatabase.viewContext

    let uploading: FileSubmission = context.insert()
    uploading.assignmentName = "Battery Manufacturing"
    uploading.courseID = "1"
    uploading.assignmentID = "1"
    uploading.isHiddenOnDashboard = false
    let uploadingItem: FileUploadItem = context.insert()
    uploadingItem.fileSubmission = uploading
    uploadingItem.localFileURL = URL.temporaryDirectory.appendingPathComponent("uploading.pdf")
    uploadingItem.fileSize = 1000
    uploadingItem.bytesToUpload = 1000
    uploadingItem.bytesUploaded = 600

    let success: FileSubmission = context.insert()
    success.assignmentName = "Math Homework"
    success.courseID = "1"
    success.assignmentID = "2"
    success.isHiddenOnDashboard = false
    success.isSubmitted = true
    let successItem: FileUploadItem = context.insert()
    successItem.fileSubmission = success
    successItem.localFileURL = URL.temporaryDirectory.appendingPathComponent("success.pdf")
    successItem.apiID = "uploaded-id"
    successItem.fileSize = 1000
    successItem.bytesToUpload = 1000
    successItem.bytesUploaded = 1000

    let failed: FileSubmission = context.insert()
    failed.assignmentName = "Essay Draft"
    failed.courseID = "1"
    failed.assignmentID = "3"
    failed.isHiddenOnDashboard = false
    let failedItem: FileUploadItem = context.insert()
    failedItem.fileSubmission = failed
    failedItem.localFileURL = URL.temporaryDirectory.appendingPathComponent("failed.pdf")
    failedItem.uploadError = "Upload failed"
    failedItem.fileSize = 1000
    failedItem.bytesToUpload = 1000
    failedItem.bytesUploaded = 400

    try? context.save()

    let viewModel = FileUploadProgressWidgetViewModel(
        config: .init(id: .fileUploadProgress, order: 1, isVisible: true),
        listViewModel: FileUploadNotificationCardListViewModel(environment: env)
    )

    return FileUploadProgressWidgetView(model: viewModel)
        .padding()
}

#endif
