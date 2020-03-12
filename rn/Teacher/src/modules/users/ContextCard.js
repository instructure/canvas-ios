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

import React, { Component } from 'react'
import {
  FlatList,
  View,
} from 'react-native'
import { connect } from 'react-redux'
import { Text } from '../../common/text'
import Screen from '../../routing/Screen'
import ActivityIndicatorView from '../../common/components/ActivityIndicatorView'
import ErrorView from '../../common/components/ErrorView'
import Avatar from '../../common/components/Avatar'
import { colors, createStyleSheet } from '../../common/stylesheet'
import i18n from 'format-message'
import Images from '../../images'
import UserSubmissionRow from './UserSubmissionRow'
import { graphql } from 'react-apollo'
import { courseQuery } from '../../canvas-api-v2/queries/ContextCard'
import * as app from '../app'
import { personDisplayName } from '../../common/formatters'

export class ContextCard extends Component {
  renderHeader () {
    const { course, user, enrollment, isStudent, permissions = {} } = this.props
    let sectionName
    if (enrollment) {
      const section = enrollment.section
      if (section) {
        sectionName = section.name
      }
    }

    let grade
    if (enrollment && enrollment.grades && (enrollment.grades.current_grade || enrollment.grades.current_score != null)) {
      grade = enrollment.grades.current_grade || i18n.number(enrollment.grades.current_score / 100, 'percent')
    }

    let unpostedGrade
    if (enrollment && enrollment.grades && (enrollment.grades.unposted_current_grade || enrollment.grades.unposted_current_score != null)) {
      unpostedGrade = enrollment.grades.unposted_current_grade || i18n.number(enrollment.grades.unposted_current_score / 100, 'percent')
    }
    if (unpostedGrade === grade) {
      unpostedGrade = null
    }

    let overrideGrade
    if (enrollment && enrollment.grades && (enrollment.grades.override_grade || enrollment.grades.override_score != null)) {
      overrideGrade = enrollment.grades.override_grade || i18n.number(enrollment.grades.override_score / 100, 'percent')
    }

    const selectedBox = { backgroundColor: this.props.courseColor }
    const selectedText = { color: colors.white }
    const gradeSelected = !unpostedGrade && !overrideGrade
    const unpostedSelected = Boolean(unpostedGrade && !overrideGrade)

    return (
      <View>
        <View style={styles.user}>
          <View style={styles.avatar}>
            <Avatar
              avatarURL={user.avatar_url}
              userName={user.name}
              height={80}
            />
          </View>
          <Text testID='ContextCard.userNameLabel' style={styles.userName}>
            {personDisplayName(user.short_name, user.pronouns)}
          </Text>
          { user.primary_email &&
            <Text testID='ContextCard.userEmailLabel' style={styles.userEmail}>
              {user.primary_email}
            </Text>
          }
          { enrollment && enrollment.last_activity_at && !app.isStudent() &&
            <Text testID='ContextCard.lastActivityLabel' style={styles.lastActivity}>
              {i18n(`Last activity on {lastActivity, date, 'MMMM d'} at {lastActivity, time, short}`, {
                lastActivity: new Date(enrollment.last_activity_at),
              })}
            </Text>
          }
        </View>
        <View style={styles.course}>
          <View style={styles.courseLine} />
          <View style={styles.courseBox}>
            <Text testID='ContextCard.courseLabel' style={styles.courseName}>
              {course.name}
            </Text>
            { sectionName &&
              <Text testID='ContextCard.sectionLabel' style={styles.section}
                accessibilityLabel={i18n('Section: {sectionName}', { sectionName })}
              >
                {sectionName}
              </Text>
            }
          </View>
        </View>
        { isStudent && Boolean(grade) &&
          <React.Fragment>
            <Text style={styles.heading}>{i18n('Grades')}</Text>
            <View style={styles.boxes}>
              <View
                accessible={true}
                style={[styles.box, gradeSelected && selectedBox]}
                testID='ContextCard.currentGradeLabel'
                accessibilityLabel={ unpostedGrade
                  ? i18n('Grade before posting {grade}', { grade })
                  : i18n('Current grade {grade}', { grade })
                }
              >
                <Text testID='context-card.grade' style={[styles.largeText, gradeSelected && selectedText]}>{grade}</Text>
                <Text style={[styles.label, gradeSelected && selectedText]}>
                  { unpostedGrade
                    ? i18n('Grade before posting')
                    : i18n('Current Grade')
                  }
                </Text>
              </View>
              { Boolean(unpostedGrade) &&
                <View
                  accessible={true}
                  style={[styles.box, unpostedSelected && selectedBox]}
                  testID='ContextCard.unpostedGradeLabel'
                  accessibilityLabel={i18n('Grade after posting {grade}', { grade: unpostedGrade })}
                >
                  <Text testID='context-card.unposted-grade' style={[styles.largeText, unpostedSelected && selectedText]}>{unpostedGrade}</Text>
                  <Text style={[styles.label, unpostedSelected && selectedText]}>{i18n('Grade after posting')}</Text>
                </View>
              }
              { Boolean(overrideGrade) &&
                <View
                  accessible={true}
                  style={[styles.box, selectedBox]}
                  testID='ContextCard.overrideGradeLabel'
                  accessibilityLabel={i18n('Grade Override {grade}', { grade: overrideGrade })}
                >
                  <Text testID='context-card.override-grade' style={[styles.largeText, selectedText]}>{overrideGrade}</Text>
                  <Text style={[styles.label, selectedText]}>{i18n('Grade Override')}</Text>
                </View>
              }
            </View>
          </React.Fragment>
        }
        { isStudent && Boolean(permissions.viewAnalytics && user.analytics) &&
          <React.Fragment>
            <Text style={styles.heading}>{i18n('Submissions')}</Text>
            <View style={styles.boxes}>
              <View
                accessible={true}
                style={styles.box}
                testID='ContextCard.submissionsTotalLabel'
                accessibilityLabel={i18n('Total Submissions {total, number}', {
                  total: user.analytics.tardinessBreakdown.total,
                })}
              >
                <Text style={styles.largeText}>{i18n.number(user.analytics.tardinessBreakdown.total)}</Text>
                <Text style={styles.label}>{i18n('Submitted')}</Text>
              </View>
              <View
                accessible={true}
                style={styles.box}
                testID='ContextCard.submissionsLateLabel'
                accessibilityLabel={i18n('Late Submissions {late, number}', {
                  late: user.analytics.tardinessBreakdown.late,
                })}
              >
                <Text style={styles.largeText}>{i18n.number(user.analytics.tardinessBreakdown.late)}</Text>
                <Text style={styles.label}>{i18n('Late')}</Text>
              </View>
              <View
                accessible={true}
                style={styles.box}
                testID='ContextCard.submissionsMissingLabel'
                accessibilityLabel={i18n('Missing Submissions {missing, number}', {
                  missing: user.analytics.tardinessBreakdown.missing,
                })}
              >
                <Text style={styles.largeText}>{i18n.number(user.analytics.tardinessBreakdown.missing)}</Text>
                <Text style={styles.label}>{i18n('Missing')}</Text>
              </View>
            </View>
          </React.Fragment>
        }
      </View>
    )
  }

  renderItem = ({ item: submission, index }) => {
    return (
      <UserSubmissionRow
        tintColor={this.props.courseColor}
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
      navBarStyle: this.props.navigator.isModal ? 'modal' : 'context',
      navBarColor: this.props.navigator.isModal ? undefined : this.props.courseColor,
    }

    if (this.props.loading && !this.props.course) {
      return <Screen {...screenProps }><ActivityIndicatorView /></Screen>
    }

    if (this.props.error) {
      return <Screen {...screenProps }><ErrorView error={this.props.error} /></Screen>
    }

    return (
      <Screen
        title={user.short_name}
        subtitle={course.name}
        {...screenProps }
      >
        <FlatList
          ListHeaderComponent={this.renderHeader()}
          data={isStudent && permissions.viewAllGrades ? submissions : []}
          renderItem={this.renderItem}
          keyExtractor={this._keyExtractor}
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

const styles = createStyleSheet((colors, vars) => ({
  user: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    backgroundColor: colors.backgroundLightest,
    marginTop: 32,
    marginBottom: 24,
  },
  avatar: {
    borderRadius: 40,
    backgroundColor: colors.backgroundLightest,
    height: 80,
    width: 80,
    shadowColor: 'black',
    shadowOpacity: 0.12,
    shadowOffset: { width: 0, height: 4 },
    shadowRadius: 16,
  },
  userName: {
    color: colors.textDarkest,
    fontSize: 20,
    fontWeight: 'bold',
    lineHeight: 24,
    marginTop: 12,
  },
  userEmail: {
    color: colors.textDarkest,
    fontSize: 14,
    fontWeight: '500',
    lineHeight: 17,
    marginTop: 4,
  },
  lastActivity: {
    color: colors.textDark,
    fontSize: 12,
    fontWeight: '500',
    lineHeight: 14,
    marginTop: 8,
  },
  course: {
    width: '100%',
    alignItems: 'center',
    marginBottom: 16,
  },
  courseLine: {
    borderTopColor: colors.borderMedium,
    borderTopWidth: vars.hairlineWidth,
    position: 'absolute',
    top: '50%',
    left: 0,
    right: 0,
  },
  courseBox: {
    alignItems: 'center',
    backgroundColor: colors.backgroundLightest,
    borderColor: colors.borderMedium,
    borderRadius: 4,
    borderWidth: vars.hairlineWidth,
    paddingTop: 8,
    paddingBottom: 12,
    paddingHorizontal: 16,
  },
  courseName: {
    color: colors.textDarkest,
    fontSize: 16,
    fontWeight: 'bold',
    lineHeight: 19,
  },
  section: {
    color: colors.textDarkest,
    fontSize: 12,
    fontWeight: '500',
    lineHeight: 14,
    marginTop: 4,
  },
  heading: {
    color: colors.textDark,
    fontSize: 14,
    fontWeight: '600',
    lineHeight: 17,
    marginHorizontal: 16,
    marginBottom: 12,
  },
  boxes: {
    flexDirection: 'row',
    marginHorizontal: 12,
    marginBottom: 16,
  },
  box: {
    alignItems: 'center',
    flex: 1,
    borderRadius: 8,
    backgroundColor: colors.backgroundLight,
    paddingHorizontal: 8,
    paddingVertical: 12,
    marginHorizontal: 4,
  },
  largeText: {
    color: colors.textDarkest,
    fontSize: 20,
    fontWeight: 'bold',
    lineHeight: 24,
  },
  label: {
    color: colors.textDarkest,
    fontSize: 12,
    fontWeight: '500',
    lineHeight: 14,
    marginTop: 4,
  },
}))

export function props (props) {
  const data = props.data
  if (data.error) {
    return { error: data.error }
  }

  const course = data.course
  const user = course?.users?.edges?.[0]?.user

  if (!course || !user) {
    if (data.loading) {
      return { loading: true }
    } else {
      return { error: Error(i18n('There was an unexepected error.')) }
    }
  }

  const enrollment = user?.enrollments?.[0] ?? {}
  const submissions = (course?.submissions?.edges ?? []).map(e => e.submission).filter(Boolean)
  const isStudent = enrollment.type === 'StudentEnrollment'
  const permissions = course.permissions ?? {}

  return { course, user, enrollment, submissions, isStudent, permissions, loading: data.loading }
}

export function mapStateToProps (state, { courseID }) {
  return { courseColor: state.entities.courses[courseID]?.color || '#00BCD5' }
}

export default graphql(courseQuery, {
  options: ({ courseID, userID }) => ({ variables: { courseID, userID } }),
  fetchPolicy: 'cache-and-network',
  props,
})(connect(mapStateToProps, {})(ContextCard))
