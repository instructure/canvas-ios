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

import {
  NativeModules,
  Linking,
} from 'react-native'

import { registerScreens } from '../register-screens'
import Navigator from '../Navigator'
import canvas from '../../canvas-api'
import app from '../../modules/app'

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

jest.mock('react-native/Libraries/Linking/Linking', () => ({ openURL: jest.fn() }))

registerScreens({})

describe('Navigator', () => {
  beforeEach(() => {
    jest.clearAllMocks()
    app.setCurrentApp('teacher')
  })

  it('forwards show as a push', () => {
    new Navigator('push').show('/courses/1')
    expect(NativeModules.Helm.pushFrom).toHaveBeenCalledWith(
      'push',
      '/courses/:courseID',
      { courseID: '1', screenInstanceID: expect.any(String), location: expect.any(Object) },
      { canBecomeMaster: true, deepLink: true, detail: false }
    )
  })

  it('passes detail option from show to push', () => {
    new Navigator('detail').show('/courses/1', { detail: true })
    expect(NativeModules.Helm.pushFrom).toHaveBeenCalledWith(
      'detail',
      '/courses/:courseID',
      expect.any(Object),
      { canBecomeMaster: true, deepLink: true, detail: true },
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
      { canBecomeMaster: true, embedInNavigationController: true, modal: true, modalPresentationStyle: 'formsheet', disableSwipeDownToDismissModal: true }
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
        disableSwipeDownToDismissModal: false,
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
      disableSwipeDownToDismissModal: true,
    })

    expect(NativeModules.Helm.present).toHaveBeenCalledWith(
      '/:context/:contextID/announcements/:announcementID',
      { context: 'courses', contextID: '1', announcementID: '3', screenInstanceID: expect.any(String), location: expect.any(Object) },
      { canBecomeMaster: false, embedInNavigationController: true, modal: true, modalPresentationStyle: 'formsheet', disableSwipeDownToDismissModal: true }
    )
  })

  it('opens SFSafariViewController in Teacher if we try to deepLink to something that is unsupported', async () => {
    let promise = Promise.resolve({ data: { session_url: 'https://google.com' } })
    canvas.getAuthenticatedSessionURL.mockReturnValueOnce(promise)
    new Navigator('deepLink').show('https://google.com', {
      deepLink: true,
    })

    await promise

    expect(NativeModules.Helm.openInSafariViewController).toHaveBeenCalledWith('https://google.com')
  })

  it('opens Safari in Student if we try to deepLink to something that is unsupported', async () => {
    app.setCurrentApp('student')
    let promise = Promise.resolve({ data: { session_url: 'https://google.com' } })
    canvas.getAuthenticatedSessionURL.mockReturnValueOnce(promise)
    new Navigator('deepLink').show('https://google.com', {
      deepLink: true,
    })

    await promise

    expect(Linking.openURL).toHaveBeenCalledWith('https://google.com')
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
    expect(NativeModules.Helm.openInSafariViewController).toHaveBeenCalledWith('https://google.com')
  })

  it('opens a webview with the https url if we dont route some canvas protocol', async () => {
    const httpsUrl = 'https://canvas.instructure.com/bogus'
    const promise = Promise.resolve({ data: { session_url: httpsUrl + '?auth' } })
    canvas.getAuthenticatedSessionURL.mockReturnValueOnce(promise)
    new Navigator('push').show('canvas-teacher://canvas.instructure.com/bogus')

    expect(canvas.getAuthenticatedSessionURL).toHaveBeenCalledWith(httpsUrl)
    await promise
    expect(NativeModules.Helm.openInSafariViewController).toHaveBeenCalledWith(httpsUrl + '?auth')
  })

  it('opens the original url if getting the authenticated session url errors', async () => {
    let promise = Promise.reject()
    canvas.getAuthenticatedSessionURL.mockReturnValueOnce(promise)
    new Navigator('showWebView').showWebView('https://google.com')

    try {
      await promise
    } catch (err) {
      expect(NativeModules.Helm.openInSafariViewController).toHaveBeenCalledWith('https://google.com')
    }
  })

  it('sets options', () => {
    let n = new Navigator('push', { modal: true })

    expect(n.isModal).toEqual(true)
  })
})
