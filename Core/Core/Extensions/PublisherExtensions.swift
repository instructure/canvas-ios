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

import Foundation
import Combine
import CombineExt
import CoreData

public extension Publisher {
    func sink() -> AnyCancellable {
        sink { _ in } receiveValue: { _ in }
    }

    func bindProgress(_ isLoading: PassthroughRelay<Bool>) -> AnyPublisher<Output, Failure> {
        handleEvents(
            receiveSubscription: { _ in
                isLoading.accept(true)
            },
            receiveCompletion: { _ in
                isLoading.accept(false)
            }
        )
        .eraseToAnyPublisher()
    }
}

public extension Publisher where Output: Collection, Output.Element: NSManagedObject, Failure == Error {
    func parseHtmlContent(
        attribute keyPath: ReferenceWritableKeyPath<Output.Element, String>,
        id: ReferenceWritableKeyPath<Output.Element, String>,
        courseId: String,
        baseURLKey: ReferenceWritableKeyPath<Output.Element, URL?>? = nil,
        htmlParser: HTMLParser
    ) -> AnyPublisher<[Output.Element], Error> {
        let rootURL = URL.Directories.documents
            .appendingPathComponent(URL.Paths.Offline.courseSectionFolder(sessionId: htmlParser.sessionId, courseId: courseId, sectionName: htmlParser.sectionName))
        return self
            .flatMap { dataArray in
                Publishers.Sequence(sequence: dataArray)
                    .setFailureType(to: Error.self)
                    .flatMap { element in
                        let value = element[keyPath: keyPath]
                        let resourceId = element[keyPath: id]
                        var baseURL: URL?
                        if let baseURLKey {
                            baseURL = element[keyPath: baseURLKey]
                        }
                        return htmlParser.parse(value, resourceId: resourceId, courseId: courseId, baseURL: baseURL)
                            .map {
                                return (element, $0)
                            }
                    }
                    .receive(on: DispatchQueue.main)
                    .map { (element: Output.Element, parsedAttribute: String) in
                        let resourceId = element[keyPath: id]
                        let saveFolder = rootURL.appendingPathComponent("\(htmlParser.prefix)-\(resourceId)")
                        let saveURL = saveFolder.appendingPathComponent("body.html")
                        do {

                            try FileManager.default.createDirectory(atPath: saveFolder.path, withIntermediateDirectories: true, attributes: nil)
                            FileManager.default.createFile(atPath: saveURL.path, contents: nil)
                            try parsedAttribute.write(to: saveURL, atomically: true, encoding: .utf8)
                        } catch {
                            Swift.print("ERROR: \(error)")
                        }
                        return element
                    }
                    .collect()
            }
            .eraseToAnyPublisher()
    }

    func parseHtmlContent(
        attribute keyPath: ReferenceWritableKeyPath<Output.Element, String?>,
        id: ReferenceWritableKeyPath<Output.Element, String>,
        courseId: String,
        baseURLKey: ReferenceWritableKeyPath<Output.Element, URL?>? = nil,
        htmlParser: HTMLParser
    ) -> AnyPublisher<[Output.Element], Error> {
        let rootURL = URL.Directories.documents.appendingPathComponent(
            URL.Paths.Offline.courseSectionFolder(
                sessionId: htmlParser.sessionId,
                courseId: courseId,
                sectionName: htmlParser.sectionName)
        )
        return self
            .flatMap { dataArray in
                Publishers.Sequence(sequence: dataArray)
                    .setFailureType(to: Error.self)
                    .flatMap { element in
                        let value = element[keyPath: keyPath] ?? ""
                        let resourceId = element[keyPath: id]
                        var baseURL: URL?
                        if let baseURLKey {
                            baseURL = element[keyPath: baseURLKey]
                        }
                        return htmlParser.parse(value, resourceId: resourceId, courseId: courseId, baseURL: baseURL)
                            .map {
                                return (element, $0)
                            }
                    }
                    .receive(on: DispatchQueue.main)
                    .map { (element: Output.Element, parsedAttribute: String) in
                        let resourceId = element[keyPath: id]
                        let saveFolder = rootURL.appendingPathComponent("\(htmlParser.prefix)-\(resourceId)")
                        let saveURL = saveFolder.appendingPathComponent("body.html")
                        do {
                            try FileManager.default.createDirectory(atPath: saveFolder.path, withIntermediateDirectories: true, attributes: nil)
                            FileManager.default.createFile(atPath: saveURL.path, contents: nil)
                            try parsedAttribute.write(to: saveURL, atomically: true, encoding: .utf8)
                        } catch {
                            Swift.print("ERROR: \(error)")
                        }
                        return element
                    }
                    .collect()
            }
            .eraseToAnyPublisher()
    }
}
