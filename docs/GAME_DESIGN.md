# Direção do jogo

## Fantasia

O jogador é um shinobi sem clã que escolhe uma das quatro linhagens originais, aprende técnicas, derrota entidades que ameaçam cada região e fortalece seu clã em temporadas semanais.

## Ciclo contínuo

`Missões e treino → combate → chefe rotativo → loot e skin → rank → Rebirth → novo nível de mundo`

O Rebirth reinicia nível e atributos distribuíveis, preservando cosméticos, domínio, coleção e Essência. O nível do mundo aumenta a vida, o dano e as recompensas dos chefes. Mutadores mudam o comportamento e a recompensa de cada rotação. A combinação de quatro chefes, cinco mutadores, cinco níveis de mundo, missões diárias e guerra semanal mantém objetivos renováveis sem apagar conquistas cosméticas.

## Clãs

- Kurogane: poder.
- Arashima: velocidade.
- Midorin: defesa.
- Hoshikai: chakra.

Cada participação em chefe soma pontos pessoais e sazonais. A tabela da temporada usa um OrderedDataStore separado pelo período de sete dias.

## Chefes iniciais

- Ronin das Cinzas: cortes, anel de cinzas e chuva de brasas.
- Oni da Tempestade: investida, pilares elétricos e prisão de tempestade.
- Sábio Primordial: raízes, explosão de flores e guardiões.
- Shogun do Vazio: cortes dimensionais, poço gravitacional e clones.

Todos possuem três fases, silhueta, paleta, material, olhos e acessórios próprios. Os ataques são telegrafados antes do dano.

## Princípios técnicos

- O servidor calcula dano, drops, moedas e progressão.
- O cliente envia intenções de ataque e apresenta interface e efeitos.
- O arquivo original permanece fora da fonte nova.
- Nenhum modelo gratuito executável é incorporado.
- IDs externos ficam centralizados em `AssetConfig.lua`.
