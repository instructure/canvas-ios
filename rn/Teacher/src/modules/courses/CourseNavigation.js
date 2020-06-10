//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

/**
* Launching pad for navigation for a single course
* @flow
*/

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  processColor,
  NativeModules,
  Alert,
  Linking,
} from 'react-native'

import Images from '../../images'
import CourseDetailsActions from './tabs/actions'
import CourseActions from './actions'
import LTIActions from '../external-tools/actions'
import UserInfoActions from '../userInfo/actions'
import refresh from '../../utils/refresh'
import Screen from '../../routing/Screen'
import i18n from 'format-message'
import ActivityIndicatorView from '../../common/components/ActivityIndicatorView'
import currentWindowTraits from '../../utils/windowTraits'
import { isTeacher, isStudent } from '../app'
import * as LTITools from '../../common/LTITools'
import TabsList from '../tabs/TabsList'
import { logEvent } from '../../common/CanvasAnalytics'
import showColorOverlayForCourse from '../../common/show-color-overlay-for-course'
import { getFakeStudent } from '../../canvas-api'

type RoutingParams = {
  +courseID: string,
}

export type CourseNavigationDataProps = {
  pending: number,
  error?: ?string,
  tabs: Array<Tab>,
  course: ?Course,
  color: string,
  attendanceTabID: ?string,
  showColorOverlay: boolean,
}

export type CourseNavigationProps = CourseNavigationDataProps
  & typeof CourseActions
  & typeof UserInfoActions
  & RoutingParams
  & RefreshProps
  & { navigator: Navigator }

const { NativeLogin } = NativeModules

export class CourseNavigation extends Component<CourseNavigationProps, any> {
  static defaultProps = {
    getFakeStudent,
  }

  state = {
    windowTraits: currentWindowTraits(),
    selectedTabId: null,
    loadingStudentView: false,
  }

  homeDidShow: boolean = false

  async getFakeStudentID () {
    let { data } = await this.props.getFakeStudent(this.props.courseID)
    return data?.id
  }

  componentWillMount () {
    this.props.navigator.traitCollection((traits) => {
      this.setState({ windowTraits: traits.window })
    })
  }

  editCourse = () => {
    let course = this.props.course || {}
    this.props.navigator.show(`/courses/${course.id}/settings`, { modal: true, modalPresentationStyle: 'formsheet' })
  }

  launchStudentView = async () => {
    let showError = () => {
      Alert.alert(
        i18n('Error'),
        i18n('Please try again.'),
        [
          { text: i18n('OK'), onPress: null, style: 'cancel' },
        ]
      )
    }
    this.setState({ loadingStudentView: true })
    try {
      let fakeStudentID = await this.getFakeStudentID()
      if (fakeStudentID == null) {
        showError()
        return
      }
      let canOpen = await Linking.canOpenURL('canvas-student:')
      if (!canOpen) {
        return Linking.openURL('https://apps.apple.com/us/app/canvas-student/id480883488')
      }
      NativeLogin.actAsFakeStudentWithID(fakeStudentID)
    } catch (e) {
      showError()
    }
    this.setState({ loadingStudentView: false })
  }

  onTraitCollectionChange = () => {
    this.props.navigator.traitCollection((traits) => {
      if (
        this.state.windowTraits.horizontal === 'compact' &&
        traits.window.horizontal !== 'compact'
      ) {
        this.homeDidShow = false
      }
      this.setState({ windowTraits: traits.window })
    })
  }

  selectTab = (tab: Tab) => {
    logEvent('course_tab_selected', { tabId: tab.id })
    if (tab.id === this.props.attendanceTabID && this.props.course) {
      const toolID = tab.id.replace('context_external_tool_', '')
      this.props.navigator.show(`/courses/${this.props.courseID}/attendance/${toolID}`)
    } else {
      if (tab.type === 'external' && tab.url) {
        LTITools.launchExternalTool(tab.url)
      } else {
        if (tab.id === 'pages') {
          const url = `/courses/${this.props.courseID}/pages`
          this.props.navigator.show(url)
        } else if (tab.id === 'collaborations' || tab.id === 'conferences' || tab.id === 'outcomes') {
          this.props.navigator.show(tab.full_url)
        } else if (tab.id === 'student-view') {
          this.launchStudentView()
        } else if (isTeacher() || tab.id === 'syllabus') {
          this.props.navigator.show(tab.html_url)
        } else if (tab.id === 'home' && this.props.course && this.props.course.default_view === 'wiki') {
          const url = `/courses/${this.props.courseID}/pages/front_page`
          this.props.navigator.show(url)
        } else if (tab.id === 'people' && isStudent()) {
          this.props.navigator.show(tab.html_url)
        } else if (tab.id === 'home' && this.props.course && this.props.course.default_view) {
          let view = this.props.course.default_view
          if (view === 'feed') {
            view = 'activity_stream'
          }
          let url = `native-route/courses/${this.props.courseID}/${view}`
          if (view === 'assignments') {
            // Jira: MBL-10948
            // This block is a hack because the native-route resolver does not use the props that are passed in until
            // after the route is handled and a Helm view controller is created. So instead of using props, we use a
            // one-off route subpath. See Routes.swift
            url += '-fromHomeTab'
          }
          this.props.navigator.show(url, undefined, { color: processColor(this.props.color) })
        } else {
          const url = `/native-route-master${tab.html_url}`
          this.props.navigator.show(url)
        }
      }
    }
    if (this.state.windowTraits.horizontal !== 'compact' && tab.type !== 'external') {
      this.setState({ selectedTabId: tab.id })
    }
  }

  showHome () {
    if (this.homeDidShow) return
    if (this.props.tabs.length) {
      if (this.state.windowTraits.horizontal !== 'compact' && !this.props.navigator.isModal) {
        const home = this.props.tabs.find(({ id }) => id === 'home')
        if (home) {
          this.homeDidShow = true
          Promise.resolve().then(() => this.selectTab(home))
        } else if (this.props.course) {
          this.homeDidShow = true
          this.props.navigator.show(`/courses/${this.props.course.id}/placeholder`, {}, { courseColor: this.props.color, course: this.props.course })
        }
      }
    }
  }

  render () {
    this.showHome()
    const course = this.props.course
    const courseColor = this.props.color
    if (!course) return <ActivityIndicatorView />
    const courseCode = course.course_code || ''
    const name = course.name || ''
    const termName = (course.term || {}).name || ''

    let compactMode = this.state.windowTraits.horizontal === 'compact'
    let screenProps = {}
    if (compactMode) {
      // when we have the color overlay we want the nav bar to be transparent
      screenProps.navBarTransparent = this.props.showColorOverlay
      screenProps.automaticallyAdjustsScrollViewInsets = false
      screenProps.drawUnderNavBar = true
    } else {
      screenProps.automaticallyAdjustsScrollViewInsets = true
      screenProps.navBarTransparent = false
    }

    let rightBarButtons = []
    if (isTeacher()) {
      rightBarButtons.push({
        image: Images.course.settings,
        testID: 'course-details.navigation-edit-course-btn',
        action: this.editCourse,
        accessibilityLabel: i18n('Edit course settings'),
      })
    }

    return (
      <Screen
        title={courseCode}
        navBarColor={courseColor}
        navBarStyle='context'
        onTraitCollectionChange={this.onTraitCollectionChange}
        {...screenProps}
        disableGlobalSafeArea
        rightBarButtons={rightBarButtons}
      >
        <TabsList
          tabs={this.props.tabs}
          title={name}
          subtitle={termName}
          color={courseColor}
          showColorOverlay={this.props.showColorOverlay}
          defaultView={course.default_view}
          imageURL={course.image_download_url}
          onSelectTab={this.selectTab}
          refreshing={this.props.refreshing}
          onRefresh={this.props.refresh}
          attendanceTabID={this.props.attendanceTabID}
          selectedTabId={this.state.selectedTabId}
          windowTraits={this.state.windowTraits}
          loadingStudentView={this.state.loadingStudentView}
        />
      </Screen>
    )
  }
}

export function mapStateToProps (state: AppState, { courseID }: RoutingParams): CourseNavigationDataProps {
  let courseState = state.entities.courses[courseID]

  if (!courseState) {
    return {
      pending: 0,
      tabs: [],
      course: null,
      color: '',
      attendanceTabID: null,
      showColorOverlay: true,
    }
  }

  const {
    course,
    color,
    permissions,
  } = courseState

  const pending = state.favoriteCourses.pending +
    courseState.tabs.pending +
    courseState.attendanceTool.pending

  const attendanceTabID = courseState.attendanceTool.tabID

  const availableCourseTabs = ['assignments', 'quizzes', 'discussions', 'announcements', 'people', 'pages', 'files', 'modules']
  if (attendanceTabID) availableCourseTabs.push(attendanceTabID)

  let tabs = courseState.tabs.tabs
    .filter((tab) => {
      if (tab.id === attendanceTabID && tab.hidden) return false
      if (isStudent() || tab.id.includes('external_tool')) return !tab.hidden
      return availableCourseTabs.includes(tab.id)
    })
    .sort((t1, t2) => (t1.position - t2.position))

  if (isTeacher() && permissions?.use_student_view) {
    tabs.push({
      id: 'student-view',
      label: i18n('Student View'),
      subtitle: i18n('Opens in Canvas Student'),
      visibility: 'public',
      position: Math.max(),
    })
  }
  const error = state.favoriteCourses.error || courseState.tabs.error

  return {
    course,
    color,
    tabs,
    pending,
    error,
    attendanceTabID,
    showColorOverlay: showColorOverlayForCourse(course, state.userInfo.userSettings.hide_dashcard_color_overlays || false),
    permissions,
  }
}

export let Refreshed: any = refresh(
  props => {
    if (isTeacher()) {
      props.refreshLTITools(props.courseID)
    }
    props.refreshCourse(props.courseID)
    props.refreshTabs(props.courseID)
    props.getUserSettings()
    props.getCoursePermissions(props.courseID)
  },
  props => !props.course || props.tabs.length === 0,
  props => Boolean(props.pending)
)(CourseNavigation)
let Connected = connect(mapStateToProps, {
  ...CourseDetailsActions,
  ...CourseActions,
  ...LTIActions,
  ...UserInfoActions,
})(Refreshed)
export default (Connected: Component<CourseNavigationProps, any>)
