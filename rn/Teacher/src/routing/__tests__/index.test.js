/* @flow */

import { View, Text } from 'react-native'
import React from 'react'
import { wrapScreenWithContext, wrapComponentInReduxProvider, route } from '../'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'

class TestScreen extends React.Component {
  render () {
    return (<View>
              <Text>Test Screen</Text>
            </View>)
  }
}

test('renders wrapped screen correctly', () => {
  const generator = () => TestScreen
  const wrappedGenerator = wrapScreenWithContext('TestScreen', generator)
  const Wrapped = wrappedGenerator()

  let tree = renderer.create(
    <Wrapped />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('renders wrapped screen with store correctly', () => {
  const generator = () => TestScreen
  const wrappedGenerator = wrapComponentInReduxProvider('TestScreen', generator, {})
  const Wrapped = wrappedGenerator()

  let tree = renderer.create(
    <Wrapped />
  )
  expect(tree.toJSON()).toMatchSnapshot()
})

test('route to something that does not exist', () => {
  try {
    route('garbage')
  } catch (error) {
    expect(error).toBeDefined()
  }
})
