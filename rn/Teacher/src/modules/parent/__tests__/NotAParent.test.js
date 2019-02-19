//
// Copyright (C) 2017-present Instructure, Inc.
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

/**
 * @flow
 */

import { NativeModules, Linking } from 'react-native'
import React from 'react'
import NotAParent from '../NotAParent'
import explore from '../../../../test/helpers/explore'

jest.mock('TouchableOpacity', () => 'TouchableOpacity')

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

test('renders NotAParent correctly', () => {
  let tree = renderer.create(
    <NotAParent />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('all the tapping should work', () => {
  let tree = renderer.create(
    <NotAParent />
  ).toJSON()

  const logout = explore(tree).selectByID('no-parent.logout') || {}
  const student = explore(tree).selectByID('no-parent.open-student') || {}
  const parent = explore(tree).selectByID('no-parent.open-teacher') || {}

  logout.props.onPress()
  expect(NativeModules.NativeLogin.logout).toHaveBeenCalled()
  student.props.onPress()
  expect(Linking.openURL).toHaveBeenCalledWith('https://itunes.apple.com/us/app/canvas-by-instructure/id480883488?ls=1&mt=8')
  parent.props.onPress()
  expect(Linking.openURL).toHaveBeenCalledWith('https://itunes.apple.com/us/app/canvas-teacher/id1257834464?ls=1&mt=8')
})
