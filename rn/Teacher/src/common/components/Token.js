//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

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
    textAlign: 'center',
  },
})

export default Token
