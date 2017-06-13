// @flow

import 'react-native'
import React from 'react'
import renderer from 'react-test-renderer'
import CommentRow, { type CommentRowProps } from '../CommentRow'

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

test('my media comments render correclty', () => {
  const comment = {
    ...testComment,
    from: 'me',
    contents: { type: 'media_comment' },
  }
  let tree = renderer.create(
    <CommentRow {...comment} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
})

test('their media comments render correctly', () => {
  const comment = {
    ...testComment,
    contents: { type: 'media_comment' },
  }
  let tree = renderer.create(
    <CommentRow {...comment} />
  ).toJSON()
  expect(tree).toMatchSnapshot()
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
