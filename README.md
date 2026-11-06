# Shinobi Rebirth

Projeto Roblox estruturado para desenvolvimento com Rojo. A versão nova preserva o arquivo `.rbxl` original apenas como referência e substitui os sistemas conflitantes por uma arquitetura controlada pelo servidor.

## Ciclo de jogo

1. Complete missões e derrote inimigos para ganhar XP, Ryo e materiais.
2. Enfrente chefes rotativos com fases, padrões e mutações diferentes.
3. Fabrique e equipe técnicas, armas, títulos e skins cosméticas.
4. Suba de rank para liberar regiões e dificuldades.
5. Faça Rebirth para ganhar Essência permanente e elevar o nível do mundo.
6. Continue em ciclos mais difíceis, com novas combinações de mutadores e recompensas.

## Mapa

A Vila Shinobi funciona como hub e reúne residência central, academia, clínica, mercado, dojo, salão de clã e treino. Quatro regiões exploráveis saem dela: Fronteira das Cinzas com vulcão, Planalto da Tempestade com torre elétrica, Bosque Ancestral com santuário e Pântano do Vazio com ruínas. Cada região possui rota, inimigos, portal e arena de chefe.

## Estrutura

- `src/ReplicatedStorage/ShinobiShared`: configurações e módulos compartilhados.
- `src/ServerScriptService/ShinobiServer`: dados, combate, progressão, chefes, recompensas e mundo.
- `src/StarterPlayer/StarterPlayerScripts/ShinobiClient`: entrada, HUD e efeitos visuais.

O servidor é a autoridade sobre dano, moedas, drops, progressão e compras. O cliente envia apenas intenções de ação.

## Desenvolvimento

Instale o Rojo 7 e execute `rojo serve` na raiz. No Roblox Studio, conecte o plugin Rojo ao endereço exibido. Para gerar um place local, use `rojo build -o ShinobiRebirth.rbxl`.

O jogo usa materiais nativos e modelos procedurais para funcionar sem IDs externos. Texturas, sons, animações e thumbnails próprios podem ser adicionados em `AssetConfig.lua` após serem publicados na conta ou no grupo do jogo.
