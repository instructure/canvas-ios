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
import mapStateToProps from './map-state-to-props'

type Props = {
  navigator: ReactNavigator,
  courses: Array<Course>,
  toggleFavorite: (courseId: string, favorite: boolean) => Promise<*>,
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
  }

  componentWillReceiveProps (nextProps: Props) {
    this.setState({
      dataSource: this.state.ds.cloneWithRows(nextProps.courses),
    })
  }

  onNavigatorEvent = (event: NavigatorEvent) => {
    if (event.type === 'NavBarButtonPress') {
      if (event.id === 'done') {
        this.props.navigator.dismissModal({
          animationType: 'slide-down',
        })
      }
    }
  }

  renderCourse = (course: Course) => {
    return (
      <CourseFavorite
        course={course}
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

let connected = connect(mapStateToProps, FavoritesActions)(FavoritesList)
export default (connected: FavoritesList)

const styles = StyleSheet.create({
  listStyle: {
    backgroundColor: '#fff',
  },
})
