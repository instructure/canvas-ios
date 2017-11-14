// @flow

import React, { Component } from 'react'
import { requireNativeComponent, Platform, View } from 'react-native'

const DropViewNative = requireNativeComponent('DropView', null)

type BaseProps = {
  children?: any,
}
type DataProps = { dragItem: string } | { dragItems: string[] }
export type Props = BaseProps & DataProps

export default class DragView extends Component<Props, any> {
  render () {
    let { children, ...rest } = this.props

    // Ensure that we are on iOS 11+
    let validPlatform = false
    if (Platform.OS === 'ios') {
      const majorVersionIOS = parseInt(Platform.Version, 10)
      if (majorVersionIOS >= 11) {
        validPlatform = true
      }
    }
    if (!validPlatform) {
      console.warn('DropView can only be used on iOS 11+')
      return <View {...rest}>
              { children }
             </View>
    }

    // Finally, return the view with the child inside it
    return (
      <DropViewNative {...rest}>
        { children }
      </DropViewNative>
    )
  }
}
