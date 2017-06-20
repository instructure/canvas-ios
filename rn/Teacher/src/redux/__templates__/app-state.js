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
    groups: {},
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
