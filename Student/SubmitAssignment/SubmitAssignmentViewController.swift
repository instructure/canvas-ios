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

import UIKit
import Social
import Core

class SubmitAssignmentViewController: SLComposeServiceViewController {
    let env = AppEnvironment.shared
    var courses: Store<GetCourse>?
    var assignments: Store<GetAssignment>?
    var course: Course?
    var assignment: Assignment?
    var urls: [URL] = []
    var error: Error?

    var uploadManager = UploadManager(
        identifier: "com.instructure.icanvas.SubmitAssignment.file-uploads",
        sharedContainerIdentifier: "group.instructure.shared"
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        if let session = LoginSession.mostRecent {
            env.userDidLogin(session: session)
        }
        placeholder = NSLocalizedString("Comments...", comment: "")
        navigationController?.navigationBar.topItem?.rightBarButtonItem?.title = NSLocalizedString("Submit", comment: "")
    }

    override func presentationAnimationDidFinish() {
        super.presentationAnimationDidFinish()
        env.window = view.window
        if let courseID = env.userDefaults?.submitAssignmentCourseID, let assignmentID = env.userDefaults?.submitAssignmentID {
            courses = env.subscribe(GetCourse(courseID: courseID, include: [])) { [weak self] in
                self?.update()
            }
            courses?.refresh(force: true)
            assignments = env.subscribe(GetAssignment(courseID: courseID, assignmentID: assignmentID, include: [])) { [weak self] in
                self?.update()
            }
            assignments?.refresh(force: true)
        }
        let items = extensionContext?.inputItems as? [NSExtensionItem] ?? []
        load(items: items)
    }

    override func isContentValid() -> Bool {
        return course != nil && assignment != nil && !urls.isEmpty && error == nil
    }

    override func didSelectPost() {
        submit(comment: contentText) { [weak self] in
            self?.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        var items: [Any] = []
        let courseItem = SLComposeSheetConfigurationItem()!
        courseItem.title = NSLocalizedString("Course", comment: "")
        courseItem.value = self.course?.name
        courseItem.valuePending = courses?.pending == true
        courseItem.tapHandler = courseItem.valuePending ? nil : { [weak self] in
            guard let self = self else { return }
            let courses = CoursesViewController.create(selectedCourseID: self.course?.id) {
                self.course = $0
                self.assignments = nil
                self.assignment = nil
                self.update()
                self.navigationController?.popViewController(animated: true)
            }
            self.pushConfigurationViewController(courses)
        }
        items.append(courseItem)

        let assignmentItem = SLComposeSheetConfigurationItem()!
        assignmentItem.title = NSLocalizedString("Assignment", comment: "")
        assignmentItem.value = self.assignment?.name
        assignmentItem.valuePending = assignments?.pending == true
        if let course = self.course, !assignmentItem.valuePending {
            assignmentItem.tapHandler = { [weak self] in
                guard let self = self else { return }
                let assignments = AssignmentsViewController.create(courseID: course.id, selectedAssignmentID: self.assignment?.id) {
                    self.assignment = $0
                    self.update()
                    self.navigationController?.popViewController(animated: true)
                }
                self.pushConfigurationViewController(assignments)
            }
        }
        items.append(assignmentItem)
        return items
    }

    func update() {
        if courses?.requested == true, courses?.pending == false, course == nil {
            course = courses?.first
        }
        if assignments?.requested == true, assignments?.pending == false, assignment == nil {
            assignment = assignments?.first
        }
        reloadConfigurationItems()
        validateContent()
    }

    func load(items: [NSExtensionItem]) {
        let loadGroup = DispatchGroup()
        for item in items {
            item.attachments?.forEach { attachment in
                loadGroup.enter()
                load(attachment: attachment) { [weak self] result in
                    switch result {
                    case .success(let url):
                        self?.urls.append(url)
                    case .failure(let error):
                        self?.error = error
                    }
                    loadGroup.leave()
                }
            }
        }
        loadGroup.notify(queue: .main) {
            self.update()
        }
    }

    func load(attachment: NSItemProvider, callback: @escaping (Result<URL, Error>) -> Void) {
        let supported: [UTI] = [.image, .fileURL, .any] // in priority order
        guard let uti = supported.first(where: { attachment.hasItemConformingToTypeIdentifier($0.rawValue) }) else {
            let error = NSError.instructureError(NSLocalizedString("Format not supported", comment: ""))
            callback(.failure(error))
            return
        }
        attachment.loadItem(forTypeIdentifier: uti.rawValue, options: nil) { data, error in
            guard let coding = data, error == nil else {
                callback(.failure(error ?? NSError.internalError()))
                return
            }
            guard let appGroup = Bundle.main.appGroupID(), let container = URL.sharedContainer(appGroup) else {
                callback(.failure(NSError.internalError()))
                return
            }
            let directory = container
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
                callback(.success(newURL))
            } catch {
                callback(.failure(error))
            }
        }
    }

    func submit(comment: String?, callback: @escaping () -> Void) {
        guard let assignment = assignment else { return }
        let urls = self.urls
        let uploadContext = FileUploadContext.submission(
            courseID: assignment.courseID,
            assignmentID: assignment.id,
            comment: comment
        )
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
}
