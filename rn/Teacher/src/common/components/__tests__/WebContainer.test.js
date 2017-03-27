/**
 * @flow
 */

import 'react-native'
import React from 'react'
import WebContainer from '../WebContainer'
import renderer from 'react-test-renderer'

jest.unmock('ScrollView')

test('render', () => {
  let tree = renderer.create(
    <WebContainer />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('render html', () => {
  let html = '<div>hello world</div>'
  let tree = renderer.create(
    <WebContainer html={html} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

