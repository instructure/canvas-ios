// @flow

import React, { Component } from 'react'
import {
  View,
  FlatList,
  StyleSheet,
  ActionSheetIOS,
  AlertIOS,
} from 'react-native'
import { connect } from 'react-redux'
import type {
  SubmissionListProps,
  SubmissionProps,
  SubmissionDataProps,
} from './submission-prop-types'
import { mapStateToProps } from './map-state-to-props'
import i18n from 'format-message'
import SubmissionRow from './SubmissionRow'
import SubmissionActions from './actions'
import EnrollmentActions from '../../enrollments/actions'
import refresh from '../../../utils/refresh'
import { LinkButton } from '../../../common/buttons'
import { Heading1 } from '../../../common/text'
import { route } from '../../../routing'

type Props = SubmissionListProps & NavProps & RefreshProps
type FilterOptionType = 'all' | 'late' | 'notsubmitted' | 'notgraded' | 'graded' | 'lessthan' | 'morethan' | 'cancel'
type FilterOption = {
  type: FilterOptionType,
  title: string,
}
type SelectedFilter = {
  type: FilterOptionType,
  data?: any,
}

export class SubmissionList extends Component<any, Props, any> {
  filterOptions: FilterOption[]
  selectedFilter: ?SelectedFilter

  constructor (props: Props) {
    super(props)

    this.state = {
      submissions: props.submissions || [],
    }

    props.navigator.setTitle({
      title: i18n({
        default: 'Submissions',
        description: 'Title for the list of submissions for an assignment',
      }),
    })

    if (props.courseColor) {
      const color: string = props.courseColor
      props.navigator.setStyle({
        navBarBackgroundColor: color,
      })
    }

    this.filterOptions = [
      {
        type: 'all',
        title: i18n({ default: 'All submissions', description: 'Title for a button to show all submissions' }),
      },
      {
        type: 'late',
        title: i18n({ default: 'Submitted late', description: 'Title for a button to filter submissions by submitted late' }),
      },
      {
        type: 'notsubmitted',
        title: i18n({ default: "Haven't submitted yet", description: 'Title for a button to filter submissions by not submitted' }),
      },
      {
        type: 'notgraded',
        title: i18n({ default: "Haven't been graded", description: 'Title for a button to filter submissions by not graded' }),
      },
      {
        type: 'lessthan',
        title: i18n({ default: 'Scored less than…', description: 'Title for a button to filter submissions by less than a value' }),
      },
      {
        type: 'morethan',
        title: i18n({ default: 'Scored more than…', description: 'Title for a button to filter submissions by more than a value' }),
      },
      {
        type: 'cancel',
        title: i18n('Cancel'),
      },
    ]
  }

  componentWillMount = () => {
    // $FlowFixMe
    if (this.props.filterType) {
      this.selectedFilter = {
        type: this.props.filterType,
      }
      this.updateSubmissions(this.props.submissions)
    }
  }

  componentWillReceiveProps = (newProps: Props) => {
    this.updateSubmissions(newProps.submissions)
  }

  keyExtractor = (item: SubmissionProps) => {
    return item.userID
  }

  navigateToSubmission = (userID: string) => {
    if (!global.V03) { return } // such features

    let destination = route(`/courses/${this.props.courseID}/assignments/${this.props.assignmentID}/submissions/${userID}`)
    this.props.navigator.showModal({
      ...destination,
      navigatorStyle: {
        navBarHidden: true,
        statusBarHidden: true,
        statusBarHideWithNavBar: true,
      },
    })
  }

  renderRow = ({ item }: { item: SubmissionProps }) => {
    return <SubmissionRow {...item} onPress={this.navigateToSubmission} />
  }

  chooseFilter = () => {
    const titles = this.filterOptions.map((option) => option.title)
    ActionSheetIOS.showActionSheetWithOptions({
      options: titles,
      cancelButtonIndex: titles.length - 1,
      title: i18n({
        default: 'Filter by:',
        description: 'Indicates to the user that they can filter by a few options',
      }),
    }, this.updateFilter)
  }

  updateFilter = (index: number) => {
    const prompt = (title: string, callback: Function) => {
      let message = i18n({
        default: 'Out of {count}',
        description: 'Subtitle for a submission to filter by points',
      }, {
        count: this.props.pointsPossible || 0,
      })
      AlertIOS.prompt(
        title,
        message,
        callback,
        'plain-text',
        '',
        'numeric'
      )
    }

    const filter = this.filterOptions[index]
    const selectedFilter: SelectedFilter = {
      type: filter.type,
    }

    const update = () => {
      this.selectedFilter = selectedFilter
      this.updateSubmissions(this.props.submissions)
    }

    switch (filter.type) {
      case 'lessthan':
        prompt(filter.title, (text) => {
          selectedFilter.data = text
          update()
        })
        return
      case 'morethan':
        prompt(filter.title, (text) => {
          selectedFilter.data = text
          update()
        })
        return
      case 'cancel':
        break
      default:
        update()
        break
    }
  }

  clearFilter = () => {
    this.selectedFilter = null
    this.updateSubmissions(this.props.submissions)
  }

  updateSubmissions = (submissions: SubmissionDataProps[]) => {
    let filtered = null

    const filter = this.selectedFilter
    if (filter) {
      switch (filter.type) {
        case 'late':
          filtered = submissions.filter((s) => s.status === 'late')
          break
        case 'notsubmitted':
          filtered = submissions.filter((s) => s.grade === 'not_submitted')
          break
        case 'notgraded':
          filtered = submissions.filter((s) => s.grade === 'ungraded')
          break
        case 'graded':
          filtered = submissions.filter((s) => s.score !== null && s.score !== undefined)
          break
        case 'lessthan':
          filtered = submissions.filter((s) => {
            return (s.score !== null && s.score !== undefined) && (s.score < Number(filter.data))
          })
          break
        case 'morethan':
          filtered = submissions.filter((s) => {
            return (s.score !== null && s.score !== undefined) && (s.score > Number(filter.data))
          })
          break
        default:
          break
      }
    }

    this.setState({
      submissions: filtered || submissions,
    })
  }

  renderFilterButton = (): React.Element<View> => {
    let title = i18n('Filter')
    let accessibilityLabel = i18n('Filter Submissions')
    let onPress = this.chooseFilter

    if (this.selectedFilter &&
        this.selectedFilter.type !== 'all' &&
        this.selectedFilter.type !== 'cancel') {
      title = i18n('Clear Filter')
      accessibilityLabel = i18n('Clear Filter Submissions')
      onPress = this.clearFilter
    }

    return (<LinkButton
              testID='submission-list.filter'
              onPress={onPress}
              style={styles.filterButton}
              accessibilityLabel={ accessibilityLabel }
              >
              { title }
            </LinkButton>)
  }

  render () {
    return (
      <View style={styles.container}>
        <View style={styles.header}>
          <Heading1
            style={styles.headerTitle}
            >
            { i18n('All Submissions') }
          </Heading1>
          { this.renderFilterButton() }
        </View>
        <FlatList
          data={this.state.submissions}
          keyExtractor={this.keyExtractor}
          testID='submission-list'
          renderItem={this.renderRow}
          refreshing={this.props.pending}
          onRefresh={this.props.refresh}
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
    paddingBottom: 12,
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

export function refreshSubmissionList (props: SubmissionListProps): void {
  props.refreshSubmissions(props.courseID, props.assignmentID)
  props.refreshEnrollments(props.courseID)
}

export function shouldRefresh (props: SubmissionListProps): boolean {
  return props.shouldRefresh
}

const Refreshed = refresh(
  refreshSubmissionList,
  shouldRefresh,
  props => props.pending
)(SubmissionList)
const Connected = connect(mapStateToProps, { ...SubmissionActions, ...EnrollmentActions })(Refreshed)
export default (Connected: Component<any, SubmissionListProps, any>)
