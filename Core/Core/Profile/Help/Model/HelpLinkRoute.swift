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

extension HelpLink {
    var route: (path: String, options: RouteOptions)? {
        switch id {
        case "instructor_question":
            let autoTeacherSelectKey = ComposeMessageOptions.QueryParameterKey.autoTeacherSelect.rawValue
            let recipientsDisabledKey = ComposeMessageOptions.QueryParameterKey.recipientsDisabled.rawValue
            let alwaysShowRecipientsKey = ComposeMessageOptions.QueryParameterKey.alwaysShowRecipients.rawValue
            let trueValue = String(true)
            return ("/conversations/compose?\(autoTeacherSelectKey)=\(trueValue)&\(recipientsDisabledKey)=\(trueValue)&\(alwaysShowRecipientsKey)=\(trueValue)", .modal(.formSheet, embedInNav: true))
        case "report_a_problem":
            return ("/support/problem", .modal(.formSheet, embedInNav: true))
        default:
            guard let url = url else { return nil }
            return (url.absoluteString, .modal(embedInNav: true))
        }
    }
}
