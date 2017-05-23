// @flow

import 'react-native'
import React from 'react'
import renderer from 'react-test-renderer'
import CommentInput from '../CommentInput'
import explore from '../../../../../test/helpers/explore'

jest.mock('react-native-button', () => 'Button')

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

  const send = explore(tree)
    .selectByID('comment-input.send') || {}

  const input = explore(tree)
    .selectByID('comment-input.comment') || {}

  send.props.onPress()
  expect(blur).not.toHaveBeenCalled()

  input.props.onChangeText('Hello!')

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
