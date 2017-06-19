// @flow

import { Image, Linking } from 'react-native'
import React from 'react'
import renderer from 'react-test-renderer'
import URLSubmissionViewer from '../URLSubmissionViewer'
import setProps from '../../../../../test/helpers/setProps'
import explore from '../../../../../test/helpers/explore'

const t = {
  ...require('../../../../api/canvas-api/__templates__/submissions.js'),
  ...require('../../../../api/canvas-api/__templates__/attachment.js'),
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
    <URLSubmissionViewer submission={submission} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('on new url received, fetch image height if attachment', () => {
  const rendered = renderer.create(
    <URLSubmissionViewer submission={submission} />
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
    <URLSubmissionViewer submission={submission} />
  )

  rendered.getInstance().onScrollViewLayout(
    { nativeEvent: { layout: { width: 200, height: 200 } } }
  )

  expect(rendered.getInstance().state.size).toEqual({ width: 200, height: 200 })
})

test('loaded image sets aspect ration for rendered image view', () => {
  const rendered = renderer.create(
    <URLSubmissionViewer submission={submission} />
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
    <URLSubmissionViewer submission={submission} />
  )

  setProps(rendered, { submission: newSub })
  expect(Image.getSize).toHaveBeenCalledWith(url, rendered.getInstance().imageSizeLoaded)
})

test('tapping the url opens the link in Safari', () => {
  const tree = renderer.create(
    <URLSubmissionViewer submission={submission} />
  ).toJSON()

  const urlButton = explore(tree).selectByID('url-submission-viewer.url')
  urlButton && urlButton.props.onPress()

  expect(Linking.openURL).toHaveBeenCalledWith(submission.url)
})
