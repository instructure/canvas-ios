// @flow

import 'react-native'
import React from 'react'
import * as courseTemplate from '../../../api/canvas-api/__templates__/course'
import * as navigationTemplate from '../../../__templates__/react-native-navigation'
import { FavoritesList } from '../FavoritesList'

import renderer from 'react-test-renderer'

let courses = [
  courseTemplate.course({ is_favorite: false }),
  courseTemplate.course({ is_favorite: true }),
]

let defaultProps = {
  navigator: navigationTemplate.navigator(),
  courses: courses,
  toggleFavorite: () => Promise.resolve(),
}

test('renders correctly', () => {
  let tree = renderer.create(
    <FavoritesList {...defaultProps} />
  ).toJSON()

  expect(tree).toMatchSnapshot()
})

test('calls dismissModal when back button is selected', () => {
  let navigator = navigationTemplate.navigator({
    dismissModal: jest.fn(),
  })

  let tree = renderer.create(
    <FavoritesList {...defaultProps} navigator={navigator} />
  )

  tree._component._renderedComponent._instance.onNavigatorEvent({
    type: 'NavBarButtonPress',
    id: 'done',
  })

  expect(navigator.dismissModal).toHaveBeenCalledWith({
    animationType: 'slide-down',
  })
})
