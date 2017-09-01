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
  View,
  StyleSheet,
  TouchableHighlight,
} from 'react-native'
import DisclosureIndicator from '../../../common/components/DisclosureIndicator'
import Token from '../../../common/components/Token'
import i18n from 'format-message'
import type {
  GradeProp,
  SubmissionStatusProp,
} from './submission-prop-types'
import colors from '../../../common/colors'
import { Text } from '../../../common/text'
import SubmissionStatus from './SubmissionStatus'
import Avatar from '../../../common/components/Avatar'
import { formatGradeText } from '../../../common/formatters'

type RowProps = {
  testID: string,
  onPress: () => void,
  children?: Array<any>,
  disclosure?: boolean,
}

export type SubmissionRowDataProps = {
  userID: string,
  groupID?: string,
  avatarURL: string,
  name: string,
  status: SubmissionStatusProp,
  grade: GradeProp,
  score: ?number,
  disclosure?: boolean,
  anonymous: boolean,
}

export type SubmissionRowProps = {
  onPress: () => void,
  onAvatarPress?: Function,
} & SubmissionRowDataProps

class Row extends Component<any, RowProps, any> {
  render () {
    const { onPress, testID, children, disclosure } = this.props
    return (
      <View>
        <TouchableHighlight style={styles.touchableHighlight} onPress={onPress} testID={testID} accessibilityTraits={['button']}>
          <View style={styles.container}>
            {children}
            {disclosure && <DisclosureIndicator />}
          </View>
        </TouchableHighlight>
      </View>
    )
  }
}

const Grade = ({ grade }: {grade: ?GradeProp}): * => {
  if (!grade || grade === 'not_submitted') {
    return null
  }

  if (grade === 'ungraded') {
    const ungraded = i18n('Needs Grading')
    return <Token style={{ flex: 0.5, alignSelf: 'center' }} color={ colors.primaryButton }>{ ungraded }</Token>
  }

  let gradeText = grade
  if (grade === 'excused') {
    gradeText = i18n('Excused')
  } else {
    gradeText = formatGradeText(grade, 2)
  }

  return <Text style={[ styles.gradeText, { alignSelf: 'center' } ]}>{ gradeText }</Text>
}

class SubmissionRow extends Component<any, SubmissionRowProps, any> {
  onPress = () => {
    this.props.onPress(this.props.userID)
  }

  onAvatarPress = () => {
    if (this.props.onAvatarPress) {
      this.props.onAvatarPress(this.props.userID)
    }
  }

  render () {
    let { userID, avatarURL, name, status, grade, disclosure } = this.props
    if (disclosure === undefined) {
      disclosure = true
    }
    if (this.props.anonymous) {
      name = (this.props.groupID ? i18n('Group') : i18n('Student'))
      avatarURL = null
    }
    return (
      <Row disclosure={disclosure} testID={`submission-${userID}`} onPress={this.onPress}>
        <View style={styles.avatar}>
          <Avatar
            key={userID}
            avatarURL={avatarURL}
            userName={name}
            onPress={this.props.onAvatarPress && this.onAvatarPress}
          />
        </View>
        <View style={styles.textContainer}>
          <Text
            style={styles.title}
            ellipsizeMode='tail'
            numberOfLines={2}>{name}</Text>
          <SubmissionStatus status={status} />
        </View>
        <Grade grade={grade} />
      </Row>
    )
  }
}

export default SubmissionRow

const styles = StyleSheet.create({
  touchableHighlight: {
    flex: 1,
  },
  container: {
    flex: 1,
    backgroundColor: 'white',
    alignItems: 'flex-start',
    flexDirection: 'row',
    paddingTop: 10,
    paddingBottom: 10,
    paddingLeft: 16,
    paddingRight: 16,
  },
  textContainer: {
    flex: 1,
    paddingLeft: 8,
  },
  title: {
    flex: 1,
    fontSize: 16,
    fontWeight: '600',
    color: '#2D3B45',
  },
  gradeText: {
    fontSize: 14,
    fontWeight: '600',
    color: colors.primaryButtonColor,
  },
  avatar: {
    width: 40,
    height: 40,
    marginRight: 8,
  },
})
