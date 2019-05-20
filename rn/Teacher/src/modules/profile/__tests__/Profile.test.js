//
// Copyright (C) 2017-present Instructure, Inc.
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
import { NativeModules, ActionSheetIOS, Linking, AsyncStorage } from 'react-native'
import React from 'react'
import { Profile, mapStateToProps } from '../Profile'
import app from '../../app'

// Note: test renderer must be required after react-native.
import renderer from 'react-test-renderer'
import explore from '../../../../test/helpers/explore'

import * as template from '../../../__templates__'

jest.mock('ActionSheetIOS', () => ({
  showActionSheetWithOptions: jest.fn(),
}))
jest.mock('TouchableHighlight', () => 'TouchableHighlight')

let defaultProps = {}

describe('Profile Tests', () => {
  beforeEach(() => {
    jest.resetAllMocks()

    NativeModules.RNMail = {
      ...NativeModules.RNMail,
      canSendMail: true,
    }
    app.setCurrentApp('teacher')
    var navigator = template.navigator({
      dismiss: jest.fn(() => {
        return Promise.resolve()
      }),
    })
    defaultProps = {
      navigator: navigator,
      refreshCanActAsUser: jest.fn(),
      refreshAccountExternalTools: jest.fn(),
      refreshHelpLinks: jest.fn(),
      canActAsUser: true,
      externalTools: [],
      userSettings: {
        hide_dashcard_color_overlays: false,
      },
      getUserProfile: jest.fn(() => Promise.resolve({ data: template.user() })),
      getUserSettings: jest.fn(),
      updateUserSettings: jest.fn(),
    }
  })
  it('renders correctly', () => {
    const tree = renderer.create(
      <Profile { ...defaultProps } canActAsUser={true} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders correctly with no session', () => {
    const tree = renderer.create(
      <Profile { ...defaultProps } canActAsUser={true} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders correctly with lti apps', () => {
    app.setCurrentApp('student')
    let externalTools = [template.launchDefinition()]
    defaultProps = { ...defaultProps, externalTools }
    const tree = renderer.create(
      <Profile { ...defaultProps } canActAsUser={true} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders correctly with no lti apps', () => {
    app.setCurrentApp('student')
    let externalTools = null
    defaultProps = { ...defaultProps, externalTools }
    const tree = renderer.create(
      <Profile { ...defaultProps } canActAsUser={true} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('renders correctly for students', () => {
    app.setCurrentApp('student')
    const tree = shallow(
      <Profile { ...defaultProps } />
    )

    expect(tree).toMatchSnapshot()
    expect(tree.find('[testID="profile.settings-btn"]').length).toEqual(1)
  })

  it('renders correctly for parents', () => {
    app.setCurrentApp('parent')
    const tree = shallow(
      <Profile { ...defaultProps } />
    )

    expect(tree).toMatchSnapshot()
    expect(tree.find('[testID="profile.navigation-settings-btn"]').length).toEqual(0)
  })

  it('navigate to manage children screen', async () => {
    app.setCurrentApp('parent')
    const instance = renderer.create(
      <Profile { ...defaultProps } />
    ).getInstance()
    await instance.manageObserverStudents()
    expect(defaultProps.navigator.show).toHaveBeenCalledWith('/parent/manage-children', { modal: false })
  })

  it('renders correctly without act as user', () => {
    const tree = renderer.create(
      <Profile { ...defaultProps } canActAsUser={false} />
    ).toJSON()

    expect(tree).toMatchSnapshot()
  })

  it('logout methods called', () => {
    const instance = renderer.create(
      <Profile { ...defaultProps } />
    ).getInstance()

    instance.logout()
    expect(NativeModules.NativeLogin.logout).toHaveBeenCalled()
    instance.switchUser()
    expect(NativeModules.NativeLogin.changeUser).toHaveBeenCalled()
  })

  it('navigate to lti gauge tool', async () => {
    app.setCurrentApp('student')
    let externalTools = [template.launchDefinition()]
    defaultProps = { ...defaultProps, externalTools }
    const spy = jest.fn()
    defaultProps.navigator.dismiss = spy
    const row: any = explore(renderer.create(
      <Profile {...defaultProps} />
    ).toJSON()).selectByID('row-lti-gauge.instructure.com-360860')
    row.props.onPress()
    expect(spy).toHaveBeenCalled()
  })

  it('navigate to student settings', async () => {
    app.setCurrentApp('student')
    const instance = renderer.create(
      <Profile { ...defaultProps } />
    ).getInstance()
    await instance.settings()
    expect(defaultProps.navigator.show).toHaveBeenCalledWith('/profile/settings', { modal: true })
  })

  it('navigate to user files', async () => {
    const instance = renderer.create(
      <Profile { ...defaultProps } />
    ).getInstance()
    await instance.userFiles()
    expect(defaultProps.navigator.show).toHaveBeenCalledWith('/users/self/files', { modal: false }, { 'customPageViewPath': '/files' })
  })

  it('shows the action sheet', async () => {
    const instance = renderer.create(
      <Profile { ...defaultProps } />
    ).getInstance()

    await instance.settings()
    expect(ActionSheetIOS.showActionSheetWithOptions).toHaveBeenCalled()
  })

  it('redirects to Canvas Guides', async () => {
    const instance = renderer.create(
      <Profile { ...defaultProps } />
    ).getInstance()

    await instance.handleActions(0)
    expect(Linking.openURL).toHaveBeenCalled()
  })

  it('redirects to Terms of Use', async () => {
    const instance = renderer.create(
      <Profile { ...defaultProps } />
    ).getInstance()

    await instance.handleActions(1)
    expect(defaultProps.navigator.dismiss).toHaveBeenCalled()
    expect(defaultProps.navigator.show).toHaveBeenCalledWith(
      '/terms-of-use',
      { modal: true }
    )
  })

  it('secret tap! enables developer menu', async () => {
    AsyncStorage.getItem = jest.fn()
    AsyncStorage.setItem = jest.fn()
    AsyncStorage.removeItem = jest.fn()
    const instance = renderer.create(
      <Profile { ...defaultProps } />
    ).getInstance()
    const spy = jest.spyOn(instance, 'enableDeveloperMenu')
    var times = 12
    for (var i = 0; i < times; i++) {
      await instance.secretTap()
    }
    expect(AsyncStorage.getItem).toHaveBeenCalled()
    expect(AsyncStorage.setItem).toHaveBeenCalled()
    expect(AsyncStorage.removeItem).not.toHaveBeenCalled()
    expect(spy).toHaveBeenCalled()
  })

  it('secret tap! disables developer menu', async () => {
    AsyncStorage.getItem = jest.fn(() => true)
    AsyncStorage.setItem = jest.fn()
    AsyncStorage.removeItem = jest.fn()
    const instance = renderer.create(
      <Profile { ...defaultProps } />
    ).getInstance()
    const spy = jest.spyOn(instance, 'enableDeveloperMenu')
    var times = 12
    for (var i = 0; i < times; i++) {
      await instance.secretTap()
    }
    expect(AsyncStorage.getItem).toHaveBeenCalled()
    expect(AsyncStorage.setItem).not.toHaveBeenCalled()
    expect(AsyncStorage.removeItem).toHaveBeenCalled()
    expect(spy).toHaveBeenCalled()
  })

  it('refreshes avatar url on mount', async () => {
    const url = 'test-refresh-on-mount'
    const user = template.user({
      avatar_url: url,
    })
    let promise = Promise.resolve({ data: user })
    const getUserProfile = jest.fn(() => promise)
    const props = {
      ...defaultProps,
      getUserProfile,
    }
    const tree = shallow(<Profile {...props} />)
    await promise
    tree.update()

    expect(getUserProfile).toHaveBeenCalledWith('self')
    const avatar = tree.find('Avatar').first()
    expect(avatar.props().avatarURL).toEqual(url)
  })

  it('refreshes help links on mount', async () => {
    const promise = Promise.resolve({ data: template.helpLinks() })
    const props = {
      ...defaultProps,
      refreshHelpLinks: jest.fn(() => promise),
    }
    shallow(<Profile {...props} />)
    await promise
    expect(props.refreshHelpLinks).toHaveBeenCalled()
  })

  it('shows custom help link', async () => {
    let selectedActionSheet = jest.fn()
    const showActionSheet = jest.fn((options, callback) => {
      selectedActionSheet = callback
    })
    ActionSheetIOS.showActionSheetWithOptions = showActionSheet
    const helpLink = template.helpLink({ id: 'link1', url: 'https://google.com' })
    const helpLinks = template.helpLinks({
      custom_help_links: [helpLink],
    })
    const props = {
      ...defaultProps,
      helpLinks,
      navigator: template.navigator({
        showWebView: jest.fn(),
      }),
    }
    const view = shallow(<Profile {...props} />)
    await view.update()
    const helpBtn = view.find('[testID="profile.help-menu-btn"]')
    helpBtn.simulate('Press')
    await selectedActionSheet(0)
    expect(props.navigator.showWebView).toHaveBeenCalledWith('https://google.com')
  })

  it('handles instructor question', async () => {
    let selectedActionSheet = jest.fn()
    const showActionSheet = jest.fn((options, callback) => {
      selectedActionSheet = callback
    })
    ActionSheetIOS.showActionSheetWithOptions = showActionSheet
    const helpLink = template.helpLink({ id: 'instructor_question' })
    const helpLinks = template.helpLinks({
      custom_help_links: [helpLink],
    })
    const props = {
      ...defaultProps,
      helpLinks,
      navigator: template.navigator({
        show: jest.fn(),
      }),
    }
    const view = shallow(<Profile {...props} />)
    const helpBtn = view.find('[testID="profile.help-menu-btn"]')
    helpBtn.simulate('Press')
    await selectedActionSheet(0)
    expect(props.navigator.show).toHaveBeenCalledWith('/conversations/compose', { modal: true }, {
      instructorQuestion: true,
      canAddRecipients: false,
    })
  })

  it('handles report a problem', async () => {
    let selectedActionSheet = jest.fn()
    const showActionSheet = jest.fn((options, callback) => {
      selectedActionSheet = callback
    })
    ActionSheetIOS.showActionSheetWithOptions = showActionSheet
    const helpLink = template.helpLink({ id: 'report_a_problem' })
    const helpLinks = template.helpLinks({
      custom_help_links: [helpLink],
    })
    const props = {
      ...defaultProps,
      helpLinks,
      navigator: template.navigator({
        show: jest.fn(),
      }),
    }
    const view = shallow(<Profile {...props} />)
    const helpBtn = view.find('[testID="profile.help-menu-btn"]')
    helpBtn.simulate('Press')
    await selectedActionSheet(0)
    expect(props.navigator.show).toHaveBeenCalledWith('/support/problem', { modal: true })
  })

  it('handles cancel from help menu', async () => {
    let selectedActionSheet = jest.fn()
    const showActionSheet = jest.fn((options, callback) => {
      selectedActionSheet = callback
    })
    ActionSheetIOS.showActionSheetWithOptions = showActionSheet
    const helpLink = template.helpLink({ id: 'report_a_problem' })
    const helpLinks = template.helpLinks({
      custom_help_links: [helpLink],
    })
    const props = {
      ...defaultProps,
      helpLinks,
      navigator: template.navigator({
        show: jest.fn(),
        dismiss: jest.fn(),
        showWebView: jest.fn(),
      }),
    }
    const view = shallow(<Profile {...props} />)
    const helpBtn = view.find('[testID="profile.help-menu-btn"]')
    helpBtn.simulate('Press')
    await selectedActionSheet(1) // cancel index is 1
    expect(props.navigator.dismiss).not.toHaveBeenCalled()
    expect(props.navigator.show).not.toHaveBeenCalled()
    expect(props.navigator.showWebView).not.toHaveBeenCalled()
  })

  it('only shows student help menu links for students', () => {
    app.setCurrentApp('student')
    let actionSheet
    const helpLinks = template.helpLinks({
      default_help_links: [],
      custom_help_links: [
        template.helpLink({ text: 'Student', available_to: ['student'] }),
        template.helpLink({ text: 'Teacher', available_to: ['teacher'] }),
      ],
    })
    const showActionSheet = jest.fn((options, callback) => {
      actionSheet = options
    })
    ActionSheetIOS.showActionSheetWithOptions = showActionSheet
    const props = {
      ...defaultProps,
      helpLinks,
    }
    const view = shallow(<Profile {...props} />)
    const helpBtn = view.find('[testID="profile.help-menu-btn"]')
    helpBtn.simulate('Press')
    expect(actionSheet.options.length).toEqual(2)
    expect(actionSheet.options[0]).toEqual('Student')
    expect(actionSheet.options[1]).toEqual('Cancel')
  })

  it('only shows teacher help menu links for teachers', () => {
    app.setCurrentApp('teacher')
    let actionSheet
    const helpLinks = template.helpLinks({
      default_help_links: [],
      custom_help_links: [
        template.helpLink({ text: 'Student', available_to: ['student'] }),
        template.helpLink({ text: 'Teacher', available_to: ['teacher'] }),
      ],
    })
    const showActionSheet = jest.fn((options, callback) => {
      actionSheet = options
    })
    ActionSheetIOS.showActionSheetWithOptions = showActionSheet
    const props = {
      ...defaultProps,
      helpLinks,
    }
    const view = shallow(<Profile {...props} />)
    const helpBtn = view.find('[testID="profile.help-menu-btn"]')
    helpBtn.simulate('Press')
    expect(actionSheet.options.length).toEqual(2)
    expect(actionSheet.options[0]).toEqual('Teacher')
    expect(actionSheet.options[1]).toEqual('Cancel')
  })

  it('uses default help links if there are no custom ones', () => {
    let actionSheet
    const helpLinks = template.helpLinks({
      default_help_links: [template.helpLink()],
      custom_help_links: [],
    })
    const showActionSheet = jest.fn((options, callback) => {
      actionSheet = options
    })
    ActionSheetIOS.showActionSheetWithOptions = showActionSheet
    const props = {
      ...defaultProps,
      helpLinks,
    }
    const view = shallow(<Profile {...props} />)
    const helpBtn = view.find('[testID="profile.help-menu-btn"]')
    helpBtn.simulate('Press')
    expect(actionSheet.options.length).toEqual(2)
  })

  it('refreshes the user settings', () => {
    shallow(<Profile {...defaultProps} />)
    expect(defaultProps.getUserSettings).toHaveBeenCalled()
  })

  it('updates the user settings', () => {
    let tree = shallow(<Profile {...defaultProps} />)
    let row = tree.find('[testID="profile.color-overlay-toggle"]')
    row.simulate('valueChange', true)
    expect(defaultProps.updateUserSettings).toHaveBeenCalledWith('self', false)
  })
})

describe('map state to prop', () => {
  it('maps state to props', () => {
    const state: AppState = template.appState({
      userInfo: {
        canActAsUser: true,
        showsGradesOnCourseCards: true,
        externalTools: [],
      },
    })

    expect(mapStateToProps(state, {})).toMatchObject({
      canActAsUser: true,
      showsGradesOnCourseCards: true,
      externalTools: [],
    })
  })
})
