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
import { ERROR_TITLE, parseErrorMessage } from '../../../redux/middleware/error-handler'
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
  async componentWillMount () {
    await this.refresh()
  }

  render () {
    return (
      <Screen
        navBarColor={color.navBarColor}
        navBarButtonColor={color.navBarTextColor}
        navBarStyle='dark'
        statusBarStyle='light'
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
      const { data } = await this.props.getToDo()
      this.props.refreshedToDo(data)
    } catch (error) {
      Alert.alert(ERROR_TITLE, parseErrorMessage(error))
    }
    this.setState({ refreshing: false })
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
  const items = toDo
    .items
    .filter(i => i.type === 'grading')
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

  return {
    items,
  }
}

const Connected = connect(mapStateToProps, Actions)(ToDoList)
export default (Connected: *)
