//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import AVFoundation
import UniformTypeIdentifiers

extension Sequence where Element == URL {
    public var pathExtensions: Set<String> {
        reduce(into: Set<String>()) {
            if $1.pathExtension != "" {
                $0.insert($1.pathExtension)
            }
        }
    }
}

public extension URL {
    enum Directories {

        public static var temporary: URL {
            URL(fileURLWithPath: NSTemporaryDirectory())
        }

        public static var caches: URL {
            FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        }

        public static func caches(appGroup: String?) -> URL {
            var folder = caches
            if let appGroup = appGroup, let group = sharedContainer(appGroup: appGroup) {
                folder = group.appendingPathComponent("caches", isDirectory: true)
                try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
            }
            return folder
        }

        /// The `Documents` directory in the application's private folder.
        public static var documents: URL {
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        }

        public static var library: URL {
            FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        }

        public static func sharedContainer(appGroup identifier: String) -> URL? {
            FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)
        }

        /// Returns the full url with the file name to where the database should be saved.
        public static func databaseURL(appGroup: String?, session: LoginSession?) -> URL {
            guard let session else {
                return URL.Directories.caches
                    .appendingPathComponent("Database.sqlite", isDirectory: false)
            }

            let documents: URL = {
                if let appGroup, let container = URL.Directories.sharedContainer(appGroup: appGroup) {
                    return container.appendingPathComponent("Documents", isDirectory: true)
                } else {
                    return URL.Directories.documents
                }
            }()

            return documents
                    .appendingPathComponent(session.uniqueID, isDirectory: true)
                    .appendingPathComponent("Offline", isDirectory: true)
                    .appendingPathComponent("Database.sqlite", isDirectory: false)
        }
    }

    enum Paths {
        public enum Offline {

            public static func rootURL(
                sessionID: String
            ) -> URL {
                URL.Directories.documents.appending(path: "\(sessionID)/Offline")
            }

            public static func courseFolder(
                sessionID: String,
                courseId: String
            ) -> String {
                "\(sessionID)/Offline/Files/course-\(courseId)"
            }

            public static func courseSectionFolder(
                sessionId: String,
                courseId: String,
                sectionName: String
            ) -> String {
                "\(sessionId)/Offline/course-\(courseId)/\(sectionName)"
            }

            public static func courseSectionFolderURL(
                sessionId: String,
                courseId: String,
                sectionName: String
            ) -> URL {
                URL.Directories.documents.appendingPathComponent(
                    URL.Paths.Offline.courseSectionFolder(
                        sessionId: sessionId,
                        courseId: courseId,
                        sectionName: sectionName
                    )
                )
            }

            public static func courseSectionResourceFolder(
                sectionName: String,
                resourceId: String
            ) -> String {
                "\(sectionName)-\(resourceId)"
            }

            public static func courseSectionResourceFolderURL(
                sessionId: String,
                courseId: String,
                sectionName: String,
                resourceId: String
            ) -> URL {
                Paths.Offline.courseSectionFolderURL(
                    sessionId: sessionId,
                    courseId: courseId,
                    sectionName: sectionName
                )
                .appendingPathComponent("\(sectionName)-\(resourceId)")
            }
        }
    }

    func lookupFileSize() -> Int {
        guard self.isFileURL else { return 0 }
        let attributes = try? FileManager.default.attributesOfItem(atPath: path)
        return attributes?[FileAttributeKey.size] as? Int ?? 0
    }

    func appendingQueryItems(_ items: URLQueryItem...) -> URL {
        var components = URLComponents.parse(self)
        components.queryItems = (components.queryItems ?? []) + items
        return components.url ?? self
    }

    func containsQueryItem(named key: String) -> Bool {
        let components = URLComponents.parse(self)
        return components.queryValue(for: key) != nil
    }

    func appendingOrigin(_ origin: String) -> URL {
        return appendingQueryItems(.init(name: "origin", value: origin))
    }

    func move(to destination: URL, override: Bool = true, copy: Bool = false) throws {
        let manager = FileManager.default
        if destination.hasDirectoryPath {
            try manager.createDirectory(at: destination, withIntermediateDirectories: true, attributes: nil)
        } else {
            try manager.createDirectory(at: destination.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        }
        if override && manager.fileExists(atPath: destination.path) {
            try manager.removeItem(at: destination)
        }
        if copy {
            try manager.copyItem(at: self, to: destination)
        } else {
            try manager.moveItem(at: self, to: destination)
        }
    }

    func copy(to destination: URL, override: Bool = true) throws {
        try move(to: destination, override: override, copy: true)
    }

    var withCanonicalQueryParams: URL? {
        return URLComponents(url: self, resolvingAgainstBaseURL: false)?.withCanonicalQueryParams.url
    }

    /**
     Returns the base url from this url that can be passed to an API instance.

     Example: https://test.instructure.com/courses/123?param=1 -> https://test.instructure.com
     */
    var apiBaseURL: URL? {
        var components = URLComponents()
        components.host = host
        components.scheme = scheme
        return components.url
    }
}

public extension URL {
    func mimeType() -> String {
        let pathExtension = self.pathExtension
        if let type = UTType(filenameExtension: pathExtension) {
            if let mimetype = type.preferredMIMEType {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }

    /// Returns an image of the first frame of the video located at this url.
    func videoPreview() throws -> UIImage {
        let asset = AVURLAsset(url: self)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        let cgImage = try imageGenerator.copyCGImage(at: .zero, actualTime: nil)

        return UIImage(cgImage: cgImage)
    }

    /// Writes the result of the `videoPreview()` method to the given url in png format.
    func writeVideoPreview(to url: URL) throws {
        let previewImage = try videoPreview()
        guard let imageData = previewImage.pngData() else {
            throw "Failed to convert preview data to png."
        }
        try imageData.write(to: url)
    }
}
