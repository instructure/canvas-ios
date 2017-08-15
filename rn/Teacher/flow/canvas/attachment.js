// @flow

export type Attachment = File & {
  filename?: string,
  uri?: string, // local only
}
