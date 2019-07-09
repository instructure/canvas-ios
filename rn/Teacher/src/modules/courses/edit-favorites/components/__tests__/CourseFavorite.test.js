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
