// @flow

import React from 'react'
import { RubricDetails } from '../RubricDetails'
import renderer from 'react-test-renderer'
import explore from '../../../../../test/helpers/explore'
import { registerScreens } from '../../../../routing/register-screens'

registerScreens({})
jest.mock('react-native-button', () => 'Button')

const templates = {
  ...require('../../../../api/canvas-api/__templates__/rubric'),
}

let defaultProps = {
  assignmentID: '1',
  courseID: '1',
  rubricItems: [templates.rubric()],
  rubricSettings: templates.rubricSettings(),
  showModal: jest.fn(),
}

describe('Rubric', () => {
  it('doesnt render anything when there is no rubric', () => {
    let props = {
      ...defaultProps,
      rubricItems: null,
    }
    let tree = renderer.create(
      <RubricDetails {...props} />
    ).toJSON()

    expect(tree).toBeNull()
  })

  it('renders a rubric', () => {
    let tree = renderer.create(
      <RubricDetails {...defaultProps} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('calls showModal with the proper route when a view description is pressed', () => {
    let tree = renderer.create(
      <RubricDetails {...defaultProps} />
    ).toJSON()

    let button = explore(tree).selectByID('rubric-item.description') || {}
    button.props.onPress()

    expect(defaultProps.showModal).toHaveBeenCalledWith({
      screen: '(/api/v1)/courses/:courseID/assignments/:assignmentID/rubrics/:rubricID/description',
      passProps: {
        courseID: '1',
        assignmentID: '1',
        rubricID: defaultProps.rubricItems[0].id,
      },
    })
  })
})
