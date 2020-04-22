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

/* eslint-disable flowtype/require-valid-file-annotation */

import { shallow } from 'enzyme'
import React from 'react'
import { Alert, Animated, NativeModules } from 'react-native'
import { GradePicker, mapStateToProps } from '../GradePicker'
import renderer from 'react-test-renderer'
import explore from '../../../../../test/helpers/explore'
import setProps from '../../../../../test/helpers/setProps'
import * as templates from '../../../../__templates__/index'

jest
  .mock('react-native/Libraries/Components/Touchable/TouchableOpacity', () => 'TouchableOpacity')
  .mock('react-native/Libraries/Alert/Alert', () => ({
    prompt: jest.fn(),
    alert: jest.fn(),
  }))
  .mock('react-native/Libraries/Animated/src/Animated', () => ({
    timing: jest.fn(),
    View: 'Animated.View',
    Value: jest.fn(),
  }))
NativeModules.AlertControls = {
  onSubmitEditing: jest.fn(),
}

let ownProps = {
  submissionID: '1',
  assignmentID: '2',
  courseID: '3',
  userID: '4',
  isModeratedGrading: false,
  useRubricForGrading: false,
  rubricScore: '',
  navigator: templates.navigator(),
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
  isModeratedGrading: false,
  postedAt: null,
}

describe('GradePicker', () => {
  beforeEach(() => {
    jest.resetAllMocks()
    Animated.timing = jest.fn(() => ({
      start: jest.fn(),
    }))
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

  it('renders the points slider when the grading type is points and doesnt use the rubric for grading', () => {
    let tree = shallow(<GradePicker {...defaultProps} />)
    let slider = tree.find('Slider')
    expect(slider).toHaveLength(1)
  })

  it('passes the points slider the score without late policy', () => {
    let props = {
      ...defaultProps,
      score: 10,
      enteredScore: null,
      late: false,
      pointsDeducted: null,
    }

    let tree = shallow(<GradePicker {...props} />)
    let slider = tree.find('Slider')
    expect(slider.prop('score')).toEqual(10)
  })

  it('passes the points slider the entered score with late policy', () => {
    let props = {
      ...defaultProps,
      score: 10,
      enteredScore: 100,
      late: true,
      pointsDeducted: 90,
    }

    let tree = shallow(<GradePicker {...props} />)
    let slider = tree.find('Slider')
    expect(slider.prop('score')).toEqual(100)
  })

  it('renders points and grade', () => {
    let props = {
      ...defaultProps,
      score: 1,
      pointsPossible: 10,
      grade: 'F',
      gradingType: 'gpa_scale',
    }
    let tree = shallow(<GradePicker {...props} />)
    const label = tree.find('[testID="grade-picker.button"]').find('Heading1')
    expect(label.children().text()).toEqual('1/10 (F)')
  })

  it('renders the activity indicator when pending', () => {
    let tree = renderer.create(
      <GradePicker {...defaultProps} pending={true} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders the rubric score when useRubricForGrading', () => {
    let tree = renderer.create(
      <GradePicker {...defaultProps} grade={'A'} useRubricForGrading={true} rubricScore={'22'} />
    )

    tree.getInstance().setState({ useCustomGrade: false })

    expect(tree.toJSON()).toMatchSnapshot()
  })

  it('updates the visible rubric score when useRubricForGrading and rubrucScore changes', () => {
    let tree = renderer.create(
      <GradePicker {...defaultProps} grade={'B'} useRubricForGrading={true} rubricScore={'22'} />
    )

    tree.getInstance().setState({ useCustomGrade: false, originalRubricScore: '0' })

    expect(tree.toJSON()).toMatchSnapshot()
  })

  it('calls Alert.prompt when the grade picker button is pressed', () => {
    let tree = renderer.create(
      <GradePicker {...defaultProps} />
    ).toJSON()

    let button = explore(tree).selectByID('grade-picker.button') || {}
    button.props.onPress()

    expect(Alert.prompt).toHaveBeenCalled()
  })

  it('calls gradeSubmission with no value when No Grade is pressed', () => {
    Alert.prompt = jest.fn((title, message, buttons) => buttons[0].onPress())
    let tree = renderer.create(
      <GradePicker {...defaultProps} />
    )
    let instance = tree.getInstance()
    instance.slider.moveTo = jest.fn()

    let button = explore(tree.toJSON()).selectByID('grade-picker.button') || {}
    button.props.onPress()

    expect(instance.slider.moveTo).toHaveBeenCalledWith(0, false)
    expect(defaultProps.gradeSubmission).toHaveBeenCalledWith('3', '2', '4', '1', '')
  })

  it('calls excuseAssignment with the right ids when the excuse button is pressed', () => {
    Alert.prompt = jest.fn((title, message, buttons) => buttons[1].onPress())

    let tree = renderer.create(
      <GradePicker {...defaultProps} />
    )
    let instance = tree.getInstance()
    instance.slider.moveTo = jest.fn()

    let button = explore(tree.toJSON()).selectByID('grade-picker.button') || {}
    button.props.onPress()

    expect(instance.slider.moveTo).toHaveBeenCalledWith(instance.slider.width, false)
    expect(defaultProps.excuseAssignment).toHaveBeenCalledWith('3', '2', '4', '1')
  })

  it('calls gradeSubmission with the prompt value', () => {
    Alert.prompt = jest.fn((title, message, buttons) => buttons[2].onPress('34'))

    let tree = renderer.create(
      <GradePicker {...defaultProps} />
    )
    let instance = tree.getInstance()
    instance.slider.moveToScore = jest.fn()

    let button = explore(tree.toJSON()).selectByID('grade-picker.button') || {}
    button.props.onPress()

    expect(instance.slider.moveToScore).toHaveBeenCalledWith('34', false)
    expect(defaultProps.gradeSubmission).toHaveBeenCalledWith('3', '2', '4', '1', '34')
  })

  it('calls gradeSubmission with a % at the end of the grade for percentage grading type if the user leaves it off', () => {
    Alert.prompt = jest.fn((title, message, buttons) => buttons[2].onPress('80'))

    let tree = renderer.create(
      <GradePicker {...defaultProps} gradingType='percent' />
    ).toJSON()

    let button = explore(tree).selectByID('grade-picker.button') || {}
    button.props.onPress()

    expect(defaultProps.gradeSubmission).toHaveBeenCalledWith('3', '2', '4', '1', '80%')
  })

  it('does not show the excuse student button and has default value if the student is already excused', () => {
    let tree = renderer.create(
      <GradePicker {...defaultProps} excused={true} />
    ).toJSON()

    let button = explore(tree).selectByID('grade-picker.button') || {}
    button.props.onPress()

    expect(Alert.prompt.mock.calls[0][2].length).toEqual(3)
    expect(Alert.prompt.mock.calls[0][4]).not.toEqual('')
  })

  it('does not do anything if the student is already excused and ok is pressed', () => {
    Alert.prompt = jest.fn((title, message, buttons) => buttons[1].onPress('Excused'))
    const spy = jest.fn()
    let tree = renderer.create(
      <GradePicker {...defaultProps} excused={true} gradeSubmission={spy} />
    ).toJSON()

    let button = explore(tree).selectByID('grade-picker.button') || {}
    button.props.onPress()

    expect(spy.mock.calls.length).toBe(0)
  })

  it('calls gradeSubmission for a previously excused submission if ok is pressed and the prompt value no longer equals Excused', () => {
    Alert.prompt = jest.fn((title, message, buttons) => buttons[1].onPress('Excuse'))
    const spy = jest.fn()
    let tree = renderer.create(
      <GradePicker {...defaultProps} excused={true} gradeSubmission={spy} />
    ).toJSON()

    let button = explore(tree).selectByID('grade-picker.button') || {}
    button.props.onPress()

    expect(spy.mock.calls.length).toBe(1)
  })

  it('shows the current grade as the default value of the prompt when not excused', () => {
    let tree = renderer.create(
      <GradePicker {...defaultProps} grade='80%' />
    ).toJSON()

    let button = explore(tree).selectByID('grade-picker.button') || {}
    button.props.onPress()

    expect(Alert.prompt.mock.calls[0][4]).toEqual('80%')
  })

  it('submits when onSumitEditing is called', () => {
    NativeModules.AlertControls = {
      onSubmitEditing: jest.fn((cb: Function) => cb('prompt')),
    }
    let tree = shallow(<GradePicker {...defaultProps} />)
    let button = tree.find('[testID="grade-picker.button"]')
    button.simulate('press')

    expect(defaultProps.gradeSubmission).toHaveBeenCalledWith(
      defaultProps.courseID,
      defaultProps.assignmentID,
      defaultProps.userID,
      defaultProps.submissionID,
      'prompt'
    )
    expect(defaultProps.navigator.dismiss).toHaveBeenCalled()
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
    const spy = jest.fn()
    let tree = renderer.create(
      <GradePicker {...defaultProps} gradingType='pass_fail' excuseAssignment={spy} />
    )

    const picker: any = explore(tree.toJSON()).selectByType('PickerIOS')
    picker.props.onValueChange('ex')

    expect(spy).toHaveBeenCalledWith('3', '2', '4', '1')
  })

  it('calls gradeSubmission with the pass fail value when it is not excused for pass fail assignments', () => {
    const spy = jest.fn()
    let tree = renderer.create(
      <GradePicker {...defaultProps} gradingType='pass_fail' gradeSubmission={spy} />
    )

    const picker: any = explore(tree.toJSON()).selectByType('PickerIOS')
    picker.props.onValueChange('complete')

    expect(spy).toHaveBeenCalledWith('3', '2', '4', '1', 'complete')
  })

  it('disables the button and has correct text for not graded assignment type', () => {
    let tree = renderer.create(
      <GradePicker {...defaultProps} gradingType='not_graded' />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('calls Alert.alert when the grade doesnt stick', () => {
    Alert.prompt = jest.fn((title, message, buttons) => buttons[2].onPress('asdf'))

    let view = renderer.create(
      <GradePicker {...defaultProps} />
    )

    let button = explore(view.toJSON()).selectByID('grade-picker.button') || {}
    button.props.onPress()

    setProps(view, { grade: 'asdf', pending: true })
    setProps(view, { grade: null, pending: false })

    expect(Alert.alert).toHaveBeenCalledWith(
      'Error Saving Grade',
      'There was a problem saving the grade. Please try again.',
    )
  })

  it('renders late policy with single point deducted', () => {
    let props = {
      ...defaultProps,
      late: true,
      pointsDeducted: 1,
      enteredGrade: '9',
      enteredScore: 9,
      grade: '8',
      score: 8,
    }

    let view = renderer.create(
      <GradePicker {...props} />
    )

    expect(view).toMatchSnapshot()
  })

  it('renders late policy with multiple points deducted', () => {
    let props = {
      ...defaultProps,
      late: true,
      pointsDeducted: 2,
      enteredGrade: '9',
      enteredScore: 9,
      grade: '7',
      score: 7,
    }

    let view = renderer.create(
      <GradePicker {...props} />
    )

    expect(view).toMatchSnapshot()
  })

  it('doesnt render late policy if no grade', () => {
    let props = {
      ...defaultProps,
      late: true,
      pointsDeducted: 1,
      enteredGrade: null,
      enteredScore: null,
      grade: null,
      score: null,
    }

    let view = renderer.create(
      <GradePicker {...props} />
    )

    expect(view).toMatchSnapshot()
  })

  it('shows the enteredGrade as default value for the prompt with late policy', () => {
    let props = {
      ...defaultProps,
      late: true,
      pointsDeducted: 10,
      enteredGrade: '90%',
      enteredScore: 90,
      grade: '80%',
    }

    let tree = renderer.create(
      <GradePicker {...props} />
    ).toJSON()

    let button = explore(tree).selectByID('grade-picker.button') || {}
    button.props.onPress()

    expect(Alert.prompt.mock.calls[0][4]).toEqual('90%')
  })

  it('doesnt show the eye on non graded submissions', () => {
    let tree = shallow(
      <GradePicker
        {...defaultProps}
        grade={''}
        postedAt={null}
      />
    )

    expect(tree.exists('[testID="GradePicker.postedEye"]')).toBe(false)
  })

  it('doesnt show the eye on graded, posted submissions', () => {
    let tree = shallow(
      <GradePicker
        {...defaultProps}
        grade={'B+'}
        postedAt='2019-08-29T00:00:00.000Z'
      />
    )
    expect(tree.exists('[testID="GradePicker.postedEye"]')).toBe(false)
  })

  it('shows the eye on graded, not posted submissions', () => {
    let tree = shallow(
      <GradePicker
        {...defaultProps}
        grade={'B+'}
        postedAt={null}
      />
    )
    expect(tree.exists('[testID="GradePicker.postedEye"]')).toBe(true)
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
    let submission = templates.submissionHistory([{
      id: '1',
      grade: 'yo',
      score: 10,
      excused: true,
      posted_at: '2019-08-29T00:00:00.000Z',
    }])
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
      postedAt: submission.posted_at,
    })
  })
})
