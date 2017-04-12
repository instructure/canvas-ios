/**
 * @flow
 */

import React, { Component } from 'react'
import {
  View,
  Image,
  Text,
  TouchableHighlight,
  StyleSheet,
} from 'react-native'

import { type Assignee } from './AssigneePicker'
import Images from '../../images'
import Button from 'react-native-button'
import colors from '../../common/colors'

export type Props = {
  assignee: Assignee,
  onPress: Function,
  onDelete: Function,
}

export default class AssigneeRow extends Component<any, Props, any> {

  renderImage (): any {
    const assignee = this.props.assignee
    if (!assignee.imageURL) {
      const altText = assignee.name
      .split(' ')
      .map((word) => word[0])
      .filter((c) => c)
      .reduce((m, c) => m + c)
      .substring(0, 4)
      .toUpperCase()
      return (<View style={styles.altImage}>
                <Text style={styles.altImageText}>{altText}</Text>
              </View>)
    } else {
      return (<View style={styles.imageContainer}>
                <Image source={{ uri: assignee.imageURL }} style={styles.image} />
              </View>)
    }
  }

  onPress = () => {
    if (this.props.onPress) {
      this.props.onPress(this.props.assignee)
    }
  }

  onDelete = () => {
    if (this.props.onDelete) {
      this.props.onDelete(this.props.assignee)
    }
  }

  render (): React.Element<View> {
    const assignee = this.props.assignee
    const image = this.renderImage()

    return (<TouchableHighlight style={styles.touchable} onPress={this.onPress} >
              <View style={styles.container}>
                {image}
                <View style={styles.textContainer}>
                  <Text>{assignee.name}</Text>
                  { assignee.info && <Text>{assignee.info}</Text> }
                </View>
                { this.props.onDelete && (<View style={styles.deleteButtonContainer}>
                                            <Button onPress={this.onDelete} style={styles.deleteButton}>
                                              <Image source={Images.x} />
                                            </Button>
                                          </View>) }
              </View>
            </TouchableHighlight>)
  }
}

const styles = StyleSheet.create({
  touchable: {
    flex: 1,
    height: 54,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: colors.seperatorColor,
  },
  container: {
    flex: 1,
    backgroundColor: 'white',
    flexDirection: 'row',
    alignItems: 'center',
    paddingLeft: global.style.defaultPadding,
    paddingRight: global.style.defaultPadding,
  },
  textContainer: {
    flexDirection: 'column',
    justifyContent: 'center',
  },
  imageContainer: {
    height: 40,
    width: 40,
    overflow: 'hidden',
    marginRight: global.style.defaultPadding,
    borderRadius: 20,
  },
  image: {
    height: 40,
    width: 40,
  },
  altImage: {
    height: 40,
    width: 40,
    borderRadius: 20,
    borderColor: colors.seperatorColor,
    borderWidth: StyleSheet.hairlineWidth,
    overflow: 'hidden',
    marginRight: global.style.defaultPadding,
    justifyContent: 'center',
    alignItems: 'center',
  },
  altImageText: {
    fontSize: 16,
    fontWeight: 'bold',
  },
  deleteButtonContainer: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'flex-end',
    justifyContent: 'flex-end',
  },
  deleteButton: {
    flex: 0,
    height: 44,
    width: 44,
  },
})
