//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
  beforeEach(() => jest.clearAllMocks())

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
