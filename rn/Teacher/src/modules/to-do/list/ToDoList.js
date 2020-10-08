//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

// @flow

import i18n from 'format-message'
import React, { Component } from 'react'
import {
  View,
  FlatList,
  Image,
} from 'react-native'
import Screen from '../../../routing/Screen'
import { createStyleSheet } from '../../../common/stylesheet'
import images from '../../../images'
import icon from '../../../images/inst-icons'
import {
  fetchPropsFor,
  ToDoModel,
} from '../../../canvas-api/model-api'
import RowSeparator from '../../../common/components/rows/RowSeparator'
import { alertError } from '../../../redux/middleware/error-handler'
import { Text } from '../../../common/text'
import { updateBadgeCounts } from '../../tabbar/badge-counts'
import ToDoListItem from './ToDoListItem'
import ExperimentalFeature from '../../../common/ExperimentalFeature'

type Props = {
  navigator: Navigator,
  list: ToDoModel[],
  getNextPage: ?() => ApiPromise<any>,
  isLoading: boolean,
  loadError: ?Error,
  refresh: () => void,
}

type State = {
  height: number,
  list: ToDoModel[],
}

export class ToDoList extends Component<Props, State> {
  state = {
    height: 0,
    list: this.prepareList(this.props.list),
  }

  prepareList (list: ToDoModel[]) {
    const seen = new Set()
    return list
      .filter(todo => (
        todo.type === 'grading' &&
        todo.needsGradingCount && todo.needsGradingCount > 0 &&
        todo.courseID && (todo.assignment || todo.quiz) &&
        !seen.has(todo.htmlUrl) && seen.add(todo.htmlUrl) // filter out non-unique
      ))
  }

  UNSAFE_componentWillReceiveProps (props: Props) {
    if (props.loadError && props.loadError !== this.props.loadError) {
      alertError(props.loadError)
    }
    let list = this.state.list
    if (props.list !== this.props.list) {
      this.setState({ list: list = this.prepareList(props.list) })
    }
    // workaround MBL-9964 the first pages may not actually need grading
    // and onEndReached would never get called for an empty list
    if (list.length < 10 && props.getNextPage && props.getNextPage !== this.props.getNextPage) {
      props.getNextPage()
    }
  }

  refresh = () => {
    updateBadgeCounts()
    return this.props.refresh()
  }

  showProfile = () => {
    this.props.navigator.show('/profile', { modal: true, modalPresentationStyle: 'drawer', embedInNavigationController: false })
  }

  render () {
    return (
      <Screen
        navBarStyle='global'
        navBarLogo
        drawUnderNavBar
        customPageViewPath='/'
        leftBarButtons={[{
          image: icon('hamburger', 'solid'),
          width: 24,
          height: 24,
          testID: 'Todo.profileButton',
          action: this.showProfile,
          accessibilityLabel: i18n('Profile Menu'),
        }]}
      >
        <View style={styles.container} onLayout={this.handleLayout}>
          <FlatList
            data={this.state.list}
            renderItem={this.renderItem}
            refreshing={this.props.isLoading}
            onRefresh={this.refresh}
            keyExtractor={ToDoModel.keyExtractor}
            testID='to-do-list.list'
            ItemSeparatorComponent={RowSeparator}
            ListEmptyComponent={this.renderEmpty()}
            onEndReached={this.props.getNextPage}
            onEndReachedThreshold={0.5}
          />
        </View>
      </Screen>
    )
  }

  renderItem = (({ item }: { item: ToDoModel }) => {
    return (
      <ToDoListItem
        item={item}
        onPress={this.showSpeedGrader}
      />
    )
  })

  showSpeedGrader = (item: ToDoModel) => {
    if (!item.courseID) return
    let assignmentID
    if (item.assignment) {
      assignmentID = item.assignment.id
    }
    if (item.quiz) {
      assignmentID = item.quiz.assignment_id
    }
    const path = `/courses/${item.courseID}/assignments/${assignmentID}/submissions/speedgrader`
    if (ExperimentalFeature.nativeSpeedGrader.isEnabled) {
      return this.props.navigator.show(
        `${path}?filter=needs_grading`,
        { modal: true, modalPresentationStyle: 'fullscreen', embedInNavigationController: false }
      )
    }
    const filter = (submissions) => submissions.filter(({ grade }) => grade === 'ungraded')
    this.props.navigator.show(
      path,
      { modal: true, modalPresentationStyle: 'fullscreen' },
      { filter, studentIndex: 0, assignmentID, onDismiss: this.refresh }
    )
  }

  handleLayout = (event: any) => {
    this.setState({ height: event.nativeEvent.layout.height })
  }

  renderEmpty () {
    return (
      <View style={[styles.emptyContainer, { height: this.state.height }]}>
        <Image style={styles.emptyImage} source={images.relax} />
        <Text style={styles.emptyText}>{i18n('Nothing more to do.')}</Text>
        <Text style={styles.emptyText}>{i18n('Enjoy your day!')}</Text>
      </View>
    )
  }
}

const styles = createStyleSheet(colors => ({
  container: {
    flex: 1,
  },
  emptyContainer: {
    flex: 1,
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: colors.backgroundLightest,
  },
  emptyImage: {
    marginBottom: 24,
  },
  emptyText: {
    color: colors.textDark,
    fontSize: 18,
  },
}))

export default fetchPropsFor(ToDoList, (_, api) => api.getToDos())
