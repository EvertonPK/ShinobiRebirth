# Eventos e calendário de recompensas

O calendário usa tempo UTC do servidor. A escolha do evento é determinística, então todos os servidores exibem o mesmo evento sem depender de um serviço externo.

## Eventos diários

- Treino Intensivo: bônus de XP e Ryo.
- Investida dos Chefes: recompensa maior em chefes.
- Caçada aos Renegados: bônus em inimigos de campo.
- Chuva de Tesouros: sorte global de drops.
- Chamado dos Clãs: contribuição dobrada.
- Surto de Maestria: progressão acelerada.
- Caçada Lendária: maior sorte em itens raros sem remover o pity.

Além do evento diário, uma microatividade de duas horas alterna entre Hora do Ryo, Hora Shinobi e Hora da Sorte.

## Retorno diário

O ciclo gratuito possui sete recompensas e continua acumulando streak. Um jogador que perder exatamente um dia pode gastar uma proteção de sequência. A proteção é recuperada periodicamente e não é vendida por Robux.

## Objetivos semanais

O progresso considera dano, inimigos, chefes, missões diárias e treino. Cada objetivo concluído fornece moeda, XP ou Essência e pontos para a temporada.

## Temporada gratuita

A temporada dura 28 dias e possui 30 níveis. Todos os níveis são gratuitos. Não há trilha premium nem recompensa de poder exclusiva de pagamento. O servidor valida todos os resgates e guarda cada nível já coletado.

## Remotes

- `LiveOpsRequest`: `Get`, `ClaimLogin`, `ClaimWeekly(index)` e `ClaimSeason(level)`.
- `LiveOpsState`: snapshot do calendário, streak, objetivos e temporada.

As ações têm limite de frequência por jogador. Recompensas e datas são calculadas no servidor.
