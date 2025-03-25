//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import CoreData
import Core

public class GetRootFolders: UseCase {
    public typealias Model = Folder
    public typealias Response = [APIFolder]

    let pageURL: URL?

    public init(_ url: URL? = nil) {
        pageURL = url
    }

    public var cacheKey: String? { "folders" }

    public func reset(context: NSManagedObjectContext) {
        let all: [Model] = context.fetch(scope: scope)
        context.delete(all)
    }

    public var scope: Scope {
        .where(#keyPath(Folder.parentFolderID), equals: nil, orderBy: #keyPath(Folder.name), naturally: true)
    }

    public func makeRequest(environment: AppEnvironment, completionHandler: @escaping RequestCallback) {
        var folders: [APIFolder] = []
        var resp: URLResponse?
        var err: Error?
        let group = DispatchGroup()
        let handleCourses = { (courses: [APICourse]?, response: URLResponse?, error: Error?) in
            resp = response
            err = error
            courses?.forEach { course in
                group.enter()
                environment.api.makeRequest(GetFolderRequest(context: .course(course.id.value), id: "root")) { (folder, _, _) in
                    if var folder = folder {
                        folder.name = course.name ?? folder.name
                        folders.append(folder)
                    }
                    group.leave()
                }
            }
            group.leave()
        }
        if let url = pageURL {
            group.enter()
            environment.api.exhaust(GetNextRequest<[APICourse]>(path: url.absoluteString), callback: handleCourses)
        } else {
            if let userID = environment.currentSession?.userID { // "self" doesn't work
                group.enter()
                environment.api.makeRequest(GetFolderRequest(context: .user(userID), id: "root")) { (folder, _, _) in
                    if var folder = folder {
                        folder.name = NSLocalizedString("My Files", comment: "")
                        folders.append(folder)
                    }
                    group.leave()
                }
            }
            group.enter()
            environment.api.exhaust(GetCoursesRequest(include: []), callback: handleCourses)
        }
        group.notify(queue: .main) {
            completionHandler(folders, resp, err)
        }
    }
}
