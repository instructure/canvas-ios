/**
* Launching pad for navigation for a single course
* @flow
*/

import React, { Component } from 'react'
import { connect } from 'react-redux'
import {
  View,
  StyleSheet,
  ActionSheetIOS,
  SectionList,
  NativeModules,
} from 'react-native'
import i18n from 'format-message'

import AssignmentListActions from './actions'
import CourseActions from '../courses/actions'
import { mapStateToProps, type AssignmentListProps } from './map-state-to-props'
import refresh from '../../utils/refresh'

import SectionHeader from '../../common/components/rows/SectionHeader'
import AssignmentListRowView from './components/AssignmentListRow'
import { LinkButton } from '../../common/buttons'
import { Heading1 } from '../../common/text'
import Screen from '../../routing/Screen'
import { type TraitCollection } from '../../routing/Navigator'
import { isRegularDisplayMode } from '../../routing/utils'
import ActivityIndicatorView from '../../common/components/ActivityIndicatorView'

type State = {
  currentFilter: {
    index?: number,
    title: string,
  },
  filterApplied: boolean,
}

const { NativeAccessibility } = NativeModules

export class AssignmentList extends Component<any, AssignmentListProps, State> {
  state: State
  isRegularScreenDisplayMode: boolean
  data: any = []
  didSelectFirstItem = false

  constructor (props: AssignmentListProps) {
    super(props)

    this.state = {
      currentFilter: { title: i18n('All Grading Periods') },
      filterApplied: false,
    }
  }

  componentWillReceiveProps (nextProps: AssignmentListProps) {
    if (nextProps.assignmentGroups.length && nextProps.gradingPeriods.length) {
      NativeAccessibility.refresh()
    }
  }

  onTraitCollectionChange () {
    this.props.navigator.traitCollection((traits) => { this.traitCollectionDidChange(traits) })
  }

  traitCollectionDidChange (traits: TraitCollection) {
    this.isRegularScreenDisplayMode = isRegularDisplayMode(traits)
    if (!this.isRegularScreenDisplayMode) {
      this.didSelectFirstItem = false
    }
    this.selectFirstListItemIfNecessary()
  }

  selectFirstListItemIfNecessary () {
    let assignment = null
    if (!this.didSelectFirstItem && this.isRegularScreenDisplayMode && (assignment = this.firstAssignmentInList())) {
      this.selectedAssignment(assignment)
      this.didSelectFirstItem = true
    }
  }

  firstAssignmentInList (): ?Assignment {
    if (this.data.length > 0 && this.data[0].assignments.length > 0) {
      return this.data[0].assignments.sort((a, b) => a.position - b.position)[0]
    }
    return null
  }

  prepareListData () {
    return this.props.assignmentGroups.map(group => {
      let gradingPeriodFilter
      if (this.state.currentFilter.index != null) {
        gradingPeriodFilter = this.props.gradingPeriods[this.state.currentFilter.index]
      }
      let assignments = this.state.filterApplied
        ? group.assignments.filter(({ id }) => gradingPeriodFilter.assignmentRefs.includes(id))
        : group.assignments

      if (assignments.length) {
        return {
          key: group.id,
          ...group,
          data: assignments.slice().sort((a, b) => a.position - b.position),
        }
      }
    }).filter(item => item)
  }

  renderRow = ({ item, index }: { item: Assignment, index: number }) => {
    let selected = this.isRegularScreenDisplayMode && this.props.selectedRowID === item.id
    return <AssignmentListRowView assignment={item} tintColor={this.props.courseColor} onPress={this.selectedAssignment} key={index} selected={selected } />
  }

  renderSectionHeader = ({ section }: any) => {
    return <SectionHeader title={section.name} key={section.key} top={section.position === 1} />
  }

  selectedAssignment = (assignment: Assignment) => {
    this.props.updateCourseDetailsSelectedTabSelectedRow(assignment.id)

    if (assignment.quiz_id) {
      this.props.navigator.show(`/courses/${assignment.course_id}/quizzes/${assignment.quiz_id}`)
    } else if (assignment.discussion_topic) {
      this.props.navigator.show(`/courses/${assignment.course_id}/discussion_topics/${assignment.discussion_topic.id}`)
    } else {
      this.props.navigator.show(assignment.html_url)
    }
  }

  clearFilter = () => {
    this.setState({
      currentFilter: { title: i18n('All Grading Periods') },
      filterApplied: false,
    })
  }

  applyFilter = () => {
    let buttons = this.props.gradingPeriods.map(({ title }) => title).concat(i18n('Cancel'))
    ActionSheetIOS.showActionSheetWithOptions({
      options: buttons,
      cancelButtonIndex: buttons.length - 1,
      title: i18n('Filter by:'),
    }, this.updateFilter)
  }

  updateFilter = (index: number) => {
    // don't do anything if the user hits cancel
    if (index === this.props.gradingPeriods.length) return

    // get assignment info for grading period only if we don't have it yet
    if (this.props.gradingPeriods[index].assignmentRefs.length === 0) {
      this.props.refreshAssignmentList(this.props.courseID, this.props.gradingPeriods[index].id)
    }

    this.setState({
      currentFilter: {
        title: this.props.gradingPeriods[index].title,
        index,
      },
      filterApplied: true,
    })
  }

  toggleFilter = () => {
    if (this.state.filterApplied) {
      this.clearFilter()
    } else {
      this.applyFilter()
    }
  }

  render () {
    if (this.props.pending && !this.props.refreshing) {
      return <ActivityIndicatorView />
    }
    if (this.data.length === 0) {
      this.data = this.prepareListData()
      this.selectFirstListItemIfNecessary()
    } else {
      this.data = this.prepareListData()
    }

    return (
      <Screen
        title={i18n('Assignments')}
        onTraitCollectionChange={this.onTraitCollectionChange.bind(this)}
        subtitle={this.props.courseName}
        navBarStyle='dark'
        navBarColor={this.props.courseColor}
        testID='assignment-list'
      >
        <View style={styles.container} testID='assignment-list.container-view'>
          <View style={styles.header} testID='assignment-list.filter-header-view'>
            <Heading1 style={styles.headerTitle} testID='assignment-list.filter-title-lbl'>{this.state.currentFilter.title}</Heading1>
            {this.props.gradingPeriods.length > 0 &&
              <LinkButton testID='assignment-list.filter' onPress={this.toggleFilter} style={styles.filterButton}>
                {this.state.filterApplied
                  ? i18n('Clear filter')
                  : i18n('Filter')}
              </LinkButton>
            }
          </View>
          <SectionList
            testID='assignment-list.list'
            sections={this.data}
            renderItem={this.renderRow}
            renderSectionHeader={this.renderSectionHeader}
            refreshing={this.props.refreshing}
            onRefresh={this.props.refresh}
            keyExtractor={(item, index) => item.id}
          />
        </View>
      </Screen>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    marginBottom: global.tabBarHeight,
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
  props => props.assignmentGroups.length === 0 || props.gradingPeriods.length === 0,
  props => Boolean(props.pending),
)(AssignmentList)
const Connected = connect(mapStateToProps, { ...AssignmentListActions, ...CourseActions })(Refreshed)
export default (Connected: Component<any, AssignmentListProps, State>)
