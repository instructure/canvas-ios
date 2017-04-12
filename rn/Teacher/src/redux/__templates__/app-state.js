/* @flow */

import template from '../../utils/template'

const emptyAppState: AppState = {
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
  },
}

export const appState: Template<AppState> = template(emptyAppState)
