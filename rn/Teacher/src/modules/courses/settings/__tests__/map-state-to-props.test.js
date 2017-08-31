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

import { mapStateToProps } from '../map-state-to-props'
import { appState } from '../../../../redux/__templates__/app-state'

test('finds the correct data', () => {
  let state = appState({
    entities: {
      courses: {
        '1': {
          course: { id: '1' },
          color: '#fff',
        },
        '2': {
          pending: 1,
          course: { id: '2' },
          color: '#333',
          error: 'error',
        },
      },
    },
  })

  let data = mapStateToProps(state, { courseID: '2' })
  expect(data).toMatchObject({
    pending: 1,
    course: { id: '2' },
    color: '#333',
    error: 'error',
  })
})
