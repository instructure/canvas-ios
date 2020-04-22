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

import { shallow } from 'enzyme'
import React from 'react'
import {
  Alert,
  NativeModules,
} from 'react-native'

import * as template from '../../../../__templates__'
import { DiscussionEdit, mapStateToProps, type Props } from '../DiscussionEdit'
import app from '../../../app'

jest.useFakeTimers()

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
  .mock('react-native/Libraries/Alert/Alert', () => ({
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
      getCourseSettings: jest.fn(),
      refreshGroup: jest.fn(),
      assignment: null,
      defaultDate: new Date(0),
      can_unpublish: true,
      attachment: null,
      allowAttachments: true,
    }
  })

  afterEach(() => {
    app.setCurrentApp('teacher')
  })

  it('renders', () => {
    let tree = shallow(<DiscussionEdit {...props} discussionID={null} />)
    expect(tree.find('Screen').prop('title')).toEqual('New Discussion')
    expect(tree.find('ModalOverlay').prop('text')).toEqual('Saving')
    expect(tree.find('UnmetRequirementBanner').prop('text')).toEqual('Invalid field')
    expect(tree.find('RichTextEditor').prop('placeholder')).toEqual('Add description')
    expect(props.getCourseSettings).toHaveBeenCalledWith(props.contextID)
  })

  it('refreshes groups when the context is a group', () => {
    shallow(<DiscussionEdit {...props} context='groups' />)
    expect(props.refreshGroup).toHaveBeenCalledWith(props.contextID)
  })

  it('renders edit form', () => {
    props.discussionID = '1'
    props.defaultDate = null
    const tree = shallow(<DiscussionEdit {...props} />)
    expect(tree.find('Screen').prop('title')).toBe('Edit Discussion')
  })

  it('shows modal when saving', async () => {
    const tree = shallow(<DiscussionEdit {...props} />)
    await tapDone(tree)
    expect(tree.find('ModalOverlay').prop('visible')).toBeTruthy()
  })

  it('focus unmetRequirementBanner after it shows', async () => {
    props.title = null
    const tree = shallow(<DiscussionEdit {...props} />)
    expect(tree.find('UnmetRequirementBanner').prop('visible')).toBeFalsy()
    await tapDone(tree)
    expect(tree.find('UnmetRequirementBanner').prop('visible')).toBeTruthy()
    jest.runAllTimers()
    expect(NativeModules.NativeAccessibility.focusElement)
      .toHaveBeenCalledWith('DiscussionEdit.invalidLabel')
  })

  it('alerts save errors', async () => {
    props.discussionID = null
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
    const dismiss = Promise.resolve()
    props.navigator.dismissAllModals = jest.fn(() => dismiss)
    let tree
    props.updateDiscussion = jest.fn(() => {
      tree.setProps({ pending: 0 })
    })
    tree = shallow(<DiscussionEdit {...props} />)
    await tapDone(tree)
    expect(props.navigator.dismissAllModals).toHaveBeenCalled()
    await dismiss
    expect(NativeModules.AppStoreReview.handleSuccessfulSubmit)
      .not.toHaveBeenCalled()
  })

  it('requests app store review on successful create', async () => {
    const dismiss = Promise.resolve()
    props.discussionID = null
    props.navigator.dismissAllModals = jest.fn(() => dismiss)
    let tree
    props.createDiscussion = jest.fn(() => {
      tree.setProps({ pending: 0 })
    })
    tree = shallow(<DiscussionEdit {...props} />)
    await tapDone(tree)
    expect(props.navigator.dismissAllModals).toHaveBeenCalled()
    await dismiss
    expect(NativeModules.AppStoreReview.handleSuccessfulSubmit)
      .toHaveBeenCalled()
  })

  it('updates with new props', async () => {
    const tree = shallow(<DiscussionEdit {...props} />)
    tree.setProps({ title: 'component will receive this title prop' })
    expect(tree.state('title')).toEqual('component will receive this title prop')
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

  it('calls updateDiscussion on done', async () => {
    props.updateDiscussion = jest.fn()
    props.contextID = '1'
    props.discussionID = '2'
    const tree = shallow(<DiscussionEdit {...props} />)
    tree.find('[identifier="DiscussionEdit.titleField"]')
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

  test('title', async () => {
    // default
    let tree = shallow(<DiscussionEdit {...props} title='The title' />)
    let title = tree.find('[identifier="DiscussionEdit.titleField"]')
    expect(title.prop('defaultValue')).toEqual('The title')

    // clear and submit
    title.simulate('changeText', '')
    await tapDone(tree)
    expect(tree.find('[testID="DiscussionEdit.invalidTitleLabel"]').prop('visible')).toEqual(true)

    // submit with value
    title.simulate('changeText', 'Do it!')
    await tapDone(tree)
    expect(props.updateDiscussion).toHaveBeenCalledWith(
      props.context,
      props.contextID,
      { ...formFields, id: '1', title: 'Do it!' }
    )
  })

  test('message', async () => {
    // default
    let tree = shallow(<DiscussionEdit {...props} message='The message' />)
    let messageEditor = tree.find('RichTextEditor')
    expect(messageEditor.prop('defaultValue')).toEqual('The message')

    // submit with value
    let message = 'A new message'
    await tapDone(tree, message)
    expect(props.updateDiscussion).toHaveBeenCalledWith(
      props.context,
      props.contextID,
      { ...formFields, id: '1', message }
    )
  })

  describe('publish', () => {
    it('doesnt show without permission and in the teacher app', () => {
      app.setCurrentApp('student')
      let tree = shallow(<DiscussionEdit {...props} can_unpublish={false} />)
      expect(tree.find('[testID="DiscussionEdit.publishSwitch"]').exists()).toEqual(false)

      tree.setProps({
        ...props,
        can_unpublish: true,
      })
      expect(tree.find('[testID="DiscussionEdit.publishSwitch"]').exists()).toEqual(false)

      app.setCurrentApp('teacher')
      tree.instance().forceUpdate()
      expect(tree.find('[testID="DiscussionEdit.publishSwitch"]').exists()).toEqual(true)

      tree.setProps({
        ...props,
        can_unpublish: null,
      })
      expect(tree.find('[testID="DiscussionEdit.publishSwitch"]').exists()).toEqual(true)
    })

    it('submits', async () => {
      // default
      let tree = shallow(<DiscussionEdit {...props} can_unpublish published={false} />)
      let publishSwitch = tree.find('[testID="DiscussionEdit.publishSwitch"]')
      expect(publishSwitch.prop('value')).toEqual(false)

      publishSwitch.simulate('valueChange', true)
      await tapDone(tree)
      expect(props.updateDiscussion).toHaveBeenCalledWith(
        props.context,
        props.contextID,
        { ...formFields, id: '1', published: true }
      )
    })
  })

  test('threaded switch', async () => {
    let tree = shallow(<DiscussionEdit {...props} discussion_type='side_comment' />)
    let threadSwitch = tree.find('[testID="DiscussionEdit.threadSwitch"]')
    expect(threadSwitch.prop('value')).toEqual(false)

    threadSwitch.simulate('valueChange', true)
    await tapDone(tree)
    expect(props.updateDiscussion).toHaveBeenCalledWith(props.context, props.contextID, {
      ...formFields,
      id: '1',
      discussion_type: 'threaded',
    })

    threadSwitch.simulate('valueChange', false)
    expect(tree.state('discussion_type')).toEqual('side_comment')
  })

  describe('subscribe toggle', () => {
    it('doesnt show with no discussionID', () => {
      let tree = shallow(<DiscussionEdit {...props} discussionID={null} />)
      expect(tree.find('[testID="DiscussionEdit.subscribeSwitch"]').exists()).toEqual(false)
    })

    it('subscribes when subscribe switch toggled on', () => {
      props.contextID = '1'
      props.discussionID = '2'
      props.subscribeDiscussion = jest.fn()
      props.subscribed = false
      const tree = shallow(<DiscussionEdit {...props} />)
      tree.find('[testID="DiscussionEdit.subscribeSwitch"]')
        .simulate('ValueChange', true)
      expect(props.subscribeDiscussion).toHaveBeenCalledWith('courses', '1', '2', true)
    })

    it('unsubscribes when subscribe switch toggled off', () => {
      props.contextID = '1'
      props.discussionID = '2'
      props.subscribeDiscussion = jest.fn()
      props.subscribed = true
      const tree = shallow(<DiscussionEdit {...props} />)
      tree.find('[testID="DiscussionEdit.subscribeSwitch"]')
        .simulate('ValueChange', false)
      expect(props.subscribeDiscussion).toHaveBeenCalledWith('courses', '1', '2', false)
    })
  })

  describe('require_inital_post', () => {
    it('does not render when not a teacher', () => {
      app.setCurrentApp('student')
      let tree = shallow(<DiscussionEdit {...props} />)
      expect(tree.find('[testID="DiscussionEdit.requirePostSwitch"]').exists()).toEqual(false)
    })

    it('submits', async () => {
      // default
      let tree = shallow(<DiscussionEdit {...props} require_initial_post={false} />)
      let postSwitch = tree.find('[testID="DiscussionEdit.requirePostSwitch"]')
      expect(postSwitch.prop('value')).toEqual(false)

      postSwitch.simulate('valueChange', true)
      await tapDone(tree)
      expect(props.updateDiscussion).toHaveBeenCalledWith(
        props.context,
        props.contextID,
        { ...formFields, id: '1', require_initial_post: true }
      )
    })
  })

  describe('points_possible', () => {
    it('does not show when discussion is not an assignment', () => {
      let tree = shallow(<DiscussionEdit {...props} assignment={null} />)
      expect(tree.find('[testID="DiscussionEdit.pointsField"]').exists()).toEqual(false)
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
      expect(tree.find('[testID="DiscussionEdit.invalidPointsLabel"]').prop('visible')).toBeTruthy()

      tree.find('[testID="DiscussionEdit.pointsField"]')
        .simulate('ChangeText', 'D')
      await tapDone(tree)
      expect(tree.find('UnmetRequirementBanner').prop('visible')).toBeTruthy()
      expect(tree.find('[testID="DiscussionEdit.invalidPointsLabel"]').prop('visible')).toBeTruthy()

      tree.find('[testID="DiscussionEdit.pointsField"]')
        .simulate('ChangeText', '1')
      await tapDone(tree)
      expect(tree.find('UnmetRequirementBanner').prop('visible')).toBeFalsy()
      expect(tree.find('[testID="DiscussionEdit.invalidPointsLabel"]').prop('visible')).toBeFalsy()

      tree.find('[testID="DiscussionEdit.pointsField"]')
        .simulate('ChangeText', '-1')
      await tapDone(tree)
      expect(tree.find('UnmetRequirementBanner').prop('visible')).toBeTruthy()
      expect(tree.find('[testID="DiscussionEdit.invalidPointsLabel"]').prop('visible')).toBeTruthy()

      tree.find('[testID="DiscussionEdit.pointsField"]')
        .simulate('ChangeText', '')
      await tapDone(tree)
      expect(tree.find('UnmetRequirementBanner').prop('visible')).toBeTruthy()
      expect(tree.find('[testID="DiscussionEdit.invalidPointsLabel"]').prop('visible')).toBeTruthy()
    })

    it('submits', async () => {
      let assignment = template.assignment({
        points_possible: null,
      })
      let tree = shallow(
        <DiscussionEdit {...props} assignment={assignment} />
      )
      expect(tree.find('[testID="DiscussionEdit.pointsField"]').prop('defaultValue')).toEqual('0')

      let pointsField = tree.find('[testID="DiscussionEdit.pointsField"]')
      pointsField.simulate('changeText', '50')
      tree.find('AssignmentDatesEditor').getElement().ref({
        validate: () => true,
        updateAssignment: (assignment) => assignment,
      })
      await tapDone(tree)
      expect(props.updateAssignment).toHaveBeenCalledWith(
        props.contextID,
        { ...assignment, points_possible: '50' },
        assignment
      )
    })
  })

  describe('grading type', () => {
    it('does not show the toggle if the disucssion is not an assignment', () => {
      let tree = shallow(<DiscussionEdit {...props} assignment={null} />)
      expect(tree.find('[testID="DiscussionEdit.gradeAsButton"]').exists()).toEqual(false)
    })

    it('toggles grading type picker', () => {
      const tree = shallow(<DiscussionEdit {...props} assignment={template.assignment()} />)
      expect(tree.find('[testID="DiscussionEdit.gradeTypePicker"]').exists()).toBe(false)
      tree.find('[testID="DiscussionEdit.gradeAsButton"]').simulate('Press')
      expect(tree.find('[testID="DiscussionEdit.gradeTypePicker"]').exists()).toBe(true)
    })

    it('submits', async () => {
      let assignment = template.assignment()
      let tree = shallow(<DiscussionEdit {...props} assignment={assignment} />)
      expect(tree.find('[testID="DiscussionEdit.gradeAsButton"]').prop('detail')).toEqual('Points')

      let gradeAsButton = tree.find('[testID="DiscussionEdit.gradeAsButton"]')
      gradeAsButton.simulate('press')
      tree.find('[testID="DiscussionEdit.gradeTypePicker"]').simulate('valueChange', 'percent')

      tree.find('AssignmentDatesEditor').getElement().ref({
        validate: () => true,
        updateAssignment: (assignment) => assignment,
      })
      await tapDone(tree)
      expect(props.updateAssignment).toHaveBeenCalledWith(
        props.contextID,
        { ...assignment, grading_type: 'percent' },
        assignment
      )
    })
  })

  describe('assignment dates', () => {
    it('does not show the editor when not an assignment', () => {
      let tree = shallow(<DiscussionEdit {...props} assignment={null} />)
      expect(tree.find('AssignmentDatesEditor').exists()).toEqual(false)
    })

    it('submits', async () => {
      let assignment = template.assignment()
      let tree = shallow(<DiscussionEdit {...props} assignment={assignment} />)
      let datesEditor = tree.find('AssignmentDatesEditor')
      expect(datesEditor.prop('assignment')).toEqual(assignment)

      datesEditor.getElement()
        .ref({ validate: () => false })
      await tapDone(tree)
      expect(tree.find('UnmetRequirementBanner').prop('visible')).toEqual(true)

      datesEditor.getElement()
        .ref({
          validate: () => true,
          updateAssignment: (assignment) => {
            assignment.due_at = '2036-06-01T05:59:00Z'
            return assignment
          },
        })
      await tapDone(tree)
      expect(props.updateAssignment).toHaveBeenCalledWith(
        props.contextID,
        { ...assignment, due_at: '2036-06-01T05:59:00Z' },
        assignment
      )
    })
  })

  it('updates from props', () => {
    const tree = shallow(<DiscussionEdit {...props} discussion_type='threaded' />)
    tree.setProps({ discussion_type: null })
    expect(tree.state('discussion_type')).toEqual('side_comment')
  })

  it('does not update state from props while pending', async () => {
    const tree = shallow(<DiscussionEdit {...props} />)
    await new Promise(resolve => tree.setState({ pending: true }, resolve))
    const state = tree.state()
    tree.setProps({ title: 'new title', pending: true })
    expect(tree.state()).toEqual(state)
  })

  it('toggles available from date picker', () => {
    props.assignment = null
    const tree = shallow(<DiscussionEdit {...props} />)
    expect(tree.find('[testID="DiscussionEdit.delayPostAtPicker"]').exists()).toBe(false)
    tree.find('[testID="DiscussionEdit.delayPostAtButton"]').simulate('Press')
    expect(tree.find('[testID="DiscussionEdit.delayPostAtPicker"]').exists()).toBe(true)
  })

  it('toggles available until date picker', () => {
    props.assignment = null
    const tree = shallow(<DiscussionEdit {...props} />)
    expect(tree.find('[testID="DiscussionEdit.lockAtPicker"]').exists()).toBe(false)
    tree.find('[testID="DiscussionEdit.lockAtButton"]')
      .simulate('Press')
    expect(tree.find('[testID="DiscussionEdit.lockAtPicker"]').exists()).toBe(true)
  })

  it('should clear dates', () => {
    props.assignment = null
    const tree = shallow(<DiscussionEdit {...props} />)
    tree.find('[testID="DiscussionEdit.delayPostAtButton"]')
      .simulate('Press')
    tree.find('[testID="DiscussionEdit.delayPostAtPicker"]')
      .simulate('DateChange', new Date(1000))
    tree.find('[testID="DiscussionEdit.delayPostAtButton"]')
      .simulate('RemoveDatePress')
    expect(tree.find('[testID="DiscussionEdit.delayPostAtPicker"]').exists()).toBe(false)

    tree.find('[testID="DiscussionEdit.lockAtButton"]')
      .simulate('Press')
    tree.find('[testID="DiscussionEdit.lockAtPicker"]')
      .simulate('DateChange', new Date(1000))
    tree.find('[testID="DiscussionEdit.lockAtButton"]')
      .simulate('RemoveDatePress')
    expect(tree.find('[testID="DiscussionEdit.lockAtPicker"]').exists()).toBe(false)
  })

  it('shows attachments', () => {
    const spy = jest.fn()
    props.navigator.show = spy
    props.attachment = template.attachment()
    const tree = shallow(<DiscussionEdit {...props} />)
    tree.find('Screen').prop('rightBarButtons')
      .find(({ testID }) => testID === 'DiscussionEdit.attachmentButton')
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

  function tapDone (tree, html) {
    tree.find('RichTextEditor')
      .getElement()
      .ref({ getHTML: jest.fn(() => Promise.resolve(html ?? props.message)) })

    tree.find('Screen').prop('rightBarButtons')
      .find(({ testID }) => testID === 'DiscussionEdit.doneButton')
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

  it('maps true course attachment settings to allowAttachments', () => {
    const discussion = template.discussion({ id: '45', title: 'IT WORKED' })
    const state: AppState = template.appState({
      entities: {
        ...template.appState().entities,
        courses: {
          '1': {
            pending: 0,
            error: null,
            settings: template.courseSettings({
              allow_student_forum_attachments: true,
            }),
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
    ).toMatchObject({ allowAttachments: true })
  })

  it('maps false course attachment settings to allowAttachments', () => {
    const discussion = template.discussion({ id: '45', title: 'IT WORKED' })
    const state: AppState = template.appState({
      entities: {
        ...template.appState().entities,
        courses: {
          '1': {
            pending: 0,
            error: null,
            settings: template.courseSettings({
              allow_student_forum_attachments: false,
            }),
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
    ).toMatchObject({ allowAttachments: false })
  })

  it('maps group attachment settings to allowAttachments', () => {
    const discussion = template.discussion({ id: '45', title: 'IT WORKED' })
    const state: AppState = template.appState({
      entities: {
        ...template.appState().entities,
        courses: {
          '1': {
            pending: 0,
            error: null,
            settings: template.courseSettings({
              allow_student_forum_attachments: true,
            }),
          },
        },
        groups: {
          '2': {
            group: template.group({
              course_id: '1',
            }),
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
      mapStateToProps(state, { context: 'groups', contextID: '2', discussionID: null })
    ).toMatchObject({ allowAttachments: true })
  })
})
