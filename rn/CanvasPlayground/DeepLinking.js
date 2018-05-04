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

import React from 'react';
import { 
  Text,
  View,
  FlatList,
  TouchableHighlight,
  Alert,
  TextInput,
  LayoutAnimation,
  AsyncStorage,
  StyleSheet,
  Linking,
  Button,
} from 'react-native';
import links from './deep-links.json'

export default class DeepLinkingScreen extends React.Component {

  state = {
    items: [],
  }

  static navigationOptions = {
    title: 'Deep Linking',
  };

  componentDidMount = async () => {
    let data = await AsyncStorage.getItem('route-items')
    let items = JSON.parse(data || []).filter((item) => !!item && !!item.url)
    let predefinedItems = links.map((item) => ({ url: item }))
    this.setState({ items: [...items, ...predefinedItems] })
  }

  onPress = (item) => {
    let url = `canvas-student://${item.url}`
    Linking.openURL(url)
  }

  onBlur = () => {
    if (!this.state.text) return
    LayoutAnimation.easeInEaseOut()
    let deletable = this.state.items.filter((item) => item.deletable)
    let provided = this.state.items.filter((item) => !item.deletable)
    let items = [...deletable, { url: this.state.text, deletable: true }, ...provided]
    this.setState({
      text: null,
      items,
    })
    let toPersist = items.filter((item) => item.deletable)
    AsyncStorage.setItem('route-items', JSON.stringify(toPersist))
  }

  deleteItem = (item) => {
    let items = this.state.items.filter((thing) => thing.url !== item.url)
    this.setState({ items })
    AsyncStorage.setItem('route-items', JSON.stringify(items))
  }

  renderItem = ({ item }) => {
    return (<TouchableHighlight onPress={() => this.onPress(item)}>
              <View style={{ backgroundColor: 'white', padding: 8, flex: 1, flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' }}>
                <Text numberOfLines={0}>{item.url}</Text>
                { item.deletable && <Button title={'Delete'} onPress={() => this.deleteItem(item) } /> }
              </View>
            </TouchableHighlight>)
  }

  renderSeperator = () => {
    return <View style={{ height: StyleSheet.hairlineWidth, backgroundColor: 'lightgrey' }} />
  }

  render() {
    return (
      <View style={{ flex: 1, backgroundColor: 'white' }}>
        <View>
          <TextInput
            style={{ height: 34, padding: 8 }}
            onChangeText={(text) => this.setState({text})}
            value={this.state.text}
            placeholder={'Enter a new route'}
            onBlur={this.onBlur}
            autoCapitalize={'none'}
          />
        </View>
        <Text style={{ padding: 8 }}>Saved Routes:</Text>
        <FlatList 
          data={this.state.items}
          renderItem={this.renderItem}
          ItemSeparatorComponent={this.renderSeperator}
          ListFooterComponent={this.renderSeperator} />
      </View>
    )
  }
}
