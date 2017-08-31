//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

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
