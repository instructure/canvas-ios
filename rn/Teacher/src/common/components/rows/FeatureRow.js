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

import React, { Component } from 'react'
import {
  StyleSheet,
  View,
} from 'react-native'

import Row, { type RowProps } from './Row'

export default class FeatureRow extends Component<RowProps, any> {
  render () {
    return (
      <View style={style.container}>
        <View style={style.shadow}>
          <View style={style.innerContainer}>
            <Row
              titleStyles={style.title}
              subtitleStyles={style.subtitle}
              {...this.props}
            />
          </View>
        </View>
      </View>
    )
  }
}

const style = StyleSheet.create({
  container: {
    paddingTop: 16,
    paddingBottom: 8,
    paddingLeft: 16,
    paddingRight: 16,
  },
  shadow: {
    shadowColor: '#000',
    shadowRadius: 3,
    shadowOpacity: 0.3,
    shadowOffset: {
      width: 0,
      height: 1,
    },
    borderRadius: 4,
  },
  innerContainer: {
    borderColor: '#e3e3e3',
    borderWidth: StyleSheet.hairlineWidth,
    borderRadius: 4,
    overflow: 'hidden',
    flex: 1,
    backgroundColor: 'white',
  },
  title: {
    fontSize: 24,
    fontWeight: '400',
  },
  subtitle: {
    fontWeight: '600',
  },
})

