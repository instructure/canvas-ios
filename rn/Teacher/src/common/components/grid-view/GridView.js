/**
 * React Native Grid Component
 * https://github.com/phil-r/react-native-grid-component
 * @flow
 */

import React, { Component } from 'react'
import ReactNative, {
  StyleSheet,
  View,
  ListView,
  Dimensions,
} from 'react-native'

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

type Props = {
  itemsPerRow: number,
  onEndReached: Function,
  itemHasChanged: Function,
  renderItem: Function,
  renderPlaceholder: Function,
  renderSectionHeader: Function,
  data: Array<any>,
  renderFooter: Function,
  sections: boolean,
  placeholderStyle: StyleSheet,
  style: StyleSheet,
  onLayout: Function,
}

type State = {
  dataSource: ReactNative.ListViewDataSource,
}

//  Lifted from https://github.com/phil-r/react-native-grid-component/blob/master/index.js
export default class GridView extends Component<any, Props, State> {
  state: State

  static propTypes = {
    itemsPerRow: React.PropTypes.number,
    onEndReached: React.PropTypes.func,
    itemHasChanged: React.PropTypes.func,
    renderItem: React.PropTypes.func.isRequired,
    renderPlaceholder: React.PropTypes.func,
    data: React.PropTypes.arrayOf(React.PropTypes.any).isRequired,
    renderFooter: React.PropTypes.func,
  }

  static defaultProps = {
    itemsPerRow: 2,
    onEndReached () {},
    itemHasChanged (r1: any, r2: any): boolean {
      return r1 !== r2
    },
    renderFooter: () => null,
  }

  constructor (props: Props) {
    super(props)

    const ds = new ListView.DataSource({
      rowHasChanged: (r1, r2) => r1.some((e, i) => props.itemHasChanged(e, r2[i])),
      sectionHeaderHasChanged: (s1, s2) => s1 !== s2,
    })
    if (props.sections === true) {
      this.state = {
        dataSource: ds.cloneWithRowsAndSections(this._prepareSectionedData(this.props.data, props)),
      }
    } else {
      this.state = {
        dataSource: ds.cloneWithRows(this._prepareData(this.props.data, props)),
      }
    }
  }

  componentWillReceiveProps (nextProps: Object) {
    if (nextProps.sections === true) {
      this.state = {
        dataSource: this.state.dataSource.cloneWithRowsAndSections(this._prepareSectionedData(nextProps.data, nextProps)),
      }
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

  _renderRow = rowData =>
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

  render (): React.Element<View> {
    return (
      <View style={[styles.container, this.props.style]} onLayout={this.props.onLayout}>
        <ListView
          {...this.props}
          style={styles.list}
          dataSource={this.state.dataSource}
          renderRow={this._renderRow}
          enableEmptySections
          onEndReached={this.props.onEndReached}
          onEndReachedThreshold={height}
          renderFooter={this.props.renderFooter}
          renderSectionHeader={this.props.renderSectionHeader}
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
  },
  row: {
    justifyContent: 'space-around',
    flexDirection: 'row',
    flexWrap: 'wrap',
    alignItems: 'flex-start',
    flex: 1,
  },
})
