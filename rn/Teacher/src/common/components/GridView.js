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

/**
 * React Native Grid Component
 * https://github.com/phil-r/react-native-grid-component
 * @flow
 */

import React, { Component } from 'react'
import PropTypes from 'prop-types'
import ReactNative, {
  StyleSheet,
  View,
  Dimensions,
} from 'react-native'

import { RefreshableListView } from './RefreshableList'

const { height } = Dimensions.get('window')

// http://stackoverflow.com/questions/8495687/split-array-into-chunks
// I don't see the reason to take lodash.chunk for this
const chunk = (arr: Array<any>, n: number) => {
  if (n === 0) return [arr]
  return Array.from(Array(Math.ceil(arr.length / n)), (_, i) => arr.slice(i * n, (i * n) + n))
}

const mapValues = (obj: any, callback: Function) => {
  const newObj = {}

  Object.keys(obj).forEach((key: string) => {
    newObj[key] = callback(obj[key])
  })

  return newObj
}

type DefaultProps = {
  itemsPerRow: number,
  onEndReached: () => void,
  renderFooter: () => void,
}

type Props = {
  itemsPerRow: number,
  onEndReached?: Function,
  renderItem: Function,
  renderPlaceholder?: Function,
  renderSectionHeader?: Function,
  data: Array<any>,
  renderFooter?: Function,
  renderHeader?: Function,
  sections?: boolean,
  placeholderStyle: any,
  style: any,
  onLayout: Function,
  contentInset?: Object,
  showsVerticalScrollIndicator?: boolean,
  onRefresh: Function,
}

type State = {
  dataSource: ReactNative.ListViewDataSource,
  refreshing: boolean,
}

//  Lifted from https://github.com/phil-r/react-native-grid-component/blob/master/index.js
export default class GridView extends Component<DefaultProps, Props, State> {
  state: State

  static propTypes = {
    itemsPerRow: PropTypes.number,
    onEndReached: PropTypes.func,
    renderItem: PropTypes.func.isRequired,
    renderPlaceholder: PropTypes.func,
    data: PropTypes.arrayOf(PropTypes.any).isRequired,
    renderFooter: PropTypes.func,
    contentInset: PropTypes.object,
    showsVerticalScrollIndicator: PropTypes.bool,
  }

  static defaultProps = {
    itemsPerRow: 2,
    onEndReached: () => {},
    renderFooter: () => {},
  }

  constructor (props: Props) {
    super(props)

    const ds = new RefreshableListView.DataSource({
      rowHasChanged: (r1, r2) => r1 !== r2,
      sectionHeaderHasChanged: (s1, s2) => s1 !== s2,
    })
    let state = {
      refreshing: false,
      dataSource: null,
    }
    if (props.sections === true) {
      state.dataSource = ds.cloneWithRowsAndSections(this._prepareSectionedData(this.props.data, props))
    } else {
      state.dataSource = ds.cloneWithRows(this._prepareData(this.props.data, props))
    }

    this.state = state
  }

  componentWillReceiveProps (nextProps: Object) {
    this.setState({ refreshing: false })
    if (nextProps.sections === true) {
      this.setState({
        dataSource: this.state.dataSource.cloneWithRowsAndSections(this._prepareSectionedData(nextProps.data, nextProps)),
      })
    } else {
      this.setState({
        dataSource: this.state.dataSource.cloneWithRows(this._prepareData(nextProps.data, nextProps)),
      })
    }
  }

  _prepareSectionedData = (data, props) => {
    const preparedData = mapValues(data, (vals) => this._prepareData(vals, props))
    return preparedData
  }

  _prepareData = (data: Array<any>, props) => {
    const rows = chunk(data, props.itemsPerRow)
    if (rows.length) {
      const lastRow = rows[rows.length - 1]
      for (let i = 0; lastRow.length < props.itemsPerRow; i += 1) {
        lastRow.push(null)
      }
    }
    return rows
  }

  _renderPlaceholder = i =>
    <View key={i} style={this.props.placeholderStyle} />

  _renderRow = rowData => {
    return (
      <View style={styles.row}>
        {rowData.map((item, i) => {
          if (item) {
            return this.props.renderItem(item, i)
          }
          // render a placeholder
          if (this.props.renderPlaceholder) {
            return this.props.renderPlaceholder(i)
          }
          return this._renderPlaceholder(i)
        })}
      </View>
    )
  }

  onRefresh = () => {
    this.setState({ refreshing: true })
    this.props.onRefresh()
  }

  render () {
    return (
      <View style={[styles.container, this.props.style]} onLayout={this.props.onLayout}>
        <RefreshableListView
          {...this.props}
          style={styles.list}
          dataSource={this.state.dataSource}
          renderRow={this._renderRow}
          enableEmptySections
          onEndReached={this.props.onEndReached}
          onEndReachedThreshold={height}
          renderHeader={this.props.renderHeader}
          renderFooter={this.props.renderFooter}
          renderSectionHeader={this.props.renderSectionHeader}
          refreshing={this.state.refreshing}
          onRefresh={this.onRefresh}
        />
      </View>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  list: {
    flex: 1,
    overflow: 'visible',
  },
  row: {
    justifyContent: 'space-around',
    flexDirection: 'row',
    flexWrap: 'wrap',
    alignItems: 'flex-start',
    flex: 1,
  },
})
