//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

// @flow

import i18n from 'format-message'
import React, { Component } from 'react'
import {
  View,
  StyleSheet,
  FlatList,
  Image,
} from 'react-native'
import Screen from '../../../routing/Screen'
import color from '../../../common/colors'
import images from '../../../images'
import branding from '../../../common/branding'
import {
  fetchPropsFor,
  ToDoModel,
} from '../../../canvas-api/model-api'
import RowSeparator from '../../../common/components/rows/RowSeparator'
import { alertError } from '../../../redux/middleware/error-handler'
import { Text } from '../../../common/text'
import { updateBadgeCounts } from '../../tabbar/badge-counts'
import ToDoListItem from './ToDoListItem'

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

  componentWillReceiveProps (props: Props) {
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

  render () {
    return (
      <Screen
        navBarColor={color.navBarColor}
        navBarButtonColor={color.navBarTextColor}
        statusBarStyle={color.statusBarStyle}
        drawUnderNavBar
        navBarImage={branding.headerImage}
        customPageViewPath={'/'}
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
    const path = `/courses/${item.courseID}/gradebook/speed_grader`
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

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  emptyContainer: {
    flex: 1,
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'white',
  },
  emptyImage: {
    marginBottom: 24,
  },
  emptyText: {
    color: color.grey4,
    fontSize: 18,
  },
})

export default fetchPropsFor(ToDoList, (_, api) => api.getToDos())
