
// @flow

export default function resetStoreKeys (object: Object): Object {
  let newObj = Object.keys(object).reduce((current, key) => {
    if (object[key] && typeof object[key] === 'object' && !Array.isArray(object[key])) {
      current[key] = resetStoreKeys(object[key])
    } else if (key === 'pending') {
      current.pending = 0
    } else {
      current[key] = object[key]
    }
    return current
  }, {})
  return newObj
}
