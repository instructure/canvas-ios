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
  TouchableHighlight,
  View,
  StyleSheet,
  Image,
} from 'react-native'
import i18n from 'format-message'
import Images from '../../../../images/'

type Props = {
  color: string,
  onPress: (color: string) => void,
  selected: boolean,
}

export default class ColorButton extends Component<Props> {
  onPress = () => {
    this.props.onPress(this.props.color)
  }

  render () {
    return (
      <TouchableHighlight
        style={styles.button}
        accessibilityLabel={i18n('Choose {color}', { color: this.props.color })}
        onPress={this.onPress}
        underlayColor='#fff'
        testID={`colorButton.${this.props.color}`}
      >
        <View
          style={[styles.color, { backgroundColor: this.props.color }]}
        >
          {this.props.selected &&
            <Image source={Images.check} />
          }
        </View>
      </TouchableHighlight>
    )
  }
}

const styles = StyleSheet.create({
  button: {
    height: 48,
    margin: 8,
  },
  color: {
    width: 48,
    height: 48,
    borderRadius: 24,
    alignItems: 'center',
    justifyContent: 'center',
  },
})
