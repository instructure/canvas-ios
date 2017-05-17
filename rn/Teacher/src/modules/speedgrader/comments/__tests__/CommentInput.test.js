// @flow

import 'react-native'
import React from 'react'
import renderer from 'react-test-renderer'
import CommentInput from '../CommentInput'
import explore from '../../../../../test/helpers/explore'

jest.mock('react-native-button', () => 'Button')

test('CommentInput renders', () => {
  let tree = renderer.create(
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

test('Calls props.makeComment when the submit button is pressed', () => {
  let makeComment = jest.fn()
  let tree = renderer.create(
    <CommentInput makeComment={makeComment} />
  )

  tree.getInstance().setState({ textComment: 'text' })
  let button = explore(tree.toJSON()).selectByID('submit-comment') || {}
  button.props.onPress()

  expect(makeComment).toHaveBeenCalledWith({
    type: 'text',
    message: 'text',
  })
})
