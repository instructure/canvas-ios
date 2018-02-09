//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

// @flow
import { NativeModules } from 'react-native'
import { route } from './index'
import SFSafariViewController from 'react-native-sfsafariviewcontroller'
import { getAuthenticatedSessionURL } from '../canvas-api'

type ShowOptions = {
  modal: boolean,
  modalPresentationStyle: string,
  embedInNavigationController: boolean,
}

export type TraitCollectionType = 'compact' | 'regular' | 'unspecified'
export type TraitCollection = { [scope: string]: { [key: string]: TraitCollectionType} }

export default class Navigator {
  moduleName = ''
  isModal = false

  constructor (moduleName: string, options: { String: any } = {}) {
    this.moduleName = moduleName
    // options consists of any option that was passed into show when
    // routing so we can add other options here as needed
    this.isModal = options.modal
  }

  show (url: string, options: Object = { modal: false, modalPresentationStyle: 'formsheet', deepLink: false }, additionalProps: Object = {}) {
    try {
      const r = route(url, additionalProps)
      if (options.deepLink && !r.config.deepLink) {
        return this.showWebView(url)
      }

      let canBecomeMaster = false
      if (r.config && r.config.canBecomeMaster) {
        canBecomeMaster = r.config.canBecomeMaster
      }
      if (options.modal) {
        const embedInNavigationController = options.embedInNavigationController == null || options.embedInNavigationController
        return this.present(r, { modal: options.modal, modalPresentationStyle: options.modalPresentationStyle || 'formsheet', embedInNavigationController, canBecomeMaster: canBecomeMaster, modalTransitionStyle: options.modalTransitionStyle })
      } else {
        return this.push(r)
      }
    } catch (err) {
      return this.showWebView(url)
    }
  }

  async showWebView (url: string) {
    try {
      let { data: { session_url: authenticatedURL } } = await getAuthenticatedSessionURL(url)
      SFSafariViewController.open(authenticatedURL)
    } catch (err) {
      SFSafariViewController.open(url)
    }
  }

  replace (url: string, options: Object = { modal: false, modalPresentationStyle: 'formsheet' }, additionalProps: Object = {}) {
    const r = route(url, additionalProps)
    return NativeModules.Helm.pushFrom(this.moduleName, r.screen, r.passProps, { ...r.config, replace: true })
  }

  push (route: RouteOptions) {
    return NativeModules.Helm.pushFrom(this.moduleName, route.screen, route.passProps, route.config)
  }

  pop () {
    return NativeModules.Helm.popFrom(this.moduleName)
  }

  present (route: RouteOptions, options: ShowOptions) {
    return NativeModules.Helm.present(route.screen, route.passProps, options)
  }

  dismiss () {
    return NativeModules.Helm.dismiss({})
  }

  dismissAllModals () {
    return NativeModules.Helm.dismissAllModals({})
  }

  traitCollection (handler: (traits: TraitCollection) => void): any {
    return NativeModules.Helm.traitCollection(this.moduleName, handler)
  }

  showNotification (notification: PushNotificationIOS) {
    if (notification.getData() && notification.getData().html_url) {
      const url = notification.getData().html_url
      this.show(url, {
        modal: true,
        modalPresentationStyle: 'fullscreen',
        embedInNavigationController: true,
        deepLink: true,
      }, {
        pushNotification: {
          alert: notification.getAlert(),
          data: notification.getData(),
        },
      })
    }
  }

  launchExternalTool (url: string) {
    NativeModules.Helm.launchExternalTool(url)
  }
}
