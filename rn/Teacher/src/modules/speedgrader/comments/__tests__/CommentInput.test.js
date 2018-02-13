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

/* eslint-disable flowtype/require-valid-file-annotation */

import 'react-native'
import React from 'react'
import renderer from 'react-test-renderer'
import CommentInput from '../CommentInput'
import explore from '../../../../../test/helpers/explore'

jest.mock('TouchableOpacity', () => 'TouchableOpacity')

test('CommentInput renders', () => {
  const tree = renderer.create(
    <CommentInput makeComment={jest.fn()} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('Wont render the media buttons when allowMediaInputs is set to false', () => {
  let tree = renderer.create(
    <CommentInput allowMediaComments={false} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('makeComment sends the comment', () => {
  const makeComment = jest.fn()
  const component = renderer.create(
    <CommentInput makeComment={makeComment} />
  )
  const tree = component.toJSON()

  // mock _textInput stuff
  const blur = jest.fn()
  component.getInstance()._textInput.blur = blur

  const input = explore(tree)
    .selectByID('comment-input.comment') || {}
  input.props.onChangeText('Hello!')

  const noSend = explore(tree)
    .selectByID('comment-input.send')
  expect(noSend).toBeNull()

  const send = explore(component.toJSON())
    .selectByID('comment-input.send') || {}
  send.props.onPress()

  expect(makeComment).toHaveBeenCalledWith({ type: 'text', message: 'Hello!' })
  expect(blur).toHaveBeenCalled()
})

test('Allows for an initialValue', () => {
  let tree = renderer.create(
    <CommentInput initialValue='Comment' />
  )

  expect(tree.getInstance().state.textComment).toEqual('Comment')
})

test('disables the send button with a prop', () => {
  let tree = renderer.create(
    <CommentInput disabled={true} />
  ).toJSON()

  expect(tree).toMatchSnapshot()
})
