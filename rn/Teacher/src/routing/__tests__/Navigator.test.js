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

import {
  NativeModules,
  Linking,
} from 'react-native'

import { registerScreens } from '../register-screens'
import Navigator from '../Navigator'
import canvas from '../../canvas-api'
import SFSafariViewController from 'react-native-sfsafariviewcontroller'

jest.mock('../../canvas-api', () => ({
  getAuthenticatedSessionURL: jest.fn(),
  getSession: () => ({
    authToken: '',
    baseURL: 'canvas.instructure.com',
    user: {
      primary_email: 'user@user.com',
      id: '1',
      avatar_url: 'image.image.com',
      name: 'User User',
    },
    actAsUserID: null,
  }),
}))

jest.mock('react-native-sfsafariviewcontroller', () => ({
  open: jest.fn(),
}))

jest.mock('Linking', () => ({ openURL: jest.fn() }))

registerScreens({})

describe('Navigator', () => {
  beforeEach(() => {
    jest.clearAllMocks()

    NativeModules.Helm = {
      pushFrom: jest.fn(() => Promise.resolve()),
      popFrom: jest.fn(() => Promise.resolve()),
      present: jest.fn(() => Promise.resolve()),
      dismiss: jest.fn(() => Promise.resolve()),
      dismissAllModals: jest.fn(() => Promise.resolve()),
      traitCollection: jest.fn(),
    }
  })

  it('forwards show as a push', () => {
    new Navigator('push').show('/courses/1')
    expect(NativeModules.Helm.pushFrom).toHaveBeenCalledWith(
      'push',
      '/courses/:courseID',
      { courseID: '1', screenInstanceID: expect.any(String), location: expect.any(Object) },
      { canBecomeMaster: true, deepLink: true }
    )
  })

  it('forwards pop to native helm', () => {
    new Navigator('pop').pop()
    expect(NativeModules.Helm.popFrom).toHaveBeenCalledWith('pop')
  })

  it('forwards replace as a push', () => {
    new Navigator('replace').replace('/courses/2')
    expect(NativeModules.Helm.pushFrom).toHaveBeenCalledWith(
      'replace',
      '/courses/:courseID',
      { courseID: '2', screenInstanceID: expect.any(String), location: expect.any(Object) },
      { canBecomeMaster: true, replace: true, deepLink: true },
    )
  })

  it('forwards present to native helm', () => {
    new Navigator('present').show('/courses/1', { modal: true })
    expect(NativeModules.Helm.present).toHaveBeenCalledWith(
      '/courses/:courseID',
      { courseID: '1', screenInstanceID: expect.any(String), location: expect.any(Object) },
      { canBecomeMaster: true, embedInNavigationController: true, modal: true, modalPresentationStyle: 'formsheet' }
    )
  })

  it('forwards dismiss to native helm', () => {
    new Navigator('dismiss').dismiss()
    expect(NativeModules.Helm.dismiss).toHaveBeenCalledWith({})
  })

  it('forwards dismiss all to native helm', () => {
    new Navigator('dismiss all').dismissAllModals()
    expect(NativeModules.Helm.dismissAllModals).toHaveBeenCalledWith({})
  })

  it('traitCollection', () => {
    const handler = () => {}
    new Navigator('traitCollection').traitCollection(handler)
    expect(NativeModules.Helm.traitCollection).toHaveBeenCalledWith('traitCollection', handler)
  })

  it('shows push notifications', () => {
    const notification = {
      getAlert: () => 'New Submission',
      getData: () => ({
        html_url: '/courses/1/assignments/2/submissions/3',
      }),
    }
    new Navigator('new submission notification').showNotification(notification)
    expect(NativeModules.Helm.present).toHaveBeenCalledWith(
      '/courses/:courseID/assignments/:assignmentID/submissions/:userID',
      {
        courseID: '1',
        assignmentID: '2',
        userID: '3',
        screenInstanceID: expect.any(String),
        forceRefresh: true,
        pushNotification: {
          alert: 'New Submission',
          data: {
            html_url: '/courses/1/assignments/2/submissions/3',
          },
        },
        location: expect.any(Object),
      },
      {
        embedInNavigationController: true,
        modal: true,
        modalPresentationStyle: 'fullscreen',
        canBecomeMaster: false,
      },
    )
  })

  it('should not throw if we cant handle notification', () => {
    const notification = {
      getAlert: () => 'Web team forgot to tell you about this one',
      getData: () => ({
        html_url: '/something/you/dont/know/about',
      }),
    }
    expect(() => {
      new Navigator('dont throw').showNotification(notification)
    }).not.toThrow()
  })

  it('shows as a modal if modal config is true', () => {
    new Navigator('deepLink').show('/courses/1/announcements/3', {
      modal: true,
      embedInNavigationController: true,
      deepLink: true,
    })

    expect(NativeModules.Helm.present).toHaveBeenCalledWith(
      '/:context/:contextID/announcements/:announcementID',
      { context: 'courses', contextID: '1', announcementID: '3', screenInstanceID: expect.any(String), location: expect.any(Object) },
      { canBecomeMaster: false, embedInNavigationController: true, modal: true, modalPresentationStyle: 'formsheet' }
    )
  })

  it('opens a webview if we try to deepLink to something that is unsupported', async () => {
    let promise = Promise.resolve({ data: { session_url: 'https://google.com' } })
    canvas.getAuthenticatedSessionURL.mockReturnValueOnce(promise)
    new Navigator('deepLink').show('https://google.com', {
      deepLink: true,
    })

    await promise

    expect(SFSafariViewController.open).toHaveBeenCalledWith('https://google.com')
  })

  it('linking should  be called if something is unsupported and it is not http or https', () => {
    new Navigator('deepLink').show('mailto:johny@johnny.com', {
      deepLink: true,
    })

    expect(Linking.openURL).toHaveBeenCalledWith('mailto:johny@johnny.com')
  })

  it('opens a webview with the url if we do not have a route for it', async () => {
    let promise = Promise.resolve({ data: { session_url: 'https://google.com' } })
    canvas.getAuthenticatedSessionURL.mockReturnValueOnce(promise)
    new Navigator('push').show('https://google.com')

    await promise
    expect(SFSafariViewController.open).toHaveBeenCalledWith('https://google.com')
  })

  it('opens a webview with the https url if we dont route some canvas protocol', async () => {
    const httpsUrl = 'https://canvas.instructure.com/bogus'
    const promise = Promise.resolve({ data: { session_url: httpsUrl + '?auth' } })
    canvas.getAuthenticatedSessionURL.mockReturnValueOnce(promise)
    new Navigator('push').show('canvas-teacher://canvas.instructure.com/bogus')

    expect(canvas.getAuthenticatedSessionURL).toHaveBeenCalledWith(httpsUrl)
    await promise
    expect(SFSafariViewController.open).toHaveBeenCalledWith(httpsUrl + '?auth')
  })

  it('opens the original url if getting the authenticated session url errors', async () => {
    let promise = Promise.reject()
    canvas.getAuthenticatedSessionURL.mockReturnValueOnce(promise)
    new Navigator('showWebView').showWebView('https://google.com')

    try {
      await promise
    } catch (err) {
      expect(SFSafariViewController.open).toHaveBeenCalledWith('https://google.com')
    }
  })

  it('sets options', () => {
    let n = new Navigator('push', { modal: true })

    expect(n.isModal).toEqual(true)
  })
})
