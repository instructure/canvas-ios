// @flow

export type TabVisibility = "public" | "members" | "admins" | "none"

export type Tab = {
  id: string,
  label: string,
  type: string,
  hidden?: boolean, // only included if true
  visibility: TabVisibility,
  position: number,
}
