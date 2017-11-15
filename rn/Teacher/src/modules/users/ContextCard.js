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
import { connect } from 'react-redux'
import refresh from '../../utils/refresh'
import Screen from '../../routing/Screen'
import UserActions from './actions'
import CourseActions from '../courses/actions'
import EnrollmentActions from '../enrollments/actions'
import SubmissionActions from '../submissions/list/actions'
import AssignmentActions from '../assignments/actions'
import ActivityIndicatorView from '../../common/components/ActivityIndicatorView'
import Avatar from '../../common/components/Avatar'
import colors from '../../common/colors'
import i18n from 'format-message'
import Images from '../../images'
import type { SubmissionStatusProp } from '../submissions/list/submission-prop-types'
import { statusProp, dueDate } from '../submissions/list/get-submissions-props'
import UserSubmissionRow from './UserSubmissionRow'
import RowSeparator from '../../common/components/rows/RowSeparator'

type ContextCardOwnProps = {
  courseID: string,
  userID: string,
  navigator: Navigator,
  modal: boolean,
}

type ContextCardActionProps = {
  refreshUsers: Function,
  refreshCourses: Function,
  refreshEnrollments: Function,
}

type ContextCardDataProps = {
  user: ?User,
  course: ?Course,
  enrollment: ?Enrollment,
  assignments: Assignment[],
  courseColor: string,
  pending: boolean,
  numLate: number,
  numMissing: number,
  totalPoints: number,
}

type ContextCardProps = ContextCardOwnProps & ContextCardDataProps & ContextCardActionProps & {
  refreshing: boolean,
  refresh: Function,
}

type ContextCardState = {
  hasGottenSubmissions: boolean,
}

export class ContextCard extends Component<any, ContextCardProps, any> {
  state: ContextCardState

  constructor (props: ContextCardProps) {
    super(props)
    this.state = { hasGottenSubmissions: false }
  }

  componentDidMount () {
    this.refreshSubmissions(this.props)
  }
  componentWillReceiveProps (nextProps: ContextCardProps) {
    this.refreshSubmissions(nextProps)
  }

  refreshSubmissions (props: ContextCardProps) {
    if (!this.props.userIsDesigner &&
        !this.state.hasGottenSubmissions &&
        props.enrollment &&
        props.enrollment.type === 'StudentEnrollment') {
      this.props.getUserSubmissions(this.props.courseID, this.props.userID)
      this.setState({ hasGottenSubmissions: true })
    }
  }

  refresh = () => {
    if (this.props.enrollment.type === 'StudentEnrollment') {
      this.props.getUserSubmissions(this.props.courseID, this.props.userID)
    }
    this.props.refresh()
  }

  donePressed = () => {
    this.props.navigator.dismiss()
  }

  renderHeader () {
    let sectionName
    if (this.props.enrollment) {
      const section = this.props.sections.find(({ id }) => id === this.props.enrollment.course_section_id)
      if (section) {
        sectionName = section.name
      }
    }
    let grade = this.props.enrollment.grades && this.props.enrollment.grades.current_grade
    let isStudent = this.props.enrollment.type === 'StudentEnrollment'
    return (
      <View style={styles.header}>
        <View style={styles.headerSection}>
          <View style={styles.user}>
            <Avatar
              avatarURL={this.props.user.avatar_url}
              userName={this.props.user.name}
              height={80}
            />
            <View style={styles.userText}>
              <Text style={styles.userName}>{this.props.user.name}</Text>
              <SubTitle>{this.props.user.login_id}</SubTitle>
            </View>
          </View>
          <View>
            <Heading1>{this.props.course.name}</Heading1>
            { sectionName && <Text testID='context-card.section-name' style={{ marginVertical: 4, fontSize: 14 }}>{i18n('Section: {sectionName}', { sectionName })}</Text> }
            <SubTitle testID='context-card.last-activity'>
              {this.props.enrollment && i18n(`Last activity on {lastActivity, date, 'MMMM d'} at {lastActivity, time, short}`, {
                lastActivity: new Date(this.props.enrollment.last_activity_at),
              })}
            </SubTitle>
          </View>
        </View>
        {isStudent && !this.props.userIsDesigner &&
          <View style={styles.headerSection}>
            <Heading1 style={{ marginBottom: 16 }}>{i18n('Submissions')}</Heading1>
            <View style={styles.line}>
              <Text testID='context-card.grade' style={styles.largeText}>{grade || i18n.number(this.props.enrollment.grades.current_score / 100, 'percent') || 0}</Text>
              <Text style={styles.largeText}>{i18n.number(this.props.numLate)}</Text>
              <Text style={styles.largeText}>{i18n.number(this.props.numMissing)}</Text>
            </View>
            <View style={styles.line}>
              <Text style={styles.label}>{i18n('Grade')}</Text>
              <Text style={styles.label}>{i18n('Late')}</Text>
              <Text style={styles.label}>{i18n('Missing')}</Text>
            </View>
          </View>
        }
      </View>
    )
  }

  renderItem = ({ item: assignment, index }: { item: Assignment, index: number }) => {
    let submission = this.props.submissions.find(submission => assignment.id === submission.assignment_id)
    return (
      <UserSubmissionRow
        tintColor='#00BCD5'
        assignment={assignment}
        submission={submission}
        user={this.props.user}
        onPress={this._navigateToSpeedGrader}
      />
    )
  }

  render () {
    const { course, enrollment, submissions } = this.props
    if (this.props.pending && !this.props.refreshing) {
      return <Screen><ActivityIndicatorView /></Screen>
    }

    let isStudent = enrollment.type === 'StudentEnrollment'
    if (!this.props.userIsDesigner && isStudent && submissions.length === 0) {
      return <Screen><ActivityIndicatorView /></Screen>
    }

    let leftBarButtons = null
    if (this.props.modal) {
      leftBarButtons = [{
        testID: 'context-card.done-btn',
        title: i18n('Done'),
        style: 'done',
        action: this.donePressed,
      }]
    }

    let rightBarButtons = []
    if (course) {
      rightBarButtons = [{
        action: this._emailContact,
        image: Images.smallMail,
        testID: 'context-card.email-contact',
        accessibilityLabel: i18n('Email Contact'),
      }]
    }

    return (
      <Screen
        title={this.props.user.name}
        subtitle={this.props.course.name}
        navBarStyle='dark'
        navBarColor={this.props.courseColor}
        leftBarButtons={leftBarButtons}
        rightBarButtons={rightBarButtons}
      >
        <FlatList
          ListHeaderComponent={this.renderHeader()}
          onRefresh={this.refresh}
          refreshing={this.props.refreshing}
          data={isStudent && !this.props.userIsDesigner ? this.props.assignments : []}
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
    let userID = this.props.user.id
    let filter = (submissions: any) => submissions.filter((s) => s.userID === userID)

    let url = `${assignment.html_url}/submissions/${userID}`
    this.props.navigator.show(url, { modal: true, modalPresentationStyle: 'fullscreen' }, {
      studentIndex: 0,
      filter,
    })
  }
}

ContextCard.defaultProps = {
  modal: true,
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
})

export function shouldRefresh (props: ContextCardProps): boolean {
  return !props.user || !props.course || !props.enrollment || !props.totalPoints
}

export function fetchData (props: ContextCardProps): void {
  props.refreshUsers(props.courseID, [props.userID])
  props.refreshCourses()
  props.refreshEnrollments(props.courseID)
  props.refreshAssignmentList(props.courseID)
}

export function isRefreshing (props: ContextCardProps): boolean {
  return props.pending
}

const Refreshed = refresh(
  fetchData,
  shouldRefresh,
  isRefreshing
)(ContextCard)

export function mapStateToProps (state: AppState, ownProps: ContextCardOwnProps): ContextCardDataProps {
  let user = state.entities.users[ownProps.userID] || {}
  let { color, course, enrollments } = state.entities.courses[ownProps.courseID] || {}

  let enrollment
  if (enrollments) {
    let enrollmentID = enrollments.refs.find(id => {
      let e = state.entities.enrollments[id]
      return e && e.user_id === ownProps.userID
    }) || ''
    enrollment = state.entities.enrollments[enrollmentID]
  } else {
    enrollments = {}
  }

  let submissions = Object.keys(state.entities.submissions)
    .map(submissionID => state.entities.submissions[submissionID].submission)
    .filter(submission => submission.user_id === ownProps.userID)
    .filter(submission => {
      let assignmentID = submission.assignment_id
      return state.entities.assignments[assignmentID].data.course_id === ownProps.courseID
    })

  let assignments = Object.keys(state.entities.assignments)
    .map(assignmentID => state.entities.assignments[assignmentID].data)
    .filter(assignment => assignment.course_id === ownProps.courseID)
    .sort((a, b) => {
      let submissionA = submissions.find(submission => submission.assignment_id === a.id)
      let submissionB = submissions.find(submission => submission.assignment_id === b.id)

      if (!submissionA) return 1
      if (!submissionB) return -1
      let aSubmit = new Date(submissionA.submitted_at)
      let bSubmit = new Date(submissionB.submitted_at)
      if (aSubmit < bSubmit) return 1
      else return -1
    })

  const sections = Object.values(state.entities.sections).filter((s) => {
    return s.course_id === ownProps.courseID
  })

  let asyncActions = state.asyncActions
  let pending = asyncActions['users.refresh'] && asyncActions['users.refresh'].pending ||
                asyncActions['courses.refresh'] && asyncActions['courses.refresh'].pending ||
                asyncActions['enrollments.update'] && asyncActions['enrollments.update'].pending ||
                asyncActions['assignmentList.refresh'] && asyncActions['assignmentList.refresh'].pending

  return {
    user: user.data,
    pending: Boolean(pending) || !enrollment,
    courseColor: color,
    course,
    enrollment,
    submissions,
    assignments,
    sections,
    userIsDesigner: course && course.enrollments[0].type === 'designer',
    totalPoints: calculateTotalPoints(state, ownProps),
    numLate: calculateStatus(state, ownProps, 'late'),
    numMissing: calculateStatus(state, ownProps, 'missing'),
  }
}

const Connected = connect(mapStateToProps, {
  ...UserActions,
  ...CourseActions,
  ...EnrollmentActions,
  ...AssignmentActions,
  ...SubmissionActions,
})(Refreshed)
export default (Connected: any)

export function calculateTotalPoints (state: AppState, ownProps: ContextCardOwnProps): number {
  let assignments = state.entities.assignments

  return Object.keys(assignments)
    .map(assignmentID => state.entities.assignments[assignmentID].data)
    .filter(assignment => assignment.course_id === ownProps.courseID)
    .filter(assignment => {
      return assignment.overrides.length === 0 || assignment.overrides.find(override => override.student_ids && override.student_ids.includes(ownProps.userID))
    })
    .map(assignment => assignment.points_possible)
    .reduce((sum, points) => {
      sum += points
      return sum
    }, 0)
}

export function calculateStatus (state: AppState, ownProps: ContextCardOwnProps, status: SubmissionStatusProp): number {
  let courseAssignments = Object.keys(state.entities.assignments)
    .map(assignmentID => state.entities.assignments[assignmentID].data)
    .filter(assignment => assignment.course_id === ownProps.courseID)

  let userSubmissions = Object.keys(state.entities.submissions)
    .map(submissionID => state.entities.submissions[submissionID].submission)
    .filter(submission => submission.user_id === ownProps.userID)
    .filter(submission => {
      let assignmentID = submission.assignment_id
      return state.entities.assignments[assignmentID].data.course_id === ownProps.courseID
    })

  return courseAssignments
    .map(assignment => {
      let submission = userSubmissions.find(submission => submission.assignment_id === assignment.id)
      let due = dueDate(assignment, submission && submission.user)
      return statusProp(submission, due)
    })
    .filter(submissionStatus => submissionStatus === status)
    .length
}
