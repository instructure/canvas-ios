// @flow

import React, { Component } from 'react'
import ReactNative, {
  StyleSheet,
} from 'react-native'
import { connect } from 'react-redux'
import i18n from 'format-message'

import CourseFavorite from './components/CourseFavorite'
import FavoritesActions from './actions'
import CoursesActions from '../actions'
import mapStateToProps from './map-state-to-props'
import refresh from '../../../utils/refresh'
import { RefreshableListView } from '../../../common/components/RefreshableList'
import Screen from '../../../routing/Screen'
import Navigator from '../../../routing/Navigator'
import colors from '../../../common/colors'

type Props = {
  navigator: Navigator,
  courses: Array<Course>,
  favorites: Array<string>,
  toggleFavorite: (courseID: string, favorite: boolean) => Promise<*>,
  pending: number,
} & RefreshProps

type State = {
  ds: ReactNative.ListViewDataSource,
  dataSource: ReactNative.ListViewDataSource,
}

export class FavoritesList extends Component {
  props: Props
  state: State

  constructor (props: Props) {
    super(props)

    let ds = new RefreshableListView.DataSource({
      rowHasChanged: (r1, r2) => r1 !== r2,
    })

    this.state = {
      ds,
      dataSource: ds.cloneWithRows(this.props.courses),
    }
  }

  componentWillReceiveProps (nextProps: Props) {
    this.setState({
      dataSource: this.state.ds.cloneWithRows(nextProps.courses),
    })
  }

  dismiss = () => {
    this.props.navigator.dismiss()
  }

  renderCourse = (course: Course) => {
    return (
      <CourseFavorite
        course={course}
        isFavorite={this.props.favorites.includes(course.id)}
        onPress={this.props.toggleFavorite}
      />
    )
  }

  render () {
    return (
      <Screen
        navBarStyle='light'
        navBarTitleColor={colors.darkText}
        navBarButtonColor={colors.link}
        title={i18n('Edit Courses')}
        rightBarButtons={[
          {
            title: i18n('Done'),
            style: 'done',
            testID: 'edit-favorites.done-btn',
            action: this.dismiss,
          },
        ]}
      >
        <RefreshableListView
          style={styles.listStyle}
          dataSource={this.state.dataSource}
          renderRow={this.renderCourse}
          refreshing={this.props.refreshing}
          onRefresh={this.props.refresh}
        />
      </Screen>
    )
  }
}

let Refreshed = refresh(
  props => props.refreshCourses(),
  props => props.courses.length === 0,
  props => Boolean(props.pending)
)(FavoritesList)
let Connected = connect(mapStateToProps, { ...CoursesActions, ...FavoritesActions })(Refreshed)
export default (Connected: FavoritesList)

const styles = StyleSheet.create({
  listStyle: {
    backgroundColor: '#fff',
  },
})
