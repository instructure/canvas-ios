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

import React, { Component } from 'react'
import {
  View,
  TouchableHighlight,
} from 'react-native'
import DisclosureIndicator from '../../../common/components/DisclosureIndicator'
import Token from '../../../common/components/Token'
import i18n from 'format-message'
import type {
  GradeProp,
} from './submission-prop-types'
import { colors, createStyleSheet } from '../../../common/stylesheet'
import { Text } from '../../../common/text'
import OldSubmissionStatusLabel from './OldSubmissionStatusLabel'
import Avatar from '../../../common/components/Avatar'
import { formatGradeText } from '../../../common/formatters'

type RowProps = {
  testID: string,
  onPress: () => void,
  children?: Array<any>,
  disclosure?: boolean,
}

export type OldSubmissionRowDataProps = {
  userID: string,
  groupID?: string,
  avatarURL: string,
  name: string,
  status: ?SubmissionStatus,
  grade: ?GradeProp,
  gradingType: GradingType,
  score: ?number,
  disclosure?: boolean,
  disabled?: boolean,
}

export type OldSubmissionRowProps = {
  onPress: (userID: string) => any,
  onAvatarPress?: Function,
  anonymous: boolean,
} & OldSubmissionRowDataProps

class Row extends Component<RowProps, any> {
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

export const Grade = ({ grade, score, gradingType }) => {
  if (!grade || grade === 'not_submitted' || grade === 'ungraded' || gradingType === 'not_graded') {
    return null
  }

  let gradeText = grade
  if (grade === 'excused') {
    gradeText = i18n('Excused')
  } else {
    gradeText = formatGradeText({ grade, score, gradingType })
  }

  return <Text style={[ styles.gradeText, { alignSelf: 'center' } ]}>{ gradeText }</Text>
}

class OldSubmissionRow extends Component<OldSubmissionRowProps, any> {
  onPress = () => {
    // $FlowFixMe
    this.props.onPress(this.props.userID)
  }

  onAvatarPress = () => {
    if (this.props.onAvatarPress) {
      this.props.onAvatarPress(this.props.userID)
    }
  }

  render () {
    let { userID, avatarURL, name, status, grade, score, gradingType, disclosure } = this.props
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
          {status && gradingType !== 'not_graded' &&
            <OldSubmissionStatusLabel status={status} />
          }
          {grade === 'ungraded' && gradingType !== 'not_graded' &&
            <Token style={{ alignSelf: 'flex-start', marginTop: 8 }} color={ colors.textInfo }>
              {i18n('Needs Grading')}
            </Token>
          }
        </View>
        <Grade grade={grade} score={score} gradingType={gradingType} />
      </Row>
    )
  }
}

export default OldSubmissionRow

const styles = createStyleSheet(colors => ({
  touchableHighlight: {
    flex: 1,
  },
  container: {
    flex: 1,
    backgroundColor: colors.backgroundLightest,
    alignItems: 'center',
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
    fontSize: 16,
    fontWeight: '600',
    color: colors.textDarkest,
  },
  gradeText: {
    fontSize: 14,
    fontWeight: '600',
    color: colors.textDarkest,
  },
  avatar: {
    width: 40,
    height: 40,
    marginRight: 8,
  },
}))
