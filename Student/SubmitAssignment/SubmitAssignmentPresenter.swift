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
    let env: AppEnvironment = .shared
    let sharedContainer: URL
    var uploadManager = UploadManager(
        identifier: "com.instructure.icanvas.SubmitAssignment.file-uploads",
        sharedContainerIdentifier: "group.instructure.shared"
    )
    weak var view: SubmitAssignmentView?

    private(set) var course: Course? {
        didSet { view?.update() }
    }

    private(set) var assignment: Assignment? {
        didSet { view?.update() }
    }

    private(set) var urls: [URL]? {
        didSet { view?.update() }
    }

    var assignments: Store<GetAssignments>?
    lazy var courses: Store<GetCourses> = env.subscribe(GetCourses()) { [weak self] in
        if self?.course == nil, let course = self?.courses.first {
            self?.select(course: course)
        }
    }

    var defaultCourses: Store<GetCourse>?
    var defaultAssignments: Store<GetAssignment>?

    var isContentValid: Bool {
        return course != nil && assignment != nil && urls != nil
    }

    init?() {
        guard
            let session = LoginSession.mostRecent,
            let appGroup = Bundle.main.appGroupID(),
            let container = URL.sharedContainer(appGroup)
        else { return nil }
        env.userDidLogin(session: session)
        sharedContainer = container
    }

    func selectCourse(_ course: Course, autoSelectAssignment: Bool) {
        self.course = course
        if autoSelectAssignment {
            assignment = nil
            assignments = env.subscribe(GetSubmittableAssignments(courseID: course.id)) { [weak self] in
                self?.assignment = self?.assignment ?? self?.assignments?.first
            }
            assignments?.refresh()
        }
        view?.update()
    }

    func viewIsReady() {
        loadDefaults()
        if let defaultCourses = defaultCourses {
            defaultCourses.refresh(force: true)
        } else {
            courses.refresh()
        }
    }

    func loadDefaults() {
        if let courseID = env.userDefaults?.submitAssignmentCourseID {
            defaultCourses = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
                if self?.course == nil, let course = self?.defaultCourses?.first {
                    self?.selectCourse(course, autoSelectAssignment: false)
                }
                if let assignmentID = self?.env.userDefaults?.submitAssignmentID {
                    self?.defaultAssignments = self?.env.subscribe(GetAssignment(courseID: courseID, assignmentID: assignmentID)) { [weak self] in
                        self?.assignment = self?.assignment ?? self?.defaultAssignments?.first
                    }
                    self?.defaultAssignments?.refresh(force: true)
                }
            }
        }
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
        self.selectCourse(course, autoSelectAssignment: true)
    }

    func select(assignment: Assignment) {
        self.assignment = assignment
    }

    var tasks: [URLSessionTask] = []
    func submit(comment: String?, callback: @escaping () -> Void) {
        guard let assignment = assignment, let urls = urls else { return }
        let uploadContext = FileUploadContext.submission(courseID: assignment.courseID, assignmentID: assignment.id, comment: comment)
        let batchID = "assignment-\(assignment.id)"
        uploadManager.cancel(batchID: batchID)
        let semaphore = DispatchSemaphore(value: 0)
        var error: Error?
        ProcessInfo.processInfo.performExpiringActivity(withReason: "get upload targets") { expired in
            if expired {
                self.uploadManager.sendFailedNotification()
                return
            }
            self.uploadManager.viewContext.perform {
                do {
                    var files: [File] = []
                    for url in urls {
                        let file = try self.uploadManager.add(url: url, batchID: batchID)
                        files.append(file)
                    }
                    for file in files {
                        self.uploadManager.upload(file: file, to: uploadContext) {
                            semaphore.signal()
                        }
                    }
                } catch let e {
                    error = e
                }
            }
            if error != nil {
                self.uploadManager.sendFailedNotification()
            }
            semaphore.wait()
            callback()
        }
    }

    private func load(attachments: [NSItemProvider], into urls: [URL] = [], callback: @escaping ([URL]?, Error?) -> Void) {
        var attachments = attachments
        var urls = urls
        guard let attachment = attachments.popLast() else {
            callback(urls, nil)
            return
        }
        let supported: [UTI] = [.image, .fileURL, .any] // in priority order
        guard let uti = supported.first(where: { attachment.hasItemConformingToTypeIdentifier($0.rawValue) }) else {
            let error = NSError.instructureError(NSLocalizedString("Format not supported", comment: ""))
            callback(nil, error)
            return
        }
        attachment.loadItem(forTypeIdentifier: uti.rawValue, options: nil) { data, error in
            guard let coding = data, error == nil else {
                callback(nil, error)
                return
            }
            let directory = self.sharedContainer
                .appendingPathComponent("share-submit")
                .appendingPathComponent(UUID.string)
            do {
                let newURL: URL
                if let image = coding as? UIImage {
                    newURL = try image.write(to: directory, nameIt: "image")
                } else if let url = coding as? URL {
                    newURL = directory.appendingPathComponent(url.lastPathComponent)
                    try url.move(to: newURL, copy: true)
                } else if let data = coding as? Data {
                    newURL = directory.appendingPathComponent("file")
                    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
                    try data.write(to: newURL)
                } else {
                    throw NSError.instructureError(NSLocalizedString("Format not supported", comment: ""))
                }
                urls.append(newURL)
                self.load(attachments: attachments, into: urls, callback: callback)
            } catch {
                callback(nil, error)
            }
        }
    }
}
