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
import * as courseTemplate from '../../../../__templates__/course'
import * as navigationTemplate from '../../../../__templates__/helm'
import { Refreshed, FavoritesList } from '../EditFavorites'
import setProps from '../../../../../test/helpers/setProps'

import renderer from 'react-test-renderer'
import { shallow } from 'enzyme/build/index'

let courses = [
  courseTemplate.course(),
  courseTemplate.course(),
]

let defaultProps = {
  navigator: navigationTemplate.navigator(),
  courses: courses,
  favorites: [courses[0].id, courses[1].id],
  toggleFavorite: () => Promise.resolve(),
  refresh: jest.fn(),
  pending: 0,
  refreshing: false,
}

test('renders correctly', () => {
  let tree = renderer.create(
    <FavoritesList {...defaultProps} />
  ).toJSON()

  expect(tree).toMatchSnapshot()
})

it('refresh courses when empty', () => {
  const refreshCourses = jest.fn()
  const refreshProps = {
    courses: [],
    refreshCourses,
  }

  const tree = shallow(<Refreshed {...refreshProps} />)
  expect(tree).toMatchSnapshot()
  expect(refreshCourses).toHaveBeenCalled()
})

it('no refresh when at least one course exists', () => {
  const refreshCourses = jest.fn()
  const refreshProps = {
    courses: [],
    refreshCourses,
  }

  const tree = shallow(<Refreshed {...refreshProps} />)
  expect(tree).toMatchSnapshot()
  expect(refreshCourses).toHaveBeenCalledTimes(1)
  expect(tree.refreshing).toBeFalsy()
  refreshProps.courses[0] = courses[0]
  tree.setProps(refreshProps)
  expect(refreshCourses).toHaveBeenCalledTimes(1)
})

it('refreshes with new props', () => {
  const refreshCourses = jest.fn()
  const refreshProps = {
    courses: [],
    refreshCourses,
  }

  let tree = shallow(<Refreshed {...refreshProps} />)
  expect(tree).toMatchSnapshot()
  tree.instance().refresh()
  tree.setProps(refreshProps)
  expect(refreshCourses).toHaveBeenCalledTimes(2)
})

it('updates when courses prop changes', () => {
  const course = courseTemplate.course({ is_favorite: true })
  const props = {
    ...defaultProps,
    courses: [course],
  }

  const component = renderer.create(
    <FavoritesList {...props} />
  )

  expect(component.toJSON()).toMatchSnapshot()

  course.is_favorite = false
  setProps(component, { courses: [course] })
  expect(component.toJSON()).toMatchSnapshot()
})
