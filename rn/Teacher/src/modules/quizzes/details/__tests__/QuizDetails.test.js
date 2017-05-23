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
  .mock('../../submissions/components/QuizSubmissionBreakdownGraphSection.js')
  .mock('../../../../routing')
  .mock('../../../../routing/Screen')

const template = {
  ...require('../../../../__templates__/helm'),
  ...require('../../../../api/canvas-api/__templates__/quiz'),
  ...require('../../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../../redux/__templates__/app-state'),
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
    }
  })

  it('renders', () => {
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
      assignment: null,
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
})
