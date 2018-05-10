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

import { shallow } from 'enzyme'
import React from 'react'
import { EditReply, mapStateToProps } from '../EditReply'
import explore from '../../../../../test/helpers/explore'
import setProps from '../../../../../test/helpers/setProps'
import { Alert } from 'react-native'
import renderer from 'react-test-renderer'
import app from '../../../app'
import * as template from '../../../../__templates__'

jest
  .mock('Alert', () => ({
    alert: jest.fn(),
  }))
  .mock('../../../../routing')
  .mock('../../../../routing/Screen')
  .mock('../../../../common/components/rich-text-editor/RichTextEditor', () => 'RichTextEditor')
  .mock('LayoutAnimation', () => ({
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
    jest.resetAllMocks()
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

  it('renders', () => {
    let tree = renderer.create(
      <EditReply {...defaultProps} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders title correctly when editing', () => {
    defaultProps.isEdit = true
    let tree = renderer.create(
      <EditReply {...defaultProps} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('presents error alert', () => {
    jest.useFakeTimers()
    let component = renderer.create(
      <EditReply {...defaultProps} />
    )

    let errorMessage = 'error'

    setProps(component, { error: errorMessage })
    jest.runAllTimers()

    expect(Alert.alert).toHaveBeenCalled()
  })

  it('deletes pending replies on unmount', () => {
    let component = renderer.create(
      <EditReply {...defaultProps} />
    )
    component.getInstance().componentWillUnmount()
    expect(defaultProps.deletePendingReplies).toHaveBeenCalledWith(defaultProps.discussionID)
  })

  it('dismisses modal activity upon save error', () => {
    let component = renderer.create(
      <EditReply {...defaultProps} />
    )
    let postReply = jest.fn(() => {
      setProps(component, { pending: 0, error: 'error' })
    })
    component.update(<EditReply {...defaultProps} createEntry={postReply} />)
    const doneButton: any = explore(component.toJSON()).selectRightBarButton('edit-discussion-reply.done-btn')
    doneButton.action()
    expect(component.toJSON()).toMatchSnapshot()
  })

  it('dismisses modal after reply updates', () => {
    let component = renderer.create(
      <EditReply {...defaultProps} />
    )
    let postReply = jest.fn(() => {
      setProps(component, { pending: 0 })
    })
    let refresh = jest.fn()
    component.update(<EditReply {...defaultProps} createEntry={postReply} refreshDiscussionEntries={refresh} />)
    const doneButton: any = explore(component.toJSON()).selectRightBarButton('edit-discussion-reply.done-btn')
    doneButton.action()
    expect(defaultProps.navigator.dismissAllModals).toHaveBeenCalled()
  })

  it('sets message placeholder', () => {
    let component = renderer.create(
      <EditReply {...defaultProps} />
    )
    let textEditor = explore(component.toJSON()).query(({ type }) => type === 'RichTextEditor')[0]

    expect(textEditor.props.placeholder).toEqual('Message')
  })

  it('enters text and posts reply', async () => {
    let component = shallow(<EditReply {...defaultProps} refreshDiscussionEntries={jest.fn()} />)
    let postReply = jest.fn(() => {
      component.setProps({ pending: 0 })
    })
    component.setProps({ createEntry: postReply })
    let textEditor = component.find('RichTextEditor')
    let message = 'not empty'
    textEditor.getElement().ref({ getHTML: jest.fn(() => Promise.resolve(message)) })
    const doneButton = component.prop('rightBarButtons')[0]
    await doneButton.action()
    expect(postReply).toBeCalledWith(defaultProps.context, defaultProps.contextID, defaultProps.discussionID, defaultProps.entryID, { attachment: null, message }, [], defaultProps.lastReplyAt)
    expect(defaultProps.navigator.dismissAllModals).toHaveBeenCalled()
  })

  it('edits an existing reply', async () => {
    let editProps = {
      ...defaultProps,
      message: 'default message',
      isEdit: true,
      refreshDiscussionEntries: jest.fn(),
    }
    let component = shallow(<EditReply {...editProps} />)
    let editEntry = jest.fn(() => {
      component.setProps({ pending: 0 })
    })
    component.setProps({ editEntry })
    let textEditor = component.find('RichTextEditor')
    let message = 'edited message'
    textEditor.getElement().ref({ getHTML: jest.fn(() => Promise.resolve(message)) })
    const doneButton = component.prop('rightBarButtons')[0]
    await doneButton.action()
    expect(editEntry).toBeCalledWith(defaultProps.context, defaultProps.contextID, editProps.discussionID, editProps.entryID, { attachment: null, message }, [])
    expect(defaultProps.navigator.dismissAllModals).toHaveBeenCalled()
  })

  it('cannot add an attachment if it does not have permission', () => {
    defaultProps.permissions.attach = false
    const tree = shallow(<EditReply {...defaultProps} />)
    const attach = tree.find('Screen').prop('rightBarButtons')
      .find(({ testID }) => testID === 'edit-discussion-reply.attachment-btn')
    expect(attach).toBeUndefined()
  })

  it('can add an attachment if it has permission', () => {
    defaultProps.navigator = template.navigator({ show: jest.fn() })
    defaultProps.permissions.attach = true
    const tree = shallow(<EditReply {...defaultProps} />)
    const attach = tree.find('Screen').prop('rightBarButtons')
      .find(({ testID }) => testID === 'edit-discussion-reply.attachment-btn')
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
