# Economia e loja justa

## Princípios

- Todo item de coleção vendido por Robux também possui preço em Ryo ou Gemas obtidas jogando.
- Baús aleatórios só aceitam Ryo, Gemas ou Tickets de Evento conquistáveis. `StyleTokens`, compráveis com Robux, não abrem baús.
- Robux compra um item específico ou `StyleTokens` usados em compras diretas; nunca compra uma chance aleatória.
- As chances por raridade, o contador de pity e a compensação por duplicata são enviados ao cliente antes da abertura.
- O servidor valida saldo, catálogo, item e frequência de requisições.

## Moedas

- **Ryo:** atividades normais, inimigos, chefes e missões.
- **Gemas:** missões mais difíceis, eventos, conquistas e temporada gratuita.
- **Tickets de Evento:** participação nos eventos rotativos.
- **StyleTokens:** alternativa de compra direta para cosméticos. Não afeta caixas nem poder.
- **Essência:** progressão de Rebirth; não é vendida.

## Baús

| Baú | Moeda | Preço | Pity lendário | Pity mítico |
| --- | --- | ---: | ---: | ---: |
| Vila | Ryo | 3.500 | 35 | 100 |
| Shinobi | Gemas | 80 | 25 | 75 |
| Evento | Tickets | 25 | 15 | 50 |

Uma duplicata vira Ryo de acordo com a raridade. O pity lendário reinicia ao receber Lendário ou Mítico; o pity mítico só reinicia com Mítico.

## Robux e recibos

Todos os `ProductId` começam em `0`, portanto compras Robux ficam desativadas até o proprietário criar os produtos na experiência e preencher `StoreConfig.lua`. IDs de terceiros não devem ser usados.

`EconomyService` registra o recibo como pendente em DataStore, entrega no perfil, persiste o perfil e só então marca o recibo como entregue. O ID do recibo também fica no perfil para tornar a repetição idempotente. `PolicyService:GetPolicyInfoForPlayerAsync` é consultado e falhas assumem a política mais restritiva.

Mesmo quando `ArePaidRandomItemsRestricted` for falso, o jogo não oferece baús por Robux nem por moeda comprada com Robux.
