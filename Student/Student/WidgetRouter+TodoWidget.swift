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

extension WidgetRouter {

    static func createTodoRouter() -> WidgetRouter {
        WidgetRouter(originValue: "todo-widget", handlers: [
            plannerNotesListHandler,
            calendarDayHandler,
            newPlannerNoteHandler,
            plannerNoteHandler,
            calendarEventHandler,
            assignmentHandler,
            assignmentWithSubmissionHandler
        ])
    }

    // MARK: - ToDos screen

    private static var plannerNotesListHandler: RouteHandler {
        .init("/todo-widget/planner-notes", action: { _, _, view in
            Analytics.shared.logEvent(TodoWidgetEventNames.openTodos.rawValue)

            // Switch to To-do tab
            view.selectTab(at: 2)
            view.resetSplitMasterToRoot()
        })
    }

    // MARK: - Calendar screen

    private static var calendarDayHandler: RouteHandler {
        .init("/todo-widget/calendar/:date", action: { _, params, view in
            guard
                let dateString = params["date"]?.removingPercentEncoding,
                let date = try? Date(dateString, strategy: .queryDayDateStyle)
            else { return }
            Analytics.shared.logEvent(TodoWidgetEventNames.openItem.rawValue)

            // Switch to Calendar tab
            view.selectTab(at: 1)
            view.resetSplitMasterToRoot()

            guard let plannerVC = view.selectedTabMasterRootController as? PlannerViewController
            else { return }

            plannerVC.onAppearOnce {
                plannerVC.selectDate(date)
            }
        })
    }

    // MARK: - Add screens

    private static var newPlannerNoteHandler: RouteHandler {
        .init("/todo-widget/planner-notes/new", action: { _, _, view in
            Analytics.shared.logEvent(TodoWidgetEventNames.create.rawValue)

            // Switch to Calendar tab
            view.selectTab(at: 1)
            view.resetSplitMasterToRoot()

            // Preselect Today
            if let calendarVC = view.selectedTabMasterRootController as? PlannerViewController {
                calendarVC.onAppearOnce {
                    calendarVC.selectDate(Clock.now)
                }
            }

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

    // MARK: - Detail screens

    private static var plannerNoteHandler: RouteHandler {
        .init("/todo-widget/planner-notes/:plannableId", action: { url, params, view in
            guard let plannableId = params["plannableId"] else { return }
            Analytics.shared.logEvent(TodoWidgetEventNames.openItem.rawValue)

            let detailsVC = PlannerAssembly.makeToDoDetailsViewController(plannableId: plannableId)
            showDetailsOnCalendarTab(detailsVC, url: url, view: view)
        })
    }

    private static var calendarEventHandler: RouteHandler {
        .init("/todo-widget/calendar_events/:eventId", action: { url, params, view in
            guard let eventID = params["eventId"] else { return }
            Analytics.shared.logEvent(TodoWidgetEventNames.openItem.rawValue)

            let detailsVC = PlannerAssembly.makeEventDetailsViewController(eventId: eventID)
            showDetailsOnCalendarTab(detailsVC, url: url, view: view)
        })
    }

    private static var assignmentHandler: RouteHandler {
        .init("/courses/:courseID/assignments/:assignmentID", action: { url, _, view in
            Analytics.shared.logEvent(TodoWidgetEventNames.openItem.rawValue)
            showDetailsOnCalendarTab(url: url, view: view)
        })
    }

    private static var assignmentWithSubmissionHandler: RouteHandler {
        .init("/courses/:courseID/assignments/:assignmentID/submissions/:userID", action: { url, _, view in
            Analytics.shared.logEvent(TodoWidgetEventNames.openItem.rawValue)
            showDetailsOnCalendarTab(url: url, view: view)
        })
    }

    // MARK: - Private helpers

    private static func showDetailsOnCalendarTab(_ detailsVC: UIViewController, url: URLComponents, view: WidgetRouter.ViewProxy) {
        // Switch to Calendar tab
        view.selectTab(at: 1)
        view.resetSplitMasterToRoot()

        guard let calendarVC = view.selectedTabMasterRootController as? PlannerViewController else {
            // just a fallback, this should not happen
            view.env.router.show(
                detailsVC,
                from: view.tabController,
                options: .modal(isDismissable: true, embedInNav: true, addDoneButton: true)
            )
            return
        }

        calendarVC.onAppearOnce {
            preselectDatePageIfPossible(url, in: calendarVC)
            view.env.router.show(detailsVC, from: calendarVC, options: .detail)
        }
    }

    private static func showDetailsOnCalendarTab(url: URLComponents, view: WidgetRouter.ViewProxy) {
        let urlWithOrigin = url.withOrigin("calendar")

        // Switch to Calendar tab
        view.selectTab(at: 1)
        view.resetSplitMasterToRoot()

        guard let calendarVC = view.selectedTabMasterRootController as? PlannerViewController else {
            // just a fallback, this should not happen
            view.env.router.route(
                to: urlWithOrigin,
                from: view.tabController,
                options: .modal(isDismissable: true, embedInNav: true, addDoneButton: true)
            )
            return
        }

        calendarVC.onAppearOnce {
            preselectDatePageIfPossible(url, in: calendarVC)
            view.env.router.route(to: urlWithOrigin, from: calendarVC, options: .detail)
        }
    }

    private static func preselectDatePageIfPossible(_ url: URLComponents, in plannerVC: PlannerViewController) {
        if let dateString = url.queryValue(for: "todo_date")?.removingPercentEncoding,
           let date = try? Date(dateString, strategy: .queryDayDateStyle) {
            plannerVC.selectDate(date)
        }
    }
}
