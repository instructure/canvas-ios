/* @flow */

import React, { Component } from 'react'

const RealCircle = require.requireActual('react-native-progress').Circle
export class Circle extends Component {
  render () {
    return React.createElement('Circle', this.props, this.props.children)
  }
}
Circle.propTypes = RealCircle.propTypes
