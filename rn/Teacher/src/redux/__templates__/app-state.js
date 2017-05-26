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
    courseDetailsTabSelectedRow: { rowID: '' },
  },
}

export const appState: Template<AppState> = template(emptyAppState)
