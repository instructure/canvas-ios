// @flow

import React from 'react'
import { AlertIOS, Animated } from 'react-native'
import { GradePicker, mapStateToProps } from '../GradePicker'
import renderer from 'react-test-renderer'
import explore from '../../../../../test/helpers/explore'

jest
  .mock('TouchableOpacity', () => 'TouchableOpacity')
  .mock('AlertIOS', () => ({
    prompt: jest.fn(),
  }))
  .mock('Animated', () => ({
    timing: jest.fn(),
    View: 'Animated.View',
    Value: jest.fn(),
  }))

const templates = {
  ...require('../../../../api/canvas-api/__templates__/submissions'),
  ...require('../../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../../redux/__templates__/app-state'),
}

let ownProps = {
  submissionID: '1',
  assignmentID: '2',
  courseID: '3',
  userID: '4',
}

let defaultProps = {
  ...ownProps,
  grade: '',
  excused: false,
  excuseAssignment: jest.fn(),
  gradeSubmission: jest.fn(),
  score: 0,
  pointsPossible: 10,
  pending: false,
  gradingType: 'points',
}

describe('GradePicker', () => {
  beforeEach(() => {
    jest.resetAllMocks()
    Animated.timing.mockReturnValue({ start: jest.fn() })
  })

  it('renders with no grade', () => {
    let tree = renderer.create(
      <GradePicker {...defaultProps} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders with excused', () => {
    let tree = renderer.create(
      <GradePicker {...defaultProps} excused={true} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders points based grades', () => {
    let tree = renderer.create(
      <GradePicker {...defaultProps} grade={'5'} score={5} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders the activity indicator when pending', () => {
    let tree = renderer.create(
      <GradePicker {...defaultProps} pending={true} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('calls AlertIOS.prompt when the grade picker button is pressed', () => {
    let tree = renderer.create(
      <GradePicker {...defaultProps} />
    ).toJSON()

    let button = explore(tree).selectByID('grade-picker.button') || {}
    button.props.onPress()

    expect(AlertIOS.prompt).toHaveBeenCalled()
  })

  it('calls excuseAssignment with the right ids when the excuse button is pressed', () => {
    // $FlowFixMe
    AlertIOS.prompt = jest.fn((title, message, buttons) => buttons[0].onPress())

    let tree = renderer.create(
      <GradePicker {...defaultProps} />
    ).toJSON()

    let button = explore(tree).selectByID('grade-picker.button') || {}
    button.props.onPress()

    expect(defaultProps.excuseAssignment).toHaveBeenCalledWith('3', '2', '4', '1')
  })

  it('calls gradeSubmission with the prompt value', () => {
    // $FlowFixMe
    AlertIOS.prompt = jest.fn((title, message, buttons) => buttons[1].onPress('yo'))

    let tree = renderer.create(
      <GradePicker {...defaultProps} />
    ).toJSON()

    let button = explore(tree).selectByID('grade-picker.button') || {}
    button.props.onPress()

    expect(defaultProps.gradeSubmission).toHaveBeenCalledWith('3', '2', '4', '1', 'yo')
  })

  it('calls gradeSubmission with a % at the end of the grade for percentage grading type if the user leaves it off', () => {
    // $FlowFixMe
    AlertIOS.prompt = jest.fn((title, message, buttons) => buttons[1].onPress('80'))

    let tree = renderer.create(
      <GradePicker {...defaultProps} gradingType='percent' />
    ).toJSON()

    let button = explore(tree).selectByID('grade-picker.button') || {}
    button.props.onPress()

    expect(defaultProps.gradeSubmission).toHaveBeenCalledWith('3', '2', '4', '1', '80%')
  })

  it('doesnt show the excuse student button and has default value if the student is already excused', () => {
    let tree = renderer.create(
      <GradePicker {...defaultProps} excused={true} />
    ).toJSON()

    let button = explore(tree).selectByID('grade-picker.button') || {}
    button.props.onPress()

    expect(AlertIOS.prompt.mock.calls[0][2].length).toEqual(2)
    expect(AlertIOS.prompt.mock.calls[0][4]).not.toEqual('')
  })

  it('shows the current grade as the default value of the prompt when not excused', () => {
    let tree = renderer.create(
      <GradePicker {...defaultProps} grade='80%' />
    ).toJSON()

    let button = explore(tree).selectByID('grade-picker.button') || {}
    button.props.onPress()

    expect(AlertIOS.prompt.mock.calls[0][4]).toEqual('80%')
  })

  it('renders the picker for pass fail assignments', () => {
    let tree = renderer.create(
      <GradePicker {...defaultProps} gradingType='pass_fail' />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('toggles the grade picker open and closed for pass fail assignments when the button is pressed', () => {
    let tree = renderer.create(
      <GradePicker {...defaultProps} gradingType='pass_fail' />
    )

    let button = explore(tree.toJSON()).selectByID('grade-picker.button') || {}
    button.props.onPress()

    expect(Animated.timing).toHaveBeenLastCalledWith(tree.getInstance().state.easeAnimation, { toValue: 192 })
    expect(tree.getInstance().state.pickerOpen).toBeTruthy()

    button = explore(tree.toJSON()).selectByID('grade-picker.button') || {}
    button.props.onPress()

    expect(Animated.timing).toHaveBeenLastCalledWith(tree.getInstance().state.easeAnimation, { toValue: 0 })
    expect(tree.getInstance().state.pickerOpen).toBeFalsy()
  })

  it('calls excuseAssignment when the user chooses excused option in picker for pass fail assignments', () => {
    let tree = renderer.create(
      <GradePicker {...defaultProps} gradingType='pass_fail' />
    )

    tree.getInstance().setState({ pickerOpen: true, passFailValue: 'ex' })
    tree.getInstance().togglePicker()

    expect(defaultProps.excuseAssignment).toHaveBeenCalledWith('3', '2', '4', '1')
  })

  it('calls gradeSubmission with the pass fail value when it is not excused for pass fail assignments', () => {
    let tree = renderer.create(
      <GradePicker {...defaultProps} gradingType='pass_fail' />
    )

    tree.getInstance().setState({ pickerOpen: true, passFailValue: 'complete' })
    tree.getInstance().togglePicker()

    expect(defaultProps.gradeSubmission).toHaveBeenCalledWith('3', '2', '4', '1', 'complete')
  })

  it('disables the button and has correct text for not graded assignment type', () => {
    let tree = renderer.create(
      <GradePicker {...defaultProps} gradingType='not_graded' />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })
})

describe('mapStateToProps', () => {
  it('returns the correct data when there is no submission', () => {
    let assignment = templates.assignment({ id: '2' })
    let state = templates.appState({
      entities: {
        assignments: {
          '2': {
            data: assignment,
            pending: 0,
            error: null,
            submissions: {},
          },
        },
      },
    })

    let props = { ...ownProps, submissionID: undefined }

    let dataProps = mapStateToProps(state, props)
    expect(dataProps).toMatchObject({
      excused: false,
      grade: '',
      pending: false,
      score: 0,
      pointsPossible: assignment.points_possible,
      gradingType: assignment.grading_type,
    })
  })

  it('returns the correct data when there is a submission', () => {
    let assignment = templates.assignment({ id: '2' })
    let submission = templates.submissionHistory([{ id: '1', grade: 'yo', score: 10, excused: true }])
    let state = templates.appState({
      entities: {
        assignments: {
          '2': {
            data: assignment,
            pending: 0,
            error: null,
            submissions: {},
          },
        },
        submissions: {
          '1': {
            submission,
            pending: 3,
            error: null,
          },
        },
      },
    })

    let dataProps = mapStateToProps(state, ownProps)
    expect(dataProps).toMatchObject({
      excused: true,
      grade: 'yo',
      pending: true,
      score: 10,
      pointsPossible: assignment.points_possible,
      gradingType: assignment.grading_type,
    })
  })
})
