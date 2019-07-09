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
