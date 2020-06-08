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

import React, { type Element, type ComponentType } from 'react'
import {
  NativeEventEmitter,
  NativeModules,
  View,
  SectionList,
  StyleSheet,
} from 'react-native'
import Screen from '../../routing/Screen'
import { connect } from 'react-redux'
import refresh from '../../utils/refresh'
import localeSort from '../../utils/locale-sort'
import i18n from 'format-message'
import App, { isTeacher, isStudent } from '../app'
import CoursesActions from '../courses/actions'
import EnrollmentsActions from '../enrollments/actions'
import GroupsActions from '../groups/actions'
import GroupsFavoriteActions from '../groups/favorites/actions'
import DashboardActions from '../dashboard/actions'
import UserInfoActions from '../userInfo/actions'
import {
  Heading1,
} from '../../common/text'
import {
  LinkButton,
} from '../../common/buttons'
import LiveConferenceRow from './LiveConferenceRow'
import GlobalAnnouncementRow from './GlobalAnnouncementRow'
import CourseInvite from './CourseInvite'
import GroupRow, { type GroupRowProps } from './GroupRow'
import CourseCard from '../courses/components/CourseCard'
import NoCourses from '../courses/components/NoCourses'
import { colors } from '../../common/stylesheet'
import icon from '../../images/inst-icons'
import Navigator from '../../routing/Navigator'
import { getSessionUnsafe, getSession } from '../../canvas-api'
import AccountNotificationActions from './account-notification-actions'
import { extractGradeInfo } from '../../utils/course-grades'
import { extractDateFromString } from '../../utils/dateUtils'
import ExperimentalFeature from '../../common/ExperimentalFeature'
import { logEvent } from '../../common/CanvasAnalytics'

const {
  UserDefaults,
} = NativeModules

type ColorfulCourse = { color: string } & Course
type Props = {
  totalCourseCount: number,
  navigator: Navigator,
  refreshing: boolean,
  refresh: () => void,
  isFullDashboard: boolean,
  announcements: AccountNotification[],
  allCourses: { [string]: Course},
  sections: SectionsState,
  enrollments: Invite[],
  courses: ColorfulCourse[],
  concludedCourses: ColorfulCourse[],
  closeNotification: (string) => any,
  groups: GroupRowProps[],
  acceptEnrollment?: (string, string) => any,
  rejectEnrollment?: (string, string) => any,
  hideInvite?: (string) => any,
  pending: number,
  hideOverlays: boolean,
}
type State = {
  width?: number,
  height?: number,
  cardSize?: number,
  contentWidth?: number,
  showingModal: boolean,
  fetchingEnrollments: boolean,
  noCoursesLayout: ?{ y: number },
}
type SectionListSection = {
  sectionID: string,
  title?: string,
  seeAll?: () => void,
} & {
  data: $ReadOnlyArray<*>,
  key?: string,
  renderItem?: ?(info: {
    item: *,
    index: number,
    section: *,
    separators: {
      highlight: () => void,
      unhighlight: () => void,
      updateProps: (select: 'leading' | 'trailing', newProps: Object) => void,
    },
  }) => ?Element<any>,
  ItemSeparatorComponent?: ?ComponentType<any>,
  keyExtractor?: (item: *) => string,
}
// This is copy pasted out of `react-native/Libraries/Lists/SectionList.js` because the type
// is not exported in our RN version. It won't be exported until RN 0.52

const padding = 8
const MIN_CARD_SIZE = 150

export class Dashboard extends React.Component<Props, State> {
  noCourses: ?View

  state: State = {
    showingModal: false,
    fetchingEnrollments: false,
    noCoursesLayout: null,
    showGrades: false,
  }

  componentDidMount () {
    this.observeShowGrades()
  }

  async componentWillReceiveProps (newProps: Props) {
    if (newProps.isFullDashboard &&
        !newProps.pending &&
        !newProps.error &&
        !newProps.totalCourseCount &&
        !newProps.canActAsUser &&
        !this.state.showingModal &&
        isTeacher() &&
        getSessionUnsafe()) {
      this.props.navigator.show('/wrong-app', {
        modal: true,
        disableSwipeDownToDismissModal: true,
      })
      this.setState({
        showingModal: true,
      })
    }
  }

  observeShowGrades () {
    const emitter = new NativeEventEmitter(UserDefaults)
    emitter.addListener(UserDefaults.didChangeNotification, this.updateShowGrades)
    this.updateShowGrades()
  }

  updateShowGrades = () => {
    UserDefaults.getShowGradesOnDashboard()
      .then(showGrades => this.setState({ showGrades }))
  }

  calculateLayout = (width: number, height: number) => {
    const contentWidth = width - padding - padding
    const columns = Math.floor(contentWidth / MIN_CARD_SIZE)
    const cardSize = contentWidth / columns
    this.setState({ cardSize, width, contentWidth, height })
  }

  onLayout = ({ nativeEvent }: { nativeEvent: { layout: { width: number, height: number }}}) => {
    const { width, height } = nativeEvent.layout
    this.calculateLayout(width, height)
  }

  handleInvite = (courseId: string, enrollmentId: string, action: string) => {
    if (action === 'accept' && this.props.acceptEnrollment) {
      this.props.acceptEnrollment(courseId, enrollmentId)
    } else if (action === 'reject' && this.props.rejectEnrollment) {
      this.props.rejectEnrollment(courseId, enrollmentId)
    }
  }

  renderHeader = ({ section }: { section: SectionListSection }) => {
    if (!section.title || !this.state.contentWidth) {
      return undefined
    }
    const width = this.state.contentWidth
    return (
      <View
        key={section.sectionID}
        accessibitilityTraits='heading'
        style={[{ width, padding }, styles.header]}
      >
        <Heading1 testID={section.sectionID + '.heading-lbl'}>
          {section.title}
        </Heading1>
        { section.seeAll
          ? <LinkButton
            testID={section.sectionID + '.see-all-btn'}
            onPress={section.seeAll}
          >
            {i18n('See All')}
          </LinkButton>
          : undefined
        }
      </View>
    )
  }

  renderLiveConference = ({ item }) => {
    return (
      <LiveConferenceRow
        key={item.id}
        style={{ width: this.state.contentWidth, padding }}
        conference={item}
        onDismiss={this.props.ignoreLiveConference}
        navigator={this.props.navigator}
      />
    )
  }

  renderGlobalAnnouncement = ({ item }: { item: AccountNotification }) => {
    return (
      <GlobalAnnouncementRow
        key={item.id}
        style={{ width: this.state.contentWidth, padding }}
        notification={item}
        onDismiss={this.props.closeNotification}
        navigator={this.props.navigator}
      />
    )
  }

  renderCourseInvite = ({ item }: { item: Invite }) => {
    let courseName = ''
    let sectionName = ''
    const course = this.props.allCourses[item.course_id]
    const section = this.props.sections[item.course_section_id]
    if (course) courseName = course.name
    if (section) sectionName = section.name
    return (
      <CourseInvite
        key={`invite-${item.id}`}
        style={{ width: this.state.contentWidth, padding }}
        courseName={courseName}
        sectionName={sectionName}
        invite={item}
        handleInvite={this.handleInvite}
        hideInvite={this.props.hideInvite}
      />
    )
  }

  renderCourseCard = ({ item }: { item: ColorfulCourse }) => {
    const cardSize = this.state.cardSize
    return (
      <CourseCard
        key={item.id}
        style={{ width: cardSize, height: cardSize, padding }}
        color={item.color}
        hideOverlay={this.props.hideOverlays}
        course={item}
        grade={extractGradeInfo(item)}
        showGrade={this.state.showGrades}
        onPress={this.selectCourse}
        onCoursePreferencesPressed={this.showUserCoursePreferences}
        initialHeight={cardSize}
      />
    )
  }

  renderNoFavorites = () => {
    const { contentWidth } = this.state
    const height = this.state.height || 0

    // center empty state vertically in this section
    let calculatedHeight
    if (this.showGroups()) {
      // make it a percentage of the screen height
      // so that groups show just enough on all phone sizes
      calculatedHeight = height * 0.7
    } else {
      // fill all remaining space
      const noCoursesLayout = this.state.noCoursesLayout || { y: 0 }
      const y = noCoursesLayout ? noCoursesLayout.y : 0
      const headerHeight = 60
      calculatedHeight = height - y - headerHeight
    }

    return (
      <View onLayout={this.measureNoCourses} ref={this.captureNoCourses}>
        <NoCourses
          key='no-courses'
          onAddCoursePressed={this.showFavoritesList}
          style={[styles.noCourses, { width: contentWidth, height: calculatedHeight }]}
        />
      </View>
    )
  }

  captureNoCourses = (ref: ?View) => {
    this.noCourses = ref
  }

  measureNoCourses = () => {
    if (this.noCourses && !this.state.noCoursesLayout) {
      this.noCourses.measure((vx, vy, width, height, x, y) => {
        this.setState({ noCoursesLayout: { y } })
      })
    }
  }

  renderGroup = ({ item }: { item: GroupRowProps }) => {
    return (
      // TODO: add a unique key containing the group id
      <GroupRow
        style={{ width: this.state.contentWidth, padding }}
        { ...item }
        onPress={this.showGroup}
      />
    )
  }

  loadSections = () => {
    if (!this.props.isFullDashboard) {
      let sections = [{
        sectionID: 'dashboard.courses',
        data: this.props.courses,
        renderItem: this.renderCourseCard,
        keyExtractor: ({ id }: ColorfulCourse) => id,
      }]

      if (this.props.concludedCourses.length > 0) {
        sections.push({
          sectionID: 'dashboard.concluded-courses',
          title: i18n('Past Enrollments'),
          data: this.props.concludedCourses,
          renderItem: this.renderCourseCard,
          keyExtractor: ({ id }: ColorfulCourse) => id,
        })
      }

      return sections
    }

    const coursesHeader = {
      sectionID: 'dashboard.courses',
      title: i18n('Courses'),
      seeAll: this.showAllCourses,
    }

    let sections = []

    // Live Conferences
    sections.push({
      sectionID: 'dashboard.conferences',
      data: this.props.liveConferences,
      renderItem: this.renderLiveConference,
      keyExtractor: ({ id }) => `conference-${id}`,
    })

    // Course Invites
    if (this.props.enrollments.length > 0) {
      let courseInvites = this.props.enrollments.filter(en => {
        if (en.course_id) {
          const course = this.props.allCourses[en.course_id]
          if (course.access_restricted_by_date) {
            return false
          }
        }
        return en.displayState === 'acted' || en.enrollment_state === 'invited'
      })
      sections.push({
        sectionID: 'dashboard.courseInvites',
        data: courseInvites,
        renderItem: this.renderCourseInvite,
        keyExtractor: ({ id }: Invite) => `enrollment-${id}`,
      })
    }

    // Announcements
    sections.push({
      sectionID: 'dashboard.announcements',
      data: this.props.announcements,
      renderItem: this.renderGlobalAnnouncement,
      keyExtractor: ({ id }: AccountNotification) => `announcement-${id}`,
    })

    // Courses
    if (this.props.courses.length > 0) {
      sections.push({
        ...coursesHeader,
        data: this.props.courses,
        renderItem: this.renderCourseCard,
        keyExtractor: ({ id }: ColorfulCourse) => `course-${id}`,
      })
    } else if (!this.props.pending) {
      sections.push({
        ...coursesHeader,
        data: [{ key: 'welcome' }],
        renderItem: this.renderNoFavorites,
      })
    }

    // Groups
    if (this.showGroups()) {
      sections.push({
        sectionID: 'dashboard.groups',
        title: i18n('Groups'),
        data: this.props.groups,
        renderItem: this.renderGroup,
        keyExtractor: ({ id }: GroupRowProps) => `group-${id}`,
      })
    }

    return sections
  }

  showGroups = () => {
    return isStudent() && this.props.groups && this.props.groups.length > 0
  }

  renderDashboard = () => {
    // don't show any sections until layout has happened at least once
    const sections = this.state.width
      ? this.loadSections()
      : []

    return (
      <SectionList
        refreshing={this.props.refreshing}
        onRefresh={this.props.refresh}
        stickySectionHeadersEnabled={false}
        renderSectionHeader={this.renderHeader}
        contentContainerStyle={styles.gridish}
        onLayout={this.onLayout}
        sections={sections}
        renderItem={() => {}}
        windowSize={100}
        // this prop is only necessary because renderItem is not listed as an optional prop
        // https://github.com/facebook/react-native/pull/17262
      />
    )
  }

  showFavoritesList = () => {
    this.props.navigator.show('/course_favorites', { modal: true })
  }

  showUserCoursePreferences = (courseId: string) => {
    this.props.navigator.show(`/courses/${courseId}/user_preferences`, { modal: true })
  }

  selectCourse = (course: Course) => {
    logEvent('course_card_selected', { course_id: course.id })
    this.props.navigator.show(`/courses/${course.id}`)
  }

  showAllCourses = () => {
    this.props.navigator.show('/courses')
  }

  showProfile = () => {
    this.props.navigator.show('/profile', { modal: true, modalPresentationStyle: 'drawer', embedInNavigationController: false })
  }

  showGroup = (groupID: string) => {
    logEvent('group_card_selected', { group_id: groupID })
    this.props.navigator.show(`/groups/${groupID}`)
  }

  screenProps = () => {
    return !this.props.isFullDashboard
      ? { title: i18n('All Courses') }
      : {
        navBarLogo: true,
        rightBarButtons: [{
          title: i18n('Edit'),
          testID: 'Dashboard.editFavoritesButton',
          accessibilityLabel: i18n('Edit Dashboard'),
          action: this.showFavoritesList,
          disabled: !this.props.totalCourseCount || Boolean(this.props.pending),
        }],
        leftBarButtons: [{
          image: icon('hamburger', 'solid'),
          width: 24,
          height: 24,
          testID: 'Dashboard.profileButton',
          action: this.showProfile,
          accessibilityLabel: i18n('Profile Menu'),
        }],
      }
  }

  render () {
    return (
      <Screen
        { ...this.screenProps() }
        navBarStyle='global'
      >
        {this.renderDashboard()}
      </Screen>
    )
  }
}

const styles = StyleSheet.create({
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-end',
    paddingBottom: 0,
    paddingTop: 16,
  },
  gridish: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    padding,
  },
  noCourses: {
    flexDirection: 'column',
    justifyContent: 'center',
  },
})

export function isCourseConcluded (course: Course): boolean {
  let endAt = extractDateFromString(course.end_at)
  if (endAt && endAt < new Date()) {
    return true
  }

  endAt = extractDateFromString(course.term ? course.term.end_at : null)
  if (endAt && endAt < new Date()) {
    return true
  }

  return course.workflow_state === 'completed'
}

export function mapStateToProps (isFullDashboard: boolean) {
  return (state: AppState) => {
    const { courses: allCourses, accountNotifications, enrollments: allEnrollments } = state.entities
    const user = getSession().user

    let courses: Array<ColorfulCourse> = []
    let concludedCourses: Array<ColorfulCourse> = []
    if (isFullDashboard) {
      courses = Object.keys(allCourses)
        .map(key => allCourses[key])
        .filter(courseState => courseState.course.id && App.current().filterCourse(courseState.course) && courseState.dashboardPosition != null)
        .sort((courseOneState, courseTwoState) => (courseOneState.dashboardPosition || 0) - (courseTwoState.dashboardPosition || 0))
        .map(({ course, color }) => ({ ...course, color }))
    } else {
      courses = Object.keys(allCourses)
        .map(key => allCourses[key])
        .filter(({ course }) => (
          App.current().filterCourse(course) &&
          course.enrollments &&
          course.enrollments.some(e => !['invited', 'rejected'].includes(e.enrollment_state)) &&
          !isCourseConcluded(course)
        ))
        .map(({ course, color }) => ({ ...course, color }))
        .sort((c1, c2) => localeSort(c1.name, c2.name))
      concludedCourses = Object.keys(allCourses)
        .map(key => allCourses[key])
        .filter(({ course }) => {
          return (
            App.current().filterCourse(course) &&
            course.enrollments &&
            course.enrollments.some(e => !['invited', 'rejected'].includes(e.enrollment_state)) &&
            isCourseConcluded(course)
          )
        })
        .map(({ course, color }) => ({ ...course, color }))
        .sort((c1, c2) => localeSort(c1.name, c2.name))
    }

    const allCourseStates = Object.keys(allCourses)
      .map(key => allCourses[key])
      .filter(({ course }) => App.current().filterCourse(course))

    let allCoursesStringKeys = {}
    const sections = allCourseStates.reduce((obj, { course }) => {
      const courseSections = course.sections || []
      courseSections.forEach(sec => { obj[sec.id.toString()] = sec })
      // this doesn't relate to sections,
      // but take advantage that we're looping through them all
      allCoursesStringKeys[course.id] = course
      return obj
    }, {})

    const enrollments = Object.keys(allEnrollments)
      .map(key => allEnrollments[key])
      .filter(({ user_id: id }) => id === user.id)
      .filter((enroll) => {
        const course = allCoursesStringKeys[enroll.course_id]
        return !!course
      })

    const totalCourseCount = allCourseStates
      .map(({ course }) => course)
      .filter(App.current().filterCourse)
      .length

    const announcements = accountNotifications.list
      .filter(({ id }) => !accountNotifications.closing.includes(id))

    const liveConferences = (accountNotifications.liveConferences || [])
      .filter(({ id }) => !accountNotifications.liveConferencesIgnored.includes(id))
      .map((conference) => ({
        ...conference,
        contextName: conference.context_type.toLowerCase() === 'group'
          ? state.entities.groups[conference.context_id]?.group?.name
          : state.entities.courses[conference.context_id]?.course?.name,
      }))

    const groupFavorites = state.favoriteGroups.groupRefs
    const userHasFavoriteGroups = state.favoriteGroups.userHasFavoriteGroups
    let groups = Object.keys(state.entities.groups)
      .filter(id => {
        if (state.entities.groups[id] && state.entities.groups[id].group) {
          const group = state.entities.groups[id].group
          const course = group.course_id && state.entities.courses[group.course_id]
          const courseAvailable = course && !course.course.access_restricted_by_date
          return !group.concluded && (!group.course_id || courseAvailable)
        } else {
          return false
        }
      })
      .map((id) => {
        let group = state.entities.groups[id].group
        let groupColor = state.entities.groups[id].color
        let courseData = group.course_id && state.entities.courses[group.course_id]
        return {
          id: group.id,
          name: group.name,
          contextName: courseData ? courseData.course.name : i18n('Account Group'),
          term: courseData && courseData.course.term && courseData.course.term.name,
          color: groupColor || (courseData ? courseData.color : colors.textDark),
        }
      })

    if (ExperimentalFeature.favoriteGroups.isEnabled) {
      if (userHasFavoriteGroups) { groups = groups.filter((g) => groupFavorites.includes(g.id)) }
    }

    const pending = (
      state.favoriteCourses.pending +
      accountNotifications.pending +
      (state.asyncActions['userInfo.canActAsUser']?.pending ?? 0)
    )
    const error = state.favoriteCourses.error || accountNotifications.error
    return {
      pending,
      error,
      liveConferences,
      announcements,
      courses,
      concludedCourses,
      totalCourseCount,
      isFullDashboard,
      groups,
      allCourses: allCoursesStringKeys,
      sections,
      enrollments,
      hideOverlays: state.userInfo.userSettings.hide_dashcard_color_overlays || false,
      canActAsUser: state.userInfo.canActAsUser,
    }
  }
}

const Refreshed = refresh(
  props => {
    props.refreshNotifications()
    props.refreshCourses()
    props.refreshUserEnrollments()
    props.refreshGroupFavorites()
    props.getDashboardCards()
    props.getUserSettings()
    props.refreshCanActAsUser()

    if (isStudent()) {
      props.refreshLiveConferences()
      props.refreshUsersGroups()
    }
  },
  props => props.courses.length === 0 ||
    (isStudent() && props.groups.length === 0) ||
    (isStudent() && Object.keys(props.enrollments).length === 0),
  props => Boolean(props.pending)
)(Dashboard)
const Connected = connect(mapStateToProps(true), {
  ...AccountNotificationActions,
  ...CoursesActions,
  ...EnrollmentsActions,
  ...GroupsActions,
  ...GroupsFavoriteActions,
  ...DashboardActions,
  ...UserInfoActions,
})(Refreshed)
export default Connected
