/**
 * @flow
 */

import { NativeModules, Linking } from 'react-native'
import React from 'react'
import NotATeacher from '../NotATeacher'
import explore from '../../../../../test/helpers/explore'

jest.mock('TouchableOpacity', () => 'TouchableOpacity')

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

test('renders NotATeacher correctly', () => {
  let tree = renderer.create(
    <NotATeacher />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('all the tapping should work', () => {
  let tree = renderer.create(
    <NotATeacher />
  ).toJSON()

  const logout = explore(tree).selectByID('no-teacher.logout') || {}
  const student = explore(tree).selectByID('no-teacher.open-student') || {}
  const parent = explore(tree).selectByID('no-teacher.open-parent') || {}

  logout.props.onPress()
  expect(NativeModules.NativeLogin.logout).toHaveBeenCalled()
  student.props.onPress()
  expect(Linking.openURL).toHaveBeenCalledWith('https://itunes.apple.com/us/app/canvas-by-instructure/id480883488?ls=1&mt=8')
  parent.props.onPress()
  expect(Linking.openURL).toHaveBeenCalledWith('https://itunes.apple.com/us/app/canvas-parent/id1097996698?ls=1&mt=8')
})
