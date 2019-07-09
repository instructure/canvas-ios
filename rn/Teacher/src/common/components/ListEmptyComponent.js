//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
