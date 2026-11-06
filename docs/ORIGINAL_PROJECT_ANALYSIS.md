# Análise do arquivo original

Arquivo analisado: `SHINOBI_REBIRTH_SAIMON_ATUALIZADO.rbxl` (1.413.023 bytes).

## Inventário

- 14.449 instâncias distribuídas em 146 classes.
- 139 scripts: 98 `Script`, 23 `LocalScript` e 18 `ModuleScript`.
- 6.841 Parts, 990 MeshParts, 963 UnionOperations e 1.027 Textures.
- 45 scripts guardados em `ServerStorage.LegacySystems`.
- 36 scripts marcados explicitamente como desativados.
- 30 scripts ou módulos ativos dentro de `ServerScriptService`.

## Conteúdo aproveitável

O arquivo comprova a direção do produto e contém protótipos de combate, jutsus, chefes, clãs, missões, gacha, lojas, clima, eventos, recompensas diárias, personalização e persistência. Também contém um mapa grande, arenas e uma interface principal. A ideia central tem material suficiente para orientar a reconstrução.

## Problemas críticos encontrados

1. Há cinco cópias de `Runtime` e cinco de `ScreenBuilder` escondidas em modelos de decoração do Workspace. Elas só tentam funcionar no Studio, montam uma janela de “recuperação”, pedem acesso à Command Bar e carregam instruções ocultas que habilitam HTTP e fazem uma requisição para um domínio externo `rbx-cdn.com`. Esse padrão é incompatível com o jogo e representa risco de código injetado por modelos gratuitos. Nenhuma dessas cópias foi levada para o projeto novo.
2. O `DataService`, responsável por chamar `ProfileManager.Load` e `Unload`, está desativado. O `ProfileManager` não registra os eventos de jogadores sozinho. Como consequência, os perfis podem nunca ser carregados e os outros serviços ficam sem dados.
3. Existem dois módulos chamados `ProfileCodec` no mesmo caminho. Um contém a normalização de missões e o outro retorna apenas uma tabela vazia. A resolução por nome pode escolher o módulo errado e quebrar o salvamento.
4. Os scripts principais `Server` e `Client` contêm apenas `Hello world`; eles não inicializam os sistemas. O projeto depende de dezenas de scripts soltos iniciarem por conta própria.
5. Duas arquiteturas diferentes convivem ao mesmo tempo: `ShinobiSystems` e `ShinobiCore`. Elas possuem configurações, remotes, dados e interfaces diferentes. O legado ainda adiciona outras versões de combate, progressão, loja e DataStore.
6. Foram encontrados 11 nomes distintos de DataStore no arquivo. Mesmo que a maior parte esteja em `ServerStorage`, reativar o legado criaria dados concorrentes e moedas incompatíveis (`Yen/Gems`, `Ryo`, `Cash`).
7. A interface `ShinobiHub` tem mais de 60 mil caracteres em um único LocalScript. Isso dificulta manutenção, testes e sincronização com o Git.
8. Há IDs de gamepass e produto de exemplo nos sistemas legados, além de comentários indicando chefes e NPCs com corpos provisórios.
9. Existem testes para codec e limites do mundo, mas o executor está desativado. A presença dos módulos não prova que os testes passam.

## Decisão adotada

O projeto novo não reaproveita scripts ou modelos suspeitos. Ele preserva a visão do jogo e reconstrói os sistemas em módulos versionáveis pelo Rojo, com um bootstrap único, dados centralizados e validação de ações no servidor. Materiais nativos e modelos procedurais mantêm a primeira build independente de assets externos; texturas e animações próprias serão vinculadas depois da publicação desses assets.
