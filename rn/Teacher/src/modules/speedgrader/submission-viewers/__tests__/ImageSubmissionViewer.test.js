// @flow
import React from 'react'
import { Image } from 'react-native'
import ImageSubmissionViewer from '../ImageSubmissionViewer'
import renderer from 'react-test-renderer'

const template = {
  ...require('../../../../__templates__/attachment'),
}

Image.getSize = jest.fn()

let defaultProps = {
  attachment: template.attachment({
    mime_class: 'image',
    url: 'https://fillmurray/200/200',
  }),
  width: 300,
  height: 300,
}

describe('ImageSubmissionViewer', () => {
  beforeEach(() => jest.resetAllMocks())

  it('renders', () => {
    let tree = renderer.create(
      <ImageSubmissionViewer {...defaultProps} />
    ).toJSON()
    expect(tree).toMatchSnapshot()
  })

  it('gets the image size and sizes the image', () => {
    Image.getSize = jest.fn((uri, callback) => callback(500, 500))
    let component = renderer.create(
      <ImageSubmissionViewer {...defaultProps} />
    )
    let size = 300 - 32
    expect(component.getInstance().state).toEqual({ width: size, height: size })
  })
})
