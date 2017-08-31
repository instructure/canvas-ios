// @flow

import attendanceTool from '../attendance-tool-reducer'
import LTIActions from '../actions'

const template = {
  ...require('../../../api/canvas-api/__templates__/external-tool'),
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
