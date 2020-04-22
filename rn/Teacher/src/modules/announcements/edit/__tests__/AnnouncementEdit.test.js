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

// @flow

import React from 'react'
import {
  Alert,
  NativeModules,
} from 'react-native'
import { shallow } from 'enzyme'

import { AnnouncementEdit, mapStateToProps, type Props } from '../AnnouncementEdit'

jest
  .mock('react-native/Libraries/Components/Button', () => 'Button')
  .mock('react-native/Libraries/Components/Touchable/TouchableHighlight', () => 'TouchableHighlight')
  .mock('react-native/Libraries/Components/Touchable/TouchableOpacity', () => 'TouchableOpacity')
  .mock('../../../../routing/Screen')
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

import * as template from '../../../../__templates__'

describe('AnnouncementEdit', () => {
  let props: Props
  let formFields
  beforeEach(() => {
    jest.clearAllMocks()
    formFields = {
      title: 'Cursed Hollow',
      message: 'Gather tribute or face my curse.',
      require_initial_post: false,
      delayed_post_at: null,
      attachment: null,
      locked: true,
    }

    props = {
      ...formFields,
      announcementID: '1',
      context: 'courses',
      contextID: '1',
      pending: 0,
      error: null,
      navigator: template.navigator(),
      createDiscussion: jest.fn(),
      updateDiscussion: jest.fn(),
      refreshSections: jest.fn(),
      deletePendingNewDiscussion: jest.fn(),
      defaultDate: new Date(0),
      sections: [],
      selectedSections: [],
    }
  })

  it('renders new form', () => {
    props.announcementID = null
    const title = getTitle(render(props))
    expect(title).toEqual('New Announcement')
  })

  it('renders edit form', () => {
    props.announcementID = '1'
    const title = getTitle(render(props))
    expect(title).toEqual('Edit Announcement')
  })

  it('calls refreshSections on mount', () => {
    shallow(<AnnouncementEdit {...props} />)
    expect(props.refreshSections).toHaveBeenCalled()
  })

  it('uses title from input', async () => {
    props.announcementID = null
    props.title = 'Hanamura'
    props.createDiscussion = jest.fn()
    const view = shallow(<AnnouncementEdit {...props} />)
    view.find('RichTextEditor').getElement().ref({
      getHTML: jest.fn(() => Promise.resolve(formFields.message)),
    })
    view.find('[identifier="announcements.edit.titleInput"]')
      .simulate('ChangeText', 'Haunted Mines')
    await view.prop('rightBarButtons')[0].action()
    expect(props.createDiscussion).toHaveBeenCalledWith(
      props.context, props.contextID,
      { ...formFields, is_announcement: true, title: 'Haunted Mines' },
    )
  })

  it('sends is_announcement param on create', async () => {
    props.announcementID = null
    props.createDiscussion = jest.fn()
    const view = shallow(<AnnouncementEdit {...props} />)
    view.find('RichTextEditor').getElement().ref({
      getHTML: jest.fn(() => Promise.resolve(formFields.message)),
    })
    await view.prop('rightBarButtons')[0].action()
    expect(props.createDiscussion).toHaveBeenCalledWith(
      props.context, props.contextID,
      { ...formFields, is_announcement: true },
    )
  })

  it('provides defaults for new announcement', async () => {
    props.announcementID = null
    props.title = null
    props.message = 'required'
    props.require_initial_post = null
    props.delayed_post_at = null
    props.createDiscussion = jest.fn()
    const view = shallow(<AnnouncementEdit {...props} />)
    view.find('RichTextEditor').getElement().ref({
      getHTML: jest.fn(() => Promise.resolve('required')),
    })
    await view.prop('rightBarButtons')[0].action()
    expect(props.createDiscussion).toHaveBeenCalledWith(
      'courses',
      '1',
      {
        attachment: null,
        delayed_post_at: null,
        is_announcement: true,
        locked: true,
        message: 'required',
        require_initial_post: false,
        title: 'No Title',
      }
    )
  })

  it('renders delayed post at row if it exists', () => {
    props.delayed_post_at = null
    expect(render(props).find('[testID="announcements.edit.delayed-post-at-row"]').exists()).toEqual(false)
    props.delayed_post_at = (new Date()).toISOString()
    expect(render(props).find('[testID="announcements.edit.delayed-post-at-row"]').exists()).toEqual(true)
  })

  it('toggles delayed post at row options', () => {
    props.delayed_post_at = null
    const component = render(props)
    toggleDelayPosting(component, true)
    expect(component.find('[testID="announcements.edit.delayed-post-at-row"]').exists()).toEqual(true)
    toggleDelayPosting(component, false)
    expect(component.find('[testID="announcements.edit.delayed-post-at-row"]').exists()).toEqual(false)
  })

  it('toggles delayed post at date picker', () => {
    props.delayed_post_at = (new Date()).toISOString()
    const component = render(props)
    tapDelayedPostAtRow(component)
    expect(component.find('[testID="announcements.edit.delayed-post-at-date-picker"]').exists()).toEqual(true)
  })

  it('converts delayed post at date to iso string', () => {
    props.delayed_post_at = (new Date()).toISOString()
    const component = render(props)
    tapDelayedPostAtRow(component)
    const datePicker = component.find('[testID="announcements.edit.delayed-post-at-date-picker"]')
    datePicker.simulate('dateChange', new Date(0))
    expect(getDelayPostAtValueFromLabel(component)).toEqual('1970-01-01T00:00:00.000Z')
  })

  it('shows modal when saving', async () => {
    const component = shallow(<AnnouncementEdit {...props} />)
    component.find('RichTextEditor').getElement().ref({
      getHTML: jest.fn(() => Promise.resolve('message')),
    })
    await component.prop('rightBarButtons')[0].action()
    component.update()
    const modal = component.find('ModalOverlay')
    expect(modal.prop('visible')).toBeTruthy()
  })

  it('alerts save errors', async () => {
    props.announcementID = null
    jest.useFakeTimers()
    // $FlowFixMe
    Alert.alert = jest.fn()
    const component = shallow(<AnnouncementEdit {...props} />)
    const createDiscussion = jest.fn(() => {
      component.setProps({ error: 'ERROR WAS ALERTED' })
    })
    component.setProps({ createDiscussion })
    component.find('RichTextEditor').getElement().ref({
      getHTML: jest.fn(() => Promise.resolve('message')),
    })
    await component.prop('rightBarButtons')[0].action()
    jest.runAllTimers()
    expect(Alert.alert).toHaveBeenCalled()
  })

  it('dismisses on successful save', async () => {
    const dismiss = Promise.resolve()
    props.announcementID = null
    props.navigator.dismissAllModals = jest.fn(() => dismiss)
    const component = render(props)
    component.setProps({ ...props, pending: 1 })
    component.setProps({ ...props, pending: 0 })
    expect(props.navigator.dismissAllModals).toHaveBeenCalled()
    await dismiss
    expect(NativeModules.AppStoreReview.handleSuccessfulSubmit).toHaveBeenCalled()
  })

  it('clears delay post at date', () => {
    props.delayed_post_at = (new Date(0)).toISOString()
    const component = render(props)
    clearDelayPostAt(component)
    expect(getDelayPostAtPicker(component).exists()).toEqual(false)
  })

  it('deletes pending new discussion on unmount', () => {
    props.deletePendingNewDiscussion = jest.fn()
    render(props).instance().componentWillUnmount()
    expect(props.deletePendingNewDiscussion).toHaveBeenCalledWith(props.context, props.contextID)
  })

  it('sets message placeholder', () => {
    expect(getMessageEditor(render(props)).props().placeholder).toEqual('Add description (required)')
  })

  it('shows banner on done press if message is blank', () => {
    props.message = null
    const component = render(props)
    expect(getUnmetRequirementBanner(component).props().visible).toBeFalsy()
    tapDone(component)
    expect(getUnmetRequirementBanner(component).props().visible).toBeTruthy()
  })

  it('focuses unmetRequirementBanner when it shows', () => {
    jest.useFakeTimers()
    props.message = null
    const component = render(props)
    expect(getUnmetRequirementBanner(component).props().visible).toBeFalsy()
    tapDone(component)
    expect(getUnmetRequirementBanner(component).props().visible).toBeTruthy()
    jest.runAllTimers()
    expect(NativeModules.NativeAccessibility.focusElement).toHaveBeenCalledWith(`announcement.edit.unmet-requirement-banner`)
  })

  it('calls updateDiscussion on done', async () => {
    props.updateDiscussion = jest.fn()
    props.contextID = '1'
    props.announcementID = '2'
    const component = shallow(<AnnouncementEdit {...props} />)
    component.find('[identifier="announcements.edit.titleInput"]')
      .simulate('ChangeText', 'UPDATED TITLE')
    component.find('RichTextEditor').getElement().ref({
      getHTML: jest.fn(() => Promise.resolve(formFields.message)),
    })
    await component.prop('rightBarButtons')[0].action()
    expect(props.updateDiscussion).toHaveBeenCalledWith(
      'courses',
      '1',
      { ...formFields, title: 'UPDATED TITLE', is_announcement: true, id: '2' },
    )
  })

  it('shows attachments', () => {
    const spy = jest.fn()
    props.navigator.show = spy
    props.attachment = template.attachment()
    const btn: any = render(props)
      .find('Screen')
      .props()
      .rightBarButtons
      .find(btn => btn.testID === 'announcements.edit.attachment-btn')

    btn.action()
    expect(spy).toHaveBeenCalledWith(
      '/attachments',
      { modal: true },
      {
        attachments: [props.attachment],
        maxAllowed: 1,
        storageOptions: {
          uploadPath: undefined,
        },
        onComplete: expect.any(Function),
      },
    )
  })

  it('has a sections option', () => {
    let view = shallow(<AnnouncementEdit {...props} />)
    expect(view.find('RowWithDetail').props().title).toEqual('Sections')
  })

  it('sections row has All when no sections selected', () => {
    let view = shallow(<AnnouncementEdit {...props} />)
    expect(view.find('RowWithDetail').props().detail).toEqual('All')
  })

  it('will update the selected sections', () => {
    let section = template.section()
    let view = shallow(<AnnouncementEdit {...props} sections={[section]} />)
    view.instance().updateSelectedSections([section.id])
    view.update()
    expect(view.find('RowWithDetail').props().detail).toEqual(section.name)
  })

  it('will open the section-selector screen with props when sections row is pressed', () => {
    let section = template.section()
    let view = shallow(<AnnouncementEdit {...props} sections={[section]} />)
    view.instance().updateSelectedSections([section.id])
    view.find('RowWithDetail').simulate('press')
    expect(props.navigator.show).toHaveBeenCalledWith(
      '/courses/1/section-selector',
      {},
      {
        updateSelectedSections: view.instance().updateSelectedSections,
        currentSelectedSections: view.state().selectedSections,
      }
    )
  })

  it('scrolls view when RichTextEditor receives focus', () => {
    const spy = jest.fn()
    const tree = shallow(<AnnouncementEdit {...props} />)
    tree.find('KeyboardAwareScrollView').getElement().ref({ scrollToFocusedInput: spy })
    tree.find('RichTextEditor').simulate('Focus')
    expect(spy).toHaveBeenCalled()
  })

  it('allows user to edit ability for students to comment', () => {
    let tree = shallow(<AnnouncementEdit {...props} />)

    let toggle = tree.find('[testID="announcement.edit.locked"]')
    expect(toggle.prop('value')).toEqual(false)
    expect(tree.find('[testID="announcement.edit.initial-post"]').exists()).toEqual(false)

    toggle.simulate('valueChange', true)
    let initialPostToggle = tree.find('[testID="announcement.edit.initial-post"]')
    expect(initialPostToggle.prop('value')).toEqual(false)

    initialPostToggle.simulate('valueChange', true)
    expect(tree.state()).toMatchObject({
      locked: false,
      require_initial_post: true,
    })

    toggle.simulate('valueChange', false)
    expect(tree.state()).toMatchObject({
      locked: true,
      require_initial_post: false,
    })
    expect(tree.find('[testID="announcement.edit.initial-post"]').exists()).toEqual(false)
    expect(tree.find('[testID="announcement.edit.locked"]').prop('value')).toEqual(false)
  })

  function render (props: Props) {
    return shallow(<AnnouncementEdit {...props} />)
  }

  function tapDone (component: any): any {
    getDoneButton(component).action()
  }

  function getTitle (component: any): string {
    return component.find('Screen').props().title
  }

  function getMessageEditor (component: any): any {
    return component.find('RichTextEditor')
  }

  function getDoneButton (component: any): any {
    return component.find('Screen')
      .props()
      .rightBarButtons
      .find(button => button.testID === 'announcements.edit.doneButton')
  }

  function toggleDelayPosting (component: any, enabled: boolean) {
    component.find('[identifier="announcements.edit.delay-posting-toggle"]')
      .simulate('valueChange', enabled)
  }

  function tapDelayedPostAtRow (component: any) {
    const row = component.find('[testID="announcements.edit.delayed-post-at-row"]')
    row.simulate('press')
  }

  function getDelayPostAtPicker (component: any): any {
    return component.find('[testID="announcements.edit.delayed-post-at-date-picker"]')
  }

  function getDelayPostAtValueFromLabel (component: any): string {
    return component.find('[testID="announcements.edit.delayed-post-at-row"]').prop('date')
  }

  function clearDelayPostAt (component: any) {
    const clearButton = component.find('[testID="announcements.edit.delayed-post-at-row"]')
    clearButton.simulate('removeDatePress')
  }

  function getUnmetRequirementBanner (component: any): any {
    return component.find('[testID="announcement.edit.unmet-requirement-banner"]')
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
      mapStateToProps(state, { context: 'courses', contextID: '1', announcementID: null })
    ).toMatchObject({
      pending: 14,
      error: 'Map this error',
    })
  })

  it('maps announcement state to props using new id', () => {
    const announcement = template.discussion({ id: '45', title: 'IT WORKED' })
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
            data: announcement,
          },
        },
      },
    })
    expect(
      mapStateToProps(state, { context: 'courses', contextID: '1', announcementID: null })
    ).toMatchObject({ title: 'IT WORKED' })
  })

  it('maps announcement state to props using new id group context', () => {
    const announcement = template.discussion({ id: '45', title: 'IT WORKED' })
    const state: AppState = template.appState({
      entities: {
        ...template.appState().entities,
        groups: {
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
            data: announcement,
          },
        },
      },
    })
    expect(
      mapStateToProps(state, { context: 'groups', contextID: '1', announcementID: null })
    ).toMatchObject({ title: 'IT WORKED' })
  })

  it('maps announcement state to props', () => {
    const announcement = template.discussion({
      id: '1',
      title: 'Infernal Shrines',
      message: 'THE ENEMY IS ATTACKING YOUR CORE!',
      require_initial_post: true,
      delayed_post_at: null,
      locked: true,
    })
    const state: AppState = template.appState({
      entities: {
        ...template.appState().entities,
        discussions: {
          '1': {
            pending: 45,
            error: 'YOUR CORE IS UNDER ATTACK',
            data: announcement,
          },
        },
      },
    })
    expect(
      mapStateToProps(state, { context: 'courses', contextID: '10', announcementID: '1' })
    ).toMatchObject({
      title: 'Infernal Shrines',
      message: 'THE ENEMY IS ATTACKING YOUR CORE!',
      require_initial_post: true,
      delayed_post_at: null,
      pending: 45,
      error: 'YOUR CORE IS UNDER ATTACK',
      locked: true,
    })
  })

  it('maps attachment state to props', () => {
    const attachment = template.attachment()
    const announcement = template.discussion({
      id: '1',
      attachments: [attachment],
    })
    const state: AppState = template.appState({
      entities: {
        ...template.appState().entities,
        discussions: {
          '1': {
            pending: 0,
            error: null,
            data: announcement,
          },
        },
      },
    })
    expect(
      mapStateToProps(state, { context: 'courses', contextID: '1', announcementID: '1' })
    ).toMatchObject({ attachment })
  })
})
