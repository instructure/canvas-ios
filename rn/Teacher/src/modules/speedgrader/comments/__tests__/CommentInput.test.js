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
import CommentInput from '../CommentInput'
import explore from '../../../../../test/helpers/explore'

jest.mock('react-native/Libraries/Components/Touchable/TouchableOpacity', () => 'TouchableOpacity')

describe('CommentInput', () => {
  beforeEach(() => {
    jest.clearAllMocks()
    CommentInput.persistentComment.text = ''
  })

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
      .selectByID('SubmissionComments.commentTextView') || {}
    input.props.onChangeText('Hello!')

    const noSend = explore(tree)
      .selectByID('SubmissionComments.addCommentButton')
    expect(noSend).toBeNull()

    const send = explore(component.toJSON())
      .selectByID('SubmissionComments.addCommentButton') || {}
    send.props.onPress()

    expect(makeComment).toHaveBeenCalledWith({ type: 'text', comment: 'Hello!' })
    expect(blur).toHaveBeenCalled()
  })

  test('Allows for an initialValue', () => {
    let tree = renderer.create(
      <CommentInput initialValue='Comment' />
    ); tree // need this to avoid unused var lint error

    expect(CommentInput.persistentComment.text).toEqual('Comment')
  })

  test('disables the send button with a prop', () => {
    let tree = renderer.create(
      <CommentInput disabled={true} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })
})
