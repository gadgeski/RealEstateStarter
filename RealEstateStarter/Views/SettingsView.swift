//
//  SettingsView.swift
//  RealEstateStarter
//
//  Created by Dev Tech on 2025/09/09.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            Section("表示") {
                Toggle("ダークモードに追従", isOn: .constant(true))
                Toggle("地図にピン名を表示", isOn: .constant(true))
            }
            Section("アプリ情報") {
                LabeledContent("バージョン", value: "0.1.0")
                LabeledContent("ビルド", value: "1")
            }
        }
        .navigationTitle("設定")
    }
}

#Preview {
    SettingsView()
}
