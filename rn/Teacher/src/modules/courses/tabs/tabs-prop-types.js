// @flow

export type TabsDataProps = AsyncState & {
  +tabs: Array<Tab>,
}

export type TabsActionProps = {
  +refreshTabs: () => Promise<Tab[]>,
}

export type TabsProps = TabsDataProps & TabsActionProps
