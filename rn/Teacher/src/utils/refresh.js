// @flow

import React, { Component } from 'react'
import hoistStatics from 'hoist-non-react-statics'

type RefreshFunction = (*) => *
type ShouldRefresh = (*) => boolean

export default function refresh (refreshFunction: RefreshFunction, shouldRefresh: ShouldRefresh): * {
  return function (TheirComponent) {
    class Refreshed extends Component {
      componentWillMount () {
        if (shouldRefresh(this.props)) {
          refreshFunction(this.props)
        }
      }

      refresh = () => refreshFunction(this.props)

      render = () => <TheirComponent {...this.props} refresh={this.refresh} />
    }

    return hoistStatics(Refreshed, TheirComponent)
  }
}
