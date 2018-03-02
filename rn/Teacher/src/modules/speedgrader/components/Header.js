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
import { connect } from 'react-redux'
import {
  View,
  StyleSheet,
  TouchableHighlight,
} from 'react-native'
import { Text } from '../../../common/text'
import i18n from 'format-message'
import type {
  SubmissionDataProps,
} from '../../submissions/list/submission-prop-types'
import SubmissionStatusLabel from '../../submissions/list/SubmissionStatusLabel'
import Avatar from '../../../common/components/Avatar'

export class Header extends Component<HeaderProps, State> {
  state: State = {
    showingPicker: false,
  }

  navigateToContextCard = () => {
    this.props.navigator.show(
      `/courses/${this.props.courseID}/users/${this.props.userID}`,
      { modal: true }
    )
  }

  renderDoneButton () {
    return (
      <View style={styles.doneButton}>
        <TouchableHighlight onPress={this.props.closeModal} underlayColor='white' testID='header.navigation-done'>
          <View style={{ paddingLeft: 20 }}>
            <Text style={{ color: '#008EE2', fontSize: 18, fontWeight: '600' }}>
              {i18n('Done')}
            </Text>
          </View>
        </TouchableHighlight>
      </View>
    )
  }

  renderGroupProfile () {
    const sub = this.props.submissionProps
    let name = this.props.anonymous
      ? (sub.groupID ? i18n('Group') : i18n('Student'))
      : sub.name

    let avatarURL = this.props.anonymous
      ? ''
      : sub.avatarURL

    let action = this.navigateToContextCard
    let testID = 'header.context.button'
    if (sub.groupID && !this.props.anonymous) {
      action = this.showGroup
      testID = 'header.groupList.button'
    }

    return (
      <View style={styles.profileContainer}>
        <View style={styles.innerRowContainer}>
          <TouchableHighlight
            onPress={action}
            underlayColor='white'
            testID={testID}
          >
            <View style={styles.innerRowContainer}>
              <View style={styles.avatar}>
                <Avatar
                  key={sub.userID}
                  avatarURL={avatarURL}
                  userName={name}
                />
              </View>
              <View style={styles.nameContainer}>
                <Text style={styles.name} accessibilityTraits='header'>{name}</Text>
                <SubmissionStatusLabel status={sub.status} />
              </View>
            </View>
          </TouchableHighlight>
        </View>
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
      `/groups/${this.props.submissionProps.groupID}/users`,
      { modal: true },
      { courseID: this.props.courseID }
    )
  }
}

const styles = StyleSheet.create({
  header: {
    backgroundColor: 'white',
  },
  profileContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 16,
  },
  innerRowContainer: {
    backgroundColor: 'white',
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  navButtonImage: {
    resizeMode: 'contain',
    tintColor: '#008EE2',
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
  doneButton: {
    backgroundColor: 'white',
    marginRight: 12,
  },
})

export function mapStateToProps (state: AppState, ownProps: RouterProps) {
  const entities = state.entities
  const { courseID, assignmentID } = ownProps

  const assignmentContent = entities.assignments[assignmentID]
  const assignmentData = assignmentContent ? assignmentContent.data : null
  let quiz
  if (assignmentData && assignmentData.quiz_id && entities.quizzes[assignmentData.quiz_id]) {
    quiz = entities.quizzes[assignmentData.quiz_id].data
  }
  const courseContent = state.entities.courses[courseID]
  const anonymous = assignmentContent.anonymousGradingOn ||
                  quiz && quiz.anonymous_submissions ||
                  courseContent && courseContent.enabledFeatures.includes('anonymous_grading')
  return {
    anonymous,
  }
}

let Connected = connect(mapStateToProps)(Header)
export default (Connected: any)

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
