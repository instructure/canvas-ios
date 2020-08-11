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
import { FavoritesList } from '../EditFavorites'
import setProps from '../../../../../test/helpers/setProps'
import App from '../../../app'
import renderer from 'react-test-renderer'
import { shallow } from 'enzyme'

import * as template from '../../../../__templates__'

let courses = [
  template.course(),
  template.course({ id: '2' }),
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
  getDashboardCards: () => {},
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

it('gets the dashboard cards again when a course is favorited or unfavorited', () => {
  defaultProps.getDashboardCards = jest.fn()
  defaultProps.pending = 1
  let tree = shallow(<FavoritesList {...defaultProps} />)
  tree.instance().UNSAFE_componentWillReceiveProps({ ...defaultProps, pending: 0 })
  expect(defaultProps.getDashboardCards).toHaveBeenCalled()
})
