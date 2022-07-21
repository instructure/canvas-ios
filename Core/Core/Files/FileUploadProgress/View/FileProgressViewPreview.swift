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

#if DEBUG

import SwiftUI

class FileProgressViewPreview {
    private static let env = PreviewEnvironment()
    private static let context = env.globalDatabase.viewContext
    private static var fileToUpload: File = {
        makeFile()
    }()
    private static var fileUploadStarted: File = {
        let file = makeFile()
        file.bytesSent = 0
        file.taskID = "123"
        return file
    }()
    private static var fileCompleted: File = {
        let file = makeFile()
        file.bytesSent = file.size
        return file
    }()
    private static var fileUploading: File = {
        let file = makeFile()
        file.taskID = "123"
        file.bytesSent = Int(0.75 * Double(file.size))
        return file
    }()
    private static var fileFailed: File = {
        let file = makeFile()
        file.uploadError = "error"
        return file
    }()
    private static func makeFile() -> File {
        let file = File(context: Self.context)
        file.localFileURL = URL(string: "/1655995556.791297.1655995556.791297.1655995556.791297.MOV")!
        file.size = 2_936_013
        file.mimeClass = "video"
        return file
    }

    static var staticPreviews: some View {
        let staticPreviewData = [
            (file: fileToUpload, title: "Waiting For Upload"),
            (file: fileUploadStarted, title: "Upload Started"),
            (file: fileUploading, title: "Upload In Progress"),
            (file: fileCompleted, title: "Upload Completed"),
            (file: fileFailed, title: "Upload Failed")
        ]
        return SwiftUI.Group {
            ForEach(staticPreviewData, id: \.title) { data in
                let viewModel = FileProgressViewModel(file: data.file)
                FileProgressView(viewModel: viewModel)
                    .previewLayout(.sizeThatFits)
                    .previewDisplayName(data.title + " - Light")
            }
            ForEach(staticPreviewData, id: \.title) { data in
                let viewModel = FileProgressViewModel(file: data.file)
                FileProgressView(viewModel: viewModel).preferredColorScheme(.dark)
                    .previewLayout(.sizeThatFits)
                    .previewDisplayName(data.title + " - Dark")
            }
        }
    }

    static var loopDemoPreview: some View {
        let demoViewModel = DemoViewModel(file: Self.makeFile())
        return FileProgressView(viewModel: demoViewModel)
            .frame(maxHeight: .infinity, alignment: .top)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Live Looping Demo")
    }

    static var oneTimeDemoPreview: some View {
        return VStack(spacing: 0) {
            ForEach(0..<6) { _ in
                let demoViewModel = DemoViewModel(file: Self.makeFile(), isInfinite: false)
                FileProgressView(viewModel: demoViewModel)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Live Demo")
    }
}

extension FileProgressViewPreview {

    private class DemoViewModel: FileProgressViewModel {
        private var isFailedLastTime = Bool.random()
        private let isInfinite: Bool
        private let progressIncrementTimeout: DispatchTimeInterval

        init(file: File, isInfinite: Bool = true) {
            self.isInfinite = isInfinite
            self.progressIncrementTimeout = {
                var timeout: Int = 100

                if !isInfinite {
                    timeout += Int.random(in: 0...300)
                }

                return DispatchTimeInterval.milliseconds(timeout)
            }()

            super.init(file: file)
            waitForUpload()
        }

        private func waitForUpload() {
            file.taskID = nil
            file.uploadError = nil
            file.bytesSent = 0

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
                self.startUpload()
            }
        }

        private func startUpload() {
            file.taskID = "1"

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                self.progressUpload()
            }
        }

        private func progressUpload() {
            let increase = file.size / 20
            file.bytesSent += increase
            file.bytesSent = min(file.size, file.bytesSent)

            if file.bytesSent >= 2 * file.size / 3 {
                if !isFailedLastTime {
                    failUpload()
                    isFailedLastTime.toggle()
                    return
                }
            }

            if file.bytesSent == file.size {
                if isInfinite {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
                        self.waitForUpload()
                    }
                    isFailedLastTime.toggle()
                }
                return
            } else {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + progressIncrementTimeout) {
                    self.progressUpload()
                }
            }
        }

        private func failUpload() {
            file.uploadError = "ASD"

            if isInfinite {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
                    self.waitForUpload()
                }
            }
        }
    }
}

#endif
