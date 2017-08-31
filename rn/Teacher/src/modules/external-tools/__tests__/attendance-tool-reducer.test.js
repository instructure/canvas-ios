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

import attendanceTool from '../attendance-tool-reducer'
import LTIActions from '../actions'

const template = {
  ...require('../../../__templates__/external-tool'),
}

test('attendanceTool reducer captures pending requests', () => {
  const pending = {
    type: LTIActions.refreshLTITools.toString(),
    pending: true,
    payload: { courseID: '555' },
  }

  let state = { pending: 0 }
  state = attendanceTool(state, pending)
  expect(state).toEqual({
    pending: 1,
  })

  const nonCourseNav = template.ltiLaunchDefinition({
    placements: {},
  })
  const attendance = template.ltiLaunchDefinition()
  const definitions = [
    nonCourseNav,
    attendance,
    template.ltiLaunchDefinition({
      placements: {
        course_navigation: {
          url: 'https://sometool.megacorp.com',
        },
      },
    }),
  ]

  const resolved = {
    type: LTIActions.refreshLTITools.toString(),
    payload: {
      result: { data: definitions },
      courseID: '555',
    },
  }

  expect(attendanceTool(state, resolved)).toEqual({
    pending: 0,
    tabID: `context_external_tool_${attendance.definition_id}`,
  })

  const rejected = {
    type: LTIActions.refreshLTITools.toString(),
    error: true,
    payload: {
      error: {
        data: {
          errors: [{ message: 'Something went wrong!' }],
        },
      },
      courseID: '555',
    },
  }

  expect(attendanceTool(state, rejected)).toMatchObject({
    pending: 0,
  })
})

test('attendanceTool does not explode with empty definitions', () => {
  const pending = {
    type: LTIActions.refreshLTITools.toString(),
    pending: true,
    payload: { courseID: '555' },
  }
  let state = { pending: 0 }
  state = attendanceTool(state, pending)
  expect(state).toEqual({
    pending: 1,
  })
  const nonCourseNav = template.ltiLaunchDefinition({
    placements: {},
  })
  const definitions = [
    nonCourseNav,
  ]

  const resolved = {
    type: LTIActions.refreshLTITools.toString(),
    payload: {
      result: { data: definitions },
      courseID: '555',
    },
  }

  expect(attendanceTool(state, resolved)).toEqual({
    pending: 0,
    tabID: null,
  })
})

test('attendanceTool works correctly for a beta instance', () => {
  const pending = {
    type: LTIActions.refreshLTITools.toString(),
    pending: true,
    payload: { courseID: '555' },
  }
  let state = { pending: 0 }
  state = attendanceTool(state, pending)
  expect(state).toEqual({
    pending: 1,
  })
  const attendance = template.ltiLaunchDefinition({
    placements: {
      course_navigation: {
        url: 'https://sometool.megacorp.com',
      },
    },
  })
  const definitions = [
    attendance,
  ]

  const resolved = {
    type: LTIActions.refreshLTITools.toString(),
    payload: {
      result: { data: definitions },
      courseID: '555',
    },
  }

  expect(attendanceTool(state, resolved)).toEqual({
    pending: 0,
    tabID: null,
  })
})
