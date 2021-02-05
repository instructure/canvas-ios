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

import React, { Component } from 'react'
import {
  Image,
  FlatList,
  Alert,
} from 'react-native'
import i18n from 'format-message'
import Screen from '../../routing/Screen'
import { type SubmissionFilterOption, updateFilterSelection } from './filter-options'
import Row from '../../common/components/rows/Row'
import icon from '../../images/inst-icons'
import { createStyleSheet } from '../../common/stylesheet'

type FilterProps = {
  filterOptions: Array<SubmissionFilterOption>,
  applyFilter: (filterOptions: Array<SubmissionFilterOption>) => void,
  navigator: Navigator,
  filterPromptMessage: string,
}

type FilterState = {
  filterOptions: Array<SubmissionFilterOption>,
}

export default class Filter extends Component<FilterProps, FilterState> {
  state = {
    filterOptions: this.props.filterOptions,
  }

  resetAllFilters = () => {
    let options = this.state.filterOptions.map(filter => ({ ...filter, selected: false, disabled: false, promptValue: undefined }))
    this.setState({ filterOptions: options })
  }

  applyFilters = () => {
    this.props.applyFilter(this.state.filterOptions)
    this.props.navigator.dismiss()
  }

  updateFilterSelection = (selectedType: string, promptValue?: string) => {
    this.setState({
      filterOptions: updateFilterSelection(this.state.filterOptions, selectedType, promptValue),
    })
  }

  onFilterPress = (type: string) => {
    let selectedOption = this.state.filterOptions.find(option => option.type === type) || {}

    if (selectedOption.prompt && !selectedOption.selected) {
      Alert.prompt(selectedOption.title(), this.props.filterPromptMessage, (promptValue) => {
        this.updateFilterSelection(selectedOption.type, promptValue)
      }, 'plain-text', '', 'numeric')
    } else {
      this.updateFilterSelection(selectedOption.type)
    }
  }

  keyExtractor (item: SubmissionFilterOption) {
    return item.type
  }

  renderRow = ({ item }: { item: SubmissionFilterOption }) => {
    return (
      <Row
        title={item.title()}
        accessibilityState={{ selected: item.selected ? true : false }}
        identifier={item.type}
        onPress={this.onFilterPress}
        border='bottom'
        titleStyles={[styles.filterTitle, item.disabled ? styles.disabledOption : null]}
        accessories={
          item.selected &&
            <Image style={styles.selectedCheck} source={icon('check', 'solid')} />
        }
        testID={`filter.option-${item.type}`}
      />
    )
  }

  render () {
    return (
      <Screen
        title={i18n('Filter by')}
        leftBarButtons={[{
          title: i18n('Reset'),
          testID: 'filter.reset',
          action: this.resetAllFilters,
        }]}
        rightBarButtons={[{
          title: i18n('Done'),
          testID: 'filter.done',
          action: this.applyFilters,
        }]}
        showDismissButton={false}
      >
        <FlatList
          data={this.state.filterOptions}
          renderItem={this.renderRow}
          keyExtractor={this.keyExtractor}
        />
      </Screen>
    )
  }
}

const styles = createStyleSheet(colors => ({
  filterTitle: {
    fontWeight: '400',
    fontSize: 18,
  },
  disabledOption: {
    color: colors.textDark,
  },
  selectedCheck: {
    tintColor: colors.primary,
    width: 18,
    height: 18,
  },
}))
