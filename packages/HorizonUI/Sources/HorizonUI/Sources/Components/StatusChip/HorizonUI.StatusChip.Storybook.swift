//
//  SwiftUIView.swift
//  HorizonUI
//
//  Created by Mac on 14/09/2025.
//

import SwiftUI

public extension HorizonUI.StatusChip {
    struct Storybook: View {
        public var body: some View {
            VStack {
                HorizonUI.StatusChip(
                    title: "Title",
                    style: .gray,
                    icon: Image.huiIcons.accountCircleFilled,
                    label: nil,
                    isFilled: true,
                    hasBorder: true
                )

                HorizonUI.StatusChip(
                    title: "Title",
                    style: .white,
                    icon: Image.huiIcons.accountCircleFilled,
                    label: nil,
                    isFilled: true,
                    hasBorder: false
                )

                HorizonUI.StatusChip(
                    title: "Title",
                    style: .red,
                    icon: Image.huiIcons.accountCircleFilled,
                    label: nil,
                    isFilled: true,
                    hasBorder: false
                )

                HorizonUI.StatusChip(
                    title: "Title",
                    style: .orange,
                    icon: nil,
                    label: nil,
                    isFilled: true,
                    hasBorder: false
                )

                HorizonUI.StatusChip(
                    title: "Title",
                    style: .hone,
                    icon: nil,
                    label: nil,
                    isFilled: true,
                    hasBorder: false
                )
                HorizonUI.StatusChip(
                    title: "Title",
                    style: .plum,
                    icon: nil,
                    label: nil,
                    isFilled: false,
                    hasBorder: false
                )
            }
        }
    }
}

#Preview {
    HorizonUI.StatusChip.Storybook()
}
