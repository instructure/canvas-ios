// @flow

import React from 'react'
import {
  ContextCard,
  shouldRefresh,
  fetchData,
  isRefreshing,
  mapStateToProps,
} from '../ContextCard'

import renderer from 'react-native-test-utils'

const templates = {
  ...require('../../../api/canvas-api/__templates__/course'),
  ...require('../../../api/canvas-api/__templates__/enrollments'),
  ...require('../../../api/canvas-api/__templates__/users'),
  ...require('../../../redux/__templates__/app-state'),
}
const defaultProps = {
  courseID: '1',
  userID: '1',
  user: templates.user({ id: '1' }),
  course: templates.courseWithSection({ id: '1' }),
  enrollment: templates.enrollment({ id: '1', course_id: '1', user_id: '1', course_section_id: '32' }),
  courseColor: '#fff',
  pending: false,
  refreshUsers: jest.fn(),
  refreshCourses: jest.fn(),
  refreshEnrollments: jest.fn(),
  navigator: { dismiss: jest.fn() },
  refresh: jest.fn(),
  refreshing: false,
}

beforeEach(() => jest.resetAllMocks())

describe('ContextCard', () => {
  it('shows the activity indicator when pending', () => {
    let view = renderer(
      <ContextCard {...defaultProps} pending={true} />
    )

    expect(view.query('ActivityIndicator')).not.toBeUndefined()
  })

  it('uses the right info in the navbar', () => {
    let view = renderer(
      <ContextCard {...defaultProps} />
    )
    let navbar = view.query('Screen')
    expect(navbar.props.title).toEqual(defaultProps.user.name)
    expect(navbar.props.subtitle).toEqual(defaultProps.course.name)
    expect(navbar.props.navBarColor).toEqual(defaultProps.courseColor)
  })

  it('shows the proper section name', () => {
    let view = renderer(
      <ContextCard {...defaultProps} />
    )

    let text = view.query('#context-card.section-name').text()
    let section = defaultProps.course.sections && defaultProps.course.sections[0]
    if (section) {
      expect(text).toContain(section.name)
    }
  })

  it('formats the last_activity_at properly', () => {
    let enrollment = templates.enrollment({
      id: '1',
      course_id: '1',
      user_id: '1',
      course_section_id: '32',
      last_activity_at: (new Date(0)).toISOString(),
    })
    let view = renderer(
      <ContextCard {...defaultProps} enrollment={enrollment} />
    )

    let lastActivity = view.query('#context-card.last-activity')
    expect(lastActivity.text()).toContain('December 31 at 5:00 PM')
  })
})

describe('refresh', () => {
  it('should refresh if the user is not there', () => {
    let props = {
      ...defaultProps,
      user: undefined,
    }
    expect(shouldRefresh(props)).toEqual(true)
  })
  it('should refresh if the course is not there', () => {
    let props = {
      ...defaultProps,
      course: undefined,
    }
    expect(shouldRefresh(props)).toEqual(true)
  })
  it('should refresh if the enrollment is not there', () => {
    let props = {
      ...defaultProps,
      enrollment: undefined,
    }
    expect(shouldRefresh(props)).toEqual(true)
  })
  it('should not refresh if the user and course is there', () => {
    expect(shouldRefresh(defaultProps)).toEqual(false)
  })

  it('should call refreshUsers and refreshCourses when fetchData is called', () => {
    fetchData(defaultProps)
    expect(defaultProps.refreshUsers).toHaveBeenCalledWith(['1'])
    expect(defaultProps.refreshCourses).toHaveBeenCalled()
    expect(defaultProps.refreshEnrollments).toHaveBeenCalled()
  })

  it('isRefreshing when pending', () => {
    let props = {
      ...defaultProps,
      pending: true,
    }
    expect(isRefreshing(props)).toEqual(true)

    props.pending = false
    expect(isRefreshing(props)).toEqual(false)
  })
})

describe('mapStateToProps', () => {
  let user = templates.user({ id: '1' })
  let course = templates.courseWithSection({ id: '1' })
  let enrollment = templates.enrollment({ id: '1', course_id: '1', user_id: '1', course_section_id: '1' })
  let asyncState = {
    pending: 0,
    error: null,
    refs: [],
  }
  let state = templates.appState()
  state.entities = {
    ...state.entities,
    courses: {
      '1': {
        pending: 0,
        color: '#fff',
        course,
        enrollments: {
          pending: 0,
          error: null,
          refs: ['1'],
        },
        tabs: { ...asyncState, tabs: [] },
        quizzes: asyncState,
        groups: asyncState,
        discussions: asyncState,
        assignmentGroups: asyncState,
        announcements: asyncState,
        attendanceTool: { pending: 0 },
      },
    },
    users: {
      '1': {
        data: user,
        pending: true,
      },
    },
    enrollments: {
      '1': enrollment,
    },
  }

  const ownProps = {
    userID: '1',
    courseID: '1',
    navigator: { dismiss: jest.fn() },
  }
  it('returns the user if it is there', () => {
    let props = mapStateToProps(state, ownProps)
    expect(props.user).toEqual(user)
  })

  it('returns when the user is not there', () => {
    let props = mapStateToProps(templates.appState(), ownProps)
    expect(props.user).toBeUndefined()
  })

  it('returns the course color', () => {
    let props = mapStateToProps(state, ownProps)
    expect(props.courseColor).toEqual('#fff')
  })

  it('returns the course', () => {
    let props = mapStateToProps(state, ownProps)
    expect(props.course).toEqual(course)
  })

  it('returns with no course', () => {
    let props = mapStateToProps(templates.appState(), ownProps)
    expect(props.courseColor).toBeUndefined()
    expect(props.course).toBeUndefined()
  })

  it('returns the users enrollment', () => {
    let props = mapStateToProps(state, ownProps)
    expect(props.enrollment).toEqual(enrollment)
  })

  it('returns when there is no enrollment', () => {
    let props = mapStateToProps(templates.appState(), ownProps)
    expect(props.enrollment).toBeUndefined()
  })

  it('returns pending based off of user pending and enrollment pending', () => {
    let pendingState = { ...state }
    pendingState.entities.courses['1'].enrollments = {
      pending: 0,
      refs: ['1'],
    }
    expect(mapStateToProps(pendingState, ownProps).pending).toBeTruthy()

    pendingState.entities.courses['1'].enrollments.pending = 1
    pendingState.entities.users['1'] = {
      pending: 0,
      data: user,
    }
    expect(mapStateToProps(pendingState, ownProps).pending).toBeTruthy()

    pendingState.entities.courses['1'].enrollments.pending = 0
    expect(mapStateToProps(pendingState, ownProps).pending).toBeFalsy()

    expect(mapStateToProps(templates.appState(), ownProps).pending).toBeFalsy()
  })
})
