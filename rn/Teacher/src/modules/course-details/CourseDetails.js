/**
* Launching pad for navigation for a single course
* @flow
*/

import React, { Component, PropTypes } from 'react'
import { connect } from 'react-redux'
import {
  View,
  ScrollView,
  Text,
  Image,
  StyleSheet,
} from 'react-native'

import Images from '../../images'
import i18n from 'format-message'
import CourseDetailsActions from './actions'
import CourseDetailsTab from './components/CourseDetailsTab'
import { stateToProps } from './props'

type Props = {
  course: Course,
  tabs: Tab[],
  courseColors: string[],
  refreshTabs: () => void,
}

export class CourseDetails extends Component<any, Props, any> {
  static navigatorStyle = {
    drawUnderNavBar: true,
    navBarTranslucent: true,
    navBarTransparent: true,
  }

  static navigatorButtons = {
    rightButtons: [{
      icon: Images.course.settings,
      title: i18n({
        default: 'Edit',
        description: 'Shown at the top of the course details screen.',
      }),
    }],
  }

  editCourse () {
  }

  componentDidMount () {
    this.props.refreshTabs(this.props.course.id)
  }

  selectTab (tab: Tab) {
  }

  render (): React.Element<View> {
    const course = this.props.course
    const courseColor = this.props.courseColors[course.id]

    const tabs = this.props.tabs.sort((a, b) => a.position - b.position).map((tab) => {
      return <CourseDetailsTab tab={tab} courseColor={courseColor} onPress={this.selectTab} />
    })

    return (
      <ScrollView style={styles.container}>
        <View style={styles.header}>
          <View style={styles.headerImageContainer}>
            <Image style={styles.headerImage} source={ { uri: course.image_download_url } } />
            <View style={[styles.headerImageOverlay, { backgroundColor: courseColor }]} />
          </View>

          <Text style={styles.headerTitle}>{course.name}</Text>
          <Text style={styles.headerSubtitle}>Spring 2017</Text>
        </View>
        <View style={styles.tabContainer}>
          {tabs}
        </View>
      </ScrollView>
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
    paddingTop: 64,
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
    backgroundColor: 'red',
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
  courseColors: PropTypes.objectOf(React.PropTypes.string).isRequired,
}

export default connect(stateToProps, CourseDetailsActions)(CourseDetails)
