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

/**
 * @flow
 */

import React from 'react'
import { UnmetRequirementSubscriptText } from '../text'
import {
  View,
  LayoutAnimation,
} from 'react-native'
import { createStyleSheet } from '../stylesheet'

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

const styles = createStyleSheet((colors, vars) => ({
  visible: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'flex-start',
    alignItems: 'stretch',
    backgroundColor: colors.backgroundGrouped,
  },
  subscript: {
    marginTop: vars.padding / 4,
    marginHorizontal: vars.padding,
  },
}))
