// @flow

import React from 'react'
import { View, StyleSheet, ActivityIndicator, Modal } from 'react-native'
import { ModalActivityIndicatorAlertText } from '../text'

type Props = {
  style: Object,
  animationType: string,
  transparent: boolean,
  visible: boolean,
  text: string,
  textStyle: Object,
  activityIndicatorColor: string,
  backgroundColor: string,
  height: number,
  width: number,
}

export default class ModalActivityIndicator extends React.Component<any, Props, any> {
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
              <ModalActivityIndicatorAlertText style={[style.textContent, this.props.textStyle]}>{this.props.text}</ModalActivityIndicatorAlertText>
              </View>
            </View>
            <ActivityIndicator size='large' color={this.props.activityIndicatorColor} style={style.activityIndicator}
            />
          </View>
        </View>
      </Modal>
    )
  }
}

ModalActivityIndicator.defaultProps = {
  animationType: 'fade',
  transparent: true,
  visible: false,
  text: '',
  activityIndicatorColor: '#fff',
  backgroundColor: 'rgba(0,0,0,0.8)',
  width: 170,
  height: 170,
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
