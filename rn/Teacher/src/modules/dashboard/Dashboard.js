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

import React, { type Element, type ComponentType } from 'react'
import {
  View,
  SectionList,
  StyleSheet,
} from 'react-native'
import Screen from '@routing/Screen'
import { connect } from 'react-redux'
import refresh from '@utils/refresh'
import localeSort from '@utils/locale-sort'
import i18n from 'format-message'
import App, { isTeacher, isStudent } from '@modules/app'
import CoursesActions from '@modules/courses/actions'
import EnrollmentsActions from '@modules/enrollments/actions'
import GroupsActions from '@modules/groups/actions'
import GroupsFavoriteActions from '@modules/groups/favorites/actions'
import {
  Heading1,
} from '@common/text'
import {
  LinkButton,
} from '@common/buttons'
import GlobalAnnouncementRow from './GlobalAnnouncementRow'
import CourseInvite from './CourseInvite'
import GroupRow, { type GroupRowProps } from './GroupRow'
import CourseCard from '@modules/courses/components/CourseCard'
import NoCourses from '@modules/courses/components/NoCourses'
import color from '@common/colors'
import Images from '@images'
import branding from '@common/branding'
import Navigator from '@routing/Navigator'
import { getSessionUnsafe, getSession } from '@canvas-api'
import AccountNotificationActions from './account-notification-actions'
import { extractGradeInfo } from '@utils/course-grades'
import { extractDateFromString } from '@utils/dateUtils'
import { featureFlagEnabled } from '@common/feature-flags'

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
  showGrades?: boolean,
}
type State = {
  width?: number,
  cardSize?: number,
  contentWidth?: number,
  showingModal: boolean,
  fetchingEnrollments: boolean,
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
  state: State = {
    showingModal: false,
    fetchingEnrollments: false,
  }

  componentWillReceiveProps (newProps: Props) {
    if (newProps.isFullDashboard &&
        !newProps.pending &&
        !newProps.error &&
        !newProps.totalCourseCount &&
        !this.state.showingModal &&
        isTeacher() &&
        getSessionUnsafe()) {
      this.props.navigator.show('/notATeacher', { modal: true })
      this.setState({
        showingModal: true,
      })
    }
  }

  calculateLayout = (width: number) => {
    const contentWidth = width - padding - padding
    const columns = Math.floor(contentWidth / MIN_CARD_SIZE)
    const cardSize = contentWidth / columns
    this.setState({ cardSize, width, contentWidth })
  }

  onLayout = ({ nativeEvent }: { nativeEvent: { layout: { width: number }}}) => {
    this.calculateLayout(nativeEvent.layout.width)
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
        course={item}
        grade={extractGradeInfo(item)}
        showGrade={this.props.showGrades}
        onPress={this.selectCourse}
        onCoursePreferencesPressed={this.showUserCoursePreferences}
        initialHeight={cardSize}
      />
    )
  }

  renderNoFavorites = () => {
    const { contentWidth } = this.state

    return (
      <NoCourses
        key='no-courses'
        onAddCoursePressed={this.showFavoritesList}
        style={{ width: contentWidth, height: 300 }}
      />
    )
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

    // Announcements
    sections.push({
      sectionID: 'dashboard.announcements',
      data: this.props.announcements,
      renderItem: this.renderGlobalAnnouncement,
      keyExtractor: ({ id }: AccountNotification) => id,
    })

    // Course Invites
    if (this.props.enrollments.length > 0) {
      let courseInvites = this.props.enrollments.filter(en => {
        return en.displayState === 'acted' || en.enrollment_state === 'invited'
      })
      sections.push({
        sectionID: 'dashboard.courseInvites',
        data: courseInvites,
        renderItem: this.renderCourseInvite,
        keyExtractor: ({ id }: Invite) => `enrollment-${id}`,
      })
    }

    // Courses
    if (this.props.courses.length > 0) {
      sections.push({
        ...coursesHeader,
        data: this.props.courses,
        renderItem: this.renderCourseCard,
        keyExtractor: ({ id }: ColorfulCourse) => id,
      })
    } else if (!this.props.pending) {
      sections.push({
        ...coursesHeader,
        data: [{ key: 'welcome' }],
        renderItem: this.renderNoFavorites,
      })
    }

    // Groups
    if (isStudent() &&
        this.props.groups &&
        this.props.groups.length > 0) {
      sections.push({
        sectionID: 'dashboard.groups',
        title: i18n('Groups'),
        data: this.props.groups,
        renderItem: this.renderGroup,
        keyExtractor: ({ id }: GroupRowProps) => id,
      })
    }

    return sections
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
    this.props.navigator.show(`/courses/${course.id}`)
  }

  showAllCourses = () => {
    this.props.navigator.show('/courses')
  }

  showProfile = () => {
    this.props.navigator.show('/profile', { modal: true, modalPresentationStyle: 'drawer' })
  }

  showGroup = (groupID: string) => {
    this.props.navigator.show(`/groups/${groupID}`)
  }

  screenProps = () => {
    return !this.props.isFullDashboard
      ? { title: i18n('All Courses') }
      : {
        navBarImage: branding.headerImage,
        rightBarButtons: [{
          title: i18n('Edit'),
          testID: 'dashboard.edit-btn',
          action: this.showFavoritesList,
          disabled: !this.props.totalCourseCount,
        }],
        leftBarButtons: [
          {
            image: Images.hamburger,
            testID: 'favorited-course-list.profile-btn',
            action: this.showProfile,
            accessibilityLabel: i18n('Profile Menu'),
          },
        ],
      }
  }

  render () {
    return (
      <Screen
        { ...this.screenProps() }
        navBarHidden={false}
        navBarColor={color.navBarColor}
        navBarButtonColor={color.navBarTextColor}
        statusBarStyle={color.statusBarStyle}
      >{
          this.renderDashboard()
        }</Screen>
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

    const { courseRefs } = state.favoriteCourses
    let courseStates = []
    let concludedCourseStates = []
    if (isFullDashboard) {
      // we only want favorite courses here
      courseStates = courseRefs.map(ref => allCourses[ref])
    } else {
      // all courses view
      const blacklist = ['invited', 'rejected'] // except invited and rejected
      const filterFunc = (concluded: boolean) => {
        return (c: CourseState) => {
          if (blacklist.includes(c.course.enrollments[0].enrollment_state)) return false
          return concluded ? isCourseConcluded(c.course) : !isCourseConcluded(c.course)
        }
      }
      courseStates = allCourseStates.filter(filterFunc(false))
      concludedCourseStates = allCourseStates.filter(filterFunc(true))
    }

    const prepareCourses = (states: Array<CourseState>): Array<ColorfulCourse> => {
      return states
        .map(({ course, color }) => ({ ...course, color }))
        .filter(App.current().filterCourse)
        .sort((c1, cs2) => localeSort(c1.name, cs2.name))
    }

    const courses: Array<ColorfulCourse> = prepareCourses(courseStates)
    const concludedCourses: Array<ColorfulCourse> = prepareCourses(concludedCourseStates)

    const announcements = accountNotifications.list
      .filter(({ id }) => !accountNotifications.closing.includes(id))

    const groupFavorites = state.favoriteGroups.groupRefs
    const userHasFavoriteGroups = state.favoriteGroups.userHasFavoriteGroups
    let groups = Object.keys(state.entities.groups)
      .filter(id => {
        if (state.entities.groups[id] && state.entities.groups[id].group) {
          let group = state.entities.groups[id].group
          return !group.concluded && (!group.course_id || (group.course_id && state.entities.courses[group.course_id]))
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
          color: groupColor || (courseData ? courseData.color : color.lightText),
        }
      })

    if (featureFlagEnabled('favoriteGroups')) {
      if (userHasFavoriteGroups) { groups = groups.filter((g) => groupFavorites.includes(g.id)) }
    }

    const pending = state.favoriteCourses.pending + accountNotifications.pending
    const error = state.favoriteCourses.error || accountNotifications.error
    const showGrades = state.userInfo.showsGradesOnCourseCards
    return { pending, error, announcements, courses, concludedCourses, totalCourseCount, isFullDashboard, groups, showGrades, allCourses: allCoursesStringKeys, sections, enrollments }
  }
}

const Refreshed = refresh(
  props => {
    props.refreshNotifications()
    props.refreshCourses()
    props.refreshUserEnrollments()
    props.refreshGroupFavorites()

    if (isStudent()) {
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
})(Refreshed)
export default Connected
