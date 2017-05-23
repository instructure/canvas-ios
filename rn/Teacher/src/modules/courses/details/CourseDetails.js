/**
* Launching pad for navigation for a single course
* @flow
*/

import React, { Component, PropTypes } from 'react'
import { connect } from 'react-redux'
import {
  View,
  Image,
  StyleSheet,
  ActivityIndicator,
} from 'react-native'
import Button from 'react-native-button'

import Images from '../../../images'
import CourseDetailsActions from '../tabs/actions'
import CourseActions from '../actions'
import CourseDetailsTab from './components/CourseDetailsTab'
import mapStateToProps, { type CourseDetailsProps } from './map-state-to-props'
import NavigationBackButton from '../../../common/components/NavigationBackButton'
import refresh from '../../../utils/refresh'
import { RefreshableScrollView } from '../../../common/components/RefreshableList'
import { Text } from '../../../common/text'
import Screen from '../../../routing/Screen'
import i18n from 'format-message'
import Navigator from '../../../routing/Navigator'

export class CourseDetails extends Component<any, CourseDetailsProps, any> {

  placeholderDidShow: boolean = false

  componentDidMount () {
    this.showPlaceholder()
  }

  selectTab = (tab: Tab) => {
    this.props.navigator.show(tab.html_url)
  }

  back = () => {
    this.props.navigator.pop()
  }

  editCourse = () => {
    this.props.navigator.show(`/courses/${this.props.course.id}/settings`, { modal: true, modalPresentationStyle: 'formsheet' })
  }

  showPlaceholder () {
    let navigator: Navigator = this.props.navigator
    navigator.traitCollection((traits) => {
      if (traits.horizontal !== 'compact' && !this.placeholderDidShow && this.props.course) {
        this.placeholderDidShow = true
        this.props.navigator.show(`/courses/${this.props.course.id}/placeholder`, {}, { courseColor: this.props.color, course: this.props.course })
      }
    })
  }

  render (): React.Element<View> {
    const course = this.props.course
    const courseColor = this.props.color

    const tabs = this.props.tabs.map((tab) => {
      return <CourseDetailsTab key={tab.id} tab={tab} courseColor={courseColor} onPress={this.selectTab} />
    })

    let view
    if (!course) {
      view = <View>
               <ActivityIndicator />
             </View>
    } else {
      view = (<RefreshableScrollView
                style={styles.container}
                refreshing={this.props.refreshing}
                onRefresh={this.props.refresh}>
                <View style={styles.header}>
                  <View style={styles.headerImageContainer}>
                    {Boolean(course.image_download_url) &&
                        <Image source={{ uri: course.image_download_url }} style={styles.headerImage} />
                    }
                    <View style={[styles.headerImageOverlay, { backgroundColor: courseColor, opacity: this.props.course.image_download_url ? 0.8 : 1 }]} />
                  </View>
                  <View style={styles.navigationBar}>
                    <NavigationBackButton onPress={this.back} testID='course-details.navigation-back-btn' />
                    <Text style={styles.navigationTitle}>{course.course_code}</Text>
                    <Button style={[styles.settingsButton]} onPress={this.editCourse} testID='course-details.navigation-edit-course-btn'>
                      <View style={{ paddingLeft: 20 }} accessible={true} accessibilityLabel={i18n('Settings')} accessibilityTraits={'button'}>
                        <Image source={Images.course.settings} style={styles.navButtonImage} />
                      </View>
                    </Button>
                  </View>

                  <View style={styles.headerBottomContainer} >
                    <Text style={styles.headerTitle}>{course.name}</Text>
                    <Text style={styles.headerSubtitle}>Spring 2017</Text>
                  </View>
                </View>
                <View style={styles.tabContainer}>
                  {tabs}
                </View>
              </RefreshableScrollView>)
    }

    return (
      <Screen
        statusBarStyle='light'
        navBarHidden={true}
        navBarColor={courseColor}>
      { view }
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
    height: 235,
  },
  headerTitle: {
    backgroundColor: 'transparent',
    color: 'white',
    fontWeight: '600',
    fontSize: 24,
    textAlign: 'center',
    marginBottom: 2,
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
    width: 400,
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
  navigationBar: {
    position: 'absolute',
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingLeft: 10,
    paddingRight: 10,
    height: 44,
    top: 20,
    left: 0,
    right: 0,
  },
  navigationTitle: {
    color: 'white',
    backgroundColor: 'transparent',
    fontWeight: 'bold',
    fontSize: 18,
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
    props.refreshCourses()
    props.refreshTabs(props.courseID)
  },
  props => !props.course || props.tabs.length === 0,
  props => Boolean(props.pending)
)(CourseDetails)
let Connected = connect(mapStateToProps, { ...CourseDetailsActions, ...CourseActions })(Refreshed)
export default (Connected: Component<any, CourseDetailsProps, any>)
