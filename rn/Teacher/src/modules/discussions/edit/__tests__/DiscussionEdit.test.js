/* @flow */

import React from 'react'
import {
  Alert,
  ActionSheetIOS,
} from 'react-native'
import renderer from 'react-test-renderer'

import { DiscussionEdit, mapStateToProps, type Props } from '../DiscussionEdit'
import explore from '../../../../../test/helpers/explore'
import setProps from '../../../../../test/helpers/setProps'
import { ERROR_TITLE } from '../../../../redux/middleware/error-handler'

jest
  .mock('Button', () => 'Button')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('TouchableOpacity', () => 'TouchableOpacity')
  .mock('../../../../routing/Screen')
  .mock('DatePickerIOS', () => 'DatePickerIOS')
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
  .mock('../../../../common/components/rich-text-editor/RichTextEditor', () => 'RichTextEditor')
  .mock('Alert', () => ({
    alert: jest.fn(),
  }))
  .mock('../../../../common/components/UnmetRequirementBanner', () => 'UnmetRequirementBanner')
  .mock('../../../../common/components/RequiredFieldSubscript', () => 'RequiredFieldSubscript')
  .mock('Switch', () => 'Switch')
  .mock('../../../assignment-details/components/AssignmentDatesEditor', () => 'AssignmentDatesEditor')

const template = {
  ...require('../../../../api/canvas-api/__templates__/discussion'),
  ...require('../../../../api/canvas-api/__templates__/assignments'),
  ...require('../../../../api/canvas-api/__templates__/error'),
  ...require('../../../../__templates__/helm'),
  ...require('../../../../redux/__templates__/app-state'),
}

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
    }

    props = {
      ...formFields,
      discussionID: '1',
      courseID: '1',
      pending: 0,
      error: null,
      navigator: template.navigator(),
      createDiscussion: jest.fn(),
      updateDiscussion: jest.fn(),
      deleteDiscussion: jest.fn(),
      deletePendingNewDiscussion: jest.fn(),
      subscribeDiscussion: jest.fn(),
      updateAssignment: jest.fn(),
      assignment: null,
      defaultDate: new Date(0),
      can_unpublish: true,
    }
  })

  it('renders', () => {
    testRender(props)
  })

  it('renders new form', () => {
    props.discussionID = null
    props.title = null
    props.message = null
    props.published = null
    props.discussion_type = null
    props.subscribed = null
    props.require_initial_post = null
    const component = render(props)
    const title = getTitle(component)
    expect(title).toEqual('New Discussion')
    testRender(component)
  })

  it('renders edit form', () => {
    props.discussionID = '1'
    const title = getTitle(render(props))
    expect(title).toEqual('Edit Discussion')
  })

  it('uses title from input', () => {
    props.discussionID = null
    props.title = 'Hanamura'
    props.createDiscussion = jest.fn()
    const component = render(props)
    changeTitle(component, 'Haunted Mines')
    tapDone(component)
    expect(props.createDiscussion).toHaveBeenCalledWith(
      props.courseID,
      { ...formFields, title: 'Haunted Mines' },
    )
  })

  it('shows modal when saving', () => {
    const component = render(props)
    tapDone(component)
    const modal: any = explore(component.toJSON()).query(({ type }) => type === 'Modal')[0]
    expect(modal.props.visible).toBeTruthy()
  })

  it('alerts save errors', () => {
    props.discussionID = null
    jest.useFakeTimers()
    // $FlowFixMe
    Alert.alert = jest.fn()
    const component = render(props)
    const createDiscussion = jest.fn(() => {
      setProps(component, { error: 'ERROR WAS ALERTED' })
    })
    component.update(<DiscussionEdit {...props} createDiscussion={createDiscussion} />)
    tapDone(component)
    jest.runAllTimers()
    expect(Alert.alert).toHaveBeenCalledWith(ERROR_TITLE, 'ERROR WAS ALERTED')
  })

  it('dismisses on successful save', () => {
    props.discussionID = null
    props.navigator.dismissAllModals = jest.fn()
    const component = render(props)
    const createDiscussion = jest.fn(() => {
      setProps(component, { pending: 0 })
    })
    component.update(<DiscussionEdit {...props} createDiscussion={createDiscussion} />)
    tapDone(component)
    expect(props.navigator.dismissAllModals).toHaveBeenCalled()
  })

  it('updates with new props', () => {
    const component = render(props)
    const updateDiscussion = jest.fn(() => {
      setProps(component, { title: 'component will receive this title prop' })
    })
    component.update(<DiscussionEdit {...props} updateDiscussion={updateDiscussion} />)
    tapDone(component)
    expect(component.toJSON()).toMatchSnapshot()
  })

  it('deletes pending new discussion on unmount', () => {
    props.deletePendingNewDiscussion = jest.fn()
    render(props).getInstance().componentWillUnmount()
    expect(props.deletePendingNewDiscussion).toHaveBeenCalledWith(props.courseID)
  })

  it('calls dismiss on cancel', () => {
    props.navigator.dismiss = jest.fn()
    tapCancel(render(props))
    expect(props.navigator.dismiss).toHaveBeenCalled()
  })

  it('sets message placeholder', () => {
    expect(getMessageEditor(render(props)).props.placeholder).toEqual('Add description (required)')
  })

  it('disables done button if message is blank', () => {
    props.message = null
    const component = render(props)
    expect(getDoneButton(component).disabled).toBeTruthy()
    changeMessage(component, 'not empty')
    expect(getDoneButton(component).disabled).toBeFalsy()
    changeMessage(component, '')
    expect(getDoneButton(component).disabled).toBeTruthy()
  })

  it('calls updateDiscussion on done', () => {
    props.updateDiscussion = jest.fn()
    props.courseID = '1'
    props.discussionID = '2'
    const component = render(props)
    changeTitle(component, 'UPDATED TITLE')
    tapDone(component)
    expect(props.updateDiscussion).toHaveBeenCalledWith(
      '1',
      { ...formFields, title: 'UPDATED TITLE', id: '2' },
    )
  })

  it('calls updateAssignment on done', () => {
    const assignment = template.assignment()
    const createNodeMock = ({ type }) => {
      if (type === 'AssignmentDatesEditor') {
        return {
          validate: jest.fn(() => true),
          updateAssignment: jest.fn(a => a),
        }
      }
    }
    props.assignment = assignment
    props.courseID = '1'
    props.updateAssignment = jest.fn()
    tapDone(render(props, { createNodeMock }))
    expect(props.updateAssignment).toHaveBeenCalledWith('1', assignment, assignment)
  })

  it('does not render delete button if new', () => {
    props.discussionID = null
    expect(getDeleteButton(render(props))).toBeNull()
  })

  it('renders the delete button for edit', () => {
    props.discussionID = '1'
    expect(getDeleteButton(render(props))).not.toBeNull()
  })

  it('shows delete confirmation then deletes discussion', () => {
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, callback) => callback(0))
    props.deleteDiscussion = jest.fn()
    props.courseID = '1'
    props.discussionID = '2'
    tapDelete(render(props))
    expect(ActionSheetIOS.showActionSheetWithOptions).toHaveBeenCalled()
    expect(props.deleteDiscussion).toHaveBeenCalledWith('1', '2')
  })

  it('cancel delete confirmation does not delete discussion', () => {
    // $FlowFixMe
    ActionSheetIOS.showActionSheetWithOptions = jest.fn((options, callback) => callback(1))
    props.deleteDiscussion = jest.fn()
    tapDelete(render(props))
    expect(ActionSheetIOS.showActionSheetWithOptions).toHaveBeenCalled()
    expect(props.deleteDiscussion).not.toHaveBeenCalled()
  })

  it('transforms thread switch into threaded discussion type', () => {
    props.discussionID = '1'
    props.discussion_type = 'side_comment'
    props.updateDiscussion = jest.fn()
    const component = render(props)
    toggleThreadedReplies(component, true)
    tapDone(component)
    expect(props.updateDiscussion).toHaveBeenCalledWith(props.courseID, {
      title: expect.anything(),
      message: expect.anything(),
      published: expect.anything(),
      discussion_type: 'threaded',
      subscribed: expect.anything(),
      require_initial_post: expect.anything(),
      lock_at: null,
      delayed_post_at: null,
      id: '1',
    })
  })

  it('transforms thread switch into side_comment discussion type', () => {
    props.discussionID = '1'
    props.discussion_type = 'threaded'
    props.updateDiscussion = jest.fn()
    const component = render(props)
    toggleThreadedReplies(component, false)
    tapDone(component)
    expect(props.updateDiscussion).toHaveBeenCalledWith(props.courseID, {
      title: expect.anything(),
      message: expect.anything(),
      published: expect.anything(),
      discussion_type: 'side_comment',
      subscribed: expect.anything(),
      require_initial_post: expect.anything(),
      lock_at: null,
      delayed_post_at: null,
      id: '1',
    })
  })

  it('toggles grading type picker', () => {
    props.assignment = template.assignment()
    const component = render(props)
    expect(getGradingTypePicker(component)).toBeNull()
    tapGradingTypeRow(component)
    expect(getGradingTypePicker(component)).not.toBeNull()
  })

  it('renders assignment dates editor', () => {
    props.assignment = template.assignment()
    expect(getAssignmentDatesEditor(render(props))).toBeDefined()
  })

  it('shows unmet requirement banner if dates are invalid', () => {
    const assignment = template.assignment()
    const createNodeMock = ({ type }) => {
      if (type === 'AssignmentDatesEditor') {
        return {
          validate: jest.fn(() => false),
          updateAssignment: jest.fn(a => a),
        }
      }
    }
    props.assignment = assignment
    const component = render(props, { createNodeMock })
    expect(getUnmetRequirementBanner(component).props.visible).toBeFalsy()
    tapDone(component)
    expect(getUnmetRequirementBanner(component).props.visible).toBeTruthy()
  })

  it('shows validation errors if message is blank', () => {
    props.message = null
    const component = render(props)
    tapDone(component)
    expect(getUnmetRequirementBanner(component).props.visible).toBeTruthy()
    expect(getMessageRequiredFieldSubscript(component).props.visible).toBeTruthy()
    changeMessage(component, 'not blank')
    tapDone(component)
    expect(getUnmetRequirementBanner(component).props.visible).toBeFalsy()
    expect(getMessageRequiredFieldSubscript(component).props.visible).toBeFalsy()
    changeMessage(component, '')
    tapDone(component)
    expect(getUnmetRequirementBanner(component).props.visible).toBeTruthy()
    expect(getMessageRequiredFieldSubscript(component).props.visible).toBeTruthy()
  })

  it('shows validation errors if points is invalid', () => {
    const createNodeMock = ({ type }) => {
      if (type === 'AssignmentDatesEditor') {
        return {
          validate: jest.fn(() => true),
          updateAssignment: jest.fn(a => a),
        }
      }
    }
    props.assignment = template.assignment({ points_possible: null })
    const component = render(props, { createNodeMock })
    tapDone(component)
    expect(getUnmetRequirementBanner(component).props.visible).toBeFalsy()
    expect(getPointsPossibleRequiredFieldSubscript(component).props.visible).toBeFalsy()

    changePoints(component, 'D')
    tapDone(component)
    expect(getUnmetRequirementBanner(component).props.visible).toBeTruthy()
    expect(getPointsPossibleRequiredFieldSubscript(component).props.visible).toBeTruthy()

    changePoints(component, '1')
    tapDone(component)
    expect(getUnmetRequirementBanner(component).props.visible).toBeFalsy()
    expect(getPointsPossibleRequiredFieldSubscript(component).props.visible).toBeFalsy()

    changePoints(component, '-1')
    tapDone(component)
    expect(getUnmetRequirementBanner(component).props.visible).toBeTruthy()
    expect(getPointsPossibleRequiredFieldSubscript(component).props.visible).toBeTruthy()

    changePoints(component, '')
    tapDone(component)
    expect(getUnmetRequirementBanner(component).props.visible).toBeFalsy()
    expect(getPointsPossibleRequiredFieldSubscript(component).props.visible).toBeFalsy()
  })

  it('updates from props', () => {
    testRender(setProps(render(props), { discussion_type: null }))
  })

  it('subscribes when subscribe switch toggled on', () => {
    props.courseID = '1'
    props.discussionID = '2'
    props.subscribeDiscussion = jest.fn()
    props.subscribed = false
    toggleSubscribed(render(props), true)
    expect(props.subscribeDiscussion).toHaveBeenCalledWith('1', '2', true)
  })

  it('unsubscribes when subscribe switch toggled off', () => {
    props.courseID = '1'
    props.discussionID = '2'
    props.subscribeDiscussion = jest.fn()
    props.subscribed = true
    toggleSubscribed(render(props), false)
    expect(props.subscribeDiscussion).toHaveBeenCalledWith('1', '2', false)
  })

  it('toggles available from date picker', () => {
    props.assignment = null
    const component = render(props)
    expect(getAvailableFromDatePicker(component)).toBeNull()
    tapAvailableFrom(component)
    expect(getAvailableFromDatePicker(component)).not.toBeNull()
  })

  it('toggles available until date picker', () => {
    props.assignment = null
    const component = render(props)
    expect(getAvailableUntilDatePicker(component)).toBeNull()
    tapAvailableUntil(component)
    expect(getAvailableUntilDatePicker(component)).not.toBeNull()
  })

  it('should clear dates', () => {
    props.assignment = null
    const component = render(props)
    tapAvailableFrom(component)
    let datePicker = getAvailableFromDatePicker(component)
    datePicker.props.onDateChange(new Date(1000))
    const delayedBtn: any = explore(component.toJSON()).selectByID('discussions.edit.clear-delayed-post-at.button')
    delayedBtn.props.onPress()
    expect(getAvailableFromDatePicker(component)).toBeNull()

    tapAvailableUntil(component)
    datePicker = getAvailableUntilDatePicker(component)
    datePicker.props.onDateChange(new Date(1000))
    const lockBtn: any = explore(component.toJSON()).selectByID('discussions.edit.clear-lock-at.button')
    lockBtn.props.onPress()
    expect(getAvailableUntilDatePicker(component)).toBeNull()
  })

  it('hides publish switch if cant unpublish', () => {
    props.published = true
    props.can_unpublish = false
    expect(getPublishToggle(render(props))).toBeNull()

    props.can_unpublish = true
    expect(getPublishToggle(render(props))).not.toBeNull()
  })

  function testRender (props: Props, options: Object = {}) {
    expect(render(props, options)).toMatchSnapshot()
  }

  function render (props: Props, options: Object = {}) {
    return renderer.create(<DiscussionEdit {...props} />, options)
  }

  function tapDone (component: any): any {
    getDoneButton(component).action()
    return component
  }

  function tapDelete (component: any): any {
    getDeleteButton(component).props.onPress()
    return component
  }

  function tapCancel (component: any) {
    const done: any = explore(component.toJSON()).selectLeftBarButton('discussions.edit.cancelButton')
    done.action()
  }

  function changeTitle (component: any, value: string) {
    const input: any = explore(component.toJSON()).selectByID('discussions.edit.titleInput')
    input.props.onChangeText(value)
  }

  function changeMessage (component: any, value: string) {
    getMessageEditor(component).props.onChangeValue(value)
  }

  function changePoints (component: any, value: string) {
    getPointsInput(component).props.onChangeText(value)
  }

  function getTitle (component: any): string {
    return explore(component.toJSON()).query(({ type }) => type === 'Screen')[0].props.title
  }

  function getMessageEditor (component: any): any {
    return explore(component.toJSON()).query(({ type }) => type === 'RichTextEditor')[0]
  }

  function getPointsInput (component: any): any {
    return explore(component.toJSON()).selectByID('discussions.edit.points_possible.input')
  }

  function getDoneButton (component: any): any {
    return explore(component.toJSON()).selectRightBarButton('discussions.edit.doneButton')
  }

  function getDeleteButton (component: any): any {
    return explore(component.toJSON()).selectByID('discussions.edit.deleteButton')
  }

  function toggleThreadedReplies (component: any, enabled: boolean): any {
    const toggle: any = explore(component.toJSON()).selectByID('discussions.edit.discussion_type.switch')
    toggle.props.onValueChange(enabled)
    return component
  }

  function tapGradingTypeRow (component: any): any {
    const row: any = explore(component.toJSON()).selectByID('discussions.edit.grading_type.row')
    row.props.onPress()
    return component
  }

  function getGradingTypePicker (component: any): any {
    return explore(component.toJSON()).selectByID('discussions.edit.grading_type.picker')
  }

  function getAssignmentDatesEditor (component: any): any {
    return explore(component.toJSON()).selectByType('AssignmentDatesEditor')
  }

  function getUnmetRequirementBanner (component: any): any {
    return explore(component.toJSON()).selectByID('discussions.edit.unmet-requirement-banner')
  }

  function getMessageRequiredFieldSubscript (component: any): any {
    return explore(component.toJSON()).selectByID('discussions.edit.message.validation-error')
  }

  function getPointsPossibleRequiredFieldSubscript (component: any): any {
    return explore(component.toJSON()).selectByID('discussions.edit.points_possible.validation-error')
  }

  function toggleSubscribed (component: any, subscribed: boolean): any {
    const toggle: any = explore(component.toJSON()).selectByID('discussions.edit.subscribed.switch')
    toggle.props.onValueChange(subscribed)
    return component
  }

  function tapAvailableFrom (component: any): any {
    const row: any = explore(component.toJSON()).selectByID('discussions.edit.delayed_post_at.row')
    row.props.onPress()
    return component
  }

  function tapAvailableUntil (component: any): any {
    const row: any = explore(component.toJSON()).selectByID('discussions.edit.lock_at.row')
    row.props.onPress()
    return component
  }

  function getAvailableFromDatePicker (component: any): any {
    return explore(component.toJSON()).selectByID('discussions.edit.delayed_post_at.picker')
  }

  function getAvailableUntilDatePicker (component: any): any {
    return explore(component.toJSON()).selectByID('discussions.edit.lock_at.picker')
  }

  function getPublishToggle (component: any): any {
    return explore(component.toJSON()).selectByID('discussions.edit.published.switch')
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
      mapStateToProps(state, { courseID: '1', discussionID: null })
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
      mapStateToProps(state, { courseID: '1', discussionID: null })
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
      mapStateToProps(state, { courseID: '10', discussionID: '1' })
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
      mapStateToProps(state, { courseID: '3', discussionID: '1' })
    ).toMatchObject({
      assignment,
      pending: 1,
      error: null,
    })
  })
})

