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

/* eslint-disable flowtype/require-valid-file-annotation */

import 'react-native'
import React from 'react'
import { shallow } from 'enzyme'
import renderer from 'react-test-renderer'
import CommentRow, { type CommentRowProps } from '../CommentRow'
import explore from '../../../../../test/helpers/explore'
import * as template from '../../../../__templates__/'

jest
  .mock('../../../../common/components/Avatar', () => 'Avatar')
  .mock('../../../../common/components/Video', () => 'Video')
  .mock('../AudioComment', () => 'AudioComment')

const testComment: CommentRowProps = {
  key: 'comment-33',
  name: 'Higgs Boson',
  date: new Date('2017-03-17T19:15:25Z'),
  avatarURL: 'http://fillmurray.com/200/300',
  from: 'them',
  contents: {
    type: 'text',
    comment: template.submissionComment({ comment: 'I just need more time!?' }),
  },
  pending: 0,
  localID: '1',
  deletePendingComment: jest.fn(),
  retryPendingComment: jest.fn(),
  switchFile: jest.fn(),
  onAvatarPress: jest.fn(),
  userID: '1',
}

test('Their message rows render correctly', () => {
  testComment.from = 'them'
  testComment.contents.type = 'text'
  testComment.contents.comment.comment = 'Their message.'
  let tree = shallow(
    <CommentRow {...testComment} />
  )
  let bubble = tree.find('ChatBubble')
  expect(bubble.prop('from')).toEqual('them')
  expect(bubble.prop('message')).toEqual('Their message.')
})

test('My message rows render correctly', () => {
  testComment.from = 'me'
  testComment.contents.type = 'text'
  testComment.contents.comment.comment = 'My message.'
  let tree = shallow(
    <CommentRow {...testComment} />
  )
  let bubble = tree.find('ChatBubble')
  expect(bubble.prop('from')).toEqual('me')
  expect(bubble.prop('message')).toEqual('My message.')
})

test('their comment attachments', () => {
  let attachment = template.attachment()
  testComment.contents.comment.attachments = [attachment]
  testComment.from = 'them'
  let tree = shallow(
    <CommentRow {...testComment} />
  )
  let view = tree.find('CommentAttachment')
  expect(view.prop('attachment')).toEqual(attachment)
  expect(view.prop('from')).toEqual('them')
})

test('my comment attachments', () => {
  let attachment = template.attachment()
  testComment.contents.comment.attachments = [attachment]
  testComment.from = 'me'
  let tree = shallow(
    <CommentRow {...testComment} />
  )
  let view = tree.find('CommentAttachment')
  expect(view.prop('attachment')).toEqual(attachment)
  expect(view.prop('from')).toEqual('me')
})

test('multiple comment attachments', () => {
  testComment.contents.comment.attachments = [
    template.attachment({ id: '1' }),
    template.attachment({ id: '2' }),
  ]
  let tree = shallow(
    <CommentRow {...testComment} />
  )
  expect(tree.find('CommentAttachment')).toHaveLength(2)
})

test('audio comments render correctly', () => {
  const comment = {
    ...testComment,
    from: 'me',
    contents: {
      type: 'media',
      mediaType: 'audio',
      url: 'https://notorious.com/audio',
    },
  }
  let view = renderer.create(
    <CommentRow {...comment} />
  )
  const audioComment: any = explore(view.toJSON()).selectByType('AudioComment')
  expect(audioComment).not.toBeNull()
  expect(audioComment.props.url).toEqual('https://notorious.com/audio')
  expect(audioComment.props.from).toEqual('me')
})

test('video comments render correctly', () => {
  const comment = {
    ...testComment,
    contents: {
      type: 'media',
      mediaType: 'video',
      url: 'https://notorious.com/video',
    },
  }
  let view = renderer.create(
    <CommentRow {...comment} />
  )
  const videoComment: any = explore(view.toJSON()).selectByType('Video')
  expect(videoComment).not.toBeNull()
  expect(videoComment.props.source.uri).toEqual('https://notorious.com/video')
})

test('local video comments render correctly', () => {
  const comment = {
    ...testComment,
    contents: {
      type: 'media',
      mediaType: 'video',
      url: '/var/local/file.mov',
    },
  }
  let view = shallow(
    <CommentRow {...comment} />
  )
  const videoComment = view.find('Video')
  expect(videoComment).not.toBeNull()
  expect(videoComment.prop('source').uri).toEqual('file:///var/local/file.mov')
})

test('video comments without url render correctly', () => {
  const comment = {
    ...testComment,
    contents: {
      type: 'media',
      mediaType: 'video',
      url: null,
    },
  }
  let view = shallow(
    <CommentRow {...comment} />
  )
  expect(view.find('Video')).toHaveLength(0)
})

test('their submissions render correctly', () => {
  let submission = {
    contentID: 'text',
    title: 'Text Submission',
    subtitle: 'This is the body.',
  }
  testComment.contents.type = 'submission'
  testComment.contents.items = [submission]
  let tree = shallow(
    <CommentRow {...testComment} />
  )
  expect(tree.find('SubmittedContent').prop('contentID')).toEqual('text')
  expect(tree.find('SubmittedContent').prop('title')).toEqual('Text Submission')
})

test('calls onAvatarPress when the avatar is pressed', () => {
  let view = renderer.create(
    <CommentRow {...testComment} />
  ).toJSON()
  let avatar = explore(view).selectByType('Avatar')
  avatar.props.onPress()
  expect(testComment.onAvatarPress).toHaveBeenCalledWith('1')
})
