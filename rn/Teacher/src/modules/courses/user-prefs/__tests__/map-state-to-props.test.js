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

import stateToProps from '../map-state-to-props'

const templates = {
  ...require('../../../../redux/__templates__/app-state'),
}

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
  })

  let data = stateToProps(state, { courseID: '2' })
  expect(data).toMatchObject({
    course: { id: 2 },
    color: '#333',
  })
})
