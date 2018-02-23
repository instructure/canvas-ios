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

/* eslint-disable flowtype/require-valid-file-annotation */

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  View,
  StyleSheet,
  FlatList,
  Alert,
  Image,
} from 'react-native'
import Screen from '../../../routing/Screen'
import color from '../../../common/colors'
import images from '../../../images'
import branding from '../../../common/branding'
import Actions from './actions'
import canvas from '../../../canvas-api'
import ToDoListItem from './ToDoListItem'
import RowSeparator from '../../../common/components/rows/RowSeparator'
import { defaultErrorTitle, parseErrorMessage } from '../../../redux/middleware/error-handler'
import { gradeProp } from '../../submissions/list/get-submissions-props'
import { Text } from '../../../common/text'
import i18n from 'format-message'

const { getToDo } = canvas

type OwnProps = {
  getToDo: () => Promise<ToDoItem[]>,
}

type StateProps = {
  items: ToDoItem[],
}

export type Props = OwnProps & StateProps & NavigationProps & typeof Actions

export class ToDoList extends Component<Props, any> {
  static defaultProps = {
    getToDo,
  }

  constructor (props: Props) {
    super(props)

    this.state = {
      refreshing: false,
      height: 0,
    }
  }

  // $FlowFixMe
  async componentDidMount () {
    await this.refresh()
  }

  render () {
    return (
      <Screen
        navBarColor={color.navBarColor}
        navBarButtonColor={color.navBarTextColor}
        navBarStyle='dark'
        drawUnderNavBar={true}
        navBarImage={branding.headerImage}
      >
        <View style={styles.container} onLayout={this.onLayout}>
          <FlatList
            data={this.props.items}
            renderItem={this.renderItem}
            refreshing={this.state.refreshing}
            onRefresh={() => { this.refresh() }}
            keyExtractor={(item, index) => String(index)}
            testID='to-do-list.list'
            ItemSeparatorComponent={RowSeparator}
            ListEmptyComponent={this.renderEmpty()}
            onEndReached={this.onEndReached}
            onEndReachedThreshold={0.01}
          />
        </View>
      </Screen>
    )
  }

  renderItem = (({ item, index }: { item: ToDoItem, index: number }) => {
    return (
      <ToDoListItem
        item={item}
        index={index}
        onPress={this.onPressItem(item)}
      />
    )
  })

  refresh = async () => {
    this.setState({ refreshing: true })
    try {
      const { data, next } = await this.props.getToDo()
      this.nextPage = next
      this.props.refreshedToDo([])
      this.props.refreshedToDo(data)
    } catch (error) {
      Alert.alert(defaultErrorTitle(), parseErrorMessage(error))
    }
    this.setState({ refreshing: false })
  }

  getNextPage = async () => {
    if (!this.nextPage) return
    try {
      const { data, next } = await this.nextPage()
      this.nextPage = next
      this.props.refreshedToDo(data)
    } catch (error) {
      Alert.alert(defaultErrorTitle(), parseErrorMessage(error))
    }
  }

  onEndReached = () => {
    this.getNextPage()
  }

  onPressItem = (item: ToDoItem) => () => {
    this.showSpeedGrader(item)
  }

  showSpeedGrader = (item: ToDoItem) => {
    if (!item.course_id) return
    let assignmentID
    if (item.assignment) {
      assignmentID = item.assignment.id
    }
    if (item.quiz) {
      assignmentID = item.quiz.assignment_id
    }
    const path = `/courses/${item.course_id}/gradebook/speed_grader`
    const filter = (submissions) => submissions.filter(({ grade }) => grade === 'ungraded')
    this.props.navigator.show(
      path,
      { modal: true, modalPresentationStyle: 'fullscreen' },
      { filter, studentIndex: 0, assignmentID, onDismiss: this.refresh }
    )
  }

  onLayout = (event: any) => {
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

export function mapStateToProps ({ entities, toDo }: AppState): StateProps {
  const items = Object.values(toDo.needsGrading)
    .map(item => {
      // We can't trust the item's `needs_grading_count` because the server
      // appears to cache this value for at least a few minutes so we
      // have to calculate it ourselves.
      let submissionRefs = []
      if (item.assignment &&
        entities.assignments &&
        entities.assignments[item.assignment.id] &&
        entities.assignments[item.assignment.id].submissions) {
        submissionRefs = entities.assignments[item.assignment.id].submissions.refs
      }
      if (item.quiz &&
        entities.quizzes &&
        entities.quizzes[item.quiz.id] &&
        entities.quizzes[item.quiz.id].submissions) {
        submissionRefs = entities.quizzes[item.quiz.id].submissions.refs
      }

      let submissions = []
      if (entities.submissions) {
        submissions = submissionRefs
          .map(r => entities.submissions[r])
          .filter(s => s)
      }

      if (!submissions.length) {
        return item
      }

      const needsGradingCount = submissions
        .filter(s => gradeProp(s.submission) === 'ungraded')
        .filter(s => {
          // filter out submissions that were very recently graded
          const limit = 3 * 60 * 1000 // 3 minutes
          return s.lastGradedAt == null ||
            Date.now() > new Date(s.lastGradedAt + limit).getTime()
        })
        .length

      return {
        ...item,
        needs_grading_count: needsGradingCount,
      }
    })
    .filter(item => item.needs_grading_count && item.needs_grading_count > 0)
    .sort((a, b) => {
      /*
       * oldest due dates at the front
       * null due dates at the end
       * then sort by id
       */
      const id1 = a.assignment && a.assignment.id || a.quiz && a.quiz.id
      const id2 = b.assignment && b.assignment.id || b.quiz && b.quiz.id
      const dueAt1 = a.assignment && a.assignment.due_at || a.quiz && a.quiz.due_at
      const dueAt2 = b.assignment && b.assignment.due_at || b.quiz && b.quiz.due_at

      if (dueAt1 == null && dueAt2 == null) {
        return Number(id1) < Number(id2) ? -1 : 1
      }
      if (dueAt1 == null) return 1
      if (dueAt2 == null) return -1
      if (new Date(dueAt1).getTime() === new Date(dueAt2).getTime()) {
        return Number(id1) < Number(id2) ? -1 : 1
      }
      return new Date(dueAt1) < new Date(dueAt2) ? -1 : 1
    })

  return {
    items,
  }
}

const Connected = connect(mapStateToProps, Actions)(ToDoList)
export default (Connected: *)
