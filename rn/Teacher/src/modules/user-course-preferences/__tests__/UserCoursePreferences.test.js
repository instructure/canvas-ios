// @flow

import React from 'react'
import { UserCoursePreferences } from '../UserCoursePreferences'
import * as courseTemplates from '../../../api/canvas-api/__templates__/course'
import * as navigatorTemplates from '../../../__templates__/react-native-navigation'
import explore from '../../../../test/helpers/explore'

import renderer from 'react-test-renderer'

jest.mock('TouchableHighlight', () => 'TouchableHighlight')

let templates = { ...courseTemplates, ...navigatorTemplates }

let defaultProps = {
  navigator: templates.navigator(),
  course: templates.course(),
  color: '#333',
  updateCourseColor: jest.fn(),
  refresh: jest.fn(),
  pending: 0,
}

describe('UserCoursePreferences', () => {
  beforeEach(() => {
    jest.resetAllMocks()
  })

  it('renders', () => {
    let tree = renderer.create(
      <UserCoursePreferences {...defaultProps} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
    expect(defaultProps.navigator.setTitle).toHaveBeenCalledWith({
      title: 'Customize Course',
    })
    expect(defaultProps.navigator.setOnNavigatorEvent).toHaveBeenCalled()
  })

  it('calls dismissModal when done is pressed', () => {
    let tree = renderer.create(
      <UserCoursePreferences {...defaultProps} />
    )

    tree._component._renderedComponent._instance.onNavigatorEvent({
      type: 'NavBarButtonPress',
      id: 'done',
    })

    expect(defaultProps.navigator.dismissModal).toHaveBeenCalled()
  })

  it('calls props.updateCourseColor when a color is pressed', () => {
    let tree = renderer.create(
      <UserCoursePreferences {...defaultProps} />
    ).toJSON()

    let color = explore(tree).selectByID('colorButton.#F26090') || {}
    color.props.onPress()

    expect(defaultProps.updateCourseColor).toHaveBeenCalledWith(defaultProps.course.id, '#F26090')
  })
})
