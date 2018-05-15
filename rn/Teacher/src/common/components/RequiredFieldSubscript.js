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

/**
 * @flow
 */

import React from 'react'
import { UnmetRequirementSubscriptText } from '../text'
import {
  View,
  StyleSheet,
  LayoutAnimation,
} from 'react-native'

type Props = {
  title: ?string,
  visible: boolean,
  testID?: string,
}

export default class RequiredFieldSubscript extends React.Component<Props> {
  componentWillUpdate () {
    LayoutAnimation.easeInEaseOut()
  }

  render () {
    if (this.props.visible) {
      return (
        <View style={styles.visible}>
          <UnmetRequirementSubscriptText style={styles.subscript} testID={this.props.testID}>{this.props.title}</UnmetRequirementSubscriptText>
        </View>
      )
    } else {
      return (<View/>)
    }
  }
}

const styles = StyleSheet.create({
  visible: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'flex-start',
    alignItems: 'stretch',
    backgroundColor: '#F5F5F5',
  },
  subscript: {
    marginTop: global.style.defaultPadding / 4,
    marginHorizontal: global.style.defaultPadding,
  },
})
