//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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

    var assignments: Store<GetAssignments>?
    lazy var courses: Store<GetCourses>? = env.subscribe(GetCourses(showFavorites: false, perPage: 10)) { [weak self] in
        self?.course = self?.course ?? self?.courses?.first
    }

    var isContentValid: Bool {
        return course != nil && assignment != nil
    }

    init?() {
        guard
            let session = Keychain.mostRecentSession,
            let appGroup = Bundle.main.appGroupID(),
            let container = URL.sharedContainer(appGroup)
        else { return nil }
        env = AppEnvironment()
        env.userDidLogin(session: session)
        sharedContainer = container
    }

    func viewIsReady() {
        courses?.refresh()
    }

    func select(course: Course) {
        self.course = course
    }

    func select(assignment: Assignment) {
        self.assignment = assignment
    }

    func submit(items: [NSExtensionItem], callback: @escaping (Error?) -> Void) {
        guard let assignment = assignment else { return }
        let uploadContext = FileUploadContext.submission(courseID: assignment.courseID, assignmentID: assignment.id)
        let batchID = "assignment-\(assignment.id)"
        var attachments: [NSItemProvider] = []
        for item in items {
            attachments.append(contentsOf: item.attachments ?? [])
        }
        let manager = UploadManager.shared
        manager.cancel(environment: env, batchID: batchID)
        load(attachments: attachments) { urls, error in
            guard let urls = urls, error == nil else {
                callback(error)
                return
            }
            for url in urls {
                manager.add(environment: self.env, url: url, batchID: batchID)
            }
            manager.upload(environment: self.env, batch: batchID, to: uploadContext)
            callback(nil)
        }
    }

    func load(attachments: [NSItemProvider], into urls: [URL] = [], callback: @escaping ([URL]?, Error?) -> Void) {
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
                if let image = UIImage(contentsOfFile: newURL.path), let data = image.normalize().jpegData(compressionQuality: 0.8) {
                    try data.write(to: newURL)
                }
                urls.append(newURL)
                self.load(attachments: attachments, into: urls, callback: callback)
            } catch {
                callback(nil, error)
            }
        }
    }
}
