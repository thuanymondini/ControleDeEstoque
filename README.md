# Controle de Estoque (Flutter)

App de controle de estoque com cadastro, consulta, edição e exclusão de produtos,
pesquisa por nome, filtro por categoria, entrada/saída de estoque e identificação
automática de estoque baixo.

O visual segue o protótipo do Figma Make
([Controle de Estoque App](https://www.figma.com/make/z9wR3s0MBQ4z4WgsVWO6i2/Controle-de-Estoque-App)):
paleta baseline do Material 3 (`#6750A4` primário, `#B3261E` de alerta), fundo
`#F7F2FA`, cards brancos de raio 16, selos de categoria coloridos e cabeçalhos
coloridos por tela.

Validado com Flutter 3.47.4 (Dart 3.13.3) em emulador Android API 36.

## Como rodar

```bash
flutter pub get
```

```bash
flutter run
```

Testes das regras de negócio:

```bash
flutter test
```

As pastas de plataforma já estão geradas para Android. Para adicionar iOS/web:

```bash
flutter create . --platforms ios,web
```

## Navegação

Barra inferior com três destinos, conforme o protótipo:

| Aba | Tela | O que faz |
| --- | --- | --- |
| Início | `lib/screens/home_screen.dart` | Cabeçalho roxo com a data, cards de resumo (produtos cadastrados / estoque baixo) e os produtos em alerta |
| Produtos | `lib/screens/products_screen.dart` | Pesquisa por nome, filtro por categoria em chips e lista com selo de categoria e quantidade; FAB para cadastrar |
| Est. Baixo | `lib/screens/low_stock_screen.dart` | Cabeçalho vermelho de alerta, quanto falta para o mínimo e barra de progresso, do mais crítico para o menos |

Telas secundárias:

- `product_detail_screen.dart` — quantidades, informações, ações (entrada, saída, editar, excluir) e últimas movimentações
- `stock_movement_screen.dart` — entrada/saída com tipo, quantidade, data e observação
- `product_form_screen.dart` — cadastro e edição
- `movement_history_screen.dart` — histórico de movimentações

## Regras de negócio

Concentradas em `lib/state/inventory_controller.dart` e `lib/models/product.dart`:

- **Estoque baixo**: `quantidade atual <= estoque mínimo` (`Product.isLowStock`).
  O selo vermelho, o badge da barra de navegação, o status na tela de detalhes e a
  aba "Est. Baixo" derivam todos desse mesmo cálculo.
- **Entrada**: soma a quantidade informada ao estoque.
- **Saída**: subtrai a quantidade informada.
- **Saída maior que o disponível é bloqueada** — validada no formulário (mensagem no
  campo) e novamente no controller, que lança `StockException`. Saída igual ao
  disponível é permitida (zera o estoque).
- Quantidade de movimentação precisa ser maior que zero.
- Excluir um produto também remove o histórico de movimentações dele.

Categorias são fixas (`kCategories` em `lib/theme/app_colors.dart`): Papelaria,
Informática, Alimentos, Limpeza e Outros — cada uma com suas cores de selo.

## Estrutura

```
lib/
  main.dart                     # bootstrap + InventoryScope
  models/
    product.dart                # nome, categoria, quantidade, mínimo, isLowStock
    stock_movement.dart         # entrada/saída com data e observação
  data/
    inventory_repository.dart   # persistência local (SharedPreferences + JSON)
  state/
    inventory_controller.dart   # fonte única de verdade + regras de negócio
    inventory_scope.dart        # InheritedNotifier que expõe o controller
  theme/
    app_colors.dart             # tokens extraídos do protótipo + cores de categoria
    app_theme.dart              # ThemeData e estilos de texto
  screens/                      # home_shell, home, products, low_stock,
                                # detail, form, movement, history
  widgets/                      # app_header, app_chips, alert_stripe_card,
                                # bottom_actions, form_field_label
  utils/formatters.dart         # datas em pt-BR sem depender de intl
test/
  inventory_controller_test.dart
```

Estado com `ChangeNotifier` + `InheritedNotifier` (sem pacote de gerenciamento de
estado externo). A única dependência é `shared_preferences`, para os dados
sobreviverem ao fechamento do app. Trocar por API/sqflite exige mudar apenas
`InventoryRepository`.

Na primeira execução o app carrega os 8 produtos de exemplo do protótipo
(`_seedProducts`), sendo 6 já em estoque baixo.
