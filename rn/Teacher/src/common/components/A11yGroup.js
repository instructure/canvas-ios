// @flow

import React, { Component } from 'react'
import { requireNativeComponent } from 'react-native'

export default class A11yGroup extends Component {
  render () {
    return <NativeA11yGroup {...this.props} />
  }
}

A11yGroup.propTypes = {}

const NativeA11yGroup = requireNativeComponent('A11yGroup', A11yGroup)
