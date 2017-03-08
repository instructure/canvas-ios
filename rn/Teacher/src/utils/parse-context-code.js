// @flow

type Context = {
  type: string,
  id: string,
}

export default function parseContextCode (contextCode: string): Context {
  let split = contextCode.split('_')
  return {
    type: split[0],
    id: split[1],
  }
}
