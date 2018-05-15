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

import React, { PureComponent } from 'react'
import { View, StyleSheet, Image } from 'react-native'
import { Title } from '../text'

export type ListEmptyComponentProps = {
  title: string,
  image?: any,
}

export default class ListEmptyComponent extends PureComponent<ListEmptyComponentProps, any> {
  render () {
    return <View style={styles.container}>
      <Title>{this.props.title}</Title>
      { this.props.image && <Image source={this.props.image} /> }
    </View>
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    height: 100,
  },
})
