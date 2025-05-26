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

public struct RemoteAttachmentFile<Content: View>: View {
    private enum Phase {
        case loading, finished(URL), error
    }

    let url: URL?
    let content: (URL) -> Content

    @Environment(\.appEnvironment) private var env

    @State private var phase: Phase = .loading

    public init(url: URL?, content: @escaping (URL) -> Content) {
        self.url = url
        self.content = content
    }

    public var body: some View {

        switch phase {
        case .loading:
            ProgressView()
                .padding(100)
                .frame(maxWidth: .infinity)
                .task {
                    guard let remoteURL = url else {
                        phase = .error
                        return
                    }

                    do {
                        let localURL = try await DownloadToLocalFileTask.execute(remoteURL, using: env)
                        phase = .finished(localURL)
                    } catch {
                        phase = .error
                    }
                }
        case .finished(let url):
            content(url)
        case .error:
            VStack {
                Image
                    .warningSolid
                    .foregroundStyle(.red)
                Button("Reload") {
                    phase = .loading
                }
            }
            .padding(100)
            .frame(maxWidth: .infinity)
        }
    }
}

public enum DownloadToLocalFileTask {

    public static func execute(_ remoteURL: URL, using env: AppEnvironment) async throws -> URL {

        let result: (Data, String) = try await withCheckedThrowingContinuation { continuation in

            env.api.makeRequest(remoteURL) { (data, response, error) in

                let headers = (response as? HTTPURLResponse)?.allHeaderFields
                let disposition = (headers?[HttpHeader.contentDisposition] as? String) ?? ""

                guard
                    let data,
                    let filename = disposition.extractValue(forAttributeName: "filename")
                else {
                    continuation.resume(throwing: error ?? APIAsyncError.invalidResponse)
                    return
                }

                continuation.resume(with: .success((data, filename)))
            }
        }

        let (data, filename) = result
        let cachedFile = URL.cachesDirectory.appending(component: filename)

        try data.write(to: cachedFile)

        return cachedFile
    }
}
