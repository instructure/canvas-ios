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

// @flow

import 'react-native'
import React from 'react'
import CourseFavorite from '../CourseFavorite'
import explore from '../../../../../../test/helpers/explore'
import * as courseTemplate from '../../../../../__templates__/course'

import renderer from 'react-test-renderer'

jest.mock('TouchableHighlight', () => 'TouchableHighlight')

let defaultProps = {
  id: '1',
  course: courseTemplate.course(),
  isFavorite: true,
  onPress: () => Promise.resolve(),
}

test('renders favorited correctly', () => {
  let tree = renderer.create(
    <CourseFavorite {...defaultProps} />
  ).toJSON()

  expect(tree).toMatchSnapshot()
})

test('renders unfavorited correctly', () => {
  let tree = renderer.create(
    <CourseFavorite {...defaultProps} isFavorite={false} />
  ).toJSON()

  expect(tree).toMatchSnapshot()
})

test('calls props.onPress with the course id and the toggled favorite value', () => {
  let onPress = jest.fn()
  let tree = renderer.create(
    <CourseFavorite {...defaultProps} onPress={onPress} />
  ).toJSON()

  let buttonTestID = 'edit-favorites.course-favorite.' + defaultProps.course.id + '-favorited'
  let button: any = explore(tree).selectByID(buttonTestID)
  button.props.onPress()

  expect(onPress).toHaveBeenCalledWith(defaultProps.course.id, false)
})
