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
  FlatList,
  View,
  StyleSheet,
} from 'react-native'
import { Text, SubTitle, Heading1 } from '../../common/text'
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
}

type ContextCardProps = ContextCardOwnProps & ContextCardDataProps

export class ContextCard extends Component< ContextCardProps, any> {
  renderHeader () {
    const { course, user, enrollment, isStudent, canViewAnalytics } = this.props
    let sectionName
    if (enrollment) {
      const section = enrollment.section
      if (section) {
        sectionName = section.name
      }
    }

    let grade: ?string
    if (enrollment && enrollment.grades && enrollment.grades.current_grade) {
      grade = enrollment.grades.current_grade
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
            </View>
          </View>
          <View>
            <Heading1>{course.name}</Heading1>
            { sectionName && <Text testID='context-card.section-name' style={{ marginVertical: 4, fontSize: 14 }}>{i18n('Section: {sectionName}', { sectionName })}</Text> }
            <SubTitle testID='context-card.last-activity'>
              {enrollment && i18n(`Last activity on {lastActivity, date, 'MMMM d'} at {lastActivity, time, short}`, {
                lastActivity: new Date(enrollment.last_activity_at),
              })}
            </SubTitle>
          </View>
        </View>
        {isStudent && canViewAnalytics && user.analytics && enrollment && enrollment.grades &&
          <View style={styles.headerSection}>
            <Heading1 style={{ marginBottom: 16 }}>{i18n('Submissions')}</Heading1>
            <View style={styles.line}>
              <View
                accessible={true}
                style={styles.analyticsGroup}
                accessibilityLabel={grade
                  ? i18n('Grade {grade}', { grade })
                  : i18n('Grade {grade, number, percent}', { grade: enrollment.grades.current_score / 100 })
                }
              >
                <Text testID='context-card.grade' style={styles.largeText}>{grade || i18n.number(enrollment.grades.current_score / 100, 'percent')}</Text>
                <Text style={styles.label}>{i18n('Grade')}</Text>
              </View>
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
    const screenProps = {
      rightBarButtons: [{
        action: this._emailContact,
        image: Images.smallMail,
        testID: 'context-card.email-contact',
        accessibilityLabel: i18n('Email Contact'),
      }],
      navBarStyle: this.props.navigator.isModal ? undefined : 'dark',
    }

    if (this.props.loading && !this.props.course) {
      return <Screen {...screenProps }><ActivityIndicatorView /></Screen>
    }

    if (this.props.error) {
      return <Screen {...screenProps }><ErrorView error={this.props.error} /></Screen>
    }

    const { course, user, submissions, isStudent, canViewGrades } = this.props

    return (
      <Screen
        title={user.name}
        subtitle={course.name}
        {...screenProps }
      >
        <FlatList
          ListHeaderComponent={this.renderHeader()}
          data={isStudent && canViewGrades ? submissions : []}
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
  largeText: {
    fontSize: 28,
    fontWeight: '700',
    color: colors.darkText,
    flex: 1,
  },
  largeTextTitle: {
    fontWeight: '500',
  },
  textWrapper: {
    flex: 1,
  },
  label: {
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
  const canViewAnalytics = permissions.viewAnalytics
  const canViewGrades = permissions.viewAllGrades

  return { course, user, enrollment, submissions, isStudent, canViewAnalytics, canViewGrades, loading: data.loading }
}

export default graphql(query, {
  options: ({ courseID, userID }) => ({ variables: { courseID, userID, limit: 20 } }),
  fetchPolicy: 'cache-and-network',
  props,
})(ContextCard)
