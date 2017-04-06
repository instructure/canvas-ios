/**
* Launching pad for navigation for a single course
* @flow
*/

import React, { Component, PropTypes } from 'react'
import { connect } from 'react-redux'
import {
  View,
  Text,
  Image,
  StyleSheet,
  ActivityIndicator,
} from 'react-native'

import Images from '../../../images'
import CourseDetailsActions from '../tabs/actions'
import CourseActions from '../actions'
import CourseDetailsTab from './components/CourseDetailsTab'
import mapStateToProps, { type CourseDetailsProps } from './map-state-to-props'
import Button from 'react-native-button'
import NavigationBackButton from '../../../common/components/NavigationBackButton'
import { route } from '../../../routing'
import refresh from '../../../utils/refresh'
import { RefreshableScrollView } from '../../../common/components/RefreshableList'

type Props = CourseDetailsProps & NavProps

export class CourseDetails extends Component<any, Props, any> {

  static navigatorStyle = {
    navBarHidden: true,
  }

  state = { refreshing: false }

  componentWillReceiveProps () {
    this.setState({ refreshing: this.state.refreshing && Boolean(this.props.pending) })
  }

  selectTab = (tab: Tab) => {
    const destination = route(tab.html_url)
    this.props.navigator.push(destination)
  }

  back = () => {
    this.props.navigator.pop()
  }

  editCourse = () => {
    if (this.props.course) {
      let destination = route(`/courses/${this.props.course.id}/settings`)
      this.props.navigator.showModal(destination)
    }
  }

  refresh = () => {
    this.setState({
      refreshing: true,
    })
    this.props.refresh()
  }

  render (): React.Element<View> {
    const course = this.props.course
    const courseColor = this.props.color

    if (!course) {
      return <ActivityIndicator />
    }

    const tabs = this.props.tabs.map((tab) => {
      return <CourseDetailsTab key={tab.id} tab={tab} courseColor={courseColor} onPress={this.selectTab} />
    })

    return (
      <RefreshableScrollView
        style={styles.container}
        refreshing={this.state.refreshing}
        onRefresh={this.props.refresh}
      >
        <View style={styles.header}>
          <View style={styles.headerImageContainer}>
            {Boolean(course.image_download_url) &&
                <Image source={{ uri: course.image_download_url }} style={styles.headerImage} />
            }
            <View style={[styles.headerImageOverlay, { backgroundColor: courseColor }]} />
          </View>
          <View style={styles.navigationBar}>
            <NavigationBackButton onPress={this.back} testID='course-details.navigation-back-btn' />
            <Text style={styles.navigationTitle}>{course.course_code}</Text>
            <Button style={[styles.settingsButton]} onPress={this.editCourse} testID='course-details.navigation-edit-course-btn'>
              <View style={{ paddingLeft: 20 }}>
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
      </RefreshableScrollView>
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
    fontWeight: 'bold',
    fontSize: 20,
    textAlign: 'center',
    marginBottom: 2,
  },
  headerSubtitle: {
    color: 'white',
    opacity: 0.75,
    backgroundColor: 'transparent',
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

let Refreshed = refresh(
  props => {
    props.refreshCourses()
    props.refreshTabs(props.courseID)
  },
  props => !props.course || props.tabs.length === 0
)(CourseDetails)
let Connected = connect(mapStateToProps, { ...CourseDetailsActions, ...CourseActions })(Refreshed)
export default (Connected: Component<any, Props, any>)
