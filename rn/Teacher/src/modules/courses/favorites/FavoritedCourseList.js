// @flow

import React, { Component, PropTypes } from 'react'
import {
  Dimensions,
  View,
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
import type { CourseProps } from '../course-prop-types'
import Images from '../../../images/'
import refresh from '../../../utils/refresh'
import { Heading1 } from '../../../common/text'
import Navigator from '../../../routing/Navigator'
import Screen from '../../../routing/Screen'
import branding from '../../../common/branding'
import color from '../../../common/colors'

const { width: deviceWidth } = Dimensions.get('window')

type Props = {
  navigator: Navigator,
  refreshCourses: () => void,
  courses: Array<CourseProps>,
  error?: string,
  pending?: number,
} & RefreshProps

export class FavoritedCourseList extends Component {
  props: Props

  showFavoritesList = () => {
    this.props.navigator.show('/course_favorites', { modal: true, modalPresentationStyle: 'formsheet' })
  }

  showUserCoursePreferences = (courseId: string) => {
    this.props.navigator.show(`/courses/${courseId}/user_preferences`, { modal: true, modalPresentationStyle: 'formsheet' })
  }

  selectCourse = (course: Course) => {
    this.props.navigator.show(`/courses/${course.id}`, { modal: true, modalPresentationStyle: 'currentContext', modalTransitionStyle: 'push' })
  }

  goToAllCourses = () => {
    this.props.navigator.show('/courses')
  }

  presentBetaFeedback = () => {
    this.props.navigator.show('/beta-feedback', { modal: true })
  }

  renderHeader = () => {
    return (
      <View style={styles.header}>
        <View style={styles.headerTextWrapper}>
          <Image source={Images.starFilled} testID = 'fav-courses.header-star-img'/>
          <Heading1 style={styles.headerText} testID = 'fav-courses.header-courses-lbl'>
            {i18n('Courses')}
          </Heading1>
        </View>
        <LinkButton style={styles.seeAll} onPress={this.goToAllCourses} testID='fav-courses.see-all-btn'>
            {i18n('See All')}
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
      <Screen
        navBarTranslucent={true}
        navBarHidden={false}
        navBarImage={branding.headerImage}
        navBarColor={color.navBarColor}
        navBarStyle='dark'
        rightBarButtons={[
          {
            title: i18n('Edit'),
            testID: 'fav-courses.edit-btn',
            action: this.showFavoritesList,
          },
        ]}
        leftBarButtons={[
          {
            accessibilityLabel: i18n('Leave Feedback'),
            testID: 'fav-courses.feedback-btn',
            image: Images.feedback,
            action: this.presentBetaFeedback,
          },
        ]}
        >
        <CourseList
          {...this.props}
          selectCourse={this.selectCourse}
          onCoursePreferencesPressed={this.showUserCoursePreferences}
          width={deviceWidth}
          header={this.renderHeader()}
          onRefresh={this.props.refresh}
        />
      </Screen>
    )
  }
}

const coursePropsShape = PropTypes.shape({
  id: PropTypes.string.isRequired,
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
    marginLeft: 6,
  },
  seeAll: {
    fontWeight: '500',
  },
})

let Refreshed = refresh(
  props => props.refreshCourses(),
  props => props.courses.length === 0,
  props => Boolean(props.pending)
)(FavoritedCourseList)
let Connected = connect(mapStateToProps, CoursesActions)(Refreshed)
export default (Connected: Component<any, Props, any>)
