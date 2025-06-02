//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import UIKit

struct TodoWidgetRouter {

    struct ViewProxy {
        let env: AppEnvironment
        let tabController: UITabBarController

        func selectTab(at index: Int) {
            tabController.selectedIndex = index
        }

        func resetSplitMasterToRoot() {
            (tabController.selectedViewController as? UISplitViewController)?.resetToRoot()
        }

        var selectedTabMasterController: UINavigationController? {
            guard let splitController = tabController.selectedViewController as? UISplitViewController
            else { return nil }
            return splitController.masterNavigationController
        }

        var selectedTabMasterRootController: UIViewController? {
            selectedTabMasterController?.viewControllers.first
        }
    }

    struct RouteHandler {
        let route: Route
        let action: (URLComponents, [String: String], ViewProxy) -> Void

        init(
            _ template: String,
            action: @escaping (URLComponents, [String: String], ViewProxy) -> Void
        ) {
            self.route = Route(template)
            self.action = action
        }
    }

    private let handlers: [RouteHandler]
    fileprivate init(handlers: [RouteHandler]) {
        self.handlers = handlers
    }

    func handling(_ url: URLComponents, in window: UIWindow?, env: AppEnvironment) -> Bool {
        guard url.hasOrigin("todo-widget"),
              let rootViewController = window?.rootViewController,
              let tabController = rootViewController as? StudentTabBarController
        else { return false }

        // Dismiss all modals
        rootViewController.dismiss(animated: false)

        let viewProxy = ViewProxy(
            env: env,
            tabController: tabController
        )

        for handler in handlers {
            if let params = handler.route.match(url) {
                handler.action(url, params, viewProxy)
                return true
            }
        }

        return false
    }
}

// MARK: - Makers

extension TodoWidgetRouter {

    static func make() -> TodoWidgetRouter {
        TodoWidgetRouter(handlers: [
            plannerNotesListHandler,
            newPlannerNoteHandler,
            plannerNoteDetailHandler,
            calendarEventHandler,
            assignmentHandler,
            assignmentWithSubmissionHandler,
            calendarDayHandler
        ])
    }

    private static var plannerNotesListHandler: RouteHandler {
        .init("/todo-widget/planner-notes", action: { _, _, view in
            view.selectTab(at: 2)
            view.resetSplitMasterToRoot()
        })
    }

    private static var newPlannerNoteHandler: RouteHandler {
        .init("/todo-widget/planner-notes/new", action: { _, _, view in
            // Switch to Calendar tab
            view.selectTab(at: 1)
            view.resetSplitMasterToRoot()

            let weakVC = WeakViewController()
            let vc = PlannerAssembly.makeCreateToDoViewController(
                selectedDate: Clock.now,
                completion: { [weak env = view.env] _ in
                    env?.router.dismiss(weakVC)
                }
            )

            weakVC.setValue(vc)
            view.env.router.show(
                vc,
                from: view.tabController,
                options: .modal(isDismissable: false, embedInNav: true),
                analyticsRoute: "/calendar/new"
            )
        })
    }

    private static var plannerNoteDetailHandler: RouteHandler {
        .init("/todo-widget/planner-notes/:plannableId", action: { _, params, view in
            guard let plannableId = params["plannableId"] else { return }

            // Switch to Calendar tab
            view.selectTab(at: 1)
            view.resetSplitMasterToRoot()

            let controller = PlannerAssembly.makeToDoDetailsViewController(plannableId: plannableId)

            if let calendarVC = view.selectedTabMasterRootController as? PlannerViewController {
                calendarVC.onAppearPreferredPerform {
                    view.env.router.show(controller, from: calendarVC, options: .detail)
                }
            } else {
                view.env.router.show(
                    controller,
                    from: view.tabController,
                    options: .modal(isDismissable: true, embedInNav: true)
                )
            }
        })
    }

    private static var calendarEventHandler: RouteHandler {
        .init("/todo-widget/calendar_events/:eventId", action: { _, params, view in
            guard let eventID = params["eventId"] else { return }

            // Switch to Calendar tab
            view.selectTab(at: 1)
            view.resetSplitMasterToRoot()

            let controller = PlannerAssembly.makeEventDetailsViewController(eventId: eventID)

            if let calendarVC = view.selectedTabMasterRootController as? PlannerViewController {
                calendarVC.onAppearPreferredPerform {
                    view.env.router.show(controller, from: calendarVC, options: .detail)
                }
            } else {
                view.env.router.show(
                    controller,
                    from: view.tabController,
                    options: .modal(isDismissable: true, embedInNav: true)
                )
            }
        })
    }

    private static var assignmentHandler: RouteHandler {
        .init("/courses/:courseID/assignments/:assignmentID", action: { url, _, view in

            // Switch to Dashboard tab
            view.selectTab(at: 0)
            view.resetSplitMasterToRoot()

            view.env.router.route(
                to: url,
                from: view.tabController,
                options: .modal(isDismissable: true, embedInNav: true, addDoneButton: true)
            )
        })
    }

    private static var assignmentWithSubmissionHandler: RouteHandler {
        .init("/courses/:courseID/assignments/:assignmentID/submissions/:userID", action: { url, _, view in

            // Switch to Calendar tab
            view.selectTab(at: 1)
            view.resetSplitMasterToRoot()

            if let plannerVC = view.selectedTabMasterRootController as? PlannerViewController {

                plannerVC.onAppearPreferredPerform {
                    view.env.router.route(
                        to: url.settingOrigin("calendar"),
                        from: plannerVC,
                        options: .detail
                    )
                }

            } else {

                view.env.router.route(
                    to: url.settingOrigin("calendar"),
                    from: view.tabController,
                    options: .modal(isDismissable: true, embedInNav: true, addDoneButton: true)
                )
            }
        })
    }

    private static var calendarDayHandler: RouteHandler {
        .init("/todo-widget/calendar/:date", action: { _, params, view in
            guard
                let dateString = params["date"]?.removingPercentEncoding,
                let date = try? Date(dateString, strategy: .queryDayDateStyle)
            else { return }

            // Switch to Calendar tab
            view.selectTab(at: 1)
            view.resetSplitMasterToRoot()

            guard let plannerVC = view.selectedTabMasterRootController as? PlannerViewController
            else { return }

            plannerVC.onAppearPreferredPerform {
                plannerVC.selectDate(date)
            }
        })
    }
}

private extension UIViewController {
    func onAppearPreferredPerform(_ block: @escaping () -> Void) {
        if let observedVC = self as? VisibilityObservedViewController {
            observedVC.onAppear { block() }
        } else {
            block()
        }
    }
}
