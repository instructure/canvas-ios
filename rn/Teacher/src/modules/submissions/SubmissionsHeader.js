// @flow

import React, { Component } from 'react'
import {
  View,
  StyleSheet,
  ActionSheetIOS,
  AlertIOS,
} from 'react-native'

import i18n from 'format-message'
import { LinkButton } from '../../common/buttons'
import { Heading1 } from '../../common/text'

type SubmissionFilterOptionType = 'all' | 'late' | 'notsubmitted' | 'notgraded' | 'graded' | 'lessthan' | 'morethan' | 'cancel'

export type SubmissionFilterOption = {
  type: SubmissionFilterOptionType,
  title: string,
  filterFunc?: Function,
}

export type SelectedSubmissionFilter = {
  filter: SubmissionFilterOption,
  metadata?: ?any,
}

export type SubmissionsHeaderProps = {
  filterOptions: SubmissionFilterOption[],
  selectedFilter?: ?SelectedSubmissionFilter,
  onClearFilter: Function,
  onSelectFilter: Function,
}

export default class SubmissionsHeader extends Component<any, SubmissionsHeaderProps, any> {

  chooseFilter = () => {
    const options = this.props.filterOptions.map((option) => option.title)
    ActionSheetIOS.showActionSheetWithOptions({
      options,
      cancelButtonIndex: options.length - 1,
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

    const filter = this.props.filterOptions[index]
    const selectedFilter: SelectedSubmissionFilter = {
      filter: filter,
    }

    switch (filter.type) {
      case 'lessthan':
      case 'morethan':
        prompt(filter.title, (text) => {
          selectedFilter.metadata = text
          this.props.onSelectFilter(selectedFilter)
        })
        return
      case 'cancel':
        break
      default:
        this.props.onSelectFilter(selectedFilter)
        break
    }
  }

  clearFilter = () => {
    this.props.onClearFilter()
  }

  render () {
    let title = i18n('All Submissions')
    const selected = this.props.selectedFilter
    if (selected && selected.filter && selected.filter.type !== 'all') {
      title = selected.filter.title
    }

    return (<View style={styles.header}>
              <Heading1
                style={styles.headerTitle}
                >
                { title }
              </Heading1>
              { this.renderFilterButton() }
            </View>)
  }

  renderFilterButton = (): React.Element<View> => {
    let title = i18n('Filter')
    let accessibilityLabel = i18n('Filter Submissions')
    let onPress = this.chooseFilter
    const selected = this.props.selectedFilter

    if (selected &&
        selected.filter &&
        selected.filter.type !== 'all' &&
        selected.filter.type !== 'cancel') {
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

  // This assumes using some flavor of SubmissionRowDataProps to back the rows in a submission list
  static defaultFilterOptions (): SubmissionFilterOption[] {
    return [
      {
        type: 'all',
        title: i18n({ default: 'All submissions', description: 'Title for a button to show all submissions' }),
      },
      {
        type: 'late',
        title: i18n({ default: 'Submitted late', description: 'Title for a button to filter submissions by submitted late' }),
        filterFunc: (submissions: any) => submissions.filter((s) => s.status === 'late'),
      },
      {
        type: 'notsubmitted',
        title: i18n({ default: "Haven't submitted yet", description: 'Title for a button to filter submissions by not submitted' }),
        filterFunc: (submissions: any) => submissions.filter((s) => s.grade === 'not_submitted'),
      },
      {
        type: 'notgraded',
        title: i18n({ default: "Haven't been graded", description: 'Title for a button to filter submissions by not graded' }),
        filterFunc: (submissions: any) => submissions.filter((s) => s.grade === 'ungraded'),
      },
      {
        type: 'graded',
        title: i18n({ default: 'Graded', description: 'Title for a button to filter submissions by graded' }),
        filterFunc: (submissions: any) => submissions.filter((s) => s.score !== null && s.score !== undefined),
      },
      {
        type: 'lessthan',
        title: i18n({ default: 'Scored less than…', description: 'Title for a button to filter submissions by less than a value' }),
        filterFunc: (submissions: any, metadata: any) => submissions.filter((s) => {
          return (s.score !== null && s.score !== undefined) && (s.score < Number(metadata))
        }),
      },
      {
        type: 'morethan',
        title: i18n({ default: 'Scored more than…', description: 'Title for a button to filter submissions by more than a value' }),
        filterFunc: (submissions: any, metadata: any) => submissions.filter((s) => {
          return (s.score !== null && s.score !== undefined) && (s.score > Number(metadata))
        }),
      },
      {
        type: 'cancel',
        title: i18n('Cancel'),
      },
    ]
  }
}

const styles = StyleSheet.create({
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
