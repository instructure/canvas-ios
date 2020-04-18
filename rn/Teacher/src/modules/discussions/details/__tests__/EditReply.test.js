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

import { shallow } from 'enzyme'
import React from 'react'
import { EditReply, mapStateToProps } from '../EditReply'
import { NativeModules } from 'react-native'
import app from '../../../app'
import * as template from '../../../../__templates__'

jest
  .mock('react-native/Libraries/LayoutAnimation/LayoutAnimation', () => ({
    easeInEaseOut: jest.fn(),
    Types: {
      easeInEaseOut: jest.fn(),
      spring: jest.fn(),
    },
    Properties: {
      opacity: 1,
    },
  }))

describe('EditReply', () => {
  let defaultProps
  beforeEach(() => {
    jest.clearAllMocks()
    defaultProps = {
      discussion: template.discussion({ id: '1' }),
      navigator: template.navigator(),
      discussionID: '1',
      context: 'courses',
      contextID: '1',
      entryID: '1',
      course: template.course({ id: 1 }),
      indexPath: [],
      deletePendingReplies: jest.fn(),
      lastReplyAt: (new Date()).toISOString(),
      permissions: {
        attach: true,
        delete: true,
        reply: true,
        update: true,
      },
    }
    app.setCurrentApp('teacher')
  })

  it('renders title correctly', () => {
    let tree = shallow(<EditReply {...defaultProps} />)
    expect(tree.find('Screen').prop('title')).toEqual('Reply')

    tree = shallow(<EditReply {...defaultProps} isEdit />)
    expect(tree.find('Screen').prop('title')).toEqual('Edit')
  })

  it('deletes pending replies on unmount', () => {
    let tree = shallow(
      <EditReply {...defaultProps} />
    )
    tree.unmount()
    expect(defaultProps.deletePendingReplies).toHaveBeenCalledWith(defaultProps.discussionID)
  })

  it('dismisses modal activity upon save error', async () => {
    let promise = Promise.reject('error')
    let postReply = jest.fn(() => ({ payload: { promise } }))
    let tree = shallow(
      <EditReply
        {...defaultProps}
        createEntry={postReply}
      />
    )

    const doneButton = tree.find('Screen').prop('rightBarButtons')[0]
    doneButton.action()
    expect(tree.find('ActivityIndicator').exists()).toEqual(true)
    try { await promise } catch (_) {}
    expect(tree.find('ActivityIndicator').exists()).toEqual(false)
  })

  it('dismisses modal after reply updates', async () => {
    let postReply = jest.fn(() => ({ payload: { promise: Promise.resolve() } }))
    let refresh = jest.fn(() => ({ payload: { promise: Promise.resolve() } }))
    let tree = shallow(
      <EditReply
        {...defaultProps}
        createEntry={postReply}
        refreshDiscussionEntries={refresh}
      />
    )
    const doneButton = tree.find('Screen').prop('rightBarButtons')[0]
    await doneButton.action()
    expect(postReply).toHaveBeenCalled()
    expect(defaultProps.navigator.dismiss).toHaveBeenCalled()
    expect(NativeModules.AppStoreReview.handleSuccessfulSubmit).toHaveBeenCalled()
    expect(NativeModules.ModuleItemsProgress.contributedDiscussion).toHaveBeenCalledWith(defaultProps.contextID, defaultProps.discussionID)
  })

  it('sets message placeholder', () => {
    let tree = shallow(<EditReply {...defaultProps} />)
    let textEditor = tree.find('RichTextEditor')
    expect(textEditor.prop('placeholder')).toEqual('Message')
  })

  it('enters text and posts reply', async () => {
    let refresh = jest.fn(() => ({ payload: { promise: Promise.resolve() } }))
    let component = shallow(<EditReply {...defaultProps} refreshDiscussionEntries={refresh} />)
    let postReply = jest.fn(() => ({ payload: { promise: Promise.resolve() } }))
    component.setProps({ createEntry: postReply })
    let textEditor = component.find('RichTextEditor')
    let message = 'not empty'
    textEditor.getElement().ref({ getHTML: jest.fn(() => Promise.resolve(message)) })
    const doneButton = component.prop('rightBarButtons')[0]
    await doneButton.action()
    expect(postReply).toBeCalledWith(defaultProps.context, defaultProps.contextID, defaultProps.discussionID, defaultProps.entryID, { attachment: null, message }, [], defaultProps.lastReplyAt)
    expect(defaultProps.navigator.dismiss).toHaveBeenCalled()
  })

  it('edits an existing reply', async () => {
    let editProps = {
      ...defaultProps,
      message: 'default message',
      isEdit: true,
      refreshDiscussionEntries: jest.fn(() => ({ payload: { promise: Promise.resolve() } })),
    }
    let component = shallow(<EditReply {...editProps} />)
    let editEntry = jest.fn(() => ({ payload: { promise: Promise.resolve() } }))
    component.setProps({ editEntry })
    let textEditor = component.find('RichTextEditor')
    let message = 'edited message'
    textEditor.getElement().ref({ getHTML: jest.fn(() => Promise.resolve(message)) })
    const doneButton = component.prop('rightBarButtons')[0]
    await doneButton.action()
    expect(editEntry).toBeCalledWith(defaultProps.context, defaultProps.contextID, editProps.discussionID, editProps.entryID, { attachment: null, message }, [])
    expect(defaultProps.navigator.dismiss).toHaveBeenCalled()
    expect(NativeModules.AppStoreReview.handleSuccessfulSubmit).not.toHaveBeenCalled()
    expect(NativeModules.ModuleItemsProgress.contributedDiscussion).not.toHaveBeenCalled()
  })

  it('cannot add an attachment if it does not have permission', () => {
    defaultProps.permissions.attach = false
    const tree = shallow(<EditReply {...defaultProps} />)
    const attach = tree.find('Screen').prop('rightBarButtons')
      .find(({ testID }) => testID === 'DiscussionEditReply.attachmentButton')
    expect(attach).toBeUndefined()
  })

  it('can add an attachment if it has permission', () => {
    defaultProps.navigator = template.navigator({ show: jest.fn() })
    defaultProps.permissions.attach = true
    const tree = shallow(<EditReply {...defaultProps} />)
    const attach = tree.find('Screen').prop('rightBarButtons')
      .find(({ testID }) => testID === 'DiscussionEditReply.attachmentButton')
    expect(attach).toBeDefined()
    attach.action()
    expect(defaultProps.navigator.show).toHaveBeenCalledWith(
      '/attachments',
      { modal: true },
      {
        attachments: [],
        maxAllowed: 1,
        storageOptions: {
          uploadPath: null,
        },
        onComplete: expect.any(Function),
      }
    )
    const attachment = template.attachment()
    defaultProps.navigator.show.mock.calls[0][2].onComplete([ attachment ])
    expect(tree.state('attachment')).toBe(attachment)
  })

  it('uses course files for rce media embeds in teacher', () => {
    app.setCurrentApp('teacher')
    defaultProps.context = 'courses'
    defaultProps.contextID = '1'
    const screen = shallow(<EditReply {...defaultProps} />)
    expect(screen.find('RichTextEditor').prop('attachmentUploadPath')).toEqual('/courses/1/files')
  })

  it('uses user files for rce media embeds in student', () => {
    app.setCurrentApp('student')
    const screen = shallow(<EditReply {...defaultProps} />)
    expect(screen.find('RichTextEditor').prop('attachmentUploadPath')).toEqual('/users/self/files')
  })
})

describe('MapStateToProps', () => {
  let lastReplyAt = (new Date(0)).toISOString()
  test('maps default data for new reply', () => {
    const state: AppState = template.appState({
      entities: {
        discussions: {

        },
      },
    })
    expect(
      mapStateToProps(state, { courseID: '1', discussionID: '1', indexPath: [], lastReplyAt })
    ).toMatchObject({
      pending: 0,
      error: null,
    })
  })

  test('finds the correct data for new reply', () => {
    const state: AppState = template.appState({
      entities: {
        ...template.appState().entities,
        discussions: {
          '1': {
            pending: 0,
            error: null,
            replies: {
              pending: 0,
              error: null,
              refs: [],
              new: {
                pending: 14,
                error: 'Map this error',
              },
            },
          },
        },
      },
    })
    expect(
      mapStateToProps(state, { courseID: '1', discussionID: '1', lastReplyAt })
    ).toMatchObject({
      pending: 14,
      error: 'Map this error',
    })
  })

  test('finds the correct data for editing a reply', () => {
    const state: AppState = template.appState({
      entities: {
        ...template.appState().entities,
        discussions: {
          '1': {
            pending: 0,
            error: null,
            replies: {
              pending: 0,
              error: null,
              refs: [],
              edit: {
                pending: 14,
                error: 'Map this error',
              },
            },
          },
        },
      },
    })
    expect(
      mapStateToProps(state, { courseID: '1', discussionID: '1', lastReplyAt })
    ).toMatchObject({
      pending: 14,
      error: 'Map this error',
    })
  })
})
