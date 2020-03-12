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
  FlatList,
  View,
} from 'react-native'
import { Text, SubTitle } from '../../common/text'
import Screen from '../../routing/Screen'
import ActivityIndicatorView from '../../common/components/ActivityIndicatorView'
import ErrorView from '../../common/components/ErrorView'
import Avatar from '../../common/components/Avatar'
import { createStyleSheet } from '../../common/stylesheet'
import i18n from 'format-message'
import Images from '../../images'
import UserSubmissionRow from './UserSubmissionRow'
import RowSeparator from '../../common/components/rows/RowSeparator'
import { graphql } from 'react-apollo'
import { courseQuery, groupQuery } from '../../canvas-api-v2/queries/ContextCard'
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
    const { context, user, enrollment, isStudent, permissions = {} } = this.props
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
              <Text testID='context-card.short-name' style={styles.userName}>{user.short_name}</Text>
              { user.primary_email &&
                <SubTitle>{user.primary_email}</SubTitle>
              }
            </View>
          </View>
          <View>
            <Text testID='context-card.context-name' style={styles.heading}>{context.name}</Text>
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
          <View testID='context-card.analytics' style={styles.headerSection}>
            <Text style={[styles.heading, { marginBottom: 16 }]}>{i18n('Submissions')}</Text>
            <View style={styles.line}>
              {grade &&
                <View
                  accessible={true}
                  style={styles.analyticsGroup}
                  accessibilityLabel={i18n('Grade {grade}', { grade })}
                >
                  <Text testID='context-card.grade' style={styles.largeText}>{grade}</Text>
                  <Text style={styles.label}>{i18n('Grade')}</Text>
                </View>
              }
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
    const { context, user, submissions, isStudent, permissions = {} } = this.props

    const screenProps = {
      rightBarButtons: permissions.sendMessages || isStudent === false ? [{
        action: this._emailContact,
        image: Images.smallMail,
        testID: 'context-card.email-contact',
        accessibilityLabel: i18n('Send message'),
      }] : [],
      navBarStyle: this.props.navigator.isModal ? 'modal' : 'context',
      navBarColor: this.props.navigator.isModal ? undefined : this.props.courseColor,
    }

    if (this.props.loading && !this.props.context) {
      return <Screen {...screenProps }><ActivityIndicatorView /></Screen>
    }

    if (this.props.error) {
      return <Screen {...screenProps }><ErrorView error={this.props.error} /></Screen>
    }

    return (
      <Screen
        title={user.short_name}
        subtitle={context.name}
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
    const { context, contextType, user } = this.props
    if (context && user) {
      let recipients = [user]
      const contextName = context.name
      const contextCode = contextType === 'courses'
        ? `course_${context.id}`
        : `group_${context.id}`
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

const styles = createStyleSheet((colors, vars) => ({
  header: {
    paddingTop: 8,
  },
  headerSection: {
    padding: 16,
    borderBottomColor: colors.borderMedium,
    borderBottomWidth: vars.hairlineWidth,
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
    color: colors.textDarkest,
    flex: 1,
  },
  label: {
    fontSize: 14,
    fontWeight: '600',
    color: colors.textDarkest,
  },
  textWrapper: {
    flex: 1,
  },
  outOf: {
    fontSize: 12,
    color: colors.textDark,
    top: -3,
    fontWeight: '600',
  },
  analyticsGroup: {
    flex: 1,
  },
}))

export function props (props: any) {
  const data = props.data
  if (data.error) {
    return { error: data.error }
  }

  const context = data.course ?? data.group
  const user = context?.users?.edges[0]?.user ?? context?.member?.user

  if (!context || !user) {
    if (data.loading) {
      return { loading: true }
    } else {
      return { error: Error(i18n('There was an unexepected error.')) }
    }
  }

  const enrollment = user.enrollments?.[0] ?? {}
  const submissions = context.submissions?.edges.map(e => e.submission).filter(Boolean)
  const isStudent = enrollment.type === 'StudentEnrollment'
  const permissions = context.permissions ?? {}

  return {
    context,
    contextType: data.course != null ? 'courses' : 'groups',
    user,
    enrollment,
    submissions,
    isStudent,
    permissions,
    loading: data.loading,
  }
}

export const StudentContextCardCourse = graphql(courseQuery, {
  options: ({ courseID, userID }) => ({ variables: { courseID, userID, limit: 20 } }),
  fetchPolicy: 'cache-and-network',
  props,
})(ContextCard)

export const StudentContextCardGroup = graphql(groupQuery, {
  options: ({ groupID, userID }) => ({ variables: { groupID, userID } }),
  fetchPolicy: 'cache-and-network',
  props,
})(ContextCard)
