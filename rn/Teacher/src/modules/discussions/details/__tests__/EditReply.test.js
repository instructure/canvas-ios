// @flow

import React from 'react'
import { EditReply, mapStateToProps } from '../EditReply'
import explore from '../../../../../test/helpers/explore'
import setProps from '../../../../../test/helpers/setProps'
import { Alert } from 'react-native'
import { ERROR_TITLE } from '../../../../redux/middleware/error-handler'
import renderer from 'react-test-renderer'

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

const template = {
  ...require('../../../../api/canvas-api/__templates__/discussion'),
  ...require('../../../../api/canvas-api/__templates__/course'),
  ...require('../../../../api/canvas-api/__templates__/users'),
  ...require('../../../../__templates__/helm'),
  ...require('../../../../redux/__templates__/app-state'),
}

describe('EditReply', () => {
  let defaultProps
  beforeEach(() => {
    jest.resetAllMocks()
    defaultProps = {
      discussion: template.discussion({ id: '1' }),
      navigator: template.navigator(),
      discussionID: '1',
      courseID: '1',
      entryID: '1',
      course: template.course({ id: 1 }),
      indexPath: [],
      deletePendingReplies: jest.fn(),
      lastReplyAt: (new Date()).toISOString(),
    }
  })

  it('renders', () => {
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

    expect(Alert.alert).toHaveBeenCalledWith(ERROR_TITLE, errorMessage)
  })

  it('calls dismiss on cancel', () => {
    let component = renderer.create(
      <EditReply {...defaultProps} />
    )
    let postReply = jest.fn(() => {
      setProps(component, { pending: 0, error: 'error' })
    })
    component.update(<EditReply {...defaultProps} updateCourse={postReply} />)
    const doneButton: any = explore(component.toJSON()).selectLeftBarButton('edit-discussion-reply.cancel-btn')
    doneButton.action()
    expect(component.toJSON()).toMatchSnapshot()
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

  it('enteres text and posts reply', () => {
    let component = renderer.create(
      <EditReply {...defaultProps} />
    )
    let postReply = jest.fn(() => {
      setProps(component, { pending: 0 })
    })
    let textEditor = explore(component.toJSON()).query(({ type }) => type === 'RichTextEditor')[0]
    let message = 'not empty'
    textEditor.props.onChangeValue(message)
    let refresh = jest.fn()
    component.update(<EditReply {...defaultProps} createEntry={postReply} refreshDiscussionEntries={refresh} />)
    const doneButton: any = explore(component.toJSON()).selectRightBarButton('edit-discussion-reply.done-btn')
    doneButton.action()
    expect(postReply).toBeCalledWith(defaultProps.courseID, defaultProps.discussionID, defaultProps.entryID, { message }, [], defaultProps.lastReplyAt)
    expect(defaultProps.navigator.dismissAllModals).toHaveBeenCalled()
  })

  it('edits an existing reply', () => {
    let editProps = {
      ...defaultProps,
      message: 'default message',
      isEdit: true,
    }
    let component = renderer.create(
      <EditReply {...editProps} />
    )
    let editReply = jest.fn(() => {
      setProps(component, { pending: 0 })
    })
    let textEditor = explore(component.toJSON()).query(({ type }) => type === 'RichTextEditor')[0]
    let message = 'edited message'
    textEditor.props.onChangeValue(message)
    let refresh = jest.fn()
    component.update(<EditReply {...editProps} editEntry={editReply} refreshDiscussionEntries={refresh} />)
    const doneButton: any = explore(component.toJSON()).selectRightBarButton('edit-discussion-reply.done-btn')
    doneButton.action()
    expect(editReply).toBeCalledWith(editProps.courseID, editProps.discussionID, editProps.entryID, { message }, [])
    expect(defaultProps.navigator.dismissAllModals).toHaveBeenCalled()
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
