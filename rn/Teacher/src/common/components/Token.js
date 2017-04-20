// @flow

import React from 'react'
import {
  StyleSheet,
} from 'react-native'
import { Text } from '../../common/text'

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
    fontWeight: '500',
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
