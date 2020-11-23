//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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

/* @flow */

import template, { type Template } from '../../utils/template'

export const entities: Template<Entities> = template({
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
})

export const appState: Template<AppState> = template({
  drawer: { currentSnap: 2, currentTab: -1 },
  favoriteCourses: {
    pending: 0,
    courseRefs: [],
  },
  favoriteGroups: {
    pending: 0,
    groupRefs: [],
    userHasFavoriteGroups: true,
  },
  entities: entities(),
  inbox: {
    selectedScope: 'all',
    conversations: {},
    unread: { refs: [], pending: 0 },
    starred: { refs: [], pending: 0 },
    all: { refs: [], pending: 0 },
    archived: { refs: [], pending: 0 },
    sent: { refs: [], pending: 0 },
  },
  asyncActions: {},
  files: {},
  folders: {},
  userInfo: {
    canActAsUser: false,
    showsGradesOnCourseCards: true,
    externalTools: [],
    userSettings: {},
  },
})
