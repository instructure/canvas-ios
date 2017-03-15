/**
 * @flow
 */

import 'react-native'
import React from 'react'
import { NoCourses } from '../NoCourses'
import explore from '../../../../test/helpers/explore'

jest.mock('TouchableOpacity', () => 'TouchableOpacity')

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

let defaultProps = {
  onAddCoursePressed: () => {},
}

test('renders NoCourses correctly', () => {
  let tree = renderer.create(
    <NoCourses {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('calls onAddCoursePressed when button is pressed', () => {
  let func = jest.fn()
  let tree = renderer.create(
    <NoCourses {...defaultProps} onAddCoursePressed={func} />
  ).toJSON()

  let button: any = explore(tree).selectByID('noCourse.addCourses')
  button.props.onPress()
  expect(func).toHaveBeenCalled()
})
