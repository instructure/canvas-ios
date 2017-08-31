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
} from 'react-native'

import Images from '../../../images'
import CourseDetailsActions from '../tabs/actions'
import CourseActions from '../actions'
import CourseDetailsTab from './components/CourseDetailsTab'
import LTIActions from '../../external-tools/actions'
import mapStateToProps, { type CourseDetailsProps } from './map-state-to-props'
import refresh from '../../../utils/refresh'
import Screen from '../../../routing/Screen'
import Navigator from '../../../routing/Navigator'
import i18n from 'format-message'
import ActivityIndicatorView from '../../../common/components/ActivityIndicatorView'
import OnLayout from 'react-native-on-layout'

export class CourseDetails extends Component<any, CourseDetailsProps, any> {
  props: CourseDetailsProps
  placeholderDidShow: boolean = false
  animatedValue: Animated.Value

  constructor (props: CourseDetailsProps) {
    super(props)
    this.state = { windowTraits: { horizontal: 'compact', vertical: 'regular' } }
    this.animatedValue = new Animated.Value(-235)
  }

  componentDidMount () {
    this.showPlaceholder()
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
      this.props.navigator.show(tab.html_url)
    }
  }

  back = () => {
    this.props.navigator.dismiss()
  }

  editCourse = () => {
    this.props.navigator.show(`/courses/${this.props.course.id}/settings`, { modal: true, modalPresentationStyle: 'formsheet' })
  }

  showPlaceholder () {
    let navigator: Navigator = this.props.navigator
    navigator.traitCollection((traits) => {
      if (traits.window.horizontal !== 'compact' && !this.placeholderDidShow && this.props.course) {
        this.placeholderDidShow = true
        this.props.navigator.show(`/courses/${this.props.course.id}/placeholder`, {}, { courseColor: this.props.color, course: this.props.course })
        this.setState({ windowTraits: traits.window })
      }
    })
  }

  onTraitCollectionChange () {
    this.props.navigator.traitCollection((traits) => {
      this.setState({ windowTraits: traits.window })
      if (!this.placeholderDidShow && this.state.windowTraits.horizontal !== 'compact') {
        this.props.navigator.show(`/courses/${this.props.course.id}/placeholder`, {}, { courseColor: this.props.color, course: this.props.course })
        this.placeholderDidShow = true
      }
    })
  }

  renderTab = (tab: Tab) => {
    return <CourseDetailsTab key={tab.id} tab={tab} courseColor={this.props.color} onPress={this.selectTab} attendanceTabID={this.props.attendanceTabID} />
  }

  render () {
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

    let fadeOut = this.animatedValue.interpolate({
      inputRange: [-235, -navbarHeight],
      outputRange: [1, 0],
    })

    let inOffsets = {}
    if (compactMode) {
      inOffsets = {
        contentInset: { top: 235 },
        contentOffset: { y: -235 },
      }
    }

    return (
      <Screen
        title={courseCode}
        navBarTitleColor={compactMode ? 'transparent' : '#fff'}
        statusBarStyle='light'
        navBarColor={courseColor}
        navBarStyle='dark'
        onTraitCollectionChange={this.onTraitCollectionChange.bind(this)}
        {...screenProps}
        rightBarButtons={[
          {
            image: Images.course.settings,
            testID: 'course-details.navigation-edit-course-btn',
            action: this.editCourse.bind(this),
            accessibilityLabel: i18n('Edit course settings'),
          },
        ]}
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
                onScroll={Animated.event(
                  [{ nativeEvent: { contentOffset: { y: this.animatedValue } } }],
                )}
                refreshControl={
                  <RefreshControl
                    refreshing={this.props.refreshing}
                    onRefresh={this.props.refresh}
                    style={{ position: 'absolute', top: 235 }}
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
                  inputRange: [-235, -navbarHeight],
                  outputRange: [235, navbarHeight],
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
                              inputRange: [-235, -navbarHeight],
                              outputRange: [235, navbarHeight],
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
                            inputRange: [-235, -navbarHeight],
                            outputRange: [0.8, 1],
                            extrapolate: 'clamp',
                          })
                          : 1,
                      }]}
                    />
                  </View>
                )}
              </OnLayout>

              <View style={styles.headerBottomContainer} >
                <Animated.Text
                  style={[styles.headerTitle, {
                    fontSize: this.animatedValue.interpolate({
                      inputRange: [-235, -navbarHeight],
                      outputRange: [24, 17],
                      extrapolate: 'clamp',
                    }),
                    transform: [{
                      translateY: this.animatedValue.interpolate({
                        inputRange: [-235, -navbarHeight],
                        outputRange: [0, bothCompact ? -8 : -7],
                        extrapolate: 'clamp',
                      }),
                    }],
                    marginHorizontal: this.animatedValue.interpolate({
                      inputRange: [-235, -navbarHeight],
                      outputRange: [0, 60],
                      extrapolate: 'clamp',
                    }),
                  }]}
                  testID='course-details.title-lbl'
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
          <Animated.Text
            style={[styles.fakeTitle, {
              opacity: fadeOut,
              top: bothCompact ? 24.5 : 33,
            }]}
            numberOfLines={1}
            ellipsizeMode='tail'
            accessible={false}
          >
            {courseCode}
          </Animated.Text>
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
    height: 235,
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
    marginTop: 44,
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
  fakeTitle: {
    position: 'absolute',
    left: 0,
    right: 0,
    backgroundColor: 'transparent',
    color: '#fff',
    fontSize: 17,
    fontWeight: '600',
    paddingHorizontal: 60,
    textAlign: 'center',
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
    props.refreshLTITools(props.courseID)
    props.refreshCourses()
    props.refreshTabs(props.courseID)
  },
  props => !props.course || props.tabs.length === 0,
  props => Boolean(props.pending)
)(CourseDetails)
let Connected = connect(mapStateToProps, { ...CourseDetailsActions, ...CourseActions, ...LTIActions })(Refreshed)
export default (Connected: Component<any, CourseDetailsProps, any>)
