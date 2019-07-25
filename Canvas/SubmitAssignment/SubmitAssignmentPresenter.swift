//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
import CoreData

protocol SubmitAssignmentView: class {
    func update()
}

class SubmitAssignmentPresenter {
    let env: AppEnvironment
    let sharedContainer: URL
    weak var view: SubmitAssignmentView?

    private(set) var course: Course? {
        didSet {
            assignment = nil
            if let course = course {
                assignments = env.subscribe(GetAssignments(courseID: course.id)) { [weak self] in
                    self?.assignment = self?.assignment ?? self?.assignments?.first
                }
                assignments?.refresh()
            }
            view?.update()
        }
    }

    private(set) var assignment: Assignment? {
        didSet { view?.update() }
    }

    private(set) var urls: [URL]? {
        didSet { view?.update() }
    }

    var assignments: Store<GetAssignments>?
    lazy var courses: Store<GetCourses>? = env.subscribe(GetCourses(showFavorites: false, state: [.available], perPage: 10)) { [weak self] in
        self?.course = self?.course ?? self?.courses?.first
    }

    var isContentValid: Bool {
        return course != nil && assignment != nil && urls != nil
    }

    init?() {
        guard
            let session = Keychain.mostRecentSession,
            let appGroup = Bundle.main.appGroupID(),
            let container = URL.sharedContainer(appGroup)
        else { return nil }
        env = AppEnvironment.shared
        env.userDidLogin(session: session)
        sharedContainer = container
    }

    func viewIsReady() {
        courses?.refresh()
    }

    func load(items: [NSExtensionItem]) {
        var attachments: [NSItemProvider] = []
        for item in items {
            attachments.append(contentsOf: item.attachments ?? [])
        }
        load(attachments: attachments) { [weak self] urls, error in
            if let error = error {
                print("ERROR: \(error)")
            }
            DispatchQueue.main.async {
                self?.urls = urls
            }
        }
    }

    func select(course: Course) {
        self.course = course
    }

    func select(assignment: Assignment) {
        self.assignment = assignment
    }

    func submit(comment: String?) {
        guard let assignment = assignment, let urls = urls else { return }
        let uploadContext = FileUploadContext.submission(courseID: assignment.courseID, assignmentID: assignment.id, comment: comment)
        let batchID = "assignment-\(assignment.id)"
        let manager = UploadManager.shared
        manager.cancel(environment: env, batchID: batchID)
        for url in urls {
            manager.upload(environment: env, url: url, batchID: batchID, to: uploadContext)
        }
    }

    private func load(attachments: [NSItemProvider], into urls: [URL] = [], callback: @escaping ([URL]?, Error?) -> Void) {
        var attachments = attachments
        var urls = urls
        guard let attachment = attachments.popLast() else {
            callback(urls, nil)
            return
        }
        attachment.loadFileRepresentation(forTypeIdentifier: UTI.any.rawValue) { url, error in
            guard let url = url, error == nil else {
                callback(nil, error)
                return
            }
            let newURL = self.sharedContainer
                .appendingPathComponent("share-submit")
                .appendingPathComponent(url.lastPathComponent)
            do {
                try url.move(to: newURL)
                urls.append(newURL)
                self.load(attachments: attachments, into: urls, callback: callback)
            } catch {
                callback(nil, error)
            }
        }
    }
}
