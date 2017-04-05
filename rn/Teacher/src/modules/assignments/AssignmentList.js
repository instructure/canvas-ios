/**
* Launching pad for navigation for a single course
* @flow
*/

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  View,
  StyleSheet,
  ListView,
  ActionSheetIOS,
} from 'react-native'
import i18n from 'format-message'

import AssignmentListActions from './actions'
import CourseActions from '../courses/actions'
import { mapStateToProps, type AssignmentListProps } from './map-state-to-props'
import { route } from '../../routing'
import refresh from '../../utils/refresh'

import AssignmentListRowView from './components/AssignmentListRow'
import AssignmentListSectionView from './components/AssignmentListSection'
import ActivityIndicatorView from '../../common/components/ActivityIndicatorView'
import { LinkButton } from '../../common/buttons'
import { Heading1 } from '../../common/text'
import { RefreshableListView } from '../../common/components/RefreshableList'

type State = {
  dataSource: ListView.DataSource,
  currentFilter: {
    index?: number,
    title: string,
  },
  filterApplied: boolean,
  refreshing: boolean,
}

const DEFAULT_FILTER = {
  title: i18n({
    default: 'All Grading Periods',
    description: 'The header on the assignment list',
  }),
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

    if (props.courseColor) {
      const color: string = props.courseColor
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
      currentFilter: DEFAULT_FILTER,
      filterApplied: false,
      refreshing: false,
    }
  }

  componentDidMount () {
    this.updateListData(this.props)
  }

  componentWillReceiveProps (newProps: AssignmentListProps) {
    this.updateListData(newProps)
  }

  updateListData (props: AssignmentListProps) {
    const groupsMap = {}
    const sectionIdentities = []
    const assignmentIdentities = []

    props.assignmentGroups.forEach((group) => {
      let filteredAssignments = this.state.filterApplied
        // $FlowFixMe because it doesn't like me to access index on currentFilter
        ? group.assignments.filter(({ id }) => props.gradingPeriods[this.state.currentFilter.index].assignmentRefs.includes(id))
        : group.assignments

      if (filteredAssignments.length === 0) return

      groupsMap[group.id] = group
      sectionIdentities.push(group.id)
      let assignments = []
      filteredAssignments.forEach((assignment) => {
        assignments.push(assignment.id)
        groupsMap[`${group.id}:${assignment.id}`] = assignment
      })

      assignmentIdentities.push(assignments)
    })

    this.setState({
      dataSource: this.state.dataSource.cloneWithRowsAndSections(groupsMap, sectionIdentities, assignmentIdentities),
      refreshing: this.state.refreshing ? Boolean(props.pending) : false,
    })
  }

  getSectionHeaderData = (data: any, sectionID: string) => {
    return data[sectionID]
  }

  getRowData = (data: any, sectionID: string, rowID: string) => {
    return data[`${sectionID}:${rowID}`]
  }

  renderRow = (assignment: Assignment, sectionID: string, rowID: string) => {
    return <AssignmentListRowView assignment={assignment} tintColor={this.props.courseColor} onPress={this.selectedAssignment} />
  }

  renderSectionHeader = (group: any) => {
    return <AssignmentListSectionView assignmentGroup={group} />
  }

  renderFooter = () => {
    // we only want this to show when there are pending requests
    // that weren't started by pull to refresh
    // and only on filters that we don't already have everything for
    if (!this.state.refreshing && this.props.pending && this.state.dataSource.getRowCount() === 0) {
      return <ActivityIndicatorView height={44} />
    }

    return <View />
  }

  selectedAssignment = (assignment: Assignment) => {
    const destination = route(assignment.html_url)
    this.props.navigator.push(destination)
  }

  clearFilter = () => {
    this.setState({
      currentFilter: DEFAULT_FILTER,
      filterApplied: false,
      refreshing: false,
    }, () => {
      this.updateListData(this.props)
    })
  }

  applyFilter = () => {
    let buttons = this.props.gradingPeriods.map(({ title }) => title).concat(i18n('Cancel'))
    ActionSheetIOS.showActionSheetWithOptions({
      options: buttons,
      cancelButtonIndex: buttons.length - 1,
      title: i18n({
        default: 'Filter by:',
        description: 'Indicates to the user that they can filter by a few options',
      }),
    }, this.updateFilter)
  }

  updateFilter = (index: number) => {
    // don't do anything if the user hits cancel
    if (index === this.props.gradingPeriods.length) return

    this.setState({
      currentFilter: {
        title: this.props.gradingPeriods[index].title,
        index,
      },
      filterApplied: true,
      refreshing: false, // if the user had just pulled to refresh don't show refresh indicator
    }, () => {
      // after the filter is applied we need to update the list to update the list data
      this.updateListData(this.props)

      // get assignment info for grading period only if we don't have it yet
      if (this.props.gradingPeriods[index].assignmentRefs.length === 0) {
        this.props.refreshAssignmentList(this.props.courseID, this.props.gradingPeriods[index].id)
      }
    })
  }

  toggleFilter = () => {
    if (this.state.filterApplied) {
      this.clearFilter()
    } else {
      this.applyFilter()
    }
  }

  refresh = () => {
    this.setState({ refreshing: true }, () => {
      this.props.refresh()
    })
  }

  render (): React.Element<View> {
    return (
      <View style={styles.container}>
        <View style={styles.header}>
          <Heading1 style={styles.headerTitle}>{this.state.currentFilter.title}</Heading1>
          {this.props.gradingPeriods.length > 0 &&
            <LinkButton testID='assignment-list.filter' onPress={this.toggleFilter} style={styles.filterButton}>
              {this.state.filterApplied
                ? i18n('Clear filter')
                : i18n('Filter')}
            </LinkButton>
          }
        </View>
        <RefreshableListView
          testID='assignment-list.list'
          dataSource={this.state.dataSource}
          renderRow={this.renderRow}
          renderSectionHeader={this.renderSectionHeader}
          enableEmptySections={true}
          renderFooter={this.renderFooter}
          refreshing={this.state.refreshing}
          onRefresh={this.refresh}
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
    flexDirection: 'row',
    alignItems: 'flex-end',
    justifyContent: 'space-between',
    paddingTop: 16,
    paddingBottom: 8,
    paddingHorizontal: 16,
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: '600',
    color: '#2d3b44',
  },
  filterButton: {
    marginBottom: 1,
  },
})

const Refreshed = refresh(
  props => {
    props.refreshAssignmentList(props.courseID)
    props.refreshGradingPeriods(props.courseID)
  },
  props => props.assignmentGroups.length === 0 || props.gradingPeriods.length === 0
)(AssignmentList)
const Connected = connect(mapStateToProps, { ...AssignmentListActions, ...CourseActions })(Refreshed)
export default (Connected: Component<any, AssignmentListProps, State>)
