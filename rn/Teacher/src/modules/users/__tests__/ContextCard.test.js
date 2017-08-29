// @flow

import React from 'react'
import {
  ContextCard,
  shouldRefresh,
  fetchData,
  isRefreshing,
  mapStateToProps,
} from '../ContextCard'

import renderer from 'react-test-renderer'
import explore from '../../../../test/helpers/explore'

jest.mock('../../../routing/Screen')
    .mock('TouchableHighlight', () => 'TouchableHighlight')
    .mock('TouchableOpacity', () => 'TouchableOpacity')

const templates = {
  ...require('../../../api/canvas-api/__templates__/course'),
  ...require('../../../api/canvas-api/__templates__/enrollments'),
  ...require('../../../api/canvas-api/__templates__/users'),
  ...require('../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../api/canvas-api/__templates__/submissions'),
  ...require('../../../redux/__templates__/app-state'),
}
const defaultProps = {
  courseID: '1',
  userID: '1',
  user: templates.user({ id: '1' }),
  course: templates.courseWithSection({ id: '1' }),
  enrollment: templates.enrollment({ id: '1', course_id: '1', user_id: '1', course_section_id: '32', grades: { current_grade: 'A', current_score: 50 } }),
  assignments: [templates.assignment({ id: '1', possible_points: 100 })],
  submissions: [templates.submissionHistory([{ id: '1', assignment_id: '1', grade: 50 }])],
  courseColor: '#fff',
  pending: false,
  refreshUsers: jest.fn(),
  refreshCourses: jest.fn(),
  refreshEnrollments: jest.fn(),
  refreshAssignmentList: jest.fn(),
  navigator: { dismiss: jest.fn(), show: jest.fn() },
  refresh: jest.fn(),
  refreshing: false,
  getUserSubmissions: jest.fn(),
  numLate: 10,
  numMissing: 20,
  totalPoints: 100,
  modal: false,
}

beforeEach(() => jest.resetAllMocks())

describe('ContextCard', () => {
  it('renders', () => {
    let view = renderer.create(
      <ContextCard {...defaultProps} />
    )
    expect(view.toJSON()).toMatchSnapshot()
  })

  it('shows the activity indicator when pending', () => {
    let view = renderer.create(
      <ContextCard {...defaultProps} pending={true} />
    )

    expect(view.toJSON()).toMatchSnapshot()
  })

  it('formats the last_activity_at properly', () => {
    let enrollment = templates.enrollment({
      id: '1',
      course_id: '1',
      user_id: '1',
      course_section_id: '32',
      last_activity_at: '2017-04-05T15:12:45Z',
      grades: {
        current_grade: '100',
      },
    })
    let view = renderer.create(
      <ContextCard {...defaultProps} enrollment={enrollment} />
    )

    expect(view.toJSON()).toMatchSnapshot()
  })

  it('shows points values when there is no grade', () => {
    let enrollment = templates.enrollment({
      id: '1',
      course_id: '1',
      user_id: '1',
      course_section_id: '32',
      last_activity_at: '2017-04-05T15:12:45Z',
      grades: {
        current_score: 100,
      },
    })

    let view = renderer.create(
      <ContextCard {...defaultProps} enrollment={enrollment} />
    )

    expect(view.toJSON()).toMatchSnapshot()
  })

  it('asks for submission when the user is a student', () => {
    let enrollment = templates.enrollment({
      id: '1',
      course_id: '1',
      user_id: '1',
      course_section_id: '32',
      type: 'StudentEnrollment',
      grades: { current_grade: 'A' },
    })

    renderer.create(
      <ContextCard {...defaultProps} enrollment={enrollment} />
    )

    expect(defaultProps.getUserSubmissions).toHaveBeenCalled()
  })

  it('renders for a non student', () => {
    let enrollment = templates.enrollment({
      id: '1',
      course_id: '1',
      user_id: '1',
      course_section_id: '32',
      type: 'TeacherEnrollment',
    })

    let view = renderer.create(
      <ContextCard {...defaultProps} enrollment={enrollment} />
    )

    expect(view.toJSON()).toMatchSnapshot()
    expect(defaultProps.getUserSubmissions).not.toHaveBeenCalled()
  })

  it('navigate to speedgrader', () => {
    let view = renderer.create(
      <ContextCard {...defaultProps} />
    )
    let assignmentID = defaultProps.assignments[0].id
    let row = explore(view.toJSON()).selectByID(`user-submission-row.cell-${assignmentID}`)
    expect(row).not.toBeNull()
    row && row.props.onPress()

    expect(defaultProps.navigator.show).toHaveBeenCalled()
  })

  it('navigates to composer', () => {
    defaultProps.navigator.show = jest.fn()
    let view = renderer.create(
      <ContextCard {...defaultProps} />
    )
    const tree = view.toJSON()
    const mailButton: any = explore(tree).selectRightBarButton('context-card.email-contact')
    expect(mailButton).not.toBeNull()
    mailButton.action()
    let expectedProps = { 'canSelectCourse': false, 'contextCode': `course_${defaultProps.course.id}`, 'contextName': `${defaultProps.course.name}`, 'recipients': [templates.user()] }
    expect(defaultProps.navigator.show).toHaveBeenCalledWith(`/conversations/compose`, { 'modal': true }, expectedProps)
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
  it('should refresh if the totalPoints are not there', () => {
    let props = {
      ...defaultProps,
      totalPoints: undefined,
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
    expect(defaultProps.refreshEnrollments).toHaveBeenCalledWith('1')
    expect(defaultProps.refreshAssignmentList).toHaveBeenCalledWith('1')
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
  let assignment = templates.assignment({ id: '1', course_id: '1' })
  let assignmentContentState = {
    anonymousGradingOn: false,
    pending: 0,
    pendingComments: {},
    submissions: {
      pending: 0,
      refs: [],
    },
    submissionSummary: {
      data: { graded: 0, ungraded: 0, not_submitted: 0 },
      pending: 0,
      error: null,
    },
    gradeableStudents: {
      pending: 0,
      refs: [],
    },
  }
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
    assignments: {
      '1': {
        data: assignment,
        ...assignmentContentState,
      },
    },
  }

  const ownProps = {
    userID: '1',
    courseID: '1',
    navigator: { dismiss: jest.fn() },
    modal: false,
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

  it('returns the course assignments', () => {
    let props = mapStateToProps(state, ownProps)
    expect(props.assignments[0]).toEqual(assignment)
  })

  it('returns when there are no assignments', () => {
    let props = mapStateToProps(templates.appState(), ownProps)
    expect(props.assignments.length).toEqual(0)
  })

  it('calculates total points', () => {
    let appState = {
      ...state,
      entities: {
        ...state.entities,
        assignments: {
          '1': { data: templates.assignment({ id: '1', course_id: '1', points_possible: 10 }), ...assignmentContentState },
          '2': { data: templates.assignment({ id: '2', course_id: '1', points_possible: 10, overrides: [{ student_ids: ['1'] }] }), ...assignmentContentState },
          '3': { data: templates.assignment({ id: '3', course_id: '1', points_possible: 10, overrides: [{ student_ids: ['2'] }] }), ...assignmentContentState },
        },
      },
    }
    let props = mapStateToProps(appState, ownProps)
    expect(props.totalPoints).toEqual(20)
  })

  it('calculates numLate', () => {
    let appState = {
      ...state,
      entities: {
        ...state.entities,
        submissions: {
          '1': {
            submission: templates.submission({ id: '1', assignment_id: '1', user_id: '1', late: true }),
            selectedIndex: 0,
            selectedAttachmentIndex: 0,
            pending: 0,
            rubricGradePending: false,
          },
        },
      },
    }

    let props = mapStateToProps(appState, ownProps)
    expect(props.numLate).toEqual(1)
  })

  it('calculates numMissing', () => {
    let appState = {
      ...state,
      entities: {
        ...state.entities,
        assignments: {
          '1': {
            data: templates.assignment({ id: '1', course_id: '1', due_at: '1990-06-01T05:59:00Z' }),
            ...assignmentContentState,
          },
        },
        submissions: {},
      },
    }

    let props = mapStateToProps(appState, ownProps)
    expect(props.numMissing).toEqual(1)
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
