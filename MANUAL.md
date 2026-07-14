# it-drugs — Manual

Sistema de drogas com plantio persistente (regar, adubar, colher), mesas de processamento, efeitos de consumo, dealer de sementes e venda para NPCs.

---

## Sumário

1. [Dependências](#dependências)
2. [Instalação](#instalação)
3. [Permissões (ACE)](#permissões-ace)
4. [Configuração](#configuração)
5. [Comandos](#comandos)
6. [Plantio](#plantio)
7. [Processamento](#processamento)
8. [Efeitos das drogas](#efeitos-das-drogas)
9. [Dealer de sementes](#dealer-de-sementes)
10. [Venda para NPCs](#venda-para-npcs)
11. [Banco de dados](#banco-de-dados)
12. [Integrações](#integrações)
13. [Entrypoints para outros recursos](#entrypoints-para-outros-recursos)
14. [Localização](#localização)
15. [Estrutura de arquivos](#estrutura-de-arquivos)

---

## Dependências

| Recurso | Obrigatório | Observação |
|---|---|---|
| `ox_lib` | Sim | Declarado em `dependencies`. Callbacks, menus, progress bar, skill check |
| `oxmysql` | Sim | Declarado em `dependencies`. Persistência de plantas e mesas |
| `qb-core` **ou** `es_extended` | Sim | O bridge (`bridge/init.lua`) detecta qual está rodando. Sem um dos dois, o recurso não funciona |
| `ox_inventory` **ou** `qb-inventory` | Sim | Detectado automaticamente pelo bridge |
| `ox_target` ou `qb-target` | Não | Definido em `Config.Target`. Use `false` para desativar o target |
| `ps-dispatch` | Não | Alerta policial na venda de drogas, se o recurso estiver iniciado |

---

## Instalação

1. Copie a pasta `it-drugs` para `resources/`.
2. Adicione ao `server.cfg`:
   ```
   ensure it-drugs
   ```
3. **SQL** — as tabelas são criadas automaticamente na inicialização (`server/database/sv_setupdatabase.lua` roda os arquivos `drug_plants.sql` e `drug_processing.sql`). Não é preciso importar nada à mão.
4. **Itens** — cadastre os itens no seu inventário:
   - `ox_inventory`: copie o conteúdo de `items/ox_items.lua` para o seu `data/items.lua`.
   - `qb-inventory`: use `items/items.lua` (formato QB) ou importe `items/items.sql`.
   - Copie as imagens de `items/img/` para a pasta de imagens do inventário.
5. Ajuste `shared/config.lua`.

Itens que acompanham o recurso: `watering_can`, `fertilizer`, `advanced_fertilizer`, `liquid_fertilizer`, `weed_lemonhaze_seed`, `weed_lemonhaze`, `coca_seed`, `coca`, `paper`, `nitrous`, `cocaine`, `joint`, `weed_processing_table`, `cocaine_processing_table`.

> A receita do joint em `Config.ProcessingTables` usa o item `rolling_paper`, mas o item incluído se chama `paper`. Alinhe os dois antes de subir o recurso.

---

## Permissões (ACE)

Os comandos administrativos exigem a ACE `admin` (`IsPlayerAceAllowed(src, 'admin')`):

```
add_ace group.admin admin allow
```

Jogadores sem permissão recebem uma janela mostrando a própria license e um botão que copia para a área de transferência a linha `add_ace identifier.<license> it-drugs allow`. Essa sugestão **não** bate com o que o código checa — o gate real é a ACE `admin`.

---

## Configuração

Tudo fica em `shared/config.lua`.

### Geral

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `Config.Language` | string | Sim | Idioma. Deve existir `locales/<Language>.lua`. Padrão neste fork: `'pt-br'` |
| `Config.Target` | string \| false | Sim | `'ox_target'`, `'qb-target'` ou `false` para desativar |
| `Config.Webhook.active` | bool | Sim | Liga os logs no Discord |
| `Config.Webhook.url` | — | — | **Não faz nada.** A URL real fica hardcoded em `server/sv_webhooks.lua` |
| `Config.Webhook.name` | string | Sim | Nome exibido no embed |
| `Config.Webhook.avatar` | string | Sim | Avatar do webhook |
| `Config.EnableVersionCheck` | bool | Sim | Checa atualizações no GitHub na inicialização |
| `Config.Branch` | string | Sim | Branch usada na checagem de versão |
| `Config.Debug` | bool | Sim | Logs de diagnóstico |
| `Config.DebugPoly` | bool | Sim | Desenha as PolyZones na tela |

### Plantio

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `Config.rayCastingDistance` | number | Sim | Alcance (m) do raycast que define onde a planta será posta. Padrão `7.0` |
| `Config.FireTime` | number (ms) | Sim | Duração do fogo ao destruir uma planta. Padrão `10000` |
| `Config.ClearOnStartup` | bool | Sim | Remove plantas mortas do banco ao iniciar |
| `Config.PlayerPlantLimit` | number | Sim | Máximo de plantas simultâneas por jogador. Padrão `10` |
| `Config.PlantDistance` | number | Sim | Distância mínima (m) entre duas plantas. Padrão `1.5` |
| `Config.OnlyZones` | bool | Sim | Se `true`, só é possível plantar dentro das `Config.Zones` |
| `Config.GlobalGrowTime` | number (min) | Sim | Tempo padrão de crescimento. Padrão `1` |
| `Config.OnlyAllowedGrounds` | bool | Sim | Restringe o plantio aos hashes de solo permitidos |
| `Config.AllowedGrounds` | lista de hashes | Sim | Hashes de material do solo onde é permitido plantar. Use `/getGroundHash` para descobrir novos |
| `Config.WaterDecay` | number (%) | Sim | Água perdida por minuto. Padrão `1` |
| `Config.FertilizerDecay` | number (%) | Sim | Adubo perdido por minuto. Padrão `0.7` |
| `Config.WaterThreshold` | number (%) | Sim | Abaixo desse valor de água, a planta perde vida. Padrão `10` |
| `Config.FertilizerThreshold` | number (%) | Sim | Abaixo desse valor de adubo, a planta perde vida. Padrão `10` |
| `Config.HealthBaseDecay` | `{min, max}` | Sim | Vida perdida por ciclo quando a planta está abaixo dos thresholds. Padrão `{7, 10}` |
| `Config.Items` | tabela | Sim | Itens de cuidado: quanto cada um dá de `water` e `fertilizer`, e o `itemBack` devolvido |
| `Config.PlantTypes` | tabela | Sim | Props por estágio de crescimento (`plant1`, `plant2`, `small_plant`, `tomate_plant`). Cada estágio é `{modelo, offsetZ}` |
| `Config.Plants` | tabela | Sim | As sementes. Veja [Plantio](#plantio) |
| `Config.Zones` | tabela | Sim | Zonas de cultivo com `points`, `thickness`, `growMultiplier`, `blip` e `exclusive` |

### Processamento, drogas, dealer e venda

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `Config.EnableProcessing` | bool | Sim | Liga as mesas de processamento |
| `Config.ShowIngrediants` | bool | Sim | Mostra os ingredientes no menu da mesa |
| `Config.ProcessingSkillCheck` | bool | Sim | Substitui a progress bar por um skill check |
| `Config.SkillCheck` | tabela | Sim | `difficulty` e `keys` do skill check do `ox_lib` |
| `Config.ProcessingTables` | tabela | Sim | As mesas e suas receitas. Veja [Processamento](#processamento) |
| `Config.EnableDrugs` | bool | Sim | Liga os efeitos de consumo |
| `Config.Drugs` | tabela | Sim | As drogas consumíveis. Veja [Efeitos das drogas](#efeitos-das-drogas) |
| `Config.EnableDealers` | bool | Sim | Liga o dealer de sementes |
| `Config.DrugDealers` | tabela | Sim | Os dealers. Veja [Dealer de sementes](#dealer-de-sementes) |
| `Config.EnableSelling` | bool | Sim | Liga a venda para NPCs. **Desligado neste fork** (o servidor usa `qbx_drugs` para vendas) |
| `Config.MinimumCops` | number | Sim | Policiais online necessários para vender |
| `Config.OnlyCopsOnDuty` | bool | Sim | Conta apenas policiais em serviço (só QBCore) |
| `Config.PoliceJobs` | lista | Sim | Jobs contados como polícia |
| `Config.SellSettings` | tabela | Sim | Chances, quantidades, timeout e bônus por polícia online |
| `Config.SellZones` | tabela | Sim | Zonas de venda com `points`, `thickness` e `drugs` (item + preço) |
| `Config.BlacklistPeds` | lista | Sim | Modelos de ped que não compram drogas |

Duas funções no fim do config podem ser reescritas: `SendPoliceAlert()` (por padrão chama `ps-dispatch`) e `ShowNotification(source, message, type)` (por padrão usa `it.notify`).

---

## Comandos

Os nomes dos comandos vêm dos locales (`COMMAND__ADMINMENU` e `COMMAND__GROUNDHASH`) e mudam junto com o idioma. Nos locales incluídos, os nomes são:

| Comando | Permissão | Descrição |
|---|---|---|
| `/drugadmin plants` | ACE `admin` | Menu admin das plantas: listar, criar blips, teleportar, remover |
| `/drugadmin tables` | ACE `admin` | Menu admin das mesas de processamento |
| `/getGroundHash` | ACE `admin` | Mostra o hash do material do solo sob os pés — use para preencher `Config.AllowedGrounds` |

---

## Plantio

Usar uma semente (`Config.Plants`) inicia o plantio: um raycast até `Config.rayCastingDistance` define o ponto, que é validado contra `Config.AllowedGrounds`, `Config.PlantDistance`, `Config.Zones` (se `OnlyZones`) e `Config.PlayerPlantLimit`.

```lua
['weed_lemonhaze_seed'] = {
    growthTime = false,        -- minutos; false usa Config.GlobalGrowTime
    label = 'Lemon Haze',
    plantType = 'plant1',      -- chave de Config.PlantTypes
    products = {               -- itens produzidos na colheita
        ['weed_lemonhaze'] = { min = 1, max = 4 },
    },
    seed = {                   -- chance de recuperar sementes
        chance = 50,
        min = 1,
        max = 2
    },
    time = 3000                -- duração da ação de plantar/colher, em ms
},
```

A planta guarda `health`, `water`, `fertilizer` e `growtime` no banco. Água e adubo caem a cada minuto (`WaterDecay` e `FertilizerDecay`); abaixo dos thresholds, a planta perde vida entre `HealthBaseDecay[1]` e `[2]`. Vida zero mata a planta.

Os itens de cuidado ficam em `Config.Items`:

| Item | Água | Adubo |
|---|---|---|
| `watering_can` | +25 | 0 |
| `liquid_fertilizer` | +15 | +15 |
| `fertilizer` | 0 | +25 |
| `advanced_fertilizer` | 0 | +40 |

Definir `itemBack` faz o item ser devolvido depois do uso.

O prop da planta muda conforme o crescimento: 0-30% usa o estágio 1, 30-80% o estágio 2 e 80-100% o estágio 3.

### Zonas

Uma zona (`Config.Zones`) é um polígono (`points` + `thickness`) que multiplica a velocidade de crescimento: o tempo vira `GlobalGrowTime / growMultiplier`. O campo `exclusive` limita quais sementes se beneficiam. Com `Config.OnlyZones = true`, plantar fora de qualquer zona é bloqueado.

---

## Processamento

As mesas são **itens colocáveis**: usar `weed_processing_table` ou `cocaine_processing_table` cria a prop no mundo e a persiste na tabela `drug_processing`.

```lua
['weed_processing_table'] = {
    type = 'weed',
    model = 'bkr_prop_weed_table_01a',
    recipes = {
        ['joint'] = {
            label = 'Joint',
            ingrediants = { ['weed_lemonhaze'] = 3, ['rolling_paper'] = 1 },
            outputs = { ['joint'] = 2 },
            processTime = 5,      -- segundos
            failChance = 15,      -- % de falha (perde os ingredientes)
            animation = { dict = 'mini@repair', anim = 'fixing_a_ped' }
        },
    }
},
```

Com `Config.ProcessingSkillCheck = true`, a progress bar é trocada por um skill check do `ox_lib` com as dificuldades e teclas de `Config.SkillCheck`.

---

## Efeitos das drogas

Consumir um item listado em `Config.Drugs` aplica efeitos temporários. Só uma droga por vez, e cada uma tem cooldown próprio.

```lua
['joint'] = {
    label = 'Joint',
    animation = 'smoke',     -- smoke, blunt, sniff, pill
    time = 80,               -- duração dos efeitos, em segundos
    effects = { 'intenseEffect', 'stressDecrease', 'healthRegen', 'moreStrength', 'drunkWalk' },
    cooldown = 360,          -- segundos até poder usar de novo
},
```

Efeitos disponíveis: `stressDecrease`, `runningSpeedIncrease`, `infinateStamina`, `moreStrength`, `healthRegen`, `foodRegen`, `halfArmor`, `fullArmor`, `drunkWalk`, `psycoWalk`, `outOfBody`, `cameraShake`, `fogEffect`, `confusionEffect`, `whiteoutEffect`, `intenseEffect`, `focusEffect`, `superJump`, `swimming`.

---

## Dealer de sementes

Com `Config.EnableDealers = true`, cada dealer aparece em **uma** das `locations` (sorteada) e vende as sementes de `items`, com preço aleatório entre `min` e `max`.

```lua
['seed_dealer'] = {
    label = 'Seed Dealer',
    locations = { vector4(-462.85, 1101.56, 326.68, 166.98), ... },
    ped = 's_m_y_dealer_01',
    blip = { display = false, sprite = 140, displayColor = 2, displayText = 'Seed Dealer' },
    items = {
        ['weed_lemonhaze_seed'] = { min = 100, max = 200 },
        ['coca_seed'] = { min = 100, max = 300 },
    }
},
```

O dealer padrão vem com o blip desligado — os jogadores precisam encontrá-lo.

---

## Venda para NPCs

**Desativado neste fork** (`Config.EnableSelling = false`), com a nota no config de que as vendas ficam a cargo do `qbx_drugs`. A configuração continua no arquivo caso você queira reativar.

Quando ligado: dentro de uma `SellZone`, abordar um NPC (que não esteja em `Config.BlacklistPeds`) oferece uma venda. `sellChance` define a chance de fechar negócio, `stealChance` a chance de o NPC não pagar, e `sellAmount` a quantidade. Com `giveBonusOnPolice`, o valor sobe conforme a quantidade de policiais online (x1.2 com 1-2, x1.5 com 3-6, x1.7 com 7-10, x2.0 com mais de 10). A venda também dispara `SendPoliceAlert()`.

---

## Banco de dados

Duas tabelas, criadas automaticamente na inicialização.

```sql
CREATE TABLE IF NOT EXISTS drug_plants (
  id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  owner LONGTEXT DEFAULT NULL,
  coords LONGTEXT NOT NULL,
  time INT(255) NOT NULL,
  type VARCHAR(100) NOT NULL,
  health DOUBLE NOT NULL DEFAULT 100,
  fertilizer DOUBLE NOT NULL DEFAULT 0,
  water DOUBLE NOT NULL DEFAULT 0,
  growtime INT(11) NOT NULL
);

CREATE TABLE IF NOT EXISTS drug_processing (
  id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  coords LONGTEXT NOT NULL,
  rotation DOUBLE NOT NULL,
  type VARCHAR(100) NOT NULL
);
```

---

## Integrações

### ps-dispatch

Se o recurso estiver iniciado, a função `SendPoliceAlert()` do config chama `exports['ps-dispatch']:DrugDealing()` durante a venda de drogas. Para outro sistema de dispatch, reescreva essa função no `shared/config.lua`.

### Inventário (ox_inventory / qb-inventory)

O bridge detecta qual está rodando via `GetResourceState` e usa a API correspondente para checar, dar e remover itens, além de ler metadata (`metadata` no ox, `info` no qb).

### Framework (qb-core / es_extended)

O bridge detecta o core na inicialização. Isso muda o registro de comandos, o registro de itens usáveis, as notificações e a checagem de policiais em serviço.

---

## Entrypoints para outros recursos

O recurso **não registra exports**. A comunicação é por eventos e callbacks do `ox_lib`.

### Callbacks de servidor

| Callback | Retorno |
|---|---|
| `it-drugs:server:getPlantData` | Dados de uma planta |
| `it-drugs:server:getPlantDataWithId` | Dados de uma planta pelo id |
| `it-drugs:server:getPlantsOwned` | Plantas do jogador |
| `it-drugs:server:getPlants` | Todas as plantas (usado pelo menu admin) |
| `it-drugs:server:getTableData` | Dados de uma mesa |
| `it-drugs:server:getTables` | Todas as mesas (usado pelo menu admin) |
| `it-drugs:server:getDealerPosition` | Posição sorteada do dealer |
| `it-drugs:server:getDealerItemData` | Preços das sementes do dealer |
| `it-drugs:server:getCopsAmount` | Quantidade de policiais online |

```lua
local plants = lib.callback.await('it-drugs:server:getPlants', false)
```

### Itens usáveis

O servidor registra automaticamente como usáveis todas as chaves de `Config.Plants`, `Config.ProcessingTables` (se `EnableProcessing`) e `Config.Drugs` (se `EnableDrugs`). Não é preciso registrar nada no inventário.

---

## Localização

Os arquivos ficam em `locales/`, carregados como `shared_scripts`. O idioma ativo vem de `Config.Language` — **não** da convar `ox:locale`. A função `_U(chave)` resolve a string; se a chave não existir, ela devolve a própria chave.

Idiomas incluídos: `de`, `en`, `es`, `pt-br`.

Os nomes dos comandos também vêm dos locales (`COMMAND__ADMINMENU`, `COMMAND__GROUNDHASH`), então trocar de idioma pode mudar o comando.

Para adicionar um idioma, crie `locales/<codigo>.lua` copiando a estrutura de `en.lua` (tabela `Locales['<codigo>']`) e defina `Config.Language = '<codigo>'`.

---

## Estrutura de arquivos

```
it-drugs/
├── bridge/
│   ├── init.lua              — detecta o core (qb-core/esx) e o inventário (ox/qb)
│   ├── items/                — client.lua e server.lua: itens usáveis, dar/remover itens
│   ├── player/               — client.lua e server.lua: dados do jogador, job, dinheiro
│   └── utils/                — client.lua, server.lua e shared.lua: notify, helpers
├── client/
│   ├── cl_admin.lua          — menus admin, blips admin, ground hash
│   ├── cl_blips.lua          — blips das zonas e dos dealers
│   ├── cl_dealer.lua         — ped e loja do dealer de sementes
│   ├── cl_menus.lua          — menus do ox_lib (planta, mesa, dealer)
│   ├── cl_planting.lua       — raycast, colocação, cuidado e colheita das plantas
│   ├── cl_processing.lua     — colocação e uso das mesas de processamento
│   ├── cl_selling.lua        — abordagem de NPCs e venda
│   ├── cl_target.lua         — registro das opções no ox_target/qb-target
│   └── cl_using.lua          — animações, efeitos e cooldown das drogas
├── server/
│   ├── database/
│   │   ├── sv_setupdatabase.lua  — cria as tabelas na inicialização
│   │   ├── drug_plants.sql       — schema das plantas
│   │   └── drug_processing.sql   — schema das mesas
│   ├── sv_admin.lua          — comandos /drugadmin e /getGroundHash (gate por ACE admin)
│   ├── sv_dealer.lua         — posição e preços do dealer
│   ├── sv_planting.lua       — CRUD das plantas, decay de água/adubo/vida, colheita
│   ├── sv_processing.lua     — CRUD das mesas, consumo de ingredientes e produção
│   ├── sv_selling.lua        — venda, chance de roubo, bônus por polícia
│   ├── sv_usableitems.lua    — registra sementes, mesas e drogas como itens usáveis
│   ├── sv_versioncheck.lua   — checagem de versão no GitHub
│   └── sv_webhooks.lua       — logs no Discord (URL hardcoded aqui)
├── shared/
│   └── config.lua            — toda a configuração
├── items/
│   ├── items.lua             — itens no formato QB
│   ├── ox_items.lua          — itens no formato ox_inventory
│   ├── items.sql             — INSERT para a tabela items do QB
│   └── img/                  — imagens dos itens
├── locales/                  — de, en, es, pt-br
├── README.md
├── LICENSE
└── fxmanifest.lua
```
