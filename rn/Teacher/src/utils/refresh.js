// @flow

import React, { Component } from 'react'
import hoistStatics from 'hoist-non-react-statics'

type RefreshFunction = (*) => *
type ShouldRefresh = (*) => boolean
type IsFetchingData = (*) => boolean

export default function refresh (
    refreshFunction: RefreshFunction,
    shouldRefresh: ShouldRefresh,
    isFetchingData: IsFetchingData
  ): * {
  return function (TheirComponent) {
    class Refreshed extends Component {
      state: RefreshState
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
        refreshFunction(this.props)
        this.setState({ refreshing: true })
      }

      render = () => <TheirComponent {...this.props} refresh={this.refresh} refreshing={this.state.refreshing} />
    }

    return hoistStatics(Refreshed, TheirComponent)
  }
}
