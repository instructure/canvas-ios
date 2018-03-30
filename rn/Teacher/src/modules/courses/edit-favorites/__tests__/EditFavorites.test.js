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
import { Refreshed, FavoritesList } from '../EditFavorites'
import setProps from '../../../../../test/helpers/setProps'
import App from '../../../app'
import renderer from 'react-test-renderer'
import { shallow } from 'enzyme/build/index'

const template = {
  ...require('../../../../__templates__/group'),
  ...require('../../../../__templates__/course'),
  ...require('../../../../__templates__/helm'),
}
let courses = [
  template.course(),
  template.course(),
]

let groups = [
  template.group({ id: '1' }),
  template.group({ id: '2' }),
]

let defaultProps = {
  navigator: template.navigator(),
  courses,
  groups,
  groupFavorites: [groups[0].id, groups[1].id],
  courseFavorites: [courses[0].id, courses[1].id],
  toggleCourseFavorite: () => Promise.resolve(),
  updateGroupFavorites: () => Promise.resolve(),
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

test('renders correctly as student', () => {
  const currentApp = App.current()
  App.setCurrentApp('student')
  let tree = renderer.create(
    <FavoritesList {...defaultProps} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
  App.setCurrentApp(currentApp.appId)
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
    groups: [],
    refreshCourses,
  }

  let tree = shallow(<Refreshed {...refreshProps} />)
  expect(tree).toMatchSnapshot()
  tree.instance().refresh()
  tree.setProps(refreshProps)
  expect(refreshCourses).toHaveBeenCalledTimes(2)
})

it('updates when courses prop changes', () => {
  const course = template.course({ is_favorite: true })
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

it('un favorite group', () => {
  defaultProps.updateGroupFavorites = jest.fn()
  let tree = shallow(<FavoritesList {...defaultProps} />)
  tree.instance()._onToggleFavoriteGroup('1', true)
  expect(defaultProps.updateGroupFavorites).toHaveBeenCalledWith('self', ['2'])
})

it('favorite group', () => {
  defaultProps.updateGroupFavorites = jest.fn()
  defaultProps.groupFavorites = ['2']
  let tree = shallow(<FavoritesList {...defaultProps} />)
  tree.instance()._onToggleFavoriteGroup('1', true)
  expect(defaultProps.updateGroupFavorites).toHaveBeenCalledWith('self', ['2', '1'])
})
