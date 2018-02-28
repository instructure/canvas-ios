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

/* @flow */

import React from 'react'
import 'react-native'
import renderer from 'react-test-renderer'

import { QuizDetails, mapStateToProps } from '../QuizDetails'
import explore from '../../../../../test/helpers/explore'

jest
  .mock('Button', () => 'Button')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')
  .mock('WebView', () => 'WebView')
  .mock('../../submissions/components/QuizSubmissionBreakdownGraphSection', () => 'QuizSubmissionBreakdownGraphSection')
  .mock('../../../../routing')
  .mock('../../../../routing/Screen')

const template = {
  ...require('../../../../__templates__/helm'),
  ...require('../../../../__templates__/quiz'),
  ...require('../../../../__templates__/assignments'),
  ...require('../../../../redux/__templates__/app-state'),
  ...require('../../../../__templates__/session'),
}

describe('QuizDetails', () => {
  let props
  beforeEach(() => {
    jest.clearAllMocks()
    props = {
      refresh: jest.fn(),
      quiz: template.quiz({ id: '1' }),
      navigator: template.navigator(),
      quizID: '1',
      courseID: '1',
      assignmentGroup: null,
      assignment: null,
      showSubmissionSummary: true,
      courseColor: '#fff',
    }
  })

  it('renders', () => {
    testRender(props)
  })

  it('renders published state', () => {
    props.quiz.published = false
    testRender(props)
    props.quiz.published = true
    testRender(props)
  })

  it('renders quiz type', () => {
    props.quiz.quiz_type = 'practice_quiz'
    testRender(props)

    props.quiz.quiz_type = 'assignment'
    testRender(props)
  })

  it('renders shuffle answers', () => {
    props.quiz.shuffle_answers = false
    testRender(props)

    props.quiz.shuffle_answers = true
    testRender(props)
  })

  it('renders time limit', () => {
    props.quiz.time_limit = 5
    testRender(props)

    props.quiz.time_limit = 1
    testRender(props)
  })

  it('renders allowed attempts', () => {
    props.quiz.allowed_attempts = -1
    testRender(props)

    props.quiz.allowed_attempts = 5
    testRender(props)
  })

  it('renders view responses', () => {
    props.quiz.hide_results = null
    testRender(props)

    props.quiz.hide_results = 'until_after_last_attempt'
    testRender(props)

    props.quiz.hide_results = 'always'
    testRender(props)
  })

  it('does not render Show Correct Answers when hide_results is null', () => {
    props.quiz.hide_results = 'always'
    props.quiz.show_correct_answers = true
    testRender(props)
  })

  it('renders show correct answers', () => {
    props.quiz.hide_results = null
    props.quiz.show_correct_answers = true
    testRender(props)

    props.quiz.show_correct_answers = false
    testRender(props)
  })

  it('renders Show Correct Answers: After Last Attempt', () => {
    props.quiz.hide_results = null
    props.quiz.show_correct_answers = true
    props.quiz.show_correct_answers_last_attempt = true
    props.quiz.allowed_attempts = 3
    testRender(props)

    props.quiz.allowed_attempts = 0
    testRender(props)
  })

  it('renders Show Correct Answers dates', () => {
    props.quiz.hide_results = null
    props.quiz.show_correct_answers = true
    props.quiz.show_correct_answers_last_attempt = false
    props.quiz.show_correct_answers_at = '2013-01-23T23:59:00-07:00'
    props.quiz.hide_correct_answers_at = null
    testRender(props)

    props.quiz.hide_correct_answers_at = '2013-01-24T23:59:00-07:00'
    testRender(props)

    props.quiz.show_correct_answers_at = null
    testRender(props)
  })

  it('renders One Question At A Time:', () => {
    props.quiz.one_question_at_a_time = true
    testRender(props)

    props.quiz.one_question_at_a_time = false
    testRender(props)
  })

  it('renders scoring policy', () => {
    props.quiz.scoring_policy = 'keep_average'
    testRender(props)

    props.quiz.scoring_policy = 'keep_latest'
    testRender(props)

    props.quiz.scoring_policy = 'keep_highest'
    testRender(props)
  })

  it('renders without a quiz', () => {
    testRender({ ...props, quiz: null })
  })

  it('calls refresh on refresh', () => {
    props.refresh = jest.fn()
    const tree = render(props).toJSON()
    const refresher: any = explore(tree).query(({ type }) => type === 'RCTScrollView')[0]
    refresher.props.onRefresh()
    expect(props.refresh).toHaveBeenCalled()
  })

  it('navigates to edit screen', () => {
    props.navigator.show = jest.fn()
    const tree = render(props).toJSON()
    const editButton: any = explore(tree).selectRightBarButton('quizzes.details.editButton')
    editButton.action()
    expect(props.navigator.show).toHaveBeenCalledWith(`/courses/${props.courseID}/quizzes/${props.quizID}/edit`, { 'modal': true, 'modalPresentationStyle': 'formsheet' })
  })

  it('renders assignment group', () => {
    // $FlowFixMe
    props.assignmentGroup = template.assignmentGroup({ name: 'AG Name' })
    testRender(props)
  })

  it('displays access code', () => {
    props.quiz.access_code = 'abracadabra'
    testRender(props)
  })

  it('displays "Lock Questions After Answering"', () => {
    props.quiz.one_question_at_a_time = true
    props.quiz.cant_go_back = true
    testRender(props)
  })

  it('renders without a description', () => {
    props.quiz.description = ''
    testRender(props)
  })

  it('renders assignment due dates', () => {
    // $FlowFixMe
    props.assignment = template.assignment()
    testRender(props)
  })

  it('pushes due dates screen', () => {
    props.courseID = '1'
    // $FlowFixMe
    props.assignment = template.assignment({ id: '1' })
    props.navigator.show = jest.fn()
    props.quiz.id = '3'
    const tree = render(props).toJSON()
    const dueDates: any = explore(tree).selectByID('quizzes.details.viewDueDatesButton')
    dueDates.props.onPress()
    expect(props.navigator.show).toHaveBeenCalledWith('/courses/1/assignments/1/due_dates', { modal: false }, {
      quizID: '3',
    })
  })

  it('handles submission press', () => {
    props.navigator.show = jest.fn()
    props.courseID = '1'
    props.quizID = '1'
    const tree = render(props).toJSON()
    const submissions: any = explore(tree).query(({ type }) => type === 'QuizSubmissionBreakdownGraphSection')[0]
    submissions.props.onPress('graded')
    expect(props.navigator.show).toHaveBeenCalledWith('/courses/1/quizzes/1/submissions', { modal: false }, {
      filterType: 'graded',
    })
    submissions.props.onPress(null)
    expect(props.navigator.show).toHaveBeenCalledWith('/courses/1/quizzes/1/submissions')
  })

  it('navigates to all submissions', () => {
    props.navigator.show = jest.fn()
    props.courseID = '1'
    props.quizID = '1'
    const tree = render(props).toJSON()
    const row: any = explore(tree).selectByID('quizzes.details.viewAllSubmissionsRow')
    row.props.onPress()
    expect(props.navigator.show).toHaveBeenCalledWith('/courses/1/quizzes/1/submissions')
  })

  it('navigates to quiz preview', () => {
    props.courseID = '1'
    props.quizID = '1'
    props.navigator.show = jest.fn()
    const tree = render(props).toJSON()
    const btn: any = explore(tree).selectByID('quizzes.details.previewQuiz.btn')
    btn.props.onPress()
    expect(props.navigator.show).toHaveBeenCalledWith('/courses/1/quizzes/1/preview', { modal: true, modalPresentationStyle: 'fullscreen' })
  })

  function testRender (props: any) {
    expect(render(props).toJSON()).toMatchSnapshot()
  }

  function render (props: any) {
    return renderer.create(
      <QuizDetails {...props} />
    )
  }
})

describe('mapStateToProps', () => {
  it('maps state to props', () => {
    const quiz = template.quiz({
      id: '1',
      assignment_group_id: null,
      assignment_id: null,
    })
    const state: AppState = template.appState({
      entities: {
        ...template.appState().entities,
        quizzes: {
          '1': {
            data: quiz,
            pending: 1,
            error: null,
          },
        },
        courses: {
          '1': {
            course: {
              enrollments: [{ type: 'designer' }],
              name: 'CS1010',
            },
            color: '#123456',
          },
        },
      },
    })

    expect(
      mapStateToProps(state, { courseID: '1', quizID: '1' })
    ).toMatchObject({
      quiz,
      pending: 1,
      error: null,
      courseID: '1',
      courseName: 'CS1010',
      quizID: '1',
      assignmentGroup: null,
      assignment: null,
      courseColor: '#123456',
    })
  })

  it('maps assignment group id to assignment group prop', () => {
    const quiz = template.quiz({
      id: '1',
      assignment_group_id: '2',
      assignment_id: null,
    })
    const ag1 = template.assignmentGroup({ id: '1', name: 'AG 1' })
    const ag2 = template.assignmentGroup({ id: '2', name: 'AG 2' })
    const state: AppState = template.appState({
      entities: {
        ...template.appState().entities,
        courses: {
          '1': {
            course: {
              enrollments: [{ type: 'designer' }],
            },
            assignmentGroups: {
              refs: ['1', '2'],
            },
          },
        },
        assignmentGroups: {
          '1': {
            group: ag1,
          },
          '2': {
            group: ag2,
          },
        },
        quizzes: {
          '1': {
            data: quiz,
            pending: 1,
            error: null,
          },
        },
      },
    })

    expect(
      mapStateToProps(state, { courseID: '1', quizID: '1' })
    ).toMatchObject({
      quiz,
      pending: 1,
      error: null,
      courseID: '1',
      quizID: '1',
      assignmentGroup: ag2,
      assignment: null,
    })
  })

  it('maps assignment_id to assignment prop', () => {
    const quiz = template.quiz({
      id: '1',
      assignment_group_id: null,
      assignment_id: '2',
    })
    const assignment = template.assignment({ id: '2' })
    const state: AppState = template.appState({
      entities: {
        ...template.appState().entities,
        assignments: {
          '2': {
            data: assignment,
          },
        },
        quizzes: {
          '1': {
            data: quiz,
            pending: 1,
            error: null,
          },
        },
        courses: { '1': {} },
      },
    })

    expect(
      mapStateToProps(state, { courseID: '1', quizID: '1' })
    ).toMatchObject({
      quiz,
      pending: 1,
      error: null,
      courseID: '1',
      quizID: '1',
      assignmentGroup: null,
      assignment: assignment,
    })
  })

  it('returns showSubmissionSummary as false when the user is a designer', () => {
    const quiz = template.quiz({
      id: '1',
      assignment_group_id: null,
      assignment_id: null,
    })
    const state: AppState = template.appState({
      entities: {
        ...template.appState().entities,
        quizzes: {
          '1': {
            data: quiz,
            pending: 1,
            error: null,
          },
        },
        courses: {
          '1': {
            course: {
              name: 'CS1010',
              enrollments: [{ type: 'designer' }],
            },
          },
        },
      },
    })

    expect(
      mapStateToProps(state, { courseID: '1', quizID: '1' }).showSubmissionSummary
    ).toEqual(false)
  })
})
