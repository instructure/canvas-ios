// @flow

import 'react-native'
import React from 'react'
import * as courseTemplate from '../../../../api/canvas-api/__templates__/course'
import * as navigationTemplate from '../../../../__templates__/helm'
import { FavoritesList } from '../EditFavorites'
import setProps from '../../../../../test/helpers/setProps'

import renderer from 'react-test-renderer'

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

test('calls dismiss when back button is selected', () => {
  let navigator = navigationTemplate.navigator({
    dismiss: jest.fn(),
  })

  let tree = renderer.create(
    <FavoritesList {...defaultProps} navigator={navigator} />
  )
  tree.getInstance().dismiss()
  expect(navigator.dismiss).toHaveBeenCalledWith()
})
