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
import renderer from 'react-test-renderer'
import CommentRow, { type CommentRowProps } from '../CommentRow'
import explore from '../../../../../test/helpers/explore'

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
  contents: { type: 'text', message: 'I just need more time!?' },
  pending: 0,
  localID: '1',
  deletePendingComment: jest.fn(),
  retryPendingComment: jest.fn(),
  switchFile: jest.fn(),
  onAvatarPress: jest.fn(),
  userID: '1',
}

test('Their message rows render correctly', () => {
  let tree = renderer.create(
    <CommentRow {...testComment} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('My message rows render correctly', () => {
  const comment = {
    ...testComment,
    from: 'me',
    contents: { type: 'text', message: `You're too late!` },
  }
  let tree = renderer.create(
    <CommentRow {...comment} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
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
  let view = renderer.create(
    <CommentRow {...comment} />
  )
  const videoComment: any = explore(view.toJSON()).selectByType('Video')
  expect(videoComment).not.toBeNull()
  expect(videoComment.props.source.uri).toEqual('file:///var/local/file.mov')
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
  let view = renderer.create(
    <CommentRow {...comment} />
  )
  expect(view.toJSON()).toMatchSnapshot()
})

test('their submissions render correctly', () => {
  const comment = {
    ...testComment,
    contents: { type: 'submission', items: [] },
  }
  let tree = renderer.create(
    <CommentRow {...comment} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('calls onAvatarPress when the avatar is pressed', () => {
  let view = renderer.create(
    <CommentRow {...testComment} />
  ).toJSON()
  let avatar = explore(view).selectByType('Avatar')
  avatar.props.onPress()
  expect(testComment.onAvatarPress).toHaveBeenCalledWith('1')
})
