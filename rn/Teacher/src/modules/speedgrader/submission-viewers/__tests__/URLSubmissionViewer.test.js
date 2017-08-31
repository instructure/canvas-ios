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
jest.mock('Linking', () => ({ openURL: mockOpenURL }))
jest.mock('TouchableOpacity', () => 'TouchableOpacity')

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
