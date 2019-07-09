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

// @flow
import mapStateToProps from '../map-state-to-props'
import { appState } from '../../../../redux/__templates__/app-state'
import app from '../../../app'
import * as template from '../../../../__templates__'

test('returns the correct props with no groups', () => {
  app.setCurrentApp('student')
  let state = appState({
    entities: {
      courses: {
        '1': {
          course: {
            name: 'trump university',
            enrollments: [template.enrollment()],
          },
        },
        '2': {
          course: {
            name: 'harvard',
            enrollments: [template.enrollment()],
          },
        },
      },
      assignmentGroups: {},
      gradingPeriods: {},
    },
    favoriteCourses: {
      courseRefs: ['1', '2'],
    },
  })
  let props = mapStateToProps(state)
  expect(props.courses).toEqual([state.entities.courses['2'].course, state.entities.courses['1'].course])
  expect(props.courseFavorites).toEqual(state.favoriteCourses.courseRefs)
})

test('returns the correct props with no invited enrollments', () => {
  app.setCurrentApp('student')
  let state = appState({
    entities: {
      courses: {
        '1': {
          course: {
            name: 'trump university',
            enrollments: [template.enrollment({ enrollment_state: 'invited' })],
          },
        },
        '2': {
          course: {
            name: 'harvard',
            enrollments: [template.enrollment()],
          },
        },
      },
      assignmentGroups: {},
      gradingPeriods: {},
    },
    favoriteCourses: {
      courseRefs: ['1', '2'],
    },
  })
  let props = mapStateToProps(state)
  expect(props.courses).toEqual([state.entities.courses['2'].course])
  expect(props.courseFavorites).toEqual(state.favoriteCourses.courseRefs)
})

test('returns the correct props', () => {
  app.setCurrentApp('student')
  let state = appState({
    entities: {
      courses: {
        '1': {
          course: {
            name: 'trump university',
            enrollments: [template.enrollment()],
          },
        },
        '2': {
          course: {
            name: 'harvard',
            enrollments: [template.enrollment()],
          },
        },
      },
      groups: {
        '1': { group: { name: 'alpha' } },
        '2': { group: { name: 'bravo' } },
      },
      assignmentGroups: {},
      gradingPeriods: {},
    },
    favoriteCourses: {
      courseRefs: ['1', '2'],
    },
    favoriteGroups: {
      groupRefs: ['1', '2'],
    },
  })
  let props = mapStateToProps(state)
  expect(props.courses).toEqual([state.entities.courses['2'].course, state.entities.courses['1'].course])
  expect(props.groups).toEqual([state.entities.groups['1'].group, state.entities.groups['2'].group])
  expect(props.courseFavorites).toEqual(state.favoriteCourses.courseRefs)
  expect(props.groupFavorites).toEqual(state.favoriteGroups.groupRefs)
})
