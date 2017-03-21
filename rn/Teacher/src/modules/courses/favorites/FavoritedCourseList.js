// @flow

import React, { Component, PropTypes } from 'react'
import {
  Dimensions,
  View,
  Text,
  Image,
  StyleSheet,
} from 'react-native'

import { LinkButton } from '../../../common/buttons'
import i18n from 'format-message'
import { mapStateToProps } from './map-state-to-props'
import CoursesActions from '../actions'
import { connect } from 'react-redux'
import CourseList from '../components/CourseList'
import NoCourses from '../components/NoCourses'
import { route } from '../../../routing'
import colors from '../../../common/colors'
import type { CourseProps } from '../course-prop-types'
import Images from '../../../images/'

const { width: deviceWidth } = Dimensions.get('window')

type Props = {
  navigator: ReactNavigator,
  refreshCourses: () => void,
  courses: Array<CourseProps>,
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
      id: 'beta-feedback',
      icon: Images.feedback,
    }],
  }

  constructor (props: Props) {
    super(props)
    props.refreshCourses()
    props.navigator.setOnNavigatorEvent(this.onNavigatorEvent)
  }

  onNavigatorEvent = (event: NavigatorEvent) => {
    if (event.type === 'NavBarButtonPress') {
      switch (event.id) {
        case 'edit':
          this.showFavoritesList()
          break
        case 'beta-feedback':
          this.presentBetaFeedback()
          break
      }
    }
  }

  showFavoritesList = () => {
    let destination = route('/course_favorites')
    this.props.navigator.showModal({
      ...destination,
      animationType: 'slide-up',
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
      backButtonTitle: i18n({
        id: 'back_courses',
        default: 'Courses',
        description: 'The back button title to go from all courses to just favorited courses',
      }),
    })
  }

  presentBetaFeedback = () => {
    this.props.navigator.showModal(route('/beta-feedback'))
  }

  renderHeader = () => {
    return (
      <View style={styles.header}>
        <View style={styles.headerTextWrapper}>
          <Image source={Images.starFilled} />
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
    if (!this.props.pending && !this.props.courses.length) {
      return (
        <NoCourses
          onAddCoursePressed={this.showFavoritesList}
        />
      )
    }

    return (
      <CourseList
        {...this.props}
        selectCourse={this.selectCourse}
        width={deviceWidth}
        header={this.renderHeader()}
      />
    )
  }
}

const coursePropsShape = PropTypes.shape({
  id: PropTypes.number.isRequired,
  name: PropTypes.string.isRequired,
  course_code: PropTypes.string.isRequired,
  short_name: PropTypes.string,
  image_download_url: PropTypes.string,
  color: PropTypes.string,
})

FavoritedCourseList.propTypes = {
  courses: PropTypes.arrayOf(coursePropsShape).isRequired,
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
    color: colors.darkText,
  },
  seeAll: {
    fontSize: 14,
    color: '#6495ed',
    fontWeight: '500',
  },
})

let Connected = connect(mapStateToProps, CoursesActions)(FavoritedCourseList)
export default (Connected: Component<any, Props, any>)
