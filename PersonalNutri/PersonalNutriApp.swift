//
//  PersonalNutriApp.swift
//  PersonalNutri
//
//  Created by Julio Cesar Vieira on 13/11/25.
//

import SwiftUI

@main
struct PersonalNutriApp: App {
    init() {
        print("🎯 PersonalNutriApp.init() - Iniciando IAPManager...")
        // Inicia o observer de IAP o quanto antes para receber transações do StoreKit
        IAPManager.shared.start()
    }
    var body: some Scene {
        WindowGroup {
            WebViewContainer()
        }
    }
}
