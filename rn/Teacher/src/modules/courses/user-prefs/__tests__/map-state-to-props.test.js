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
