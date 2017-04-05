// @flow

import React from 'react'
import {
  Text,
  StyleSheet,
} from 'react-native'

type TokenProps = {
  +style?: any,
  +children?: string,
  +color: string,
}

const Token = (props: TokenProps): * => {
  let {
    style,
    children,
    color,
  } = props

  return (
    <Text {...props} style={[styles.token, { color, borderColor: color }, style]}>
      {children && children.toUpperCase()}
    </Text>
  )
}

const styles = StyleSheet.create({
  token: {
    fontSize: 11,
    fontWeight: '600',
    borderRadius: 9,
    borderWidth: 1,
    backgroundColor: 'white',
    paddingTop: 3,
    paddingBottom: 0,
    paddingLeft: 6,
    paddingRight: 6,
    overflow: 'hidden',
  },
})

export default Token
