// @flow

import React from 'react'
import { AlertIOS } from 'react-native'
import { GradePicker } from '../GradePicker'
import renderer from 'react-test-renderer'
import explore from '../../../../../test/helpers/explore'

jest.mock('TouchableOpacity', () => 'TouchableOpacity')
jest.mock('AlertIOS', () => ({
  prompt: jest.fn(),
}))

let defaultProps = {
  submissionID: '1',
  assignmentID: '2',
  courseID: '3',
  userID: '4',
  grade: '',
  excused: false,
  excuseAssignment: jest.fn(),
}

describe('GradePicker', () => {
  beforeEach(() => jest.resetAllMocks())

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

  it('calls AlertIOS.prompt when the grade picker button is pressed', () => {
    let tree = renderer.create(
      <GradePicker {...defaultProps} />
    ).toJSON()

    let button = explore(tree).selectByID('grade-picker.button') || {}
    button.props.onPress()

    expect(AlertIOS.prompt).toHaveBeenCalled()
  })

  it('calls excuseAssignment with the right ids when the excuse button is pressed', () => {
    AlertIOS.prompt = jest.fn((title, message, buttons) => buttons[0].onPress())

    let tree = renderer.create(
      <GradePicker {...defaultProps} />
    ).toJSON()

    let button = explore(tree).selectByID('grade-picker.button') || {}
    button.props.onPress()

    expect(defaultProps.excuseAssignment).toHaveBeenCalledWith('3', '2', '4', '1')
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
})
