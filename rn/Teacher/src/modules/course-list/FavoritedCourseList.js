// @flow

import React, { Component, PropTypes } from 'react'
import {
  Dimensions,
  View,
  Text,
  Image,
  StyleSheet,
} from 'react-native'

import { LinkButton } from '../../common/buttons'
import i18n from 'format-message'
import { stateToProps } from './props'
import CoursesActions from './actions'
import { connect } from 'react-redux'
import CourseList from './components/CourseList'
import NoCourses from './NoCourses'
import { route } from '../../routing'

const { width: deviceWidth } = Dimensions.get('window')

type Props = {
  navigator: ReactNavigator,
  refreshCourses: () => void,
  courses: Array<Course>,
  customColors: { [string]: string },
  error?: string,
  pending?: number,
}

export class FavoritedCourseList extends Component {
  props: Props

  static navigatorButtons = {
    rightButtons: [
      {
        title: i18n({
          default: 'Edit',
          description: 'Shown at the top of the app to allow the user to edit their course list',
        }),
        id: 'edit',
        testID: 'e2e_rules',
      },
    ],
    leftButtons: [{
      title: i18n({
        default: 'Leave Feedback',
        description: 'Shown at the top of the app to allow the user to leave feedback',
      }),
      icon: require('../../images/feedback.png'),
    }],
  }

  constructor (props: Props) {
    super(props)
    props.refreshCourses()
    props.navigator.setOnNavigatorEvent(this.onNavigatorEvent)
  }

  onNavigatorEvent = (event: NavigatorEvent) => {
    if (event.type === 'NavBarButtonPress') {
      if (event.id === 'edit') {
        this.showFavoritesList()
      }
    }
  }

  showFavoritesList = () => {
    let destination = route('/course_favorites')
    this.props.navigator.showModal({
      ...destination,
      animationType: 'slide-up',
      title: i18n({
        default: 'Edit Courses',
        description: 'The title of the screen enabling teachers to favorite and unfavorite their courses',
      }),
    })
  }

  selectCourse = (course: Course) => {
    let destination = route('/courses/' + course.id)
    this.props.navigator.push(destination)
  }

  goToAllCourses = () => {
    let destination = route('/courses')
    this.props.navigator.push({
      ...destination,
      title: i18n({
        default: 'All Courses',
        description: `The title of the screen showing all of a teacher's courses`,
      }),
      backButtonTitle: i18n({
        id: 'back_courses',
        default: 'Courses',
        description: 'The back button title to go from all courses to just favorited courses',
      }),
    })
  }

  renderHeader = () => {
    return (
      <View style={styles.header}>
        <View style={styles.headerTextWrapper}>
          <Image source={require('../../images/star-filled.png')} />
          <Text style={styles.headerText}>
            {i18n({
              default: 'Courses',
              description: 'The header for the favorited courses list',
            })}
          </Text>
        </View>
        <LinkButton onPress={this.goToAllCourses} testID='course-list.see-all-btn'>
            {i18n({
              default: 'See All',
              description: 'Button to transition from favorited courses list to all courses list',
            })}
        </LinkButton>
      </View>
    )
  }

  render (): React.Element<any> {
    let courses = this.props.courses.filter(course => course.is_favorite)

    if (!this.props.pending && !courses.length) {
      return (
        <NoCourses
          onAddCoursePressed={this.showFavoritesList}
        />
      )
    }

    return (
      <CourseList
        {...this.props}
        courses={courses}
        selectCourse={this.selectCourse}
        width={deviceWidth}
        header={this.renderHeader()}
      />
    )
  }
}

const courseListShape = PropTypes.shape({
  id: PropTypes.number.isRequired,
  name: PropTypes.string.isRequired,
  course_code: PropTypes.string.isRequired,
  short_name: PropTypes.string,
  color: PropTypes.string,
  image_download_url: PropTypes.string,
}).isRequired

FavoritedCourseList.propTypes = {
  courses: PropTypes.arrayOf(courseListShape).isRequired,
  pending: PropTypes.number,
  error: PropTypes.string,
}

const styles = StyleSheet.create({
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-end',
    marginTop: 8,
  },
  headerTextWrapper: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  headerText: {
    fontSize: 20,
    fontWeight: '600',
    marginLeft: 6,
  },
  seeAll: {
    fontSize: 14,
    color: '#6495ed',
    fontWeight: '500',
  },
})

let Connected = connect(stateToProps, CoursesActions)(FavoritedCourseList)
export default (Connected: Component<any, Props, any>)
