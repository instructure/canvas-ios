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

import React, { Component } from 'react'
import {
  View,
  Image,
  TouchableHighlight,
} from 'react-native'

import { type Assignee } from './map-state-to-props'
import Images from '../../images'
import Button from 'react-native-button'
import { createStyleSheet } from '../../common/stylesheet'
import { Text } from '../../common/text'
import Avatar from '../../common/components/Avatar'

export type Props = {
  assignee: Assignee,
  onPress?: Function,
  onDelete?: Function,
}

export default class AssigneeRow extends Component<Props> {
  renderImage (): any {
    const assignee = this.props.assignee
    return (<View style={styles.imageContainer}>
      <Avatar
        key={assignee.id}
        avatarURL={assignee.imageURL}
        userName={assignee.name}
      />
    </View>)
  }

  onPress = () => {
    if (this.props.onPress) {
      this.props.onPress(this.props.assignee)
    }
  }

  onDelete = () => {
    if (this.props.onDelete) {
      this.props.onDelete(this.props.assignee)
    }
  }

  render () {
    const assignee = this.props.assignee
    const image = this.renderImage()

    return (<TouchableHighlight style={styles.touchable} onPress={this.onPress} >
      <View style={styles.container}>
        {image}
        <View style={styles.textContainer}>
          <Text numberOfLines={1} style={styles.assigneeName} testID={`AssigneeRow.${assignee.id}.name`}>
            {assignee.name}
          </Text>
          { assignee.info && <Text numberOfLines={1} style={styles.assigneeInfo}>{assignee.info}</Text> }
        </View>
        { this.props.onDelete && (<View style={styles.deleteButtonContainer}>
          <Button onPress={this.onDelete} style={styles.deleteButton}>
            <Image source={Images.x} />
          </Button>
        </View>) }
      </View>
    </TouchableHighlight>)
  }
}

const styles = createStyleSheet((colors, vars) => ({
  touchable: {
    flex: 1,
    height: 'auto',
    borderBottomWidth: vars.hairlineWidth,
    borderBottomColor: colors.borderMedium,
  },
  container: {
    flex: 1,
    backgroundColor: colors.backgroundGroupedCell,
    flexDirection: 'row',
    alignItems: 'center',
    paddingLeft: vars.padding,
    paddingRight: vars.padding,
    paddingVertical: vars.padding / 2,
  },
  textContainer: {
    flexDirection: 'column',
    justifyContent: 'center',
  },
  assigneeName: {
    color: colors.textDarkest,
    fontWeight: '600',
  },
  assigneeInfo: {
    fontSize: 14,
    color: colors.textDark,
  },
  imageContainer: {
    height: 40,
    width: 40,
    overflow: 'hidden',
    marginRight: vars.padding,
    borderRadius: 20,
  },
  deleteButtonContainer: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'flex-end',
    justifyContent: 'flex-end',
  },
  deleteButton: {
    flex: 0,
    height: 44,
    width: 44,
  },
}))
