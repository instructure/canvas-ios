//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

/* @flow */

import template, { type Template } from '../../utils/template'

const emptyAppState: AppState = {
  drawer: { currentSnap: 2, currentTab: -1 },
  favoriteCourses: {
    pending: 0,
    courseRefs: [],
  },
  entities: {
    courses: {},
    groups: {},
    assignmentGroups: {},
    gradingPeriods: {},
    enrollments: {},
    sections: {},
    assignments: {},
    users: {},
    submissions: {},
    quizzes: {},
    quizSubmissions: {},
    discussions: {},
    announcements: {},
    courseDetailsTabSelectedRow: { rowID: '' },
  },
  inbox: {
    selectedScope: 'all',
    conversations: {},
    unread: { refs: [], pending: 0 },
    starred: { refs: [], pending: 0 },
    all: { refs: [], pending: 0 },
    archived: { refs: [], pending: 0 },
    sent: { refs: [], pending: 0 },
  },
}

export const appState: Template<AppState> = template(emptyAppState)
