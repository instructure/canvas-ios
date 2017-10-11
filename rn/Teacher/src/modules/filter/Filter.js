// @flow

import React, { Component } from 'react'
import {
  View,
  Image,
  FlatList,
  StyleSheet,
  AlertIOS,
} from 'react-native'
import i18n from 'format-message'
import Screen from '../../routing/Screen'
import { type SubmissionFilterOption, updateFilterSelection } from './filter-options'
import Row from '../../common/components/rows/Row'
import Images from '../../images'
import colors from '../../common/colors'

type FilterProps = {
  filterOptions: Array<SubmissionFilterOption>,
  applyFilter: (filterOptions: Array<SubmissionFilterOption>) => void,
  navigator: Navigator,
  filterPromptMessage: string,
}

type FilterState = {
  filterOptions: Array<SubmissionFilterOption>,
}

export default class Filter extends Component {
  props: FilterProps
  state: FilterState

  constructor (props: FilterProps) {
    super(props)
    this.state = {
      filterOptions: this.props.filterOptions,
    }
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
      AlertIOS.prompt(selectedOption.title(), this.props.filterPromptMessage, (promptValue) => {
        this.updateFilterSelection(selectedOption.type, promptValue)
      })
    } else {
      this.updateFilterSelection(selectedOption.type)
    }
  }

  renderRow = ({ item }: { item: SubmissionFilterOption }) => {
    return (
      <Row
        title={item.title()}
        identifier={item.type}
        onPress={this.onFilterPress}
        border='bottom'
        titleStyles={[styles.filterTitle, item.disabled ? styles.disabledOption : null]}
        accessories={
          item.selected &&
            <View style={styles.selectedCheck}>
              <Image source={Images.check} style={{ width: 12, height: 12 }} />
            </View>
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
      >
        <FlatList
          data={this.state.filterOptions}
          renderItem={this.renderRow}
          extraData
        />
      </Screen>
    )
  }
}

const styles = StyleSheet.create({
  filterTitle: {
    fontWeight: '400',
    fontSize: 18,
  },
  disabledOption: {
    color: colors.secondaryButton,
  },
  selectedCheck: {
    backgroundColor: colors.link,
    padding: 6,
    borderRadius: 12,
    width: 24,
    height: 24,
  },
})
