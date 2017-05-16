// @flow

import {
  processColor,
  Image,
} from 'react-native'

function isColorKey (key: string): boolean {
  const COLOR_REGEX = /color$/i
  return COLOR_REGEX.test(key)
}

function isImageKey (key: string): boolean {
  const IMAGE_REGEX = /image/i
  return IMAGE_REGEX.test(key)
}

function processConfig (config: Object, id: string, configureCallback: (event: string, callback: () => void) => string): Object {
  const obj = {}
  Object.keys(config).forEach(key => {
    if (key === 'children') return
    if (typeof config[key] === 'function') {
      const id = config['actionID'] || config['testID']
      if (!id) return
      obj[key] = configureCallback(id, config[key])
    } else if (isColorKey(key)) {
      obj[key] = processColor(config[key])
    } else if ((typeof config[key] !== 'string') && isImageKey(key)) {
      obj[key] = Image.resolveAssetSource(config[key])
    } else if (Array.isArray(config[key])) {
      obj[key] = config[key].map(c => {
        return processConfig(c, id, configureCallback)
      })
    } else {
      obj[key] = config[key]
    }
  })
  return obj
}

module.exports = {
  processConfig,
}
