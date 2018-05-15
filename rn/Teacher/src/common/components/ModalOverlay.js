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

import React from 'react'
import { View, StyleSheet, ActivityIndicator, Modal } from 'react-native'
import { ModalOverlayText } from '../text'

type Props = {
  style?: Object,
  animationType: string,
  transparent: boolean,
  visible: boolean,
  text: string,
  textStyle?: Object,
  activityIndicatorColor: string,
  backgroundColor: string,
  height: number,
  width: number,
  showActivityIndicator: boolean,
}

export default class ModalOverlay extends React.Component<Props> {
  static defaultProps = {
    animationType: 'fade',
    transparent: true,
    visible: false,
    text: '',
    activityIndicatorColor: '#fff',
    backgroundColor: 'rgba(0,0,0,0.8)',
    width: 170,
    height: 170,
    showActivityIndicator: true,
  }

  render () {
    return (
      <Modal animationType={this.props.animationType}
        transparent={this.props.transparent}
        visible={this.props.visible}
        supportedOrientations={['portrait', 'landscape']}
      >
        <View style={[style.container]}>
          <View style={[style.background, { backgroundColor: this.props.backgroundColor }, { width: this.props.width, height: this.props.height }]}>
            <View style={style.textContainer}>
              <View style={style.textSubContainer}>
                <ModalOverlayText style={[style.textContent, this.props.textStyle]}>{this.props.text}</ModalOverlayText>
              </View>
            </View>
            {this.props.showActivityIndicator &&
              <ActivityIndicator
                size='large'
                color={this.props.activityIndicatorColor}
                style={style.activityIndicator}
              />
            }
          </View>
        </View>
      </Modal>
    )
  }
}

const style = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    flexDirection: 'row',
  },
  background: {
    backgroundColor: 'rgba(0,0,0,0.6)',
    borderRadius: 12,
  },
  textContainer: {
    flex: 1,
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center',
  },
  textSubContainer: {
    flex: 1,
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center',
  },
  textContent: {
    color: '#fff',
    alignItems: 'center',
    textAlign: 'center',
  },
  activityIndicator: {
    flex: 1,
    marginTop: -40,
  },
})
