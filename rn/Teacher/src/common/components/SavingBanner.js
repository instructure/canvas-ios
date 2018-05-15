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
import {
  View,
  Text,
  ActivityIndicator,
  StyleSheet,
} from 'react-native'
import i18n from 'format-message'

export type SavingBannerProps = {
  title?: string,
  style?: Object | number,
}

export default class SavingBanner extends PureComponent<SavingBannerProps, any> {
  render () {
    const title = this.props.title || i18n('Saving...')
    return (<View style={[style.container, this.props.style]}>
      <Text style={style.text}>{title}</Text>
      <ActivityIndicator style={style.activityIndicator}/>
    </View>)
  }
}

var style = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 10,
  },
  text: {
    marginRight: 5,
    fontSize: 17,
  },
  activityIndicator: {
    marginLeft: 5,
  },
})
