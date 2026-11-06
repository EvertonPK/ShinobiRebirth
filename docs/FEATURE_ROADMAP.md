# Roadmap competitivo de produto

Este documento transforma “ter tudo que jogos atuais têm” em um escopo verificável. A referência é a fonte existente em novembro de 2026; uma funcionalidade só deve ser marcada como concluída depois de passar por teste no Roblox Studio, teste multiplayer e teste em dispositivo móvel.

## Legenda

- ✅ Implementado na fonte atual.
- 🟡 Existe uma base funcional, mas ainda precisa de conteúdo, integração ou validação no Studio.
- ⬜ Ainda precisa ser desenvolvido.
- 🔒 Obrigatório antes de abrir o jogo ao público.

## Princípios do produto

1. Todo poder relevante pode ser conquistado jogando. Robux oferece compra direta de cosméticos, conveniência limitada e economia de tempo; não vende vitória exclusiva.
2. Caixas mostram todas as probabilidades, pity atual e regra de duplicatas antes da compra. Itens aleatórios pagos respeitam as políticas retornadas por `PolicyService` e podem ser desativados por jogador ou região.
3. Jogadores gratuitos recebem moeda premium por atividade, eventos, conquistas e temporada gratuita em ritmo previsível.
4. O jogo usa objetivos renováveis e variedade de conteúdo. Evita perda artificial de progresso, pop-ups insistentes, cronômetros enganosos e punição por não comprar.
5. Conteúdo, economia e dificuldade são ajustados por dados agregados. Nenhum lançamento depende apenas de “parecer bom” em um teste individual.

## Estado atual resumido

| Área | Estado | Evidência atual | Trabalho necessário |
| --- | --- | --- | --- |
| Ciclo principal | 🟡 | Missões, treino, inimigos, chefes, loot, rank e Rebirth | Balancear duração, recompensas e dificuldade com sessões reais |
| Combate | 🟡 | Ataques leve/pesado, dash e três técnicas validadas pelo servidor | Animações, estados, hitboxes, cancelamentos, bloqueio, parry e acessibilidade |
| Mundo | 🟡 | Vila, treino, arenas e inimigos gerados por código | Regiões autorais, navegação, NPCs, dungeons, segredos e arte final |
| Chefes | 🟡 | Quatro chefes, três fases e cinco mutadores | Padrões realmente distintos, animações, áudio, câmera e testes multiplayer |
| Progressão | 🟡 | 100 níveis, ranks, stats, cinco tiers e Rebirth | Curvas de tempo, caps, catch-up e migração de dados |
| Clãs | 🟡 | Quatro clãs, contribuição e placar semanal | Guerra jogável, grupos/party, recompensas e placar cross-server confiável |
| Cosméticos | 🟡 | Inventário, equip e visuais procedurais | Catálogo maior, preview 3D, texturas e assets próprios publicados |
| Dados | 🟡 | Perfil central, reconciliação e autosave | Session lock, retries, versionamento, migração, rollback e testes de falha |
| Interface | 🟡 | HUD, clãs, progressão, inventário e controles multiplataforma | Fluxo de loja/eventos, tutorial, configurações e UX em telas pequenas |
| Loja/Robux | ⬜ | Não havia MarketplaceService na base revisada | Catálogo, receipts idempotentes, preços, políticas e testes de compra |
| Live ops | ⬜ | Rotação local simples | Calendário remoto, feature flags, eventos, kill switches e rollback |
| Analytics | ⬜ | Sem instrumentação encontrada | Funil, economia, retenção, performance e alertas |

## P0 — bloqueadores para uma versão pública

### Dados e segurança

- 🔒 ⬜ Adicionar session lock de perfil com expiração, proteção contra dois servidores e liberação em `BindToClose`.
- 🔒 ⬜ Criar migrações versionadas e backups antes de alterar o schema de perfil.
- 🔒 ⬜ Implementar retries com backoff, orçamento de DataStore e fila de salvamento; não expulsar jogador por uma falha transitória única.
- 🔒 ⬜ Definir schemas de payload para todos os RemoteEvents e limitar tamanho, frequência, tipos, distância e estado permitido.
- 🔒 ⬜ Adicionar rate limit por ação e jogador, com métricas de rejeição. O cooldown atual cobre parte do combate, não todos os remotes.
- 🔒 ⬜ Validar no servidor movimento anormal, teleporte, velocidade de ataque, dano, moedas, abertura de caixas e claims repetidos.
- 🔒 ⬜ Criar ledger idempotente de `PurchaseId` para `ProcessReceipt`, com retry seguro e testes de servidor desligando no meio da compra.
- 🔒 ⬜ Garantir que exista apenas um responsável por `MarketplaceService.ProcessReceipt`.
- 🔒 ⬜ Filtrar todo texto criado pelo jogador com `TextService` antes de exibir nomes, mensagens ou descrições de clãs.
- 🔒 ⬜ Remover ou bloquear qualquer asset/script externo não auditado. A reconstrução atual já exclui os overlays perigosos do arquivo original.

### Qualidade e compatibilidade

- 🔒 ⬜ Fazer teste Play Solo, Start Server com 2–8 clientes e teste publicado privado.
- 🔒 ⬜ Testar teclado/mouse, toque, gamepad, telas pequenas, safe areas e baixa qualidade gráfica.
- 🔒 ⬜ Medir servidor com 20–30 jogadores simulados: uso de CPU, memória, rede, instâncias e tempo de frame.
- 🔒 ⬜ Validar DataStore, OrderedDataStore, receipts, reconnect e shutdown em ambiente publicado.
- 🔒 ⬜ Criar smoke test automatizado para boot de todos os serviços e contratos de remotes.
- 🔒 ⬜ Criar painel de erro/alerta para falha de serviço, save, receipt e evento global.
- 🔒 ⬜ Configurar classificação de conteúdo, política de privacidade, ícone, thumbnails, descrição, localização e servidores privados.

### Primeira experiência

- 🔒 ⬜ Tutorial de 5–8 minutos: movimento, ataque, técnica, treino, primeira missão, primeiro baú e escolha de clã.
- 🔒 ⬜ Tutorial pode ser pulado e repetido; as recompensas não exigem compra.
- 🔒 ⬜ Primeiro chefe acessível cedo, com dificuldade adaptada e recompensa garantida útil.
- 🔒 ⬜ Objetivo atual sempre visível, com marcador de mundo opcional e indicação clara de recompensa.
- 🔒 ⬜ Proteção de spawn, recuperação quando preso, botão de voltar à vila e tratamento de desconexão.

## P1 — conteúdo necessário para competir

### Combate e builds

- ✅ Ataques leve, pesado, dash e três técnicas iniciais.
- ⬜ Combo básico com janela de encadeamento, stamina e feedback visual/sonoro.
- ⬜ Bloqueio, parry, esquiva com invulnerabilidade curta e quebra de postura.
- ⬜ Hitboxes por servidor com compensação limitada de latência e visualização em modo de desenvolvimento.
- ⬜ Quatro arquétipos de build: taijutsu, lâmina, ninjutsu e suporte.
- ⬜ Árvore de técnicas com escolhas, presets de loadout e reset obtível gratuitamente.
- ⬜ Maestria por arma/técnica com recompensas cosméticas, sem multiplicação infinita de poder.
- ⬜ Efeitos de status legíveis: queimadura, choque, raiz, fraqueza, escudo e cura.
- ⬜ Dummies com medidor de DPS, histórico e comparação de builds.

### Mundo e PvE

- 🟡 Mundo procedural inicial com vila, treino, 12 inimigos e quatro arenas.
- ⬜ Quatro regiões autorais completas, cada uma com identidade, NPCs, recursos, segredos e boss local.
- ⬜ História principal curta por região e missões secundárias com diálogos puláveis.
- ⬜ Inimigos com famílias, elites, resistências e padrões próprios; não apenas variação de vida/dano.
- ⬜ Dungeons de 1–4 jogadores com salas aleatórias, mutadores e checkpoint.
- ⬜ Raid de 6–12 jogadores com matchmaking, reentrada e recompensa por contribuição.
- ⬜ Eventos de mundo: invasão, caravana, tempestade, eclipse, caça a elite e defesa da vila.
- ⬜ Baús de exploração com respawn individual, tabelas por região e proteção contra servidor hopping abusivo.
- ⬜ Crafting de itens e cosméticos com materiais de boss e inimigos.
- ⬜ Coleção/códice que mostra fontes, chances, lore e progresso sem revelar segredos narrativos.

### Chefes

- ✅ Quatro identidades, três fases, telegraphs e mutadores.
- ⬜ Cada habilidade deve ter geometria e resposta diferentes; a base atual usa uma resolução de área genérica para vários nomes.
- ⬜ Animação de entrada, transições de fase, stagger, janela de punição e execução final.
- ⬜ Escala por grupo baseada em participantes válidos, sem permitir que jogador ausente aumente a vida.
- ⬜ Recompensa por contribuição com suporte/cura contabilizados e proteção contra último golpe.
- ⬜ Versões normal, difícil e pesadelo, com mecânicas adicionais em vez de apenas números maiores.
- ⬜ Boss semanal e boss secreto com caminho de descoberta e pity separado.

### Progressão contínua

- ✅ Níveis, ranks, stats, Rebirth, Essência e cinco tiers de mundo.
- ⬜ Curvas alvo documentadas: primeiro boss ≤ 15 min, primeiro rank ≤ 45 min, primeiro Rebirth em 6–10 h de jogo ativo.
- ⬜ Limites de multiplicadores e diminishing returns para impedir números quebrados.
- ⬜ Catch-up para novos jogadores entrarem em conteúdo social sem trivializar conquistas antigas.
- ⬜ Rebirth preserva coleção, opções e marcos; tela deve mostrar exatamente o que reinicia.
- ⬜ Conquistas permanentes, títulos, badges Roblox e marcos de coleção.
- ⬜ Leaderboards sazonais separados por poder, velocidade de raid e contribuição de clã, com anti-cheat.

## Economia F2P e monetização justa

### Moedas e fontes

- ⬜ Ryo: moeda comum de missões, inimigos, chefes e venda de duplicatas.
- ⬜ Gemas: moeda rara obtida por eventos, conquistas, temporada gratuita e pequenas quantidades semanais.
- ⬜ Tickets de evento: expiram ou convertem de forma explícita ao final da temporada.
- ✅ Essência: progressão permanente de Rebirth.
- ⬜ Materiais: fontes e sinks claros por região/boss, com inventário e limites documentados.
- ⬜ Painel “Como obter” para cada moeda e item.

### Loja

- ⬜ Loja geral com abas: destaques, skins, auras, armas visuais, emotes, títulos, bundles e utilidades.
- ⬜ Todo item de coleção possui preço direto em Robux e uma rota de conquista por Ryo, Gemas, evento, crafting ou pity.
- ⬜ Rotação nunca torna a oferta permanentemente exclusiva; itens retornam ou entram em crafting após período anunciado.
- ⬜ Preview 3D, confirmação de compra, item já possuído, saldo após compra e política de duplicata.
- ⬜ Lista de desejos e indicação de fonte sem notificações agressivas.
- ⬜ Gamepasses aceitáveis: slots de loadout, slots cosméticos, servidor privado com controles, emotes e conveniências moderadas.
- ⬜ Evitar venda de dano exclusivo, imunidade, rank, vitória de clã ou vantagem PvP incontornável.

### Baús e caixas

- ⬜ Baús de mundo gratuitos e caixas compradas com Ryo/Gemas ganhas jogando.
- ⬜ Odds completas por item e raridade, pity visível, contador persistente e histórico recente.
- ⬜ Pity não reinicia ao sair, trocar de servidor ou atualizar o catálogo.
- ⬜ Duplicatas viram fragmentos; fragmentos permitem fabricar o item desejado após quantidade previsível.
- ⬜ Recompensa garantida após marcos de aberturas e escolha entre opções no pity máximo.
- ⬜ Caixas ligadas a Robux exigem revisão jurídica/política, `PolicyService`, disclosure e alternativa direta. Preferência: Robux compra o cosmético diretamente.

### Operação de compras

- ⬜ IDs reais ficam em configuração e ofertas sem ID válido permanecem indisponíveis.
- ⬜ `ProcessReceipt` concede apenas uma vez, registra antes/depois de forma recuperável e retorna `NotProcessedYet` em falha.
- ⬜ Gamepasses são verificados no servidor; prompts nunca significam compra concluída.
- ⬜ Produtos, preços e texto são obtidos do Marketplace quando possível para não ficarem desatualizados.
- ⬜ Métricas de impressão → prompt → compra → concessão → uso, sem registrar dados pessoais.

## Eventos, temporada e retenção saudável

- ⬜ Calendário diário determinístico por servidor/UTC e estado sincronizado cross-server.
- ⬜ Login diário com ciclo curto, recuperação limitada e recompensa máxima alcançável sem Robux.
- ⬜ Três missões diárias e três semanais com reroll gratuito limitado.
- ⬜ Evento diário rotativo: boss rush, invasão, treino, coleta, dungeon mutada, caça ao tesouro e guerra de clãs.
- ⬜ Temporada gratuita com trilha curta; trilha premium apenas cosmética/conveniência e recompensa retroativa ao comprar.
- ⬜ Catch-up de temporada para quem entra tarde, sem exigir sessões excessivas.
- ⬜ Bônus por jogar com amigos é pequeno, limitado e também disponível por matchmaking.
- ⬜ Recompensa de retorno após ausência, sem apagar streak ou humilhar o jogador.
- ⬜ Códigos promocionais versionados, com expiração e claim idempotente.
- ⬜ Inbox de compensação para incidentes e manutenção.
- ⬜ Limites saudáveis: objetivos podem ser concluídos em sessões curtas e não exigem ficar AFK.

## Social e Guerra dos Clãs

- ✅ Quatro clãs, contribuição e placar semanal inicial.
- ⬜ Party de até quatro jogadores, convite, líder, ready check e reentrada.
- ⬜ Matchmaking por região/tier para dungeons, raids e bosses.
- ⬜ Guerra dos Clãs jogável em janelas repetidas para vários fusos; contribuição PvE e PvP em playlists separadas.
- ⬜ Objetivos de guerra incluem captura, defesa, boss e entrega; vitória não depende apenas de número bruto de membros.
- ⬜ Normalizar poder em PvP competitivo e separar filas casual/rankeada.
- ⬜ Recompensas sazonais por participação mínima e colocação; cosméticos, títulos e decoração de vila.
- ⬜ Ranking cross-server com cache/MemoryStore, fallback e proteção contra spam de OrderedDataStore.
- ⬜ Chat e nomes filtrados, mute/block, denúncias e ferramentas de moderação.
- ⬜ Trading somente depois de economia estabilizada: escrow, confirmação dupla, limites, logs, bloqueio de item equipado e recuperação de fraude.
- ⬜ Servidores privados com controles que não geram recompensa competitiva indevida.

## Interface, onboarding e acessibilidade

- 🟡 HUD e painéis básicos para PC, toque e gamepad.
- ⬜ Sistema consistente de navegação por foco, botão voltar e atalhos remapeáveis.
- ⬜ Escala de UI, safe areas, orientação mobile, modo canhoto e botões ajustáveis.
- ⬜ Opções de reduzir flashes, screen shake, partículas, bloom e motion blur.
- ⬜ Modo daltônico com formas/ícones além de cor; contraste e tamanho de texto.
- ⬜ Legendas para falas/sons importantes e indicadores direcionais de ataques fora da tela.
- ⬜ Português e inglês no lançamento; strings fora do código e fallback definido.
- ⬜ Inventário com busca, filtro, ordenação, favoritos, comparação e preview.
- ⬜ Loja mostra chance, pity, preço, fonte, posse e alternativa F2P na mesma tela.
- ⬜ Feedback claro para cooldown, chakra, hit, recompensa, falha de compra e save.

## Arte, áudio e identidade

- 🟡 Silhuetas e materiais procedurais próprios para chefes e cosméticos.
- ⬜ Guia visual: paleta, formas, VFX por elemento, materiais, iluminação e densidade por dispositivo.
- ⬜ Modelos finais otimizados com LOD, colisão simples e budgets de triângulos/texturas.
- ⬜ Texturas autorais e ownership verificado na conta/grupo do jogo.
- ⬜ Animações próprias para jogador, inimigos, chefes, emotes e cinematics curtas.
- ⬜ Biblioteca de áudio própria/licenciada: impacto, técnicas, ambiente, UI e música adaptativa.
- ⬜ Identidade original sem nomes, personagens, logos, sons ou designs copiados de franquias de anime.
- ⬜ Thumbnails e ícone representam a jogabilidade real e recebem testes A/B controlados.

## Performance e engenharia

- ✅ Projeto Rojo, módulos separados, bootstrap único e compilação Luau automatizada.
- ⬜ Service lifecycle determinístico; o bootstrap atual inicia `Start` em tarefas paralelas e precisa declarar dependências/readiness.
- ⬜ Maid/Janitor para conexões e instâncias temporárias; auditoria de memory leaks ao respawn/rejoin.
- ⬜ Object pooling para VFX, projéteis, damage numbers e mobs.
- ⬜ StreamingEnabled com regiões, persistent models essenciais e teleporte seguro.
- ⬜ Interest management: não replicar efeitos/dados privados para todos os jogadores.
- ⬜ Budgets alvo por plataforma para draw calls, partículas, física, memória e tráfego remoto.
- ⬜ Fallback de qualidade automático e configurações manuais.
- ⬜ CI: JSON válido, compile Luau, Rojo build, lint, testes puros, diff check e auditoria de IDs externos.
- ⬜ Ambientes separados de desenvolvimento, staging e produção, com DataStores distintos.

## Analytics, balanceamento e experimentos

- ⬜ Eventos de funil: join, carregamento, tutorial, primeira missão, primeiro boss, escolha de clã, primeira caixa, primeiro Rebirth e retorno.
- ⬜ Métricas de retenção D1/D7/D30, sessão, tempo até diversão, falhas e abandono por etapa.
- ⬜ Economia: fontes/sinks por moeda, saldo por faixa, inflação, pity, duplicatas e taxa de crafting.
- ⬜ Combate: dano recebido/causado, mortes, duração, abandono e sucesso por boss/tier/grupo.
- ⬜ Loja: impressão, preview, prompt, compra, concessão e uso; nunca registrar dados de pagamento.
- ⬜ Performance: FPS, memória, ping, tempo de load e erros por dispositivo.
- ⬜ Experimentos com hipótese, métrica primária, guardrails e amostra; não testar mecânicas enganosas.
- ⬜ Dashboard e alertas para save, receipt, crashes, inflação e queda de conclusão.

## Live ops e manutenção

- ⬜ Configuração remota assinada/versionada para calendário, multiplicadores, drops e catálogo.
- ⬜ Feature flags e kill switches por sistema, sem precisar republicar o place em emergência.
- ⬜ Calendário de quatro semanas preparado antes do lançamento: eventos, bosses, cosméticos e patches.
- ⬜ Conteúdo novo em pacotes versionados com migração e rollback.
- ⬜ Mensagens cross-server para início/fim de eventos e compensações.
- ⬜ Servidor informa versão; jogadores migram de versão de forma segura após janela definida.
- ⬜ Processo de incidente: detectar, desativar, comunicar, corrigir, compensar e publicar post-mortem.
- ⬜ Patch notes dentro do jogo, status de manutenção e histórico de mudanças de chance/preço.

## Ordem recomendada de entrega

### Marco 1 — Alpha privado

Concluir P0 de dados/segurança, tutorial, uma região com arte final, combate com animações, uma dungeon, dois chefes completos, loja F2P, caixas com Ryo, UI mobile e testes com 2–8 jogadores.

### Marco 2 — Beta fechado

Quatro regiões, quatro chefes finalizados, raid, party/matchmaking, guerra de clãs, eventos diários, temporada gratuita, catálogo cosmético, receipts testados, analytics e performance para 20 jogadores.

### Marco 3 — Lançamento público

Resolver todos os bloqueadores P0, validar economia por telemetria do beta, preencher assets próprios, localização, acessibilidade, moderação, políticas, staging/produção e plano de quatro semanas de live ops.

### Marco 4 — Crescimento

Adicionar conteúdo em cadência previsível, medir retenção e ajustar pontos de abandono. Trading, ranked PvP e sistemas econômicos complexos só entram depois de dados, anti-exploit e suporte operacional estarem maduros.

## Critério de “completo” para o lançamento

O jogo está pronto para competir quando um jogador gratuito consegue concluir o tutorial, formar uma build, obter skins lendárias via pity/crafting, participar de party e clã, enfrentar conteúdo variado por várias semanas e preservar dados com segurança; quando compras são concedidas exatamente uma vez; quando a experiência mantém FPS e UI utilizável nos dispositivos alvo; e quando a equipe consegue iniciar, ajustar ou desligar eventos sem arriscar a economia ou o save.
