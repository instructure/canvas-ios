// @flow

export type Group = {
  id: string,
  name: string,
  group_category_id: string,
  members_count: number,
  users?: [UserDisplay],
}
