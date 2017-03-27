/**
* Launching pad for navigation for a single course
* @flow
*/

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  View,
  Text,
  StyleSheet,
  ListView,
} from 'react-native'

import i18n from 'format-message'
import AssignmentListActions from './actions'
import { mapStateToProps, type AssignmentListProps } from './map-state-to-props'
import { route } from '../../routing'
import refresh from '../../utils/refresh'

import AssignmentListRowView from './components/AssignmentListRow'
import AssignmentListSectionView from './components/AssignmentListSection'
import ActivityIndicatorView from '../../common/components/ActivityIndicatorView'

type State = {
  dataSource: ListView.DataSource,
}

export class AssignmentList extends Component<any, AssignmentListProps, State> {

  state: State

  static navigatorStyle = {
    drawUnderNavBar: true,
  }

  constructor (props: AssignmentListProps) {
    super(props)
    props.navigator.setTitle({
      title: i18n({
        default: 'Assignments',
        description: 'Title of the assignments screen for a course',
      }),
    })

    if (props.course.color) {
      const color: string = props.course.color
      props.navigator.setStyle({
        navBarBackgroundColor: color,
      })
    }

    const dataSource = new ListView.DataSource({
      rowHasChanged: (r1, r2) => r1 !== r2,
      sectionHeaderHasChanged: (s1, s2) => s1 !== s2,
      getSectionHeaderData: this.getSectionHeaderData,
      getRowData: this.getRowData,
    })

    this.state = {
      dataSource: dataSource.cloneWithRowsAndSections({}),
    }
  }

  componentWillReceiveProps (newProps: AssignmentListProps) {
    const groups = newProps.assignmentGroups || []
    const sectionIdentities = groups.map((group) => group.id.toString())
    const assignmentIdentities = []

    let groupsMap = {}
    groups.forEach((group) => {
      groupsMap[group.id] = group
      let assignments = []
      group.assignments.forEach((assignment) => {
        assignments.push(assignment.id.toString())
        groupsMap[`${group.id}:${assignment.id}`] = assignment
      })

      assignmentIdentities.push(assignments)
    })

    this.setState({
      dataSource: this.state.dataSource.cloneWithRowsAndSections(groupsMap, sectionIdentities, assignmentIdentities),
    })
  }

  getSectionHeaderData = (data: any, sectionID: string) => {
    return data[sectionID]
  }

  getRowData = (data: any, sectionID: string, rowID: string) => {
    return data[`${sectionID}:${rowID}`]
  }

  renderRow = (assignment: Assignment, sectionID: number, rowID: number) => {
    return <AssignmentListRowView assignment={assignment} tintColor={this.props.course.color} onPress={this.selectedAssignment} />
  }

  renderSectionHeader = (group: any) => {
    return <AssignmentListSectionView assignmentGroup={group} />
  }

  renderFooter = () => {
    if (this.props.pending || this.props.nextPage) {
      return <ActivityIndicatorView height={44} />
    }

    return <View />
  }

  selectedAssignment = (assignment: Assignment) => {
    const destination = route(`/courses/${this.props.courseID}/assignments/${assignment.id}`)
    this.props.navigator.push(destination)
  }

  onEndReached = () => {
    if (this.props.nextPage) {
      this.props.nextPage()
    }
  }

  render (): React.Element<View> {
    return (
      <View style={styles.container}>
        <View style={styles.header}>
          <Text style={styles.headerTitle}>All Grading Periods</Text>
        </View>
        <ListView
          testID='assignment-list.list'
          dataSource={this.state.dataSource}
          renderRow={this.renderRow}
          renderSectionHeader={this.renderSectionHeader}
          onEndReached={this.onEndReached}
          enableEmptySections={true}
          renderFooter={this.renderFooter}
        />
      </View>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: 'lightgrey',
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: '600',
    marginTop: 16,
    marginLeft: 16,
    marginBottom: 8,
    color: '#2d3b44',
  },
})

const Refreshed = refresh(
  props => props.refreshAssignmentList(props.courseID),
  props => props.assignmentGroups.length === 0
)(AssignmentList)
const Connected = connect(mapStateToProps, AssignmentListActions)(Refreshed)
export default (Connected: Component<any, AssignmentListProps, State>)
