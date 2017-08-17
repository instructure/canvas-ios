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
import ActivityIndicatorView from '../../common/components/ActivityIndicatorView'
import Avatar from '../../common/components/Avatar'
import colors from '../../common/colors'
import i18n from 'format-message'
import Images from '../../images'

type ContextCardOwnProps = {
  courseID: string,
  userID: string,
  navigator: Navigator,
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
  courseColor: string,
  pending: boolean,
}

type ContextCardProps = ContextCardOwnProps & ContextCardDataProps & ContextCardActionProps & {
  refreshing: boolean,
  refresh: Function,
}

export class ContextCard extends Component {
  props: ContextCardProps

  donePressed () {
    this.props.navigator.dismiss()
  }

  renderHeader () {
    let sectionName = this.props.enrollment ? this.props.course.sections.find(({ id }) => id === this.props.enrollment.course_section_id).name : ''
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
              <SubTitle>{this.props.user.primary_email}</SubTitle>
            </View>
          </View>
          <View>
            <Heading1>{this.props.course.name}</Heading1>
            <Text testID='context-card.section-name' style={{ fontSize: 14 }}>{i18n('Section: {sectionName}', { sectionName })}</Text>
            <SubTitle testID='context-card.last-activity'>
              {this.props.enrollment && i18n(`Last activity on {lastActivity, date, 'MMMM d'} at {lastActivity, time, short}`, {
                lastActivity: new Date(this.props.enrollment.last_activity_at),
              })}
            </SubTitle>
          </View>
        </View>
      </View>
    )
  }

  render () {
    const { course, user } = this.props
    if ((this.props.pending && !this.props.refreshing) || !user) {
      return <ActivityIndicatorView />
    }

    let leftBarButtons = []
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
          onRefresh={this.props.refresh}
          refreshing={this.props.refreshing}
          data={[]}
          renderItem={() => {}}
        />
      </Screen>
    )
  }

  _emailContact = () => {
    const { course, user } = this.props
    if (course && user) {
      let recipients = [user]
      const contextName = course.name
      const contextCode = `course_${course.id}`
      this.props.navigator.show('/conversations/compose', { modal: true }, { contextName, contextCode, recipients })
    }
  }
}

const styles = StyleSheet.create({
  header: {
    paddingVertical: 8,
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
})

export function shouldRefresh (props: ContextCardProps): boolean {
  return !props.user || !props.course || !props.enrollment
}

export function fetchData (props: ContextCardProps): void {
  props.refreshUsers([props.userID])
  props.refreshCourses()
  props.refreshEnrollments(props.courseID)
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
    let enrollmentID = enrollments.refs.find(id => state.entities.enrollments[id].user_id === ownProps.userID) || ''
    enrollment = state.entities.enrollments[enrollmentID]
  } else {
    enrollments = {}
  }

  return {
    user: user.data,
    pending: user.pending || enrollments.pending || false,
    courseColor: color,
    course,
    enrollment,
  }
}

const Connected = connect(mapStateToProps, { ...UserActions, ...CourseActions, ...EnrollmentActions })(Refreshed)
export default (Connected: any)
