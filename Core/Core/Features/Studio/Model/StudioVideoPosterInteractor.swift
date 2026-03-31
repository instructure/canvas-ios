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

import Foundation
import Combine

public protocol StudioVideoPosterInteractor {

    /// - returns: The URL of the poster file. Nil if it wasn't created due to an error.
    func createVideoPosterIfNeeded(
        isVideoCached: Bool,
        mediaFolder: URL,
        videoFile: URL
    ) -> AnyPublisher<URL?, Never>
}

public class StudioVideoPosterInteractorLive: StudioVideoPosterInteractor {
    public typealias PosterFactory = (_ videoFile: URL, _ posterLocation: URL) async throws -> Void

    private let analytics: RemoteLogger
    private let posterFactory: PosterFactory

    /// - parameters:
    ///   - analytics: Since poster creation is not a blocker step we don't throw any errors from here only report them to analytics.
    ///   - posterFactory: For testing purposes. Live implementation should have a default value for this parameter.
    public init(
        analytics: RemoteLogger = .shared,
        posterFactory: @escaping PosterFactory = defaultPosterFactory
    ) {
        self.analytics = analytics
        self.posterFactory = posterFactory
    }

    public func createVideoPosterIfNeeded(
        isVideoCached: Bool,
        mediaFolder: URL,
        videoFile: URL
    ) -> AnyPublisher<URL?, Never> {
        let posterLocation = mediaFolder.appendingPathComponent(
            "poster.png",
            isDirectory: false
        )

        if isVideoCached {
            return Just(posterLocation)
                .eraseToAnyPublisher()
        }

        return Future<URL?, Never> { [weak self] promise in
            Task {
                do {
                    try await self?.posterFactory(videoFile, posterLocation)
                    promise(.success(posterLocation))
                } catch let error {
                    if error.isSourceTrackMissing == false {
                            // Because we swallow all errors they won't be caught and reported
                            // at a higher level so we have to manually report it here to analytics.
                        self?.analytics.logError(
                            name: "Studio Offline Sync Failed",
                            reason: error.localizedDescription
                        )
                    }
                    promise(.success(nil))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    public static func defaultPosterFactory(
        _ videoFile: URL,
        _ posterLocation: URL
    ) async throws {
        try await videoFile.writeVideoPreview(to: posterLocation)
    }
}
