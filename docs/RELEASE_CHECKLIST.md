# Checklist de publicação

## Antes de publicar

1. Abra `SHINOBI_REBIRTH_COMPLETO_ALPHA.rbxl` no Roblox Studio e execute **Play** e **Start Server + 2 Players**.
2. Em **Game Settings > Security**, habilite acesso a API Services somente para testar persistência em uma experiência privada.
3. Crie Developer Products na experiência para os itens cosméticos e pacotes de `StyleTokens` que deseja vender. Preencha apenas os IDs criados por sua conta ou grupo em `StoreConfig.lua`; todos começam como `0` e permanecem desativados até isso ocorrer.
4. Publique texturas, sons e animações originais na conta ou grupo do jogo. Insira os IDs publicados em `AssetConfig.lua` antes de substituir os visuais procedurais.
5. Teste compra direta com Ryo, Gemas e Tokens de Estilo, abertura de cada baú, pity e conversão de duplicatas.
6. Teste login diário, objetivos semanais, temporada, códigos, clãs, Rebirth, portais e as quatro arenas de chefe.
7. Verifique o painel **Output** sem erros e só então publique a versão privada para um grupo pequeno de jogadores.

## Garantias da versão

- Baús não aceitam Robux nem moeda comprada com Robux.
- Todo cosmético do catálogo tem preço em moeda obtida jogando.
- Eventos, temporada, códigos e conquistas entregam Gemas, Tickets e Tokens de Estilo gratuitos.
- Dano, moedas, drops, inventário e recibos de compra são validados no servidor.
