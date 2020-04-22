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
  Image,
  TouchableHighlight,
} from 'react-native'
import DisclosureIndicator from '../../../common/components/DisclosureIndicator'
import Token from '../../../common/components/Token'
import i18n from 'format-message'
import { colors, createStyleSheet } from '../../../common/stylesheet'
import { Text } from '../../../common/text'
import SubmissionStatusLabel from './SubmissionStatusLabel'
import Avatar from '../../../common/components/Avatar'
import { formatGradeText, personDisplayName } from '../../../common/formatters'
import images from '../../../images'

type RowProps = {
  testID: string,
  onPress: () => void,
  children?: Array<any>,
  disclosure?: boolean,
}

export type SubmissionRowDataProps = {
  groupID?: string,
  user: {
    id: string,
    avatarUrl: string,
    name: string,
  },
  gradingType: GradingType,
  disclosure?: boolean,
  disabled?: boolean,
  submission: Object,
}

export type SubmissionRowProps = {
  onPress: (userID: string) => any,
  onAvatarPress?: Function,
  anonymous: boolean,
} & SubmissionRowDataProps

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

export const Grade = ({ submission, gradingType }) => {
  let gradeText = submission.grade

  if (submission == null || submission.state === 'unsubmitted' || submission.gradingStatus === 'needs_grading') {
    gradeText = '--'
  } else if (submission.excused) {
    gradeText = i18n('Excused')
  } else {
    gradeText = formatGradeText({ grade: submission.grade, score: submission.score, gradingType })
  }

  return <Text style={[ styles.gradeText, { alignSelf: 'center' } ]}>{ gradeText }</Text>
}

class SubmissionRow extends Component<SubmissionRowProps, any> {
  onPress = () => {
    // $FlowFixMe
    this.props.onPress(this.props.user.id)
  }

  onAvatarPress = () => {
    if (this.props.onAvatarPress) {
      this.props.onAvatarPress(this.props.user.id)
    }
  }

  render () {
    let { user, group, submission, gradingType } = this.props
    let contextID = group?.id ?? user?.id
    let name = group?.name ?? personDisplayName(user?.name, user?.pronouns)
    let avatarName = group?.name ?? user?.name
    let avatarURL = user.avatarUrl

    if (this.props.anonymous) {
      let anonymousName = group != null ? i18n('Group') : i18n('Student')
      name = anonymousName
      avatarName = anonymousName
      avatarURL = null
    }

    return (
      <Row testID={`submission-${contextID}`} onPress={this.onPress}>
        <View style={styles.avatar}>
          <Avatar
            key={contextID}
            avatarURL={avatarURL}
            userName={avatarName}
            onPress={!this.props.anonymous && this.props.onAvatarPress && this.onAvatarPress}
          />
        </View>
        <View style={styles.textContainer}>
          <Text
            style={styles.title}
            ellipsizeMode='tail'
            numberOfLines={2}>{name}</Text>
          {gradingType !== 'not_graded' &&
            <SubmissionStatusLabel submission={submission} />
          }
          {submission.gradingStatus === 'needs_grading' &&
            <Token style={{ alignSelf: 'flex-start', marginTop: 8 }} color={ colors.textInfo }>
              {i18n('Needs Grading')}
            </Token>
          }
        </View>
        <Grade submission={submission} gradingType={gradingType} />
        {submission.grade != null && submission.postedAt == null &&
          <Image
            source={images.off}
            testID='SubmissionRow.hiddenIcon'
            style={{ tintColor: colors.textDanger, height: 20, width: 20, marginLeft: 10 }}
          />
        }
      </Row>
    )
  }
}

export default SubmissionRow

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
