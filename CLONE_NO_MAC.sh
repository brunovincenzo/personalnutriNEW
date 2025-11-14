#!/bin/bash

# ============================================
# SCRIPT PARA CLONAR O PROJETO NO SEU MAC
# ============================================
# Execute este comando no Terminal do seu Mac:
# bash ~/Downloads/CLONE_NO_MAC.sh

echo "🚀 Clonando PersonalNutri com todos os arquivos IAP..."

# Descer para a pasta Desktop (você pode mudar o destino)
cd ~/Desktop

# Clonar o repositório com submodules
git clone --recurse-submodules https://github.com/brunovincenzo/personalnutriNEW.git

if [ $? -eq 0 ]; then
    echo "✅ Clone concluído com sucesso!"
    echo ""
    echo "📁 Estrutura clonada em: ~/Desktop/personalnutriNEW"
    echo ""
    echo "📂 Conteúdo:"
    echo "   - PersonalNutri/PersonalNutri/IAPManager.swift          ✅ Gerencia StoreKit"
    echo "   - PersonalNutri/PersonalNutri/WebViewController.swift   ✅ Bridge JS ↔ Native"
    echo "   - PersonalNutri/PersonalNutri/PersonalNutriApp.swift    ✅ Inicialização"
    echo "   - PersonalNutri/PersonalNutri/PersonalNutri.storekit    ✅ Config StoreKit"
    echo "   - PersonalNutri/PersonalNutri/Resources/assinatura.html ✅ Teste offline"
    echo "   - PersonalNutri/PersonalNutri.xcodeproj/               ✅ Projeto Xcode"
    echo ""
    echo "🎯 Próximo passo: Abrir no Xcode"
    echo "   open ~/Desktop/personalnutriNEW/PersonalNutri/PersonalNutri.xcodeproj"
    echo ""
    echo "📖 Leia as instruções em:"
    echo "   ~/Desktop/personalnutriNEW/RESUMO_FINAL_TODO_PRONTO.txt"
else
    echo "❌ Erro ao clonar. Verifique sua conexão de internet."
    exit 1
fi
