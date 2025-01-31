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

import Core
import Foundation
import SwiftUI

enum HorizonRoutes {
    static func routeHandlers() -> [RouteHandler] {
        routes.flatMap { $0 }
    }

    private static let routes = [
        splashRoutes,
        moduleRoutes,
        pageRoutes,
        courseRoutes,
        fileRoutes,
        quizRoutes,
        assignmentRoutes,
        inboxRoutes,
        externalToolRoutes,
        notebookRoutes,
        aiRoutes
    ]

    private static var splashRoutes: [RouteHandler] {
        [
            RouteHandler("/splash") { _, _, _ in
                SplashAssembly.makeViewController()
            }
        ]
    }

    private static var moduleRoutes: [RouteHandler] {
        [
            RouteHandler("/courses/:courseID/module_item_redirect/:itemID") { url, params, _, env in
                guard let courseID = params["courseID"], let itemID = params["itemID"] else { return nil }
                return ModuleItemSequenceAssembly.makeItemSequenceView(
                    environment: env,
                    courseID: courseID,
                    assetType: .moduleItem,
                    assetID: itemID,
                    url: url
                )
            },
            RouteHandler("/courses/:courseID/modules/items/:itemID") { url, params, _, env in
                guard let courseID = params["courseID"], let itemID = params["itemID"] else { return nil }
                return ModuleItemSequenceAssembly.makeItemSequenceView(
                    environment: env,
                    courseID: courseID,
                    assetType: .moduleItem,
                    assetID: itemID,
                    url: url
                )
            },
            RouteHandler("/courses/:courseID/modules/:moduleID/items/:itemID") { url, params, _, env in
                guard let courseID = params["courseID"], let itemID = params["itemID"] else { return nil }
                return ModuleItemSequenceAssembly.makeItemSequenceView(
                    environment: env,
                    courseID: courseID,
                    assetType: .moduleItem,
                    assetID: itemID,
                    url: url
                )
            }
        ]
    }

    private static var pageRoutes: [RouteHandler] {
        [
            RouteHandler("/:context/:contextID/pages") { url, _, _ in
                guard let context = Context(path: url.path) else { return nil }
                return PageListViewController.create(context: context, app: .student)
            },
            RouteHandler("/:context/:contextID/pages/:url", factory: pageViewController)
        ]
    }

    private static var courseRoutes: [RouteHandler] {
        [
            RouteHandler("/courses/:courseID") { _, _, userInfo in
                guard let course = userInfo?["course"] as? HCourse else { return nil }
                return LearnAssembly.makeCourseDetailsViewController(course: course)
            }
        ]
    }

    private static var fileRoutes: [RouteHandler] {
        [
            RouteHandler("/files", factory: fileList),
            RouteHandler("/:context/:contextID/files", factory: fileList),
            RouteHandler("/files/folder/*subFolder", factory: fileList),
            RouteHandler("/:context/:contextID/files/folder/*subFolder", factory: fileList),
            RouteHandler("/folders/:folderID/edit") { _, params, _ in
                guard let folderID = params["folderID"] else { return nil }
                return CoreHostingController(FileEditorView(folderID: folderID))
            },
            RouteHandler("/files/:fileID", factory: fileDetails),
            RouteHandler("/files/:fileID/download", factory: fileDetails),
            RouteHandler("/files/:fileID/preview", factory: fileDetails),
            RouteHandler("/files/:fileID/edit", factory: fileEditor),
            RouteHandler("/:context/:contextID/files/:fileID", factory: fileDetails),
            RouteHandler("/:context/:contextID/files/:fileID/download", factory: fileDetails),
            RouteHandler("/:context/:contextID/files/:fileID/preview", factory: fileDetails),
            RouteHandler("/:context/:contextID/files/:fileID/edit", factory: fileEditor)
        ]
    }

    private static var quizRoutes: [RouteHandler] {
        [
            RouteHandler("/courses/:courseID/quizzes") { _, params, _ in
                guard let courseID = params["courseID"] else { return nil }
                return QuizListViewController.create(courseID: ID.expandTildeID(courseID))
            },

            RouteHandler("/courses/:courseID/quizzes/:quizID") { url, params, _, env in
                guard let courseID = params["courseID"], let quizID = params["quizID"] else { return nil }
                if !url.originIsModuleItemDetails {
                    return ModuleItemSequenceAssembly.makeItemSequenceView(
                        environment: env,
                        courseID: courseID,
                        assetType: .quiz,
                        assetID: quizID,
                        url: url
                    )
                }
                return StudentQuizDetailsViewController.create(courseID: courseID, quizID: quizID)
            }
        ]
    }

    private static var assignmentRoutes: [RouteHandler] {
        [
            RouteHandler("/courses/:courseID/assignments/:assignmentID") { url, params, _, env in
                guard let courseID = params["courseID"], let assignmentID = params["assignmentID"] else { return nil }
                if assignmentID == "syllabus" {
                    return SyllabusTabViewController.create(courseID: ID.expandTildeID(courseID))
                }
                if !url.originIsModuleItemDetails {
                    return ModuleItemSequenceAssembly.makeItemSequenceView(
                        environment: env,
                        courseID: ID.expandTildeID(courseID),
                        assetType: .assignment,
                        assetID: ID.expandTildeID(assignmentID),
                        url: url
                    )
                }
                return nil
            }
        ]
    }

    private static var inboxRoutes: [RouteHandler] {
        [
            RouteHandler("/conversations/:conversationID") { _, params, userInfo in
                guard let conversationID = params["conversationID"] else { return nil }
                let allowArchive: Bool = {
                    if let userInfo, let allowArchiveParam = userInfo["allowArchive"] as? Bool {
                        return allowArchiveParam
                    } else {
                        return true
                    }
                }()
                return MessageDetailsAssembly.makeViewController(
                    env: AppEnvironment.shared,
                    conversationID: conversationID,
                    allowArchive: allowArchive
                )
            }
        ]
    }

    private static var externalToolRoutes: [RouteHandler] {
        [
            RouteHandler("/courses/:courseID/external_tools/:toolID") { _, params, _ in
                guard let courseID = params["courseID"], let toolID = params["toolID"] else { return nil }
                guard let vc = AppEnvironment.shared.window?.rootViewController?.topMostViewController() else { return nil }
                let tools = LTITools(context: .course(courseID), id: toolID, isQuizLTI: nil)
                tools.presentTool(from: vc, animated: true)
                return nil
            }
        ]
    }

    private static var notebookRoutes: [RouteHandler] {
        [
            RouteHandler("/notebook") { _, _, _ in
                return NotebookCourseListAssembly.makeViewController()
            },
            RouteHandler("/notebook/:courseID") { _, params, _ in
                guard let courseId = params["courseID"] else { return nil }
                return NotebookCourseAssembly.makeView(courseId: courseId	)
            },
            RouteHandler("/notebook/note/:noteID") { _, params, _ in
                guard let noteId = params["noteID"] else { return nil }
                guard let vc = AppEnvironment.shared.window?.rootViewController?.topMostViewController() else { return nil }
                let router: Router = AppEnvironment.shared.router
                router.show(
                    NotebookNoteAssembly.makeViewNoteViewController(noteId: noteId),
                    from: vc,
                    options: .modal(.pageSheet)
                )
                return nil
            }
        ]
    }

    private static var aiRoutes: [RouteHandler] {
        [
            RouteHandler("/tutor") { _, _, _ in
                ChatBotAssembly.makeAITutorView()
            },
            RouteHandler("/summary") { _, _, _ in
                ChatBotAssembly.makeAISummaryView()
            }
        ]
    }
}

// MARK: - Helper functions

extension HorizonRoutes {
    private static func fileList(
        url: URLComponents,
        params: [String: String],
        userInfo: [String: Any]?,
        environment: AppEnvironment
    ) -> UIViewController? {
        guard url.queryItems?.contains(where: { $0.name == "preview" }) != true else {
            return fileDetails(url: url, params: params, userInfo: userInfo, environment: environment)
        }
        return FileListViewController.create(
            env: environment,
            context: Context(path: url.path) ?? .currentUser,
            path: params["subFolder"]
        )
    }

    private static func fileDetails(
        url: URLComponents,
        params: [String: String],
        userInfo _: [String: Any]?,
        environment: AppEnvironment
    ) -> UIViewController? {
        guard let fileID = url.queryItems?.first(where: { $0.name == "preview" })?.value ?? params["fileID"] else { return nil }
        var context = Context(path: url.path)
        if let courseID = url.queryItems?.first(where: { $0.name == "courseID" })?.value {
            context = Context(.course, id: courseID)
        }
        let assignmentID = url.queryItems?.first(where: { $0.name == "assignmentID" })?.value
        if !url.originIsModuleItemDetails, !url.skipModuleItemSequence, let context = context, context.contextType == .course {
            return ModuleItemSequenceAssembly.makeItemSequenceView(
                environment: environment,
                courseID: context.id,
                assetType: .file,
                assetID: fileID,
                url: url
            )
        }
        return FileDetailsViewController.create(context: context, fileID: fileID, originURL: url, assignmentID: assignmentID)
    }

    private static func fileEditor(url: URLComponents, params: [String: String], userInfo _: [String: Any]?) -> UIViewController? {
        guard let fileID = params["fileID"] else { return nil }
        return CoreHostingController(FileEditorView(context: Context(path: url.path), fileID: fileID))
    }

    private static func pageViewController(
        url: URLComponents,
        params: [String: String],
        userInfo _: [String: Any]?,
        environment: AppEnvironment
    ) -> UIViewController? {
        guard let context = Context(path: url.path), let pageURL = params["url"] else { return nil }
        if !url.originIsModuleItemDetails, context.contextType == .course {
            return ModuleItemSequenceAssembly.makeItemSequenceView(
                environment: environment,
                courseID: context.id,
                assetType: .page,
                assetID: pageURL,
                url: url
            )
        }
        return PageDetailsViewController.create(context: context, pageURL: pageURL, app: .student)
    }
}
