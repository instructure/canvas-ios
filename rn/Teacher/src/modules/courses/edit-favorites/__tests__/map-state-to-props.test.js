//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

// @flow
import mapStateToProps from '../map-state-to-props'
import { appState } from '../../../../redux/__templates__/app-state'
import app from '../../../app'

test('returns the correct props with no groups', () => {
  app.setCurrentApp('student')
  let state = appState({
    entities: {
      courses: {
        '1': {
          course: {
            name: 'trump university',
          },
        },
        '2': {
          course: {
            name: 'harvard',
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

test('returns the correct props', () => {
  app.setCurrentApp('student')
  let state = appState({
    entities: {
      courses: {
        '1': {
          course: {
            name: 'trump university',
          },
        },
        '2': {
          course: {
            name: 'harvard',
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
