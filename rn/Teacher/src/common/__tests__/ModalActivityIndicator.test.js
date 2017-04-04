/**
 * @flow
 */

import 'react-native'
import React from 'react'
import ModalActivityIndicator from '../components/ModalActivityIndicator'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

const props = {
  title: 'hello world',
}

test('renders modal activity indicator', () => {
  let tree = renderer.create(
    <ModalActivityIndicator {...props} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
