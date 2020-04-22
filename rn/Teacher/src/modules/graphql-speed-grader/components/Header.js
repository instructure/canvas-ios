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
import { Text } from '../../../common/text'
import i18n from 'format-message'
import type {
  SubmissionDataProps,
} from '../../submissions/list/submission-prop-types'
import SubmissionStatusLabel from '../../submissions/list/SubmissionStatusLabel'
import Avatar from '../../../common/components/Avatar'
import { colors, createStyleSheet } from '../../../common/stylesheet'
import icon from '../../../images/inst-icons'

export default class Header extends Component<HeaderProps, State> {
  state: State = {
    showingPicker: false,
  }

  navigateToContextCard = () => {
    this.props.navigator.show(
      `/courses/${this.props.courseID}/users/${this.props.userID}`,
      { modal: true }
    )
  }

  navigateToPostPolicies = () => {
    this.props.navigator.show(`/courses/${this.props.courseID}/assignments/${this.props.assignmentID}/post_policy`, {
      modal: true,
    })
  }

  renderDoneButton () {
    return (
      <View style={styles.barButton}>
        <TouchableHighlight onPress={this.props.closeModal} underlayColor={colors.backgroundLightest} testID='header.navigation-done'>
          <Text style={{ color: colors.linkColor, fontSize: 18, fontWeight: '600' }}>
            {i18n('Done')}
          </Text>
        </TouchableHighlight>
      </View>
    )
  }

  renderEyeBall () {
    return (
      <View style={styles.barButton}>
        <TouchableHighlight onPress={this.navigateToPostPolicies} underlayColor={colors.backgroundLightest} testID='header.navigation-eye'>
          <View style={{ paddingLeft: 20 }}>
            <Image source={icon('eye', 'line')} style={styles.eyeIcon} />
          </View>
        </TouchableHighlight>
      </View>
    )
  }

  renderGroupProfile () {
    const submission = this.props.submission

    let name, avatarURL
    if (this.props.anonymousGrading) {
      name = this.props.group != null ? i18n('Group') : i18n('Student')
      avatarURL = ''
    } else if (this.props.group != null) {
      name = this.props.group.name
      avatarURL = ''
    } else {
      name = submission.user.name
      avatarURL = submission.user.avatarUrl
    }

    let action = this.navigateToContextCard
    let testID = 'header.context.button'
    if (this.props.group != null && !this.props.anonymousGrading) {
      action = this.showGroup
      testID = 'header.groupList.button'
    }

    return (
      <View style={styles.profileContainer}>
        <View style={styles.innerRowContainer}>
          <TouchableHighlight
            onPress={action}
            underlayColor={colors.backgroundLightest}
            testID={testID}
          >
            <View style={styles.innerRowContainer}>
              <View style={styles.avatar}>
                <Avatar
                  key={submission.user.id}
                  avatarURL={avatarURL}
                  userName={name}
                />
              </View>
              <View style={styles.nameContainer}>
                <Text style={styles.name} accessibilityTraits='header'>{name}</Text>
                <SubmissionStatusLabel submission={submission} />
              </View>
            </View>
          </TouchableHighlight>
        </View>
        {this.renderEyeBall()}
        {this.renderDoneButton()}
      </View>
    )
  }

  render () {
    return (
      <View style={[this.props.style, styles.header]}>
        {this.renderGroupProfile()}
      </View>
    )
  }

  showGroup = () => {
    this.props.navigator.show(
      `/groups/${this.props.group.id}/users`,
      { modal: true },
      { courseID: this.props.courseID }
    )
  }
}

const styles = createStyleSheet(colors => ({
  header: {
    backgroundColor: colors.backgroundLightest,
    marginTop: 16,
  },
  profileContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  innerRowContainer: {
    backgroundColor: colors.backgroundLightest,
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  navButtonImage: {
    resizeMode: 'contain',
    tintColor: colors.textInfo,
  },
  avatar: {
    width: 40,
    height: 40,
    marginLeft: 16,
  },
  nameContainer: {
    flexDirection: 'column',
    justifyContent: 'space-between',
    marginLeft: 12,
  },
  name: {
    fontSize: 16,
    fontWeight: '600',
  },
  status: {
    fontSize: 14,
  },
  barButton: {
    backgroundColor: colors.backgroundLightest,
    marginRight: 12,
  },
  eyeIcon: {
    width: 20,
    height: 20,
    tintColor: colors.textDark,
  },
}))

type RouterProps = {
  courseID: string,
  assignmentID: string,
  userID: string,
  submissionID: ?string,
  submissionProps: SubmissionDataProps,
  closeModal: Function,
  style?: Object,
}

type State = {
  showingPicker: boolean,
}

type HeaderDataProps = {
  anonymous: boolean,
}

type HeaderProps = RouterProps & HeaderDataProps & { navigator: Navigator }
