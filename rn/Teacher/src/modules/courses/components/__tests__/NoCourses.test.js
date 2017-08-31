//
// Copyright (C) 2016-present Instructure, Inc.
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

import 'react-native'
import React from 'react'
import { NoCourses } from '../NoCourses'
import explore from '../../../../../test/helpers/explore'

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

  let button: any = explore(tree).selectByID('no-courses.add-courses-btn')
  button.props.onPress()
  expect(func).toHaveBeenCalled()
})
