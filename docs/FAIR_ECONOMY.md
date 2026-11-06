# Economia e monetização justa

## Regras

1. Nenhuma técnica, atributo de combate ou região é exclusiva de Robux.
2. Todo cosmético vendido por Robux possui uma rota de obtenção jogando, ainda que longa.
3. Compras de Robux são determinísticas: o jogador sabe exatamente o que receberá.
4. Caixas aleatórias usam apenas moedas conquistáveis no jogo. As chances aparecem antes da abertura.
5. O pity é permanente por categoria de caixa e nunca diminui sem entregar o prêmio anunciado.
6. Duplicatas viram Fragmentos, que permitem fabricar diretamente o item desejado.
7. Eventos não exigem pagamento; o passe gratuito contém recompensas úteis e cosméticos.
8. Nenhum bônus comprado aumenta dano em PvP ou pontuação de guerra dos clãs.

## Moedas

| Moeda | Fonte principal | Uso |
| --- | --- | --- |
| Ryo | inimigos, chefes e missões | caixas comuns, consumíveis e fabricação |
| Gems | conquistas, eventos, temporada e opção de compra | cosméticos específicos e conveniência |
| Tickets | login, missões semanais e códigos | caixas especiais |
| Fragmentos | duplicatas | fabricação direta de skins |
| Essência | Rebirth | progressão permanente jogável |
| Marcas do Clã | participação sazonal | loja do clã |
| Tokens de Evento | evento diário/limitado | loja temática do evento |

## Tipos de loja

- Loja diária: seis cosméticos rotativos, sempre com preço em Gems e opção em Robux.
- Loja permanente: emotes, slots de aparência, títulos, auras e efeitos de finalização.
- Loja de Ryo: caixas, materiais, consumíveis e itens de progressão controlada.
- Loja de clã: itens obtidos com participação, sem Robux.
- Loja de evento: itens temáticos com tokens; depois do evento podem retornar à rotação.
- Fabricação: troca de materiais e Fragmentos por um item específico.

## Caixas conquistáveis

| Caixa | Custo | Conteúdo | Proteção |
| --- | --- | --- | --- |
| Caixa Shinobi | Ryo | materiais, emotes e skins Rare/Epic | Epic garantido em 20 |
| Relíquia de Chefe | Ryo + material de chefe | skins do chefe | Legendary garantido em 40 |
| Cofre do Clã | Marcas do Clã | bandeiras, títulos e auras | sem duplicata até completar o conjunto |
| Cápsula de Evento | Tokens de Evento | coleção do evento | moeda não expira antes do encerramento anunciado |
| Cofre Lendário | Tickets | Legendary/Mythic | Legendary em 25; Mythic em 100 |

As probabilidades exatas ficam na configuração do servidor e são enviadas à interface. Uma alteração de chance exige atualizar a versão da tabela e preservar o pity existente.

## Produtos Robux permitidos

- Pacotes determinísticos de Gems.
- Cosmético específico mostrado na compra.
- Passe de temporada com trilha premium cosmética.
- Slots extras de aparência e presets.
- Servidor privado e recursos sociais sem vantagem de combate.
- VIP cosmético: tag, cor do nome, emote, aura e recompensa diária visual.

IDs de Developer Products e Game Passes permanecem desativados até serem criados na experiência oficial. O servidor nunca concede a compra a partir de um botão do cliente; a entrega ocorre somente em `ProcessReceipt` ou após confirmação da API apropriada.
