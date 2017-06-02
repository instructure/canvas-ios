/* @flow */

import React from 'react'
import {
  Alert,
} from 'react-native'
import renderer from 'react-test-renderer'

import { QuizEdit, mapStateToProps } from '../QuizEdit'
import explore from '../../../../../test/helpers/explore'
import { ERROR_TITLE } from '../../../../redux/middleware/error-handler'

jest
  .mock('Button', () => 'Button')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')
  .mock('LayoutAnimation', () => ({
    easeInEaseOut: jest.fn(),
  }))
  .mock('DatePickerIOS', () => 'DatePickerIOS')
  .mock('PickerIOS', () => require('../../../../__mocks__/PickerIOS').default)
  .mock('Alert', () => ({
    alert: jest.fn(),
  }))
  .mock('../../../../routing')
  .mock('WebView', () => 'WebView')
  .mock('../../../assignment-details/components/AssignmentDatesEditor', () => 'AssignmentDatesEditor')
  .mock('../../../../routing/Screen')

const template = {
  ...require('../../../../api/canvas-api/__templates__/quiz'),
  ...require('../../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../../api/canvas-api/__templates__/error'),
  ...require('../../../../__templates__/helm'),
  ...require('../../../../redux/__templates__/app-state'),
}

describe('QuizEdit', () => {
  let props
  beforeEach(() => {
    jest.clearAllMocks()

    props = {
      quiz: template.quiz(),
      navigator: template.navigator(),
      defaultDate: new Date(0),
      assignmentGroups: {},
      courseID: '1',
      updateQuiz: jest.fn(),
      error: null,
      updateAssignment: jest.fn(),
      refreshAssignment: jest.fn(),
      assignment: null,
    }
  })

  it('renders', () => {
    testRender(props)
  })

  it('toggles "let students see responses"', () => {
    props.quiz.hide_results = 'always'
    const component = render(props)
    const toggle: any = explore(component.toJSON()).selectByID('quizzes.edit.hide-results-toggle')
    toggle.props.onValueChange(true)
    expect(component.toJSON()).toMatchSnapshot()
  })

  it('toggles "only once after each attempt"', () => {
    props.quiz.hide_results = null
    const component = render(props)
    const toggle: any = explore(component.toJSON()).selectByID('quizzes.edit.hide-results-after-attempt-toggle')
    toggle.props.onValueChange(true)
    expect(component.toJSON()).toMatchSnapshot()
    toggle.props.onValueChange(false)
    expect(component.toJSON()).toMatchSnapshot()
  })

  it('toggles "show correct answers" options', () => {
    props.quiz.show_correct_answers = true
    const component = render(props)
    const toggle: any = explore(component.toJSON()).selectByID('quizzes.edit.show-correct-answers-toggle')
    toggle.props.onValueChange(false)
    expect(component.toJSON()).toMatchSnapshot()
  })

  it('toggles "show correct answers" date picker', () => {
    props.quiz.show_correct_answers = true
    const component = render(props)
    const row: any = explore(component.toJSON()).selectByID('quizzes.edit.show-correct-answers-at-row')
    row.props.onPress()
    expect(component.toJSON()).toMatchSnapshot()
    row.props.onPress()
    expect(component.toJSON()).toMatchSnapshot()
  })

  it('toggles "hide correct answers" date picker', () => {
    props.quiz.show_correct_answers = true
    const component = render(props)
    const row: any = explore(component.toJSON()).selectByID('quizzes.edit.hide-correct-answers-at-row')
    row.props.onPress()
    expect(component.toJSON()).toMatchSnapshot()
    row.props.onPress()
    expect(component.toJSON()).toMatchSnapshot()
  })

  it('updates "show correct answers at" date from picker', () => {
    props.quiz.show_correct_answers = true
    const component = render(props)
    const toggle: any = explore(component.toJSON()).selectByID('quizzes.edit.show-correct-answers-at-row')
    toggle.props.onPress()
    const picker: any = explore(component.toJSON()).selectByID('quizzes.edit.show-correct-answers-at-date-picker')
    picker.props.onDateChange(new Date(1000))
    expect(component.toJSON()).toMatchSnapshot()
  })

  it('clears "show correct answers at" date', () => {
    props.quiz.show_correct_answers = true
    props.quiz.show_correct_answers_at = new Date(0).toISOString()
    const component = render(props)
    const clearButton: any = explore(component.toJSON()).selectByID('quizzes.edit.clear_show_correct_answers_at_button')
    clearButton.props.onPress()
    expect(component.toJSON()).toMatchSnapshot()
  })

  it('clears "hide correct answers at" date', () => {
    props.quiz.show_correct_answers = true
    props.quiz.hide_correct_answers_at = new Date(0).toISOString()
    const component = render(props)
    const clearButton: any = explore(component.toJSON()).selectByID('quizzes.edit.clear_hide_correct_answers_at_button')
    clearButton.props.onPress()
    expect(component.toJSON()).toMatchSnapshot()
  })

  it('updates "hide correct answers at" date from picker', () => {
    props.quiz.show_correct_answers = true
    const component = render(props)
    const toggle: any = explore(component.toJSON()).selectByID('quizzes.edit.hide-correct-answers-at-row')
    toggle.props.onPress()
    const picker: any = explore(component.toJSON()).selectByID('quizzes.edit.hide-correct-answers-at-date-picker')
    picker.props.onDateChange(new Date(1000))
    expect(component.toJSON()).toMatchSnapshot()
  })

  it('toggles "one question at a time"', () => {
    props.quiz.one_question_at_a_time = false
    const component = render(props)
    const toggle: any = explore(component.toJSON()).selectByID('quizzes.edit.one-question-at-a-time-toggle')
    toggle.props.onValueChange(true)
    expect(component.toJSON()).toMatchSnapshot()
  })

  it('toggles "access code"', () => {
    props.quiz.access_code = null
    const component = render(props)
    const toggle: any = explore(component.toJSON()).selectByID('quizzes.edit.access-code-toggle')
    toggle.props.onValueChange(true)
    expect(component.toJSON()).toMatchSnapshot()
    toggle.props.onValueChange(false)
    expect(component.toJSON()).toMatchSnapshot()
  })

  it('shows quiz time picker', () => {
    const component = render(props)
    const row: any = explore(component.toJSON()).selectByID('quizzes.edit.quiz-type-row')
    row.props.onPress()
    expect(component.toJSON()).toMatchSnapshot()
  })

  it('changes quiz type', () => {
    props.quiz.quiz_type = 'assignment'
    const component = render(props)
    const row: any = explore(component.toJSON()).selectByID('quizzes.edit.quiz-type-row')
    row.props.onPress()
    const picker: any = explore(component.toJSON()).selectByID('quizzes.edit.quiz-type-picker')
    picker.props.onValueChange('graded_survey')
    expect(component.toJSON()).toMatchSnapshot()
  })

  it('shows Assignment Group picker', () => {
    props.quiz.quiz_type = 'assignment'
    props.assignmentGroups = { '1': template.assignmentGroup({ id: '1', name: 'Group Item 1' }) }
    const component = render(props)
    const row: any = explore(component.toJSON()).selectByID('quizzes.edit.assignment-group-row')
    row.props.onPress()
    expect(component.toJSON()).toMatchSnapshot()
  })

  it('changes assignment group', () => {
    const old = template.assignmentGroup({ id: '1', name: 'Old' })
    const changed = template.assignmentGroup({ id: '2', name: 'Changed' })
    props.quiz.quiz_type = 'graded_survey'
    props.quiz.assignment_group_id = old.id
    props.assignmentGroups = {
      '1': old,
      '2': changed,
    }
    const component = render(props)
    const row: any = explore(component.toJSON()).selectByID('quizzes.edit.assignment-group-row')
    row.props.onPress()
    const picker: any = explore(component.toJSON()).selectByID('quizzes.edit.assignment-group-picker')
    picker.props.onValueChange(changed.id)
    expect(component.toJSON()).toMatchSnapshot()
  })

  it('saves quiz on done', () => {
    props.updateQuiz = jest.fn()
    const tree = render(props).toJSON()
    const doneButton: any = explore(tree).selectRightBarButton('quizzes.edit.doneButton')
    doneButton.action()
    expect(props.updateQuiz).toHaveBeenCalledWith(props.quiz, props.courseID, props.quiz)
  })

  it('should validate the assignment dates on done', () => {
    const validate = jest.fn()
    const createNodeMock = ({ type }) => {
      if (type === 'AssignmentDatesEditor') {
        return {
          validate,
          updateAssignment: jest.fn(),
        }
      }
    }
    // $FlowFixMe
    props.assignment = template.assignment()
    const tree = render(props, { createNodeMock }).toJSON()
    const doneButton: any = explore(tree).selectRightBarButton('quizzes.edit.doneButton')
    doneButton.action()
    expect(validate).toHaveBeenCalled()
  })

  it('updates assignment on done', () => {
    const originalAssignment = template.assignment({ name: 'Original Assignment' })
    const updatedAssignment = { ...originalAssignment, name: 'Updated assignment' }
    const createNodeMock = ({ type }) => {
      if (type === 'AssignmentDatesEditor') {
        return {
          validate: jest.fn().mockReturnValue(true),
          updateAssignment: (assignment) => updatedAssignment,
        }
      }
    }
    // $FlowFixMe
    props.assignment = originalAssignment
    const tree = render(props, { createNodeMock }).toJSON()
    const doneButton: any = explore(tree).selectRightBarButton('quizzes.edit.doneButton')
    doneButton.action()
    expect(props.updateAssignment).toHaveBeenCalledWith(props.courseID, updatedAssignment, originalAssignment)
  })

  it('shows modal while saving', () => {
    const component = render(props)
    const doneButton: any = explore(component.toJSON()).selectRightBarButton('quizzes.edit.doneButton')
    doneButton.action()
    expect(component.toJSON()).toMatchSnapshot()
  })

  it('hides modal when save finishes', () => {
    const component = render(props)
    const doneButton: any = explore(component.toJSON()).selectRightBarButton('quizzes.edit.doneButton')
    doneButton.action()
    component.update(<QuizEdit {...props} pending={false} />)
    expect(component.toJSON()).toMatchSnapshot()
  })

  it('calls dismiss when save finishes', () => {
    const mock = jest.fn()
    props.navigator.dismissAllModals = mock
    const component = render(props)
    const doneButton: any = explore(component.toJSON()).selectRightBarButton('quizzes.edit.doneButton')
    doneButton.action()
    component.update(<QuizEdit {...props} pending={false} />)
    expect(mock).toHaveBeenCalled()
  })

  it('calls dismiss on cancel', () => {
    props.navigator.dismiss = jest.fn()
    const tree = render(props).toJSON()
    const cancelButton: any = explore(tree).selectLeftBarButton('quizzes.edit.cancelButton')
    cancelButton.action()
    expect(props.navigator.dismiss).toHaveBeenCalled()
  })

  it('presents errors', () => {
    jest.useFakeTimers()
    Alert.alert = jest.fn()
    const component = render(props)
    const error = { response: template.error('this is an error') }
    // $FlowFixMe
    component.update(<QuizEdit {...props} error={error} />)
    jest.runAllTimers()
    expect(Alert.alert).toHaveBeenCalledWith(ERROR_TITLE, 'this is an error')
  })

  it('navigates to edit description', () => {
    props.quiz.description = 'i am a description'
    props.navigator.show = jest.fn()
    const component = render(props)
    const row: any = explore(component.toJSON()).selectByID('quizzes.edit.description-row')
    row.props.onPress()
    expect(props.navigator.show).toHaveBeenCalledWith('/rich-text-editor', {
      modal: false,
    }, {
      defaultValue: 'i am a description',
      onChangeValue: expect.any(Function),
    })
  })

  it('toggles time limit', () => {
    props.quiz.time_limit = null
    const component = render(props)
    const toggle: any = explore(component.toJSON()).selectByID('quizzes.edit.time-limit-toggle')
    toggle.props.onValueChange(true)
    expect(component.toJSON()).toMatchSnapshot()
    toggle.props.onValueChange(false)
    expect(component.toJSON()).toMatchSnapshot()
  })

  it('toggles shuffle answers', () => {
    props.quiz.shuffle_answers = false
    const component = render(props)
    const toggle: any = explore(component.toJSON()).selectByID('quizzes.edit.shuffle-answers-toggle')
    toggle.props.onValueChange(true)
    expect(component.toJSON()).toMatchSnapshot()
    toggle.props.onValueChange(false)
    expect(component.toJSON()).toMatchSnapshot()
  })

  it('toggles publish', () => {
    props.quiz.published = false
    const component = render(props)
    const toggle: any = explore(component.toJSON()).selectByID('quizzes.edit.published-toggle')
    toggle.props.onValueChange(true)
    expect(component.toJSON()).toMatchSnapshot()
    toggle.props.onValueChange(false)
    expect(component.toJSON()).toMatchSnapshot()
  })

  it('toggles "Show One Question at a Time"', () => {
    props.quiz.one_question_at_a_time = false
    const component = render(props)
    const toggle: any = explore(component.toJSON()).selectByID('quizzes.edit.one-question-at-a-time-toggle')
    toggle.props.onValueChange(true)
    expect(component.toJSON()).toMatchSnapshot()
    toggle.props.onValueChange(false)
    expect(component.toJSON()).toMatchSnapshot()
  })

  it('toggles "Lock Questions After Answering', () => {
    props.quiz.one_question_at_a_time = true
    props.quiz.cant_go_back = false
    const component = render(props)
    const toggle: any = explore(component.toJSON()).selectByID('quizzes.edit.cant-go-back-toggle')
    toggle.props.onValueChange(true)
    expect(component.toJSON()).toMatchSnapshot()
    toggle.props.onValueChange(false)
    expect(component.toJSON()).toMatchSnapshot()
  })

  it('should refresh the assignment on unmount if assignment given', () => {
    props.refreshAssignment = jest.fn()

    // without assignment
    props.assignment = null
    let component = render(props)
    component.getInstance().componentWillUnmount()
    expect(props.refreshAssignment).not.toHaveBeenCalled()

    // given assignment
    // $FlowFixMe
    props.assignment = template.assignment()
    component = render(props)
    component.getInstance().componentWillUnmount()
    expect(props.refreshAssignment).toHaveBeenCalled()
  })

  function testRender (props: any) {
    expect(render(props)).toMatchSnapshot()
  }

  function render (props: any, options?: any): any {
    const opts = options || {
      createNodeMock: ({ type }) => {
        if (type === 'AssignmentDatesEditor') {
          return {
            validate: jest.fn(),
            updateAssignment: jest.fn(a => a),
          }
        }
      },
    }
    return renderer.create(
      <QuizEdit {...props} />, opts
    )
  }
})

describe('map state to props', () => {
  it('should map state to props', () => {
    const quiz = template.quiz({ id: '1' })
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
            error: 'this is an error',
          },
        },
      },
    })

    expect(
      mapStateToProps(state, { courseID: '1', quizID: '1' })
    ).toEqual({
      quiz,
      assignmentGroups: {
        '1': ag1,
        '2': ag2,
      },
      pending: 1,
      error: 'this is an error',
      assignment: null,
    })
  })

  it('should map assignment_id to assignment prop', () => {
    const quiz = template.quiz({ id: '1', assignment_id: '2', quiz_type: 'assignment' })
    const assignment = template.assignment({ id: '2' })
    const state: AppState = template.appState({
      entities: {
        ...template.appState().entities,
        assignments: {
          '2': {
            data: assignment,
            pending: 0,
            submissions: { refs: [], pending: 0 },
            pendingComments: {},
          },
        },
        quizzes: {
          '1': {
            data: quiz,
            pending: 1,
            error: 'this is an error',
          },
        },
      },
    })
    expect(
      mapStateToProps(state, { courseID: '1', quizID: '1' })
    ).toMatchObject({
      assignment,
    })
  })

  it('should not map assignment_id to assignment prop if quiz is not an assignment', () => {
    const quiz = template.quiz({ id: '1', assignment_id: '2', quiz_type: 'practice_quiz' })
    const assignment = template.assignment({ id: '2' })
    const state: AppState = template.appState({
      entities: {
        ...template.appState().entities,
        assignments: {
          '2': {
            data: assignment,
            pending: 0,
            submissions: { refs: [], pending: 0 },
            pendingComments: {},
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
      assignment: null,
    })
  })

  it('should map assignment pending to prop', () => {
    const quiz = template.quiz({ id: '1', assignment_id: '2' })
    const assignment = template.assignment({ id: '2' })
    const state: AppState = template.appState({
      entities: {
        ...template.appState().entities,
        assignments: {
          '2': {
            data: assignment,
            pending: 1,
            submissions: { refs: [], pending: 0 },
            pendingComments: {},
          },
        },
        quizzes: {
          '1': {
            data: quiz,
            pending: 0,
            error: null,
          },
        },
      },
    })
    expect(
      mapStateToProps(state, { courseID: '1', quizID: '1' })
    ).toMatchObject({
      pending: 1,
    })
  })

  it('should map assignment error to top prop', () => {
    const quiz = template.quiz({ id: '1', assignment_id: '2' })
    const assignment = template.assignment({ id: '2' })
    const state: AppState = template.appState({
      entities: {
        ...template.appState().entities,
        assignments: {
          '2': {
            data: assignment,
            pending: 0,
            error: 'Request failed',
            submissions: { refs: [], pending: 0 },
            pendingComments: {},
          },
        },
        quizzes: {
          '1': {
            data: quiz,
            pending: 0,
            error: null,
          },
        },
      },
    })
    expect(
      mapStateToProps(state, { courseID: '1', quizID: '1' })
    ).toMatchObject({
      error: 'Request failed',
    })
  })
})
