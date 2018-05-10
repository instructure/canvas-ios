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

/* @flow */

import { shallow, type ShallowWrapper } from 'enzyme'
import React from 'react'
import {
  Alert,
  NativeModules,
} from 'react-native'

import * as template from '../../../../__templates__'
import { DiscussionEdit, mapStateToProps, type Props } from '../DiscussionEdit'

jest.useFakeTimers()

jest
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
  .mock('Alert', () => ({
    alert: jest.fn(),
  }))

describe('DiscussionEdit', () => {
  let props: Props
  let formFields
  beforeEach(() => {
    jest.clearAllMocks()
    formFields = {
      title: 'Cursed Hollow',
      message: 'Gather tribute or face my curse.',
      published: false,
      discussion_type: 'side_comment',
      subscribed: false,
      require_initial_post: false,
      lock_at: null,
      delayed_post_at: null,
      attachment: null,
    }

    props = {
      ...formFields,
      discussionID: '1',
      context: 'courses',
      contextID: '1',
      pending: 0,
      error: null,
      navigator: template.navigator(),
      createDiscussion: jest.fn(),
      updateDiscussion: jest.fn(),
      deletePendingNewDiscussion: jest.fn(),
      subscribeDiscussion: jest.fn(),
      updateAssignment: jest.fn(),
      refreshDiscussionEntries: jest.fn(),
      assignment: null,
      defaultDate: new Date(0),
      can_unpublish: true,
      attachment: null,
    }
  })

  it('renders', () => {
    expect(shallow(<DiscussionEdit {...props} />)).toMatchSnapshot()
  })

  it('renders new form', () => {
    props.discussionID = null
    props.title = null
    props.message = null
    props.published = null
    props.discussion_type = null
    props.subscribed = null
    props.require_initial_post = null
    const tree = shallow(<DiscussionEdit {...props} />)
    expect(tree.find('Screen').prop('title')).toBe('New Discussion')
    expect(tree).toMatchSnapshot()
  })

  it('renders edit form', () => {
    props.discussionID = '1'
    props.defaultDate = null
    const tree = shallow(<DiscussionEdit {...props} />)
    expect(tree.find('Screen').prop('title')).toBe('Edit Discussion')
  })

  it('uses title from input', async () => {
    props.discussionID = null
    props.title = 'Hanamura'
    props.createDiscussion = jest.fn()
    const tree = shallow(<DiscussionEdit {...props} />)
    tree.find('[identifier="discussions.edit.titleInput"]')
      .simulate('ChangeText', 'Haunted Mines')
    tree.find('RichTextEditor')
      .getElement()
      .ref({ getHTML: jest.fn(() => Promise.resolve('Gather tribute or face my curse.')) })
    await tapDone(tree)
    expect(props.createDiscussion).toHaveBeenCalledWith(
      props.context,
      props.contextID,
      { ...formFields, title: 'Haunted Mines' },
    )
  })

  it('shows modal when saving', async () => {
    const tree = shallow(<DiscussionEdit {...props} />)
    await tapDone(tree)
    expect(tree.find('ModalOverlay').prop('visible')).toBeTruthy()
  })

  it('alerts save errors', async () => {
    props.discussionID = null
    // $FlowFixMe
    Alert.alert = jest.fn()
    let tree
    props.createDiscussion = jest.fn(() => {
      tree.setProps({ error: 'ERROR WAS ALERTED' })
    })
    tree = shallow(<DiscussionEdit {...props} />)
    await tapDone(tree)
    jest.runAllTimers()
    expect(Alert.alert).toHaveBeenCalled()
  })

  it('dismisses on successful save', async () => {
    props.discussionID = null
    props.navigator.dismissAllModals = jest.fn()
    let tree
    props.createDiscussion = jest.fn(() => {
      tree.setProps({ pending: 0 })
    })
    tree = shallow(<DiscussionEdit {...props} />)
    await tapDone(tree)
    expect(props.navigator.dismissAllModals).toHaveBeenCalled()
  })

  it('updates with new props', async () => {
    const tree = shallow(<DiscussionEdit {...props} />)
    const updateDiscussion = jest.fn(() => {
      tree.setProps({ title: 'component will receive this title prop' })
    })
    tree.setProps({ updateDiscussion })
    await tapDone(tree)
    expect(tree).toMatchSnapshot()
  })

  it('deletes pending new discussion on unmount', () => {
    props.deletePendingNewDiscussion = jest.fn()
    shallow(<DiscussionEdit {...props} />).unmount()
    expect(props.deletePendingNewDiscussion).toHaveBeenCalledWith(props.context, props.contextID)
  })

  it('refreshes discussion on unmount', () => {
    props.refreshDiscussionEntries = jest.fn()
    shallow(<DiscussionEdit {...props} />).unmount()
    expect(props.refreshDiscussionEntries).toHaveBeenCalled()
  })

  it('does not refresh discussion when creating new', () => {
    props.refreshDiscussionEntries = jest.fn()
    props.discussionID = null
    shallow(<DiscussionEdit {...props} />).unmount()
    expect(props.refreshDiscussionEntries).not.toHaveBeenCalled()
  })

  it('sets message placeholder', () => {
    const tree = shallow(<DiscussionEdit {...props} />)
    expect(tree.find('RichTextEditor').prop('placeholder'))
      .toBe('Add description')
  })

  it('focus unmetRequirementBanner after it shows', async () => {
    props.title = null
    const tree = shallow(<DiscussionEdit {...props} />)
    expect(tree.find('UnmetRequirementBanner').prop('visible')).toBeFalsy()
    await tapDone(tree)
    expect(tree.find('UnmetRequirementBanner').prop('visible')).toBeTruthy()
    jest.runAllTimers()
    expect(NativeModules.NativeAccessibility.focusElement)
      .toHaveBeenCalledWith('discussions.edit.unmet-requirement-banner')
  })

  it('calls updateDiscussion on done', async () => {
    props.updateDiscussion = jest.fn()
    props.contextID = '1'
    props.discussionID = '2'
    const tree = shallow(<DiscussionEdit {...props} />)
    tree.find('[identifier="discussions.edit.titleInput"]')
      .simulate('ChangeText', 'UPDATED TITLE')
    tree.find('RichTextEditor')
      .getElement()
      .ref({ getHTML: jest.fn(() => Promise.resolve('Gather tribute or face my curse.')) })
    await tapDone(tree)
    expect(props.updateDiscussion).toHaveBeenCalledWith(
      'courses',
      '1',
      { ...formFields, title: 'UPDATED TITLE', id: '2' },
    )
  })

  it('calls updateAssignment on done', async () => {
    const assignment = template.assignment()
    props.assignment = assignment
    props.contextID = '1'
    props.updateAssignment = jest.fn()
    const tree = shallow(<DiscussionEdit {...props} />)
    tree.instance().datesEditor = {
      validate: jest.fn(() => true),
      updateAssignment: jest.fn(a => a),
    }
    await tapDone(tree)
    expect(props.updateAssignment).toHaveBeenCalledWith('1', assignment, assignment)
  })

  it('transforms thread switch into threaded discussion type', async () => {
    props.discussionID = '1'
    props.discussion_type = 'side_comment'
    props.updateDiscussion = jest.fn()
    const tree = shallow(<DiscussionEdit {...props} />)
    tree.find('[identifier="discussions.edit.discussion_type.switch"]')
      .simulate('ValueChange', true)
    await tapDone(tree)
    expect(props.updateDiscussion).toHaveBeenCalledWith(props.context, props.contextID, {
      title: expect.anything(),
      message: expect.anything(),
      published: expect.anything(),
      discussion_type: 'threaded',
      subscribed: expect.anything(),
      require_initial_post: expect.anything(),
      lock_at: null,
      delayed_post_at: null,
      id: '1',
      attachment: null,
    })
  })

  it('transforms thread switch into side_comment discussion type', async () => {
    props.discussionID = '1'
    props.discussion_type = 'threaded'
    props.updateDiscussion = jest.fn()
    const tree = shallow(<DiscussionEdit {...props} />)
    tree.find('[identifier="discussions.edit.discussion_type.switch"]')
      .simulate('ValueChange', false)
    await tapDone(tree)
    expect(props.updateDiscussion).toHaveBeenCalledWith(props.context, props.contextID, {
      title: expect.anything(),
      message: expect.anything(),
      published: expect.anything(),
      discussion_type: 'side_comment',
      subscribed: expect.anything(),
      require_initial_post: expect.anything(),
      lock_at: null,
      delayed_post_at: null,
      id: '1',
      attachment: null,
    })
  })

  it('toggles grading type picker', () => {
    props.assignment = template.assignment()
    const tree = shallow(<DiscussionEdit {...props} />)
    expect(tree.find('[testID="discussions.edit.grading_type.picker"]').exists()).toBe(false)
    tree.find('[testID="discussions.edit.grading_type.row"]').simulate('Press')
    expect(tree.find('[testID="discussions.edit.grading_type.picker"]').exists()).toBe(true)
  })

  it('renders assignment dates editor', () => {
    props.assignment = template.assignment()
    const tree = shallow(<DiscussionEdit {...props} />)
    expect(tree.find('AssignmentDatesEditor').exists()).toBe(true)
  })

  it('shows unmet requirement banner if dates are invalid', async () => {
    const assignment = template.assignment()
    props.assignment = assignment
    const tree = shallow(<DiscussionEdit {...props} />)
    tree.instance().datesEditor = {
      validate: jest.fn(() => false),
      updateAssignment: jest.fn(a => a),
    }
    expect(tree.find('UnmetRequirementBanner').prop('visible')).toBeFalsy()
    await tapDone(tree)
    expect(tree.find('UnmetRequirementBanner').prop('visible')).toBeTruthy()
  })

  it('shows validation errors if title is blank', async () => {
    props.title = null
    const tree = shallow(<DiscussionEdit {...props} />)
    await tapDone(tree)
    expect(tree.find('UnmetRequirementBanner').prop('visible')).toBeTruthy()
    expect(tree.find('[testID="discussions.edit.title.validation-error"]').prop('visible')).toBeTruthy()
    tree.find('[identifier="discussions.edit.titleInput"]').simulate('ChangeText', 'not blank')
    await tapDone(tree)
    expect(tree.find('UnmetRequirementBanner').prop('visible')).toBeFalsy()
    expect(tree.find('[testID="discussions.edit.title.validation-error"]').prop('visible')).toBeFalsy()
    tree.find('[identifier="discussions.edit.titleInput"]').simulate('ChangeText', '')
    await tapDone(tree)
    expect(tree.find('UnmetRequirementBanner').prop('visible')).toBeTruthy()
    expect(tree.find('[testID="discussions.edit.title.validation-error"]').prop('visible')).toBeTruthy()
  })

  it('shows validation errors if points is invalid', async () => {
    props.assignment = template.assignment({ points_possible: null })
    const tree = shallow(<DiscussionEdit {...props} />)
    tree.instance().datesEditor = {
      validate: jest.fn(() => true),
      updateAssignment: jest.fn(a => a),
    }
    await tapDone(tree)
    expect(tree.find('UnmetRequirementBanner').prop('visible')).toBeTruthy()
    expect(tree.find('[testID="discussions.edit.points_possible.validation-error"]').prop('visible')).toBeTruthy()

    tree.find('[identifier="discussions.edit.points_possible.input"]')
      .simulate('ChangeText', 'D')
    await tapDone(tree)
    expect(tree.find('UnmetRequirementBanner').prop('visible')).toBeTruthy()
    expect(tree.find('[testID="discussions.edit.points_possible.validation-error"]').prop('visible')).toBeTruthy()

    tree.find('[identifier="discussions.edit.points_possible.input"]')
      .simulate('ChangeText', '1')
    await tapDone(tree)
    expect(tree.find('UnmetRequirementBanner').prop('visible')).toBeFalsy()
    expect(tree.find('[testID="discussions.edit.points_possible.validation-error"]').prop('visible')).toBeFalsy()

    tree.find('[identifier="discussions.edit.points_possible.input"]')
      .simulate('ChangeText', '-1')
    await tapDone(tree)
    expect(tree.find('UnmetRequirementBanner').prop('visible')).toBeTruthy()
    expect(tree.find('[testID="discussions.edit.points_possible.validation-error"]').prop('visible')).toBeTruthy()

    tree.find('[identifier="discussions.edit.points_possible.input"]')
      .simulate('ChangeText', '')
    await tapDone(tree)
    expect(tree.find('UnmetRequirementBanner').prop('visible')).toBeTruthy()
    expect(tree.find('[testID="discussions.edit.points_possible.validation-error"]').prop('visible')).toBeTruthy()
  })

  it('updates from props', () => {
    const tree = shallow(<DiscussionEdit {...props} />)
    tree.setProps({ discussion_type: null })
    expect(tree).toMatchSnapshot()
  })

  it('does not update state from props while pending', async () => {
    const tree = shallow(<DiscussionEdit {...props} />)
    await new Promise(resolve => tree.setState({ pending: true }, resolve))
    const state = tree.state()
    tree.setProps({ title: 'new title', pending: true })
    expect(tree.state()).toEqual(state)
  })

  it('subscribes when subscribe switch toggled on', () => {
    props.contextID = '1'
    props.discussionID = '2'
    props.subscribeDiscussion = jest.fn()
    props.subscribed = false
    const tree = shallow(<DiscussionEdit {...props} />)
    tree.find('[identifier="discussions.edit.subscribed.switch"]')
      .simulate('ValueChange', true)
    expect(props.subscribeDiscussion).toHaveBeenCalledWith('courses', '1', '2', true)
  })

  it('unsubscribes when subscribe switch toggled off', () => {
    props.contextID = '1'
    props.discussionID = '2'
    props.subscribeDiscussion = jest.fn()
    props.subscribed = true
    const tree = shallow(<DiscussionEdit {...props} />)
    tree.find('[identifier="discussions.edit.subscribed.switch"]')
      .simulate('ValueChange', false)
    expect(props.subscribeDiscussion).toHaveBeenCalledWith('courses', '1', '2', false)
  })

  it('toggles available from date picker', () => {
    props.assignment = null
    const tree = shallow(<DiscussionEdit {...props} />)
    expect(tree.find('[testID="discussions.edit.delayed_post_at.picker"]').exists()).toBe(false)
    tree.find('[testID="discussions.edit.delayed_post_at.row"]').simulate('Press')
    expect(tree.find('[testID="discussions.edit.delayed_post_at.picker"]').exists()).toBe(true)
  })

  it('toggles available until date picker', () => {
    props.assignment = null
    const tree = shallow(<DiscussionEdit {...props} />)
    expect(tree.find('[testID="discussions.edit.lock_at.picker"]').exists()).toBe(false)
    tree.find('[testID="discussions.edit.lock_at.row"]')
      .simulate('Press')
    expect(tree.find('[testID="discussions.edit.lock_at.picker"]').exists()).toBe(true)
  })

  it('should clear dates', () => {
    props.assignment = null
    const tree = shallow(<DiscussionEdit {...props} />)
    tree.find('[testID="discussions.edit.delayed_post_at.row"]')
      .simulate('Press')
    tree.find('[testID="discussions.edit.delayed_post_at.picker"]')
      .simulate('DateChange', new Date(1000))
    tree.find('[testID="discussions.edit.delayed_post_at.row"]')
      .simulate('RemoveDatePress')
    expect(tree.find('[testID="discussions.edit.delayed_post_at.picker"]').exists()).toBe(false)

    tree.find('[testID="discussions.edit.lock_at.row"]')
      .simulate('Press')
    tree.find('[testID="discussions.edit.lock_at.picker"]')
      .simulate('DateChange', new Date(1000))
    tree.find('[testID="discussions.edit.lock_at.row"]')
      .simulate('RemoveDatePress')
    expect(tree.find('[testID="discussions.edit.lock_at.picker"]').exists()).toBe(false)
  })

  it('hides publish switch if cant unpublish', () => {
    props.published = true
    props.can_unpublish = false
    const tree = shallow(<DiscussionEdit {...props} />)
    expect(tree.find('[testID="discussions.edit.published.switch"]').exists()).toBe(false)

    tree.setProps({ can_unpublish: true })
    expect(tree.find('[testID="discussions.edit.published.switch"]').exists()).toBe(true)
  })

  it('shows attachments', () => {
    const spy = jest.fn()
    props.navigator.show = spy
    props.attachment = template.attachment()
    const tree = shallow(<DiscussionEdit {...props} />)
    tree.find('Screen').prop('rightBarButtons')
      .find(({ testID }) => testID === 'discussions.edit.attachment-btn')
      .action()
    expect(spy).toHaveBeenCalledWith(
      '/attachments',
      { modal: true },
      {
        attachments: [props.attachment],
        maxAllowed: 1,
        storageOptions: {
          uploadPath: null,
        },
        onComplete: expect.any(Function),
      },
    )
  })

  it('scrolls view when RichTextEditor receives focus', () => {
    const spy = jest.fn()
    const tree = shallow(<DiscussionEdit {...props} />)
    tree.find('KeyboardAwareScrollView').getElement().ref({ scrollToFocusedInput: spy })
    tree.find('RichTextEditor').simulate('Focus')
    expect(spy).toHaveBeenCalled()
  })

  function tapDone (tree: ShallowWrapper) {
    tree.find('Screen').prop('rightBarButtons')
      .find(({ testID }) => testID === 'discussions.edit.doneButton')
      .action()
    return new Promise(resolve => tree.setState({}, resolve))
  }
})

describe('map state to props', () => {
  it('maps new error and pending states to props', () => {
    const state: AppState = template.appState({
      entities: {
        ...template.appState().entities,
        courses: {
          '1': {
            pending: 0,
            error: null,
            discussions: {
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
      mapStateToProps(state, { context: 'courses', contextID: '1', discussionID: null })
    ).toMatchObject({
      pending: 14,
      error: 'Map this error',
    })
  })

  it('maps discussion state to props using new id', () => {
    const discussion = template.discussion({ id: '45', title: 'IT WORKED' })
    const state: AppState = template.appState({
      entities: {
        ...template.appState().entities,
        courses: {
          '1': {
            pending: 0,
            error: null,
            discussions: {
              pending: 0,
              error: null,
              refs: [],
              new: {
                id: '45',
                pending: 14,
                error: 'Map this error',
              },
            },
          },
        },
        discussions: {
          '45': {
            pending: 0,
            error: null,
            data: discussion,
          },
        },
      },
    })
    expect(
      mapStateToProps(state, { context: 'courses', contextID: '1', discussionID: null })
    ).toMatchObject({ title: 'IT WORKED' })
  })

  it('maps discussion state to props', () => {
    const discussion = template.discussion({
      id: '1',
      title: 'Infernal Shrines',
      message: 'THE ENEMY IS ATTACKING YOUR CORE!',
      require_initial_post: true,
      can_unpublish: false,
    })
    const state: AppState = template.appState({
      entities: {
        ...template.appState().entities,
        discussions: {
          '1': {
            pending: 45,
            error: 'YOUR CORE IS UNDER ATTACK',
            data: discussion,
          },
        },
      },
    })
    expect(
      mapStateToProps(state, { context: 'courses', contextID: '10', discussionID: '1' })
    ).toMatchObject({
      title: 'Infernal Shrines',
      message: 'THE ENEMY IS ATTACKING YOUR CORE!',
      require_initial_post: true,
      can_unpublish: false,
      pending: 45,
      error: 'YOUR CORE IS UNDER ATTACK',
    })
  })

  it('maps assignment state to props', () => {
    const assignment = template.assignment({ id: '1' })
    const discussion = template.discussion({ id: '1', assignment_id: '1' })
    const state: AppState = template.appState({
      entities: {
        ...template.appState().entities,
        assignments: {
          '1': {
            pending: 1,
            error: null,
            data: assignment,
          },
        },
        discussions: {
          '1': {
            data: discussion,
            error: null,
            pending: 0,
          },
        },
      },
    })
    expect(
      mapStateToProps(state, { context: 'courses', contextID: '3', discussionID: '1' })
    ).toMatchObject({
      assignment,
      pending: 1,
      error: null,
    })
  })
})
