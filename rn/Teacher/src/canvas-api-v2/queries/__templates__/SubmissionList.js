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

// @flow
import template, { type Template } from '../../../utils/template'
import * as templates from '../../__templates__'

export const submissionListResult: Template<any> = template({
  assignment: templates.assignment({
    course: templates.course({
      groupSet: templates.groupSet(),
      groups: {
        edges: [{ group: templates.group() }],
      },
      sections: {
        edges: [{ section: templates.section() }],
      },
    }),
    submissions: {
      edges: [{ submission: templates.submission({
        user: templates.user(),
      }) }],
    },
    groupedSubmissions: {
      edges: [{ submission: templates.submission({
        user: templates.user(),
      }) }],
    },
  }),
})
