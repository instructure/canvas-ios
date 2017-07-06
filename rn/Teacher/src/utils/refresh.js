// @flow

import React, { Component } from 'react'
import hoistStatics from 'hoist-non-react-statics'

export type RefreshFunction = (*) => *
export type ShouldRefresh = (*) => boolean
export type IsFetchingData = (*) => boolean

export default function refresh (
    refreshFunction: RefreshFunction,
    shouldRefresh: ShouldRefresh,
    isFetchingData: IsFetchingData
  ): * {
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
          refreshFunction(this.props)
        }
      }

      refresh = () => {
        this.setState({ refreshing: true }, () => {
          refreshFunction(this.props)
        })
      }

      render = () => <TheirComponent {...this.props} refresh={this.refresh} refreshing={this.state.refreshing} />
    }

    return hoistStatics(Refreshed, TheirComponent)
  }
}
