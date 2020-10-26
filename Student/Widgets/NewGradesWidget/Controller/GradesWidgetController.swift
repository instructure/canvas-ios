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

import Core
import WidgetKit

class GradesWidgetController {
    private let env = AppEnvironment.shared
    private lazy var submissionList = env.subscribe(GetRecentlyGradedSubmissions(userID: "self"))

    private func update(completion: @escaping ([String]) -> Void) {
        setupLastLoginCredentials()
        submissionList.refresh { _ in
            self.submissionList
        }
    }

    private func setupLastLoginCredentials() {
        guard let mostRecentKeyChain = LoginSession.mostRecent else { return }
        env.userDidLogin(session: mostRecentKeyChain)
    }
}

extension GradesWidgetController: TimelineProvider {
    typealias Entry = GradeModel

    func placeholder(in context: TimelineProvider.Context) -> GradeModel {
        GradeModel.make()
    }

    func getSnapshot(in context: TimelineProvider.Context, completion: @escaping (GradeModel) -> ()) {
        completion(GradeModel.make())
    }

    func getTimeline(in context: TimelineProvider.Context, completion: @escaping (Timeline<GradeModel>) -> ()) {
        update { grades in
            let timeline = Timeline(entries: [GradeModel.make()], policy: .after(Date().addSeconds(60 * 60 * 2)))
            completion(timeline)
        }
    }
}
