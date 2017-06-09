// @flow

import 'react-native'
import React from 'react'
import PDFView from '../PDFView'
import renderer from 'react-test-renderer'

test('PDFView renders', () => {
  let tree = renderer.create(
    <PDFView
      config={{ documentURL: '' }}
    />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
