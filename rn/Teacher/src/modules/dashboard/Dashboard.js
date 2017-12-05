// @flow

import React from 'react'
import {
  View,
  SectionList,
  StyleSheet,
} from 'react-native'
import Screen from '../../routing/Screen'
import { connect } from 'react-redux'
import refresh from '../../utils/refresh'
import localeSort from '../../utils/locale-sort'
import i18n from 'format-message'
import App from '../app'
import CoursesActions from '../courses/actions'
import {
  Heading1,
} from '../../common/text'
import {
  LinkButton,
} from '../../common/buttons'
import GlobalAnnouncementRow, { type GlobalAnnouncementProps } from './GlobalAnnouncementRow'
import GroupRow, { type GroupRowProps } from './GroupRow'
import CourseCard from '../courses/components/CourseCard'
import NoCourses from '../courses/components/NoCourses'
import color from '../../common/colors'
import Images from '../../images'
import branding from '../../common/branding'
import Navigator from '../../routing/Navigator'
import { getSession } from '../../canvas-api'

type ColorfulCourse = { color: string } & Course
type Props = {
  totalCourseCount: number,
  navigator: Navigator,
  refreshing: boolean,
  refresh: () => void,
  isFullDashboard: boolean,
  courses: Array<ColorfulCourse>,
}
type State = {
  width?: number,
  cardSize?: number,
  contentWidth?: number,
  showingModal: boolean,
}
type SectionHeader = {
  sectionID: string,
  title?: string,
  seeAll?: () => void,
}

const padding = 8
const MIN_CARD_SIZE = 150

export class Dashboard extends React.Component<Props, State> {
  constructor (props: Props) {
    super(props)
    this.state = { showingModal: false }
  }

  componentWillReceiveProps (newProps: Props) {
    if (newProps.isFullDashboard &&
        !newProps.pending &&
        !newProps.error &&
        !newProps.totalCourseCount &&
        !this.state.showingModal &&
        getSession()) {
      this.props.navigator.show('/notATeacher', { modal: true })
      this.setState({
        showingModal: true,
      })
    }
  }

  calculateLayout = (width: number) => {
    const contentWidth = width - padding - padding
    const columns = Math.floor(contentWidth / MIN_CARD_SIZE)
    const cardSize = contentWidth / columns
    this.setState({ cardSize, width, contentWidth })
  }

  onLayout = ({ nativeEvent }: { nativeEvent: { layout: { width: number }}}) => {
    this.calculateLayout(nativeEvent.layout.width)
  }

  renderHeader = ({ section }: { section: SectionHeader }) => {
    if (!section.title || !this.state.contentWidth) {
      return undefined
    }
    const width = this.state.contentWidth
    return (
      <View
        key={section.sectionID}
        accessibitilityTraits='heading'
        style={[{ width, padding }, styles.header]}
      >
        <Heading1 testID={section.sectionID + '.heading-lbl'}>
          {section.title}
        </Heading1>
        { section.seeAll
          ? <LinkButton
              testID={section.sectionID + '.see-all-btn'}
              onPress={section.seeAll}
            >
              {i18n('See All')}
            </LinkButton>
          : undefined
        }
      </View>
    )
  }

  renderGlobalAnnouncement = ({ item }: { item: GlobalAnnouncementProps }) => {
    return (
      // TODO: add a unique key containing the announcement id
      <GlobalAnnouncementRow
        style={{ width: this.state.contentWidth, padding }}
        {...item}
      />
    )
  }

  renderCourseCard = ({ item }: { item: ColorfulCourse }) => {
    const cardSize = this.state.cardSize

    return (
      <CourseCard
        key={`course-${item.id}`}
        style={{ width: cardSize, height: cardSize, padding }}
        color={item.color}
        course={item}
        onPress={this.selectCourse}
        onCoursePreferencesPressed={this.showUserCoursePreferences}
      />
    )
  }

  renderNoFavorites = () => {
    const { contentWidth } = this.state

    return (
      <NoCourses
        key='no-courses'
        onAddCoursePressed={this.showFavoritesList}
        style={{ width: contentWidth, height: 300 }}
      />
    )
  }

  renderGroup = ({ item }: { item: GroupRowProps }) => {
    return (
      // TODO: add a unique key containing the group id
      <GroupRow
        style={{ width: this.state.contentWidth, padding }}
        { ...item }
      />
    )
  }

  loadSections = () => {
    if (!this.props.isFullDashboard) {
      return [{
        data: this.props.courses,
        renderItem: this.renderCourseCard,
      }]
    }

    const coursesHeader = {
      sectionID: 'dashboard.courses',
      title: i18n('Courses'),
      seeAll: this.showAllCourses,
    }

    return [
      // Announcements
      // {
      //   sectionID: 'dashboard.announcements',
      //   data: [
      //     { color: '#0066AA', title: 'pizza!', description: 'Theres pizza down here on 3, guys' },
      //   ],
      //   renderItem: this.renderGlobalAnnouncement,
      // },
      // Courses
      this.props.courses.length > 0
        ? {
          ...coursesHeader,
          data: this.props.courses,
          renderItem: this.renderCourseCard,
        }
        : {
          ...coursesHeader,
          data: [{/* welcome (no courses) placeholder object */}],
          renderItem: this.renderNoFavorites,
        },
      // Groups
      // {
      //   sectionID: 'dashboard.groups',
      //   title: i18n('Groups'),
      //   data: [
      //     {
      //       color: '#DDDD44',
      //       name: 'Swift Study Group',
      //       courseName: 'Swift 101',
      //       term: 'Winter 2018',
      //     },
      //   ],
      //   renderItem: this.renderGroup,
      // },
    ]
  }

  renderDashboard = () => {
    // don't show any sections until layout has happened at least once
    const sections: Array<{ data: Array<any> }> = this.state.width
      ? this.loadSections()
      : []

    return (
      <SectionList
        refreshing={this.props.refreshing}
        onRefresh={this.props.refresh}
        stickySectionHeadersEnabled={false}
        renderSectionHeader={this.renderHeader}
        onLayout={this.onLayout}
        contentContainerStyle={styles.gridish}
        onLayout={this.onLayout}
        sections={sections}
      />
    )
  }

  showFavoritesList = () => {
    this.props.navigator.show('/course_favorites', { modal: true })
  }

  showUserCoursePreferences = (courseId: string) => {
    this.props.navigator.show(`/courses/${courseId}/user_preferences`, { modal: true })
  }

  selectCourse = (course: Course) => {
    this.props.navigator.show(`/courses/${course.id}`, { modal: true })
  }

  showAllCourses = () => {
    this.props.navigator.show('/courses')
  }

  showProfile = () => {
    this.props.navigator.show('/profile', { modal: true })
  }

  avatar = () => {
    let avatarURL
    const session = getSession()
    if (session) {
      avatarURL = session.user.avatar_url
    }

    const avatarConfig = {
      uri: avatarURL,
      width: 32,
      height: 32,
      borderRadius: 16,
    }
    return avatarURL ? avatarConfig : Images.profile
  }

  screenProps = () => {
    return !this.props.isFullDashboard
      ? { title: i18n('All Courses') }
      : {
        navBarImage: branding.headerImage,
        rightBarButtons: [{
          title: i18n('Edit'),
          testID: 'dashboard.edit-btn',
          action: this.showFavoritesList,
          disabled: !this.props.totalCourseCount,
        }],
        leftBarButtons: [
          {
            image: this.avatar(),
            testID: 'favorited-course-list.profile-btn',
            action: this.showProfile,
            accessibilityLabel: i18n('Profile'),
          },
        ],
      }
  }

  render () {
    return (
      <Screen
        { ...this.screenProps() }
        navBarHidden={false}
        navBarColor={color.navBarColor}
        navBarButtonColor={color.navBarTextColor}
        navBarStyle='dark'
      >{
        this.renderDashboard()
      }</Screen>
    )
  }
}

const styles = StyleSheet.create({
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-end',
    paddingBottom: 0,
    paddingTop: 16,
  },
  gridish: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    padding,
  },
})

export function mapStateToProps (isFullDashboard: boolean) {
  return (state: AppState) => {
    const allCourses = state.entities.courses

    const allCourseStates = Object.keys(allCourses)
      .map(key => allCourses[key])

    const totalCourseCount = allCourseStates
      .map(({ course }) => course)
      .filter(App.current().filterCourse)
      .length

    const { pending, error, courseRefs } = state.favoriteCourses

    let courseStates = []
    if (isFullDashboard) {
      // we only want favorite courses here
      courseStates = courseRefs.map(ref => allCourses[ref])
    } else {
      // all courses view
      courseStates = allCourseStates
    }
    const courses: Array<ColorfulCourse> = courseStates
      .map(({ course, color }) => ({ ...course, color }))
      .filter(App.current().filterCourse)
      .sort((c1, cs2) => localeSort(c1.name, cs2.name))

    return { pending, error, courses, totalCourseCount, isFullDashboard }
  }
}

const Refreshed = refresh(
  props => props.refreshCourses(),
  props => props.courses.length === 0,
  props => Boolean(props.pending)
)(Dashboard)
const Connected = connect(mapStateToProps(true), CoursesActions)(Refreshed)
export default (Connected: *)
