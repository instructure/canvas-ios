// @flow

import React, { Component } from 'react'
import ReactNative, {
  ListView,
  StyleSheet,
} from 'react-native'
import { connect } from 'react-redux'
import i18n from 'format-message'

import CourseFavorite from './components/CourseFavorite'
import FavoritesActions from './actions'
import CoursesActions from '../actions'
import mapStateToProps from './map-state-to-props'
import refresh from '../../../utils/refresh'

type Props = {
  navigator: ReactNavigator,
  courses: Array<Course>,
  favorites: Array<string>,
  toggleFavorite: (courseID: string, favorite: boolean) => Promise<*>,
  refreshCourses: () => void,
}

type State = {
  ds: ReactNative.ListViewDataSource,
  dataSource: ReactNative.ListViewDataSource,
}

export class FavoritesList extends Component {
  props: Props
  state: State

  static navigatorButtons = {
    rightButtons: [{
      title: i18n({
        default: 'Done',
        description: 'Back button to move back a screen',
      }),
      id: 'done',
      testId: 'done_button',
    }],
  }

  constructor (props: Props) {
    super(props)

    let ds = new ListView.DataSource({
      rowHasChanged: (r1, r2) => r1 !== r2,
    })

    this.state = {
      ds,
      dataSource: ds.cloneWithRows(this.props.courses),
    }

    props.navigator.setOnNavigatorEvent(this.onNavigatorEvent)
    props.navigator.setTitle({
      title: i18n({
        default: 'Edit Courses',
        description: 'The title of the screen enabling teachers to favorite and unfavorite their courses',
      }),
    })
  }

  componentWillReceiveProps (nextProps: Props) {
    this.setState({
      dataSource: this.state.ds.cloneWithRows(nextProps.courses),
    })
  }

  onNavigatorEvent = (event: NavigatorEvent) => {
    switch (event.type) {
      case 'NavBarButtonPress':
        switch (event.id) {
          case 'done':
            this.props.navigator.dismissModal({
              animationType: 'slide-down',
            })
            break
        }
        break
    }
  }

  renderCourse = (course: Course) => {
    return (
      <CourseFavorite
        course={course}
        isFavorite={this.props.favorites.includes(course.id.toString())}
        onPress={this.props.toggleFavorite}
      />
    )
  }

  render (): React.Element<ListView> {
    return (
      <ListView
        style={styles.listStyle}
        dataSource={this.state.dataSource}
        renderRow={this.renderCourse}
      />
    )
  }
}

let Refreshed = refresh(
  props => props.refreshCourses(),
  props => props.courses.length === 0
)(FavoritesList)
let Connected = connect(mapStateToProps, { ...CoursesActions, ...FavoritesActions })(Refreshed)
export default (Connected: FavoritesList)

const styles = StyleSheet.create({
  listStyle: {
    backgroundColor: '#fff',
  },
})
