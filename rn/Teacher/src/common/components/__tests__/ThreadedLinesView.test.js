// @flow

import 'react-native'
import React from 'react'
import ThreadedLinesView from '../ThreadedLinesView'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

let defaultProps = {
  depth: 0,
  avatarSize: 24,
  marginRight: 8,
}

it('renders correctly with empty depth', () => {
  let tree = renderer.create(<ThreadedLinesView {...defaultProps} />).toJSON()
  expect(tree).toMatchSnapshot()
})

it('renders correctly with depth 1', () => {
  let props = {
    ...defaultProps,
    depth: 1,
  }
  let tree = renderer.create(<ThreadedLinesView {...props} />).toJSON()
  expect(tree).toMatchSnapshot()
})

it('renders correctly with depth 2', () => {
  let props = {
    ...defaultProps,
    depth: 2,
  }
  let tree = renderer.create(<ThreadedLinesView {...props} />).toJSON()
  expect(tree).toMatchSnapshot()
})

it('renders correctly with depth 5', () => {
  let props = {
    ...defaultProps,
    depth: 5,
  }
  let tree = renderer.create(<ThreadedLinesView {...props} />).toJSON()
  expect(tree).toMatchSnapshot()
})
