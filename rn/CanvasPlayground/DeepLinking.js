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
  FlatList,
  TouchableHighlight,
  Alert,
  LayoutAnimation,
  StyleSheet,
  Linking,
  Platform
} from 'react-native';
import {
  Root,
  ListItem,
  Body,
  Text,
  Picker,
  Icon,
  Container,
  Content,
} from 'native-base'
import { Font, AppLoading } from 'expo'
import accounts from './json/Accounts'

export default class DeepLinkingScreen extends React.Component {

  state = {
    loading: true,
    items: [],
    app: 'student',
    scheme: `canvas-student`,
    accounts: accounts,
    selectedAccount: accounts[0]
  }

  static navigationOptions = {
    title: 'Deep Linking',
  };

  componentDidMount = async () => {
    await Font.loadAsync({
      Roboto: require("native-base/Fonts/Roboto.ttf"),
      Roboto_medium: require("native-base/Fonts/Roboto_medium.ttf")
    })
    this.setState({ loading: false })
  }

  onPress = (item) => {
    let scheme = this.state.scheme
    let url = `${scheme}://${item.url}`
    Linking.openURL(url).catch(err => alert('Error! Unable to open URL.', err))
  }

  renderItem = ({ item }) => {
    const body = item.title ? (
      <Body style={{ marginStart: -10 }}>
        <Text style={{ fontSize: 18 }}>{item.title}</Text>
        <Text style={{ fontSize: 12 }}>{item.url}</Text>
      </Body>
    ) : (
        <Body style={{ marginStart: -10 }}>
          <Text style={{ fontSize: 18 }}>{item.url}</Text>
        </Body>
      )

    return (
      <ListItem button onPress={() => this.onPress(item)} style={{ justifyContent: 'space-between' }}>
        {body}
      </ListItem>
    )
  }

  render() {
    if (this.state.loading) {
      return (
        <Root><AppLoading /></Root>
      )
    }

    let accounts = this.state.accounts
    return (
      <Container>
        <Content>
          <Picker
            iosHeader="Select App"
            mode="dropdown"
            selectedValue={this.state.app}
            iosIcon={<Icon name="ios-arrow-down-outline" />}
            onValueChange={(itemValue, itemIndex) =>
              this.setState({ app: itemValue, scheme: `canvas-${itemValue}` })
            }
          >
            <Picker.Item label="Student" value="student" />
            <Picker.Item label="Teacher" value="teacher" />
            <Picker.Item label="Parent" value="parent" />
          </Picker>
          {Platform.OS === 'android' &&
            <Picker
              mode="dropdown"
              selectedValue={this.state.scheme}
              onValueChange={(itemValue, itemIndex) =>
                this.setState({ scheme: itemValue })
              }
            >
              <Picker.Item label={`canvas-${this.state.app}`} value={`canvas-${this.state.app}`} />
              <Picker.Item label="https" value="https" />
            </Picker>
          }
          <Picker
            iosHeader="Select Domain"
            iosIcon={<Icon name="ios-arrow-down-outline" />}
            mode="dropdown"
            selectedValue={this.state.selectedAccount.domain}
            onValueChange={(itemValue, itemIndex) =>
              this.setState({ selectedAccount: accounts.find((a) => a.domain == itemValue) })
            }
          >
            {accounts.map((a) =>
              <Picker.Item label={a.domain} value={a.domain} />
            )}
          </Picker>
          <FlatList
            data={this.state.selectedAccount.urls}
            renderItem={this.renderItem}
            extraData={this.state}
          >
          </FlatList>
        </Content>
      </Container>
    )
  }
}
