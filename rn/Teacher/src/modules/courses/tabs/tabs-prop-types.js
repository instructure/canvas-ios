// @flow

export type TabsActionProps = {
  +refreshTabs: (string) => Promise<Tab[]>,
}
