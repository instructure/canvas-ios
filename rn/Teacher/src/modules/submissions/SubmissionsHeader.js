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
import {
  View,
  StyleSheet,
  AlertIOS,
} from 'react-native'

import i18n from 'format-message'
import { LinkButton } from '../../common/buttons'
import { Heading1, Text } from '../../common/text'
import colors from '../../common/colors'
import { joinTitles } from '../filter/filter-options'

export type SubmissionsHeaderProps = {
  filterOptions: SubmissionFilterOption[],
  selectedFilter?: ?SelectedSubmissionFilter,
  onClearFilter: Function,
  onSelectFilter: Function,
  navigator: Navigator,
}

const anonymousSubtitle = i18n('Anonymous grading')
const mutedSubtitle = i18n('Grades muted')
const bothSubtitle = i18n('Grades muted, Anonymous grading')

export default class SubmissionsHeader extends Component<any, SubmissionsHeaderProps, any> {

  navigateToFilter = () => {
    this.props.navigator.show('/filter', {
      modal: true,
    }, { ...this.props })
  }

  updateFilter = (index: number) => {
    const prompt = (title: string, callback: Function) => {
      let message = i18n('Out of {count}', { count: this.props.pointsPossible || 0 })
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
    let title = joinTitles(this.props.filterOptions) || i18n('All Submissions')

    let subTitle = ''
    if (this.props.muted && this.props.anonymous) {
      subTitle = bothSubtitle
    } else if (this.props.muted) {
      subTitle = mutedSubtitle
    } else if (this.props.anonymous) {
      subTitle = anonymousSubtitle
    }

    return (<View style={styles.headerWrapper}>
              <View style={styles.header}>
                <Heading1
                  numberOfLines={1}
                  style={styles.headerTitle}
                  >
                  { title }
                </Heading1>
                { this.renderFilterButton() }
              </View>
              {!!subTitle && <Text style={styles.subtitle}>{subTitle}</Text>}
            </View>)
  }

  renderFilterButton = () => {
    let title = i18n('Filter')
    let accessibilityLabel = i18n('Filter Submissions')
    let onPress = this.navigateToFilter

    let selected = this.props.filterOptions.filter(option => option.selected)
    if (selected.length > 0) {
      title = i18n('Filter ({numSelected})', { numSelected: selected.length })
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
}

const styles = StyleSheet.create({
  headerWrapper: {
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: 'lightgrey',
    paddingTop: 16,
    paddingBottom: 8,
    paddingHorizontal: 16,
    height: 'auto',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    justifyContent: 'space-between',
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: '600',
    color: '#2d3b44',
    flex: 1,
  },
  subtitle: {
    color: colors.grey4,
    fontSize: 14,
    fontWeight: '500',
  },
  filterButton: {
    marginBottom: 1,
    width: 'auto',
  },
})
