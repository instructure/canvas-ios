//
// Copyright (C) 2017-present Instructure, Inc.
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
  FlatList,
  View,
  StyleSheet,
} from 'react-native'
import { Text, SubTitle } from '../../common/text'
import Screen from '../../routing/Screen'
import ActivityIndicatorView from '../../common/components/ActivityIndicatorView'
import ErrorView from '../../common/components/ErrorView'
import Avatar from '../../common/components/Avatar'
import colors from '../../common/colors'
import i18n from 'format-message'
import Images from '../../images'
import UserSubmissionRow from './UserSubmissionRow'
import RowSeparator from '../../common/components/rows/RowSeparator'
import { graphql } from 'react-apollo'
import query from '../../canvas-api-v2/queries/ContextCard.js'
import _ from 'lodash'
import * as app from '../app'

type ContextCardOwnProps = {
  courseID: string,
  userID: string,
  navigator: Navigator,
}

type ContextCardDataProps = {
  user: ?User,
  course: ?Course,
  enrollment: ?Enrollment,
  submissions: SubmissionV2[],
  courseColor: string,
  loading: boolean,
  permissions: {
    sendMessages: boolean,
    viewAllGrades: boolean,
    viewAnalytics: boolean,
  },
}

type ContextCardProps = ContextCardOwnProps & ContextCardDataProps

export class ContextCard extends Component<ContextCardProps> {
  renderHeader () {
    const { course, user, enrollment, isStudent, permissions = {} } = this.props
    let sectionName
    if (enrollment) {
      const section = enrollment.section
      if (section) {
        sectionName = section.name
      }
    }

    let grade: ?string
    if (enrollment && enrollment.grades && (enrollment.grades.current_grade || enrollment.grades.current_score != null)) {
      grade = enrollment.grades.current_grade || i18n.number(enrollment.grades.current_score / 100, 'percent')
    }

    let overrideGrade: ?string
    if (enrollment && enrollment.grades && (enrollment.grades.override_grade || enrollment.grades.override_score != null)) {
      overrideGrade = enrollment.grades.override_grade || i18n.number(enrollment.grades.override_score / 100, 'percent')
    }

    return (
      <View style={styles.header}>
        <View style={styles.headerSection}>
          <View style={styles.user}>
            <Avatar
              avatarURL={user.avatar_url}
              userName={user.name}
              height={80}
            />
            <View style={styles.userText}>
              <Text style={styles.userName}>{user.name}</Text>
              { user.primary_email &&
                <SubTitle>{user.primary_email}</SubTitle>
              }
            </View>
          </View>
          <View>
            <Text style={styles.heading}>{course.name}</Text>
            { sectionName && <Text testID='context-card.section-name' style={{ marginVertical: 4, fontSize: 14 }}>{i18n('Section: {sectionName}', { sectionName })}</Text> }
            {enrollment && enrollment.last_activity_at && !app.isStudent() &&
              <SubTitle testID='context-card.last-activity'>
                {i18n(`Last activity on {lastActivity, date, 'MMMM d'} at {lastActivity, time, short}`, {
                  lastActivity: new Date(enrollment.last_activity_at),
                })}
              </SubTitle>
            }
          </View>
        </View>
        {isStudent && ((permissions.viewAnalytics && user.analytics) || (enrollment && enrollment.grades)) &&
          <View style={styles.headerSection}>
            <Text style={[styles.heading, { marginBottom: 16 }]}>{i18n('Submissions')}</Text>
            <View style={styles.line}>
              <View
                accessible={true}
                style={styles.analyticsGroup}
                accessibilityLabel={i18n('Grade {grade}', { grade })}
              >
                <Text testID='context-card.grade' style={styles.largeText}>{grade}</Text>
                <Text style={styles.label}>{i18n('Grade')}</Text>
              </View>
              { overrideGrade &&
                <View
                  accessible={true}
                  style={styles.analyticsGroup}
                  accessibilityLabel={i18n('Override Grade {grade}', { grade: overrideGrade })}
                >
                  <Text testID='context-card.override-grade' style={styles.largeText}>{overrideGrade}</Text>
                  <Text style={styles.label}>{i18n('Override')}</Text>
                </View>
              }
              { user.analytics &&
                <View
                  accessible={true}
                  style={styles.analyticsGroup}
                  accessibilityLabel={i18n('Late Submissions {late, number}', {
                    late: user.analytics.tardinessBreakdown.late,
                  })}
                >
                  <Text style={styles.largeText}>{i18n.number(user.analytics.tardinessBreakdown.late)}</Text>
                  <Text style={styles.label}>{i18n('Late')}</Text>
                </View>
              }
              { user.analytics &&
                <View
                  accessible={true}
                  style={styles.analyticsGroup}
                  accessibilityLabel={i18n('Missing Submissions {missing, number}', {
                    missing: user.analytics.tardinessBreakdown.missing,
                  })}
                >
                  <Text style={styles.largeText}>{i18n.number(user.analytics.tardinessBreakdown.missing)}</Text>
                  <Text style={styles.label}>{i18n('Missing')}</Text>
                </View>
              }
            </View>
          </View>
        }
      </View>
    )
  }

  renderItem = ({ item: submission, index }: { item: SubmissionV2, index: number }) => {
    return (
      <UserSubmissionRow
        tintColor='#00BCD5'
        assignment={submission.assignment}
        submission={submission}
        user={this.props.user}
        onPress={this._navigateToSpeedGrader}
      />
    )
  }

  render () {
    const { course, user, submissions, isStudent, permissions = {} } = this.props

    const screenProps = {
      rightBarButtons: permissions.sendMessages || isStudent === false ? [{
        action: this._emailContact,
        image: Images.smallMail,
        testID: 'context-card.email-contact',
        accessibilityLabel: i18n('Send message'),
      }] : [],
      navBarStyle: this.props.navigator.isModal ? undefined : 'dark',
    }

    if (this.props.loading && !this.props.course) {
      return <Screen {...screenProps }><ActivityIndicatorView /></Screen>
    }

    if (this.props.error) {
      return <Screen {...screenProps }><ErrorView error={this.props.error} /></Screen>
    }

    return (
      <Screen
        title={user.name}
        subtitle={course.name}
        {...screenProps }
      >
        <FlatList
          ListHeaderComponent={this.renderHeader()}
          data={isStudent && permissions.viewAllGrades ? submissions : []}
          renderItem={this.renderItem}
          keyExtractor={this._keyExtractor}
          ItemSeparatorComponent={RowSeparator}
        />
      </Screen>
    )
  }

  _keyExtractor = (item: Object, index: number) => `${index}`

  _emailContact = () => {
    const { course, user } = this.props
    if (course && user) {
      let recipients = [user]
      const contextName = course.name
      const contextCode = `course_${course.id}`
      this.props.navigator.show('/conversations/compose', { modal: true }, { contextName, contextCode, recipients, canSelectCourse: false })
    }
  }

  _navigateToSpeedGrader = (assignment: Assignment) => {
    const user = this.props.user
    let filter = (submissions: any) => submissions.filter((s) => s.userID === user.id)

    let url = `${assignment.html_url}/submissions/${user.id}`
    this.props.navigator.show(url, { modal: true, modalPresentationStyle: 'fullscreen' }, {
      studentIndex: 0,
      filter,
    })
  }
}

const styles = StyleSheet.create({
  header: {
    paddingTop: 8,
  },
  headerSection: {
    padding: 16,
    borderBottomColor: colors.seperatorColor,
    borderBottomWidth: StyleSheet.hairlineWidth,
  },
  user: {
    display: 'flex',
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 24,
  },
  userText: {
    marginLeft: 12,
  },
  userName: {
    fontSize: 28,
    lineHeight: 34,
  },
  line: {
    flexDirection: 'row',
  },
  heading: {
    fontSize: 18,
    fontWeight: '600',
  },
  largeText: {
    fontSize: 28,
    fontWeight: '800',
    color: colors.darkText,
    flex: 1,
  },
  label: {
    fontSize: 14,
    fontWeight: '600',
    color: colors.darkText,
  },
  textWrapper: {
    flex: 1,
  },
  outOf: {
    fontSize: 12,
    color: colors.lightText,
    top: -3,
    fontWeight: '600',
  },
  analyticsGroup: {
    flex: 1,
  },
})

export function props (props: any) {
  const data = props.data
  if (data.error) {
    return { error: data.error }
  }

  const course = data.course
  const user = _.get(course, 'users.edges[0].user')

  if (!course || !user) {
    if (data.loading) {
      return { loading: true }
    } else {
      return { error: Error(i18n('There was an unexepected error.')) }
    }
  }

  const enrollment = _.get(user, 'enrollments[0]') || {}
  const submissions = (_.get(course, 'submissions.edges') || []).map(e => e.submission).filter(Boolean)
  const isStudent = enrollment.type === 'StudentEnrollment'
  const permissions = course.permissions || {}

  return { course, user, enrollment, submissions, isStudent, permissions, loading: data.loading }
}

export default graphql(query, {
  options: ({ courseID, userID }) => ({ variables: { courseID, userID, limit: 20 } }),
  fetchPolicy: 'cache-and-network',
  props,
})(ContextCard)
