// @flow

import 'react-native'
import React from 'react'
import CanvadocViewer from '../CanvadocViewer'
import renderer from 'react-test-renderer'

const templates = {
  ...require('../../../../__templates__/attachment'),
}

test('Canvadoc viewer renders', () => {
  let tree = renderer.create(
    <CanvadocViewer
      config={{ previewPath: templates.attachment().preview_url }}
    />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})
