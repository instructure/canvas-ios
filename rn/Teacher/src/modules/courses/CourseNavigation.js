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

/**
* Launching pad for navigation for a single course
* @flow
*/

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  processColor,
} from 'react-native'

import Images from '../../images'
import CourseDetailsActions from './tabs/actions'
import CourseActions from './actions'
import LTIActions from '../external-tools/actions'
import refresh from '../../utils/refresh'
import Screen from '../../routing/Screen'
import i18n from 'format-message'
import ActivityIndicatorView from '../../common/components/ActivityIndicatorView'
import currentWindowTraits from '../../utils/windowTraits'
import { isTeacher, isStudent } from '../app'
import * as LTITools from '../../common/LTITools'
import TabsList from '../tabs/TabsList'

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
}

export type CourseNavigationProps = CourseNavigationDataProps
  & typeof CourseActions
  & RoutingParams
  & RefreshProps
  & { navigator: Navigator }

export class CourseNavigation extends Component<CourseNavigationProps, any> {
  state = {
    windowTraits: currentWindowTraits(),
    selectedTabId: null,
  }

  homeDidShow: boolean = false

  componentWillMount () {
    this.props.navigator.traitCollection((traits) => {
      this.setState({ windowTraits: traits.window })
    })
  }

  editCourse = () => {
    let course = this.props.course || {}
    this.props.navigator.show(`/courses/${course.id}/settings`, { modal: true, modalPresentationStyle: 'formsheet' })
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
    if (tab.id === this.props.attendanceTabID && tab.url && this.props.course) {
      this.props.navigator.show('/attendance', {}, {
        launchURL: tab.url,
        courseName: this.props.course.name,
        courseID: this.props.courseID,
        courseColor: processColor(this.props.color),
      })
    } else {
      if (tab.type === 'external' && tab.url) {
        LTITools.launchExternalTool(tab.url)
      } else {
        if (isTeacher()) {
          this.props.navigator.show(tab.html_url)
        } else if (tab.id === 'home' && this.props.course && this.props.course.default_view === 'wiki') {
          const url = `/courses/${this.props.courseID}/pages/front_page`
          this.props.navigator.show(url)
        } else if (tab.id === 'home' && this.props.course && this.props.course.default_view) {
          let view = this.props.course.default_view
          if (view === 'feed') {
            view = 'activity_stream'
          }
          const url = `native-route/courses/${this.props.courseID}/${view}`
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
      screenProps.navBarTransparent = true
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
        navBarStyle='dark'
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
          defaultView={course.default_view}
          imageURL={course.image_download_url}
          onSelectTab={this.selectTab}
          refreshing={this.props.refreshing}
          onRefresh={this.props.refresh}
          attendanceTabID={this.props.attendanceTabID}
          selectedTabId={this.state.selectedTabId}
          windowTraits={this.state.windowTraits}
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
    }
  }

  const {
    course,
    color,
  } = courseState

  const pending = state.favoriteCourses.pending +
    courseState.tabs.pending +
    courseState.attendanceTool.pending

  const attendanceTabID = courseState.attendanceTool.tabID

  const availableCourseTabs = ['assignments', 'quizzes', 'discussions', 'announcements', 'people', 'pages', 'files']
  if (attendanceTabID) availableCourseTabs.push(attendanceTabID)

  const tabs = courseState.tabs.tabs
    .filter((tab) => {
      if (tab.id === attendanceTabID && tab.hidden) return false
      if (isStudent()) return !tab.hidden
      return (availableCourseTabs.includes(tab.id) || tab.id.includes('external_tool')) && !tab.hidden
    })
    .sort((t1, t2) => (t1.position - t2.position))
  const error = state.favoriteCourses.error || courseState.tabs.error

  return {
    course,
    color,
    tabs,
    pending,
    error,
    attendanceTabID,
  }
}

export let Refreshed: any = refresh(
  props => {
    if (isTeacher()) {
      props.refreshLTITools(props.courseID)
    }
    props.refreshCourses()
    props.refreshTabs(props.courseID)
  },
  props => !props.course || props.tabs.length === 0,
  props => Boolean(props.pending)
)(CourseNavigation)
let Connected = connect(mapStateToProps, { ...CourseDetailsActions, ...CourseActions, ...LTIActions })(Refreshed)
export default (Connected: Component<CourseNavigationProps, any>)
