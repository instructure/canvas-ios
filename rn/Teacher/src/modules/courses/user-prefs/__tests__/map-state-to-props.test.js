//
// Copyright (C) 2017-present Instructure, Inc.
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

/* eslint-disable flowtype/require-valid-file-annotation */

import stateToProps from '../map-state-to-props'
import * as templates from '../../../../__templates__'

test('finds the correct data', () => {
  let state = templates.appState({
    entities: {
      courses: {
        '1': {
          course: { id: 1 },
          color: '#fff',
        },
        '2': {
          course: { id: 2 },
          color: '#333',
        },
      },
      assignmentGroups: {},
      gradingPeriods: {},
    },
    favoriteCourses: {
      pending: 0,
    },
    userInfo: {
      userSettings: {},
    },
  })

  let data = stateToProps(state, { courseID: '2' })
  expect(data).toMatchObject({
    course: { id: 2 },
    color: '#333',
    showColorOverlay: true,
    hideOverlaySetting: false,
  })
})

test('returns the correct value for showColorOverlay', () => {
  let state = templates.appState({
    entities: {
      courses: {
        '1': {
          course: templates.course({ image_download_url: null }),
        },
      },
    },
    favoriteCourses: {
      pending: 0,
    },
    userInfo: {
      userSettings: {},
    },
  })
  expect(stateToProps(state, { courseID: '1' }).showColorOverlay).toEqual(true)

  state.entities.courses['1'].course.image_download_url = 'https://google.com'
  expect(stateToProps(state, { courseID: '1' }).showColorOverlay).toEqual(true)

  state.userInfo.userSettings.hide_dashcard_color_overlays = true
  expect(stateToProps(state, { courseID: '1' }).showColorOverlay).toEqual(false)

  state.userInfo.userSettings.hide_dashcard_color_overlays = false
  expect(stateToProps(state, { courseID: '1' }).showColorOverlay).toEqual(true)
})

test('returns the hideOverlaySetting', () => {
  let state = templates.appState({
    entities: {
      courses: {
        '1': {
          course: templates.course(),
        },
      },
    },
    favoriteCourses: {
      pending: 0,
    },
    userInfo: {
      userSettings: {},
    },
  })
  expect(stateToProps(state, { courseID: '1' }).hideOverlaySetting).toEqual(false)

  state.userInfo.userSettings.hide_dashcard_color_overlays = true
  expect(stateToProps(state, { courseID: '1' }).hideOverlaySetting).toEqual(true)

  state.userInfo.userSettings.hide_dashcard_color_overlays = false
  expect(stateToProps(state, { courseID: '1' }).hideOverlaySetting).toEqual(false)
})
