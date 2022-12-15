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

public class DiscussionWebPageViewModel: EmbeddedWebPageViewModel {
    public static func isRedesignEnabled(in context: Context) -> Bool {
        var featureFlagContext = context

        if context.contextType == .group {
            let group = AppEnvironment.shared.subscribe(GetGroup(groupID: context.id))
            if let courseID = group.first?.courseID {
                featureFlagContext = Context.course(courseID)
            }
        }
        return AppEnvironment.shared.subscribe(GetEnabledFeatureFlags(context: featureFlagContext)).first { $0.isDiscussionAndAnnouncementRedesign }?.enabled ?? false
    }
    @Published public private(set) var subTitle: String?
    @Published public private(set) var contextColor: UIColor?
    public let navTitle = NSLocalizedString("Discussion Details", comment: "")
    public let url: URL

    private let context: Context
    private let env = AppEnvironment.shared
    private lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.update()
    }
    private lazy var course = env.subscribe(GetCourse(courseID: context.id)) { [weak self] in
        self?.update()
    }
    private lazy var group = env.subscribe(GetGroup(groupID: context.id)) { [weak self] in
        self?.update()
    }

    public init(context: Context, topicID: String) {
        self.url = {
            guard var baseURL = AppEnvironment.shared.currentSession?.baseURL else {
                return URL(string: "/")! // should never happen
            }

            baseURL.appendPathComponent(context.pathComponent)
            baseURL.appendPathComponent("discussion_topics/\(topicID)")
            baseURL = baseURL.appendingQueryItems(
                URLQueryItem(name: "embed", value: "true"),
                URLQueryItem(name: "session_timezone", value: TimeZone.current.identifier),
                URLQueryItem(name: "session_locale", value: Locale.current.identifier.replacingOccurrences(of: "_", with: "-"))
            )

            return baseURL
        }()
        self.context = context

        colors.refresh()

        if context.contextType == .course {
            course.refresh()
        } else {
            group.refresh()
        }
    }

    private func update() {
        guard
            let name = context.contextType == .course ? course.first?.name : group.first?.name,
            let color = context.contextType == .course ? course.first?.color : group.first?.color
        else {
            return
        }

        subTitle = name
        contextColor = color
    }
}
