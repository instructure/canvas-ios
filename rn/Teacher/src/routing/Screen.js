// @flow

import React from 'react'
import PropTypes from 'prop-types'
import {
  NativeModules,
  DeviceEventEmitter,
} from 'react-native'

import { processConfig } from './utils'

const Helm = NativeModules.Helm

class Screen extends React.Component<any, any, any> {
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

    let configFRD = processConfig(props, id, (event, callback) => {
      const key = `HelmScreen.${id}.${event}`
      if (this.deviceEventEmitterSubscriptions[key]) {
        DeviceEventEmitter.removeSubscription(this.deviceEventEmitterSubscriptions[key])
      }
      this.deviceEventEmitterSubscriptions[key] = DeviceEventEmitter.addListener(key, callback)
      return key
    })
    Helm.setScreenConfig(configFRD, id, hasRendered)
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
