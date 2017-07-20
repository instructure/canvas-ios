// @flow

import React, { Component } from 'react'
import hoistStatics from 'hoist-non-react-statics'

export type RefreshFunction = (*) => *
export type ShouldRefresh = (*) => boolean
export type IsFetchingData = (*) => boolean

export default function refresh (
    refreshFunction: RefreshFunction,
    shouldRefresh: ShouldRefresh,
    isFetchingData: IsFetchingData,
    ttl: ?number = 1000 * 60 * 60 // 1 hour
  ): * {
  let lastUpdate = null

  return function (TheirComponent) {
    class Refreshed extends Component {
      state: RefreshState

      refreshFunction = refreshFunction
      shouldRefresh = shouldRefresh
      isFetchingData = isFetchingData

      constructor (props) {
        super(props)
        this.state = { refreshing: false }
      }

      componentWillReceiveProps (nextProps) {
        this.setState({
          refreshing: this.state.refreshing
            ? isFetchingData(nextProps)
            : false,
        })
      }

      componentWillMount () {
        if (shouldRefresh(this.props)) {
          lastUpdate = Date.now()
          refreshFunction(this.props)
        } else if (!lastUpdate || Date.now() > lastUpdate + ttl) {
          this.refresh()
        }
      }

      refresh = () => {
        this.setState({ refreshing: true }, () => {
          lastUpdate = Date.now()
          refreshFunction(this.props)
        })
      }

      render = () => <TheirComponent {...this.props} refresh={this.refresh} refreshing={this.state.refreshing} />
    }

    return hoistStatics(Refreshed, TheirComponent)
  }
}
