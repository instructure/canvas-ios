// @flow
import { NativeModules } from 'react-native'
import { route } from './index'
import PropRegistry from './PropRegistry'

type ShowOptions = {
  modal: boolean,
  modalPresentationStyle: string,
  embedInNavigationController: boolean,
}

export default class Navigator {
  moduleName = ''
  screenConfig: Object = {}

  constructor (moduleName: string) {
    this.moduleName = moduleName
  }

  show (url: string, options: Object = { modal: false, modalPresentationStyle: 'fullscreen' }, additionalProps: Object = {}): void {
    const uuid = () => {
      return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
        var r = Math.random() * 16 | 0, v = c === 'x' ? r : (r & 0x3 | 0x8) // eslint-disable-line one-var
        return v.toString(16)
      })
    }
    const screenInstanceID = uuid()
    const additionalPropsFRD = Object.assign(additionalProps, { screenInstanceID })
    const r = route(url, additionalPropsFRD)
    PropRegistry.save(screenInstanceID, additionalPropsFRD)

    if (options.modal) {
      this.present(r, { modal: options.modal, modalPresentationStyle: options.modalPresentationStyle, embedInNavigationController: true })
    } else {
      this.push(r)
    }
  }

  push (route: RouteOptions) {
    NativeModules.Helm.pushFrom(this.moduleName, route.screen, route.passProps, route.config)
  }

  pop () {
    NativeModules.Helm.popFrom(this.moduleName)
  }

  present (route: RouteOptions, options: ShowOptions) {
    NativeModules.Helm.present(route.screen, route.passProps, options)
  }

  dismiss () {
    NativeModules.Helm.dismiss({})
  }

  dismissAllModals () {
    NativeModules.Helm.dismissAllModals({})
  }

  traitCollection (handler: (traits: { [key: string]: string }) => void): any {
    return NativeModules.Helm.traitCollection(handler)
  }
}
