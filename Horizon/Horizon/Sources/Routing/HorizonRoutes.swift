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
import UIKit

public enum HorizonRoutes {
    public static func routeHandlers() -> [RouteHandler] {
        routes.flatMap { $0 }
    }

    private static let routes = [
        accountRoutes,
//        splashRoutes,
        moduleRoutes,
        pageRoutes,
        courseRoutes,
        fileRoutes,
        quizRoutes,
        assignmentRoutes,
        inboxRoutes,
        externalToolRoutes,
        notebookRoutes,
        aiRoutes,
        notificationSettings
    ]

    private static var accountRoutes: [RouteHandler] {
        [
            RouteHandler("/account/profile") { _, _, _ in
                ProfileAssembly.makeViewController()
            },
            RouteHandler("/account/advanced") { _, _, _ in
                ProfileAdvancedAssembly.makeViewController()
            }
        ]
    }

    /*
     private static var splashRoutes: [RouteHandler] {
         [
             RouteHandler("/splash") { _, _, _ in
                 SplashAssembly.makeViewController()
             }
         ]
     }
     */

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
            RouteHandler("/courses/:courseID/modules/items/:itemID") { url, params, userInfo, env in

                guard let courseID = params["courseID"],
                      let itemID = params["itemID"] else { return nil }
                let course = userInfo?["moduleItem"] as? HModuleItem

                var assetType: GetModuleItemSequenceRequest.AssetType?
                if let assetTypeRaw = url.queryItems?.first(where: { $0.name == "asset_type" })?.value {
                    assetType = GetModuleItemSequenceRequest.AssetType(rawValue: assetTypeRaw)
                }

                return ModuleItemSequenceAssembly.makeItemSequenceView(
                    environment: env,
                    courseID: courseID,
                    assetType: assetType ?? .moduleItem,
                    assetID: itemID,
                    url: url,
                    firstModuleItem: course
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
            },
            // For displaying a single module item in a modal
            RouteHandler("/courses/:courseID/modules/items/:assetID/:assetType") { _, params, _, _ in
                if let courseID = params["courseID"],
                   let assetID = params["assetID"],
                   let assetType = params["assetType"],
                   let assetTypeEnum = GetModuleItemSequenceRequest.AssetType(rawValue: assetType) {
                    PageDetailsAssembly.makeView(
                        courseID: courseID,
                        assetID: assetID,
                        assetType: assetTypeEnum
                    ).showAsPageSheet()
                }
                return nil
            }
        ]
    }

    private static var pageRoutes: [RouteHandler] {
        [
            RouteHandler("/:context/:contextID/pages") { url, _, _, env in
                guard let context = Context(path: url.path) else { return nil }
                return PageListViewController.create(context: context, app: .student, env: env)
            },
            RouteHandler("/:context/:contextID/pages/:url", factory: pageViewController)
        ]
    }

    private static var courseRoutes: [RouteHandler] {
        [
            RouteHandler("/courses/:courseID/:enrollmentID") { _, params, _ in
                let courseID = params["courseID"] ?? ""
                let enrollmentID = params["enrollmentID"] ?? ""
                return LearnAssembly.makeCourseDetailsViewController(courseID: courseID, enrollmentID: enrollmentID)
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
            RouteHandler("/courses/:courseID/quizzes") { _, params, _, env in
                guard let courseID = params["courseID"] else { return nil }
                return QuizListViewController.create(courseID: ID.expandTildeID(courseID), env: env)
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
                return StudentQuizDetailsViewController
                    .create(courseID: courseID, quizID: quizID, env: env)
            }
        ]
    }

    private static var assignmentRoutes: [RouteHandler] {
        [
            RouteHandler("/courses/:courseID/assignments/:assignmentID") { url, params, _, env in
                guard let courseID = params["courseID"], let assignmentID = params["assignmentID"] else { return nil }
                if assignmentID == "syllabus" {
                    return SyllabusTabViewController
                        .create(
                            context: Context(path: url.path),
                            courseID: ID.expandTildeID(courseID),
                            env: env
                        )
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
            RouteHandler("/conversations") { _, _, _ in HInboxAssembly.makeViewController() },
            RouteHandler("/conversations/create") { _, _, _ in
                guard let vc = AppEnvironment.shared.window?.rootViewController?.topMostViewController() else { return nil }
                let router: Router = AppEnvironment.shared.router
                router.show(
                    HCreateMessageAssembly.makeViewController(),
                    from: vc,
                    options: .modal(.pageSheet, isDismissable: false)
                )
                return nil
            },
            RouteHandler("/conversations/:conversationID") { _, params, userInfo in
                guard let conversationID = params["conversationID"] else { return nil }
                let allowArchive: Bool = {
                    if let userInfo, let allowArchiveParam = userInfo["allowArchive"] as? Bool {
                        return allowArchiveParam
                    } else {
                        return true
                    }
                }()
                return HorizonMessageDetailsAssembly.makeViewController(
                    conversationID: conversationID,
                    allowArchive: allowArchive
                )
            },
            RouteHandler("/announcements/:announcementID") { _, params, userInfo in
                guard let announcementID = params["announcementID"] else { return nil }
                let announcement = userInfo?["announcement"] as? Announcement
                return HorizonMessageDetailsAssembly.makeViewController(
                    announcementID: announcementID,
                    announcement: announcement // Pass the announcement if available
                )
            }
        ]
    }

    private static var externalToolRoutes: [RouteHandler] {
        [
            RouteHandler("/courses/:courseID/external_tools/:toolID") { _, params, _, env in
                guard let courseID = params["courseID"], let toolID = params["toolID"] else { return nil }
                guard let vc = AppEnvironment.shared.window?.rootViewController?.topMostViewController() else { return nil }
                let tools = LTITools(context: .course(courseID), id: toolID, isQuizLTI: nil, env: env)
                tools.presentTool(from: vc, animated: true)
                return nil
            }
        ]
    }

    private static var notebookRoutes: [RouteHandler] {
        [
            RouteHandler("/notebook") { url, _, _ in
                let courseID = url.queryItems?.first(where: { $0.name == "courseID" })?.value
                let pageURL = url.queryItems?.first(where: { $0.name == "pageURL" })?.value

                if let courseID = courseID,
                   let pageURL = pageURL,
                   let vc = AppEnvironment.shared.window?.rootViewController?.topMostViewController() {
                    let router: Router = AppEnvironment.shared.router
                    router.show(
                        NotebookAssembly.makeViewController(courseID: courseID, pageURL: pageURL),
                        from: vc,
                        options: .modal(.fullScreen, isDismissable: false)
                    )
                    return nil
                }
                return NotebookAssembly.makeViewController()
            },
            RouteHandler("/notebook/note") { _, _, userInfo in
                guard let courseNotebookNote = userInfo?["note"] as? CourseNotebookNote else { return nil }
                guard let vc = AppEnvironment.shared.window?.rootViewController?.topMostViewController() else { return nil }
                let router: Router = AppEnvironment.shared.router
                router.show(
                    EditNotebookAssembly.makeViewNoteViewController(courseNotebookNote: courseNotebookNote),
                    from: vc,
                    options: .modal(.pageSheet, isDismissable: false)
                )
                return nil
            }
        ]
    }

    private static var aiRoutes: [RouteHandler] {
                [
                    RouteHandler("/assistant") { url, _, _ in
                        let routingParams = url.queryItems.map { AssistAssembly.RoutingParams(from: $0) }
                        return AssistAssembly.makeAssistChatView(
                            courseID: routingParams?.courseID,
                            pageURL: routingParams?.pageURL,
                            fileID: routingParams?.fileID,
                            textSelection: routingParams?.textSelection
                        )
                    },
                    RouteHandler("/assistant/flashcards") { url, _, userInfo in
                        let flashCards = userInfo?["flashCards"] as? [AssistFlashCardModel] ?? []
                        let routingParams = url.queryItems.map { AssistAssembly.RoutingParams(from: $0) }
                        return CoreHostingController(
                            AssistAssembly.makeAIFlashCardView(
                                courseID: routingParams?.courseID,
                                fileID: routingParams?.fileID,
                                pageURL: routingParams?.pageURL,
                                flashCards: flashCards
                            )
                        )
                    },
                    RouteHandler("/assistant/quiz") { url, _, userInfo in
                        let quizzes = userInfo?["quizzes"] as? [AssistQuizModel]
                        let routingParams = url.queryItems.map { AssistAssembly.RoutingParams(from: $0) }
                        let quizView = AssistAssembly.makeAIQuizView(
                            courseID: routingParams?.courseID,
                            fileID: routingParams?.fileID,
                            pageURL: routingParams?.pageURL,
                            quizzes: quizzes ?? []
                        )

                        return CoreHostingController(quizView)
                    }
                ]
            }

    private static var notificationSettings: [RouteHandler] {
        [
            RouteHandler("/notification-settings") { _, _, _ in
                NotificationSettingsAssembly.makeView()
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
        return FileDetailsViewController.create(context: context, fileID: fileID, originURL: url, assignmentID: assignmentID, environment: environment)
    }

    private static func fileEditor(url: URLComponents, params: [String: String], userInfo _: [String: Any]?) -> UIViewController? {
        guard let fileID = params["fileID"] else { return nil }
        return CoreHostingController(FileEditorView(context: Context(path: url.path), fileID: fileID))
    }

    private static func pageViewController(
        url: URLComponents,
        params: [String: String],
        userInfo: [String: Any]?,
        environment: AppEnvironment
    ) -> UIViewController? {
        guard let context = Context(path: url.path), let pageURL = params["url"] else { return nil }

        let courseID = context.id

        if !url.originIsModuleItemDetails, context.contextType == .course {
            return ModuleItemSequenceAssembly.makeItemSequenceView(
                environment: environment,
                courseID: courseID,
                assetType: .page,
                assetID: pageURL,
                url: url
            )
        }
        let viewController = PageDetailsViewController.create(
            context: context,
            pageURL: pageURL,
            app: .student,
            env: .shared
        )
        if let item = userInfo?["item"] as? HModuleItem,
           let type = item.type {
            viewController.webView = HorizonWebView(
                courseID: courseID,
                pageURL: pageURL,
                moduleType: type,
                viewController: WeakViewController(viewController)
            )
        }
        return viewController
    }
}

extension UIViewController {
    func showAsPageSheet() {
        guard let vc = AppEnvironment.shared.window?.rootViewController?.topMostViewController() else { return }
        let router: Router = AppEnvironment.shared.router
        router.show(
            self,
            from: vc,
            options: .modal(.pageSheet, isDismissable: false)
        )
    }
}
