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
import PropTypes from 'prop-types'
import { connect } from 'react-redux'
import {
  View,
  StyleSheet,
  Animated,
  RefreshControl,
  processColor,
  DeviceInfo,
} from 'react-native'

import Images from '../../../images'
import CourseDetailsActions from '../tabs/actions'
import CourseActions from '../actions'
import CourseDetailsTab from './components/CourseDetailsTab'
import CourseDetailsHomeTab from './components/CourseDetailsHomeTab'
import LTIActions from '../../external-tools/actions'
import mapStateToProps, { type CourseDetailsProps } from './map-state-to-props'
import refresh from '../../../utils/refresh'
import Screen from '../../../routing/Screen'
import i18n from 'format-message'
import ActivityIndicatorView from '../../../common/components/ActivityIndicatorView'
import OnLayout from 'react-native-on-layout'
import currentWindowTraits from '../../../utils/windowTraits'
import { isTeacher, isStudent } from '../../app'

export class CourseDetails extends Component<CourseDetailsProps, any> {
  state = {
    windowTraits: currentWindowTraits(),
    selectedTabId: null,
  }

  homeDidShow: boolean = false
  animatedValue: Animated.Value = new Animated.Value(-235)
  animate = Animated.event(
    [{ nativeEvent: { contentOffset: { y: this.animatedValue } } }],
  )

  componentWillMount () {
    this.props.navigator.traitCollection((traits) => {
      this.setState({ windowTraits: traits.window })
    })
  }

  selectTab = (tab: Tab) => {
    if (tab.id === this.props.attendanceTabID && tab.url) {
      this.props.navigator.show('/attendance', {}, {
        launchURL: tab.url,
        courseName: this.props.course.name,
        courseID: this.props.courseID,
        courseColor: processColor(this.props.color),
      })
    } else {
      if (isTeacher()) {
        this.props.navigator.show(tab.html_url)
      } else {
        if (tab.type === 'external' && tab.url) {
          this.props.navigator.launchExternalTool(tab.url)
        } else {
          const url = `/courses/${this.props.courseID}/tabs/${tab.id}`
          this.props.navigator.show(url)
        }
      }
    }
    if (this.state.windowTraits.horizontal !== 'compact' && tab.type !== 'external') {
      this.setState({ selectedTabId: tab.id })
    }
  }

  back = () => {
    this.props.navigator.dismiss()
  }

  editCourse = () => {
    this.props.navigator.show(`/courses/${this.props.course.id}/settings`, { modal: true, modalPresentationStyle: 'formsheet' })
  }

  showHome () {
    if (this.homeDidShow || !this.props.course || !this.props.tabs.length) return
    this.homeDidShow = true
    if (this.state.windowTraits.horizontal !== 'compact') {
      const home = this.props.tabs.find(({ id }) => id === 'home')
      if (home) {
        Promise.resolve().then(() => this.selectTab(home))
      } else {
        this.props.navigator.show(`/courses/${this.props.course.id}/placeholder`, {}, { courseColor: this.props.color, course: this.props.course })
      }
    }
  }

  onTraitCollectionChange () {
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

  onScroll = (event: any) => {
    const offsetY = event.nativeEvent.contentOffset.y
    // Random bug/issue with rn or ios
    // Sometimes this would randomly be reported as 0, which is impossible based on our content inset/offsets
    if (offsetY !== 0) {
      this.animate(event)
    }
  }

  renderTab = (tab: Tab) => {
    const props = {
      key: tab.id,
      tab,
      courseColor: this.props.color,
      onPress: this.selectTab,
      attendanceTabID: this.props.attendanceTabID,
      testID: `courses-details.tab.${tab.id}`,
      selected: this.state.selectedTabId === tab.id,
      course: this.props.course,
    }
    if (isStudent() && tab.id === 'home') {
      return <CourseDetailsHomeTab {...props} />
    }

    return <CourseDetailsTab {...props} />
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

    let bothCompact = this.state.windowTraits.horizontal === 'compact' && this.state.windowTraits.vertical === 'compact'

    let navbarHeight = bothCompact ? 52 : 64
    let headerHeight = bothCompact ? 150 : 235
    let headerBottomContainerMarginTop = bothCompact ? 8 : 44
    let headerBottomContainerHorizontalMargin = bothCompact ? 44 : 0

    // David made me do it
    if (DeviceInfo.isIPhoneX_deprecated) {
      navbarHeight = bothCompact ? 32 : 88
    }

    let fadeOut = this.animatedValue.interpolate({
      inputRange: [-headerHeight, -navbarHeight],
      outputRange: [1, 0],
    })
    let inOffsets = {}
    if (compactMode) {
      inOffsets = {
        contentInset: { top: headerHeight },
        contentOffset: { y: -headerHeight },
      }
    }
    let rightBarButtons = []
    if (isTeacher()) {
      rightBarButtons.push({
        image: Images.course.settings,
        testID: 'course-details.navigation-edit-course-btn',
        action: this.editCourse.bind(this),
        accessibilityLabel: i18n('Edit course settings'),
      })
    }

    return (
      <Screen
        title={courseCode}
        navBarTitleColor='#fff'
        statusBarStyle='light'
        navBarColor={courseColor}
        navBarStyle='dark'
        onTraitCollectionChange={this.onTraitCollectionChange.bind(this)}
        {...screenProps}
        disableGlobalSafeArea
        rightBarButtons={rightBarButtons}
      >
        <View
          style={styles.container}
          refreshing={this.props.refreshing}
          onRefresh={this.props.refresh}
        >
          <OnLayout style={styles.tabContainer}>
            {({ height }) => (
              <Animated.ScrollView
                scrollEventThrottle={1}
                contentInsetAdjustmentBehavior='never'
                automaticallyAdjustContentInsets={false}
                onScroll={this.onScroll}
                refreshControl={
                  <RefreshControl
                    refreshing={this.props.refreshing}
                    onRefresh={this.props.refresh}
                    style={{ position: 'absolute', top: headerHeight }}
                  />
                }
                style={{ flex: 1 }}
                {...inOffsets}
              >
                <View style={{ minHeight: height - navbarHeight }}>
                  {this.props.tabs.map(this.renderTab)}
                </View>
              </Animated.ScrollView>
            )}
          </OnLayout>

          {compactMode &&
            <Animated.View
              style={[styles.header, {
                height: this.animatedValue.interpolate({
                  inputRange: [-headerHeight, -navbarHeight],
                  outputRange: [headerHeight, navbarHeight],
                  extrapolate: 'clamp',
                }),
              }]}
              pointerEvents='none'
            >
              <OnLayout style={styles.headerImageContainer}>
                {({ width }) => (
                  <View style={styles.headerImageContainer}>
                    {Boolean(course.image_download_url) &&
                        <Animated.Image
                          source={{ uri: course.image_download_url }}
                          style={[styles.headerImage, {
                            width,
                            height: this.animatedValue.interpolate({
                              inputRange: [-headerHeight, -navbarHeight],
                              outputRange: [headerHeight, navbarHeight],
                              extrapolate: 'clamp',
                            }),
                            opacity: fadeOut,
                          }]}
                          resizeMode='cover'
                        />
                    }
                    <Animated.View
                      style={[styles.headerImageOverlay, {
                        backgroundColor: courseColor,
                        opacity: this.props.course.image_download_url
                          ? this.animatedValue.interpolate({
                            inputRange: [-headerHeight, -navbarHeight],
                            outputRange: [0.8, 1],
                            extrapolate: 'clamp',
                          })
                          : 1,
                      }]}
                    />
                  </View>
                )}
              </OnLayout>

              <View style={[styles.headerBottomContainer, {
                marginTop: headerBottomContainerMarginTop,
                marginHorizontal: headerBottomContainerHorizontalMargin,
              }]} >
                <Animated.Text
                  style={[styles.headerTitle, {
                    opacity: fadeOut,
                  }]}
                  testID='course-details.title-lbl'
                  numberOfLines={3}
                >
                  {name}
                </Animated.Text>
                <Animated.Text
                  style={[styles.headerSubtitle, {
                    opacity: fadeOut,
                  }]}
                  testID='course-details.subtitle-lbl'
                >
                  {termName}
                </Animated.Text>
              </View>
            </Animated.View>
          }
        </View>
      </Screen>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    alignItems: 'center',
    justifyContent: 'center',
    padding: 10,
    paddingTop: 20,
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    overflow: 'hidden',
  },
  headerTitle: {
    backgroundColor: 'transparent',
    color: 'white',
    fontWeight: '600',
    fontSize: 24,
    textAlign: 'center',
    marginBottom: 3,
  },
  headerSubtitle: {
    color: 'white',
    opacity: 0.9,
    backgroundColor: 'transparent',
    fontWeight: '600',
  },
  headerImageContainer: {
    position: 'absolute',
    right: 0,
    left: 0,
    top: 0,
    bottom: 0,
  },
  headerImage: {
    position: 'absolute',
  },
  headerImageOverlay: {
    position: 'absolute',
    opacity: 0.75,
    right: 0,
    left: 0,
    top: 0,
    bottom: 0,
  },
  headerBottomContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  settingsButton: {
    width: 24,
  },
  navButtonImage: {
    resizeMode: 'contain',
    tintColor: 'white',
  },
  tabContainer: {
    flex: 1,
    justifyContent: 'flex-start',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
})

const tabListShape = PropTypes.shape({
  id: PropTypes.string.isRequired,
  label: PropTypes.string.isRequired,
  type: PropTypes.string.isRequired,
  hidden: PropTypes.bool,
  visibility: PropTypes.string.isRequired,
  position: PropTypes.number.isRequired,
})

CourseDetails.propTypes = {
  tabs: PropTypes.arrayOf(tabListShape).isRequired,
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
)(CourseDetails)
let Connected = connect(mapStateToProps, { ...CourseDetailsActions, ...CourseActions, ...LTIActions })(Refreshed)
export default (Connected: Component<CourseDetailsProps, any>)
