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

import React from 'react'
import PropTypes from 'prop-types'
import {
  NativeModules,
  DeviceEventEmitter,
} from 'react-native'

import { processConfig, checkDefaults } from './utils'

const Helm = NativeModules.Helm

type ScreenProps = {
  title?: string,
  subtitle?: string,
  statusBarStyle?: any,
  statusBarHidden?: boolean,
  statusBarUpdateAnimation?: any,
  automaticallyAdjustsScrollViewInsets?: boolean,
  supportedOrientations?: any,
  noRotationInVerticallyCompact?: boolean,
  backgroundColor?: string,

  // Nav bar stuff
  navBarStyle?: 'light' | 'dark',
  navBarButtonColor?: string,
  navBarColor?: string,
  navBarHidden?: boolean,
  navBarTranslucent?: boolean,
  navBarImage?: string,
  hideNavBarShadowImage?: boolean,
  navBarTransparent?: boolean,
  drawUnderNavBar?: boolean,
  drawUnderTabBar?: boolean,
  leftBarButtons?: any,
  rightBarButtons?: any,
  backButtonTitle?: string,

  children: any,
}

class Screen extends React.Component<any, ScreenProps, any> {
  deviceEventEmitterSubscriptions: Object = {}

  constructor (props: Object, context: Screen.contextTypes) {
    super(props, context)
    this.state = { hasRendered: false, screenInstanceID: context.screenInstanceID }
    this.handleProps(props, context.screenInstanceID, false)
  }

  componentDidMount () {
    this.handleProps(this.props, this.state.screenInstanceID, true)
    this.setState({ hasRendered: true })
  }

  componentWillReceiveProps (nextProps: Object, nextContext: Screen.contextTypes) {
    this.handleProps(nextProps, nextContext.screenInstanceID, this.state.hasRendered)
  }

  componentWillUnmount () {
    Object.keys(this.deviceEventEmitterSubscriptions).forEach(key => {
      DeviceEventEmitter.removeSubscription(this.deviceEventEmitterSubscriptions[key])
    })
  }

  handleProps (props: Object, id: string, hasRendered: boolean) {
    if (!id) return
    const configFRD = processConfig(props, id, (event, callback) => {
      const key = `HelmScreen.${id}.${event}`
      if (this.deviceEventEmitterSubscriptions[key]) {
        DeviceEventEmitter.removeSubscription(this.deviceEventEmitterSubscriptions[key])
      }
      this.deviceEventEmitterSubscriptions[key] = DeviceEventEmitter.addListener(key, callback)
      return key
    })
    Helm.setScreenConfig(checkDefaults(configFRD), id, hasRendered)
  }

  render () {
    if (!this.state.hasRendered) return null
    if (!this.props.children) return null
    return React.Children.only(this.props.children)
  }
}

Screen.propTypes = {
  children: PropTypes.node,
}

Screen.contextTypes = {
  screenInstanceID: PropTypes.string,
}

module.exports = Screen
