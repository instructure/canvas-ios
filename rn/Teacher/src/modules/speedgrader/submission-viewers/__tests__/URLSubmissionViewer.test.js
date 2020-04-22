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

import { Image, Linking } from 'react-native'
import React from 'react'
import renderer from 'react-test-renderer'
import URLSubmissionViewer from '../URLSubmissionViewer'
import setProps from '../../../../../test/helpers/setProps'
import explore from '../../../../../test/helpers/explore'

const t = {
  ...require('../../../../__templates__/submissions.js'),
  ...require('../../../../__templates__/attachment.js'),
}

Image.getSize = jest.fn()
const mockOpenURL = jest.fn()
jest.mock('react-native/Libraries/Linking/Linking', () => ({ openURL: mockOpenURL }))
jest.mock('react-native/Libraries/Components/Touchable/TouchableOpacity', () => 'TouchableOpacity')

const submission = t.submission({
  attachment: t.attachment(),
  submission_type: 'online_url',
  url: 'https://my-blog-about-rockets.com/2017/6/1/rockets-are-splosive',
})

test('url submission renders correctly', () => {
  const tree = renderer.create(
    <URLSubmissionViewer submission={submission} drawerInset={0} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('on new url received, fetch image height if attachment', () => {
  const rendered = renderer.create(
    <URLSubmissionViewer submission={submission} drawerInset={0} />
  )
  const fetch = jest.fn()
  rendered.getInstance().fetchImageSize = fetch

  setProps(rendered, { submission: { ...submission, attachments: [] } })
  expect(fetch).not.toHaveBeenCalled()

  const newPost = 'https://my-blog-about-rockets.com/2017/6/2/liftoff'
  const oldAttachments = submission.attachments || []
  const updated = {
    ...submission,
    attachments: [{ ...oldAttachments[0], url: newPost }],
  }
  setProps(rendered, { submission: updated })
  expect(fetch).toHaveBeenCalledWith(newPost)
})

test('on scrollview layout, the state is updated', () => {
  const rendered = renderer.create(
    <URLSubmissionViewer submission={submission} drawerInset={0} />
  )

  rendered.getInstance().onScrollViewLayout(
    { nativeEvent: { layout: { width: 200, height: 200 } } }
  )

  expect(rendered.getInstance().state.size).toEqual({ width: 200, height: 200 })
})

test('loaded image sets aspect ration for rendered image view', () => {
  const rendered = renderer.create(
    <URLSubmissionViewer submission={submission} drawerInset={0} />
  )

  rendered.getInstance().imageSizeLoaded(800, 600)

  expect(rendered.getInstance().state.aspectRatio).toEqual(800 / 600)
})

test('changing the fetches the dimensions', () => {
  const url = 'https://my-blog-about-rockets.com/2017/6/2/propulsion_ftw'
  const attachments = submission.attachments || [t.attachment()]
  const newSub = {
    ...submission,
    attachments: [{ ...attachments[0], url }],
  }

  const rendered = renderer.create(
    <URLSubmissionViewer submission={submission} drawerInset={0} />
  )

  setProps(rendered, { submission: newSub })
  expect(Image.getSize).toHaveBeenCalledWith(url, rendered.getInstance().imageSizeLoaded)
})

test('tapping the url opens the link in Safari', () => {
  const tree = renderer.create(
    <URLSubmissionViewer submission={submission} drawerInset={0} />
  ).toJSON()

  const urlButton = explore(tree).selectByID('url-submission-viewer.url')
  urlButton && urlButton.props.onPress()

  expect(Linking.openURL).toHaveBeenCalledWith(submission.url)
})
