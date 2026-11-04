# PetCare Hub — Banco de Dados Oracle

Projeto de banco de dados relacional desenvolvido para o Challenge FIAP 2026 — CLYVO VET.

A proposta do PetCare Hub é apoiar a jornada contínua de cuidado do pet, armazenando dados de tutor, clínicas, pets, consultas, protocolos preventivos, dispositivos IoT, leituras de sensores, alertas de saúde e score de saúde.

O banco foi modelado para servir como base para as APIs Java e .NET do projeto.

---

## Entrega da Sprint 4

**Vídeo demonstrativo:** https://youtu.be/iOoGd27AwiE

| Entregável | Pts | Onde está |
| ---------- | --- | --------- |
| Modelos lógico e físico (PDF) e codificação (SQL) | 20 | [`docs/2TDSPG_2026_Proj_BD.pdf`](docs/2TDSPG_2026_Proj_BD.pdf) · [`sql/2TDSPG_2026_CodigoSql_Alexander_Kelson.sql`](sql/2TDSPG_2026_CodigoSql_Alexander_Kelson.sql) |
| Packages com tratamento de exceções | 25 | [`sql/packages/`](sql/packages) — `PKG_LOG`, `PKG_UTIL`, `PKG_CARGA`, `PKG_RELATORIOS`, `PKG_AUDITORIA` |
| JSON gerado a partir do banco relacional | 20 | [`mongodb/pets.json`](mongodb/pets.json), [`telemetria.json`](mongodb/telemetria.json), [`alertas.json`](mongodb/alertas.json) — gerados por [`sql/export/`](sql/export) |
| Estrutura MongoDB (criação e importação) | 25 | [`mongodb/01_importar.ps1`](mongodb/01_importar.ps1) · [`mongodb/02_consultas.mongodb.js`](mongodb/02_consultas.mongodb.js) |
| Vídeo demonstrativo | 10 | link acima |

O que o vídeo mostra:

| Tempo | Parte |
| ----- | ----- |
| 0:40 | Os cinco packages e o trigger compilados, todos `VALID` |
| 1:20 | Exportação Oracle → JSON: 7 pets, 120 buckets de telemetria, 8 alertas |
| 2:00 | Importação no MongoDB, com criação dos índices |
| 2:45 | Consultas no `mongosh` provando a importação |
| 3:00 | `POST /leituras/coleira` na API Java, que chama `PKG_CARGA.PRC_INS_LEITURA_COLEIRA` |
| 3:35 | A linha nova gravada no Oracle pela procedure |
| 3:50 | As functions do `PKG_UTIL` que a API usa para o score médio |

---

## Objetivo

O banco de dados tem como objetivo centralizar as informações do ecossistema PetCare Hub, permitindo:

- Cadastro do tutor, clínicas e pets;
- Autenticação do tutor e da clínica (senha e status de acesso);
- Registro de consultas veterinárias;
- Controle de protocolos e eventos preventivos;
- Armazenamento de leituras vindas de dispositivos IoT;
- Geração de alertas de saúde;
- Registro do score de saúde do pet;
- Auditoria automática das mudanças no cadastro do tutor;
- Criação de relatórios analíticos para acompanhamento clínico;
- Registro de erros ocorridos nas procedures PL/SQL.

---

## Contexto do Challenge

O desafio da CLYVO VET busca transformar a jornada de saúde animal de um modelo reativo e fragmentado para uma experiência contínua, preventiva, inteligente e integrada.

O PetCare Hub contribui com esse objetivo ao estruturar dados clínicos, preventivos e de sensores em um histórico longitudinal do pet.

---

## Tecnologias Utilizadas

- Oracle Database
- Oracle SQL Developer
- Oracle Data Modeler
- SQL
- PL/SQL
- Procedures
- Triggers
- Functions
- Sequences
- Constraints
- Indexes
- Cursores explícitos
- Funções analíticas `LAG` e `LEAD`
- Packages PL/SQL
- SQL/JSON do Oracle (`JSON_OBJECT`, `JSON_ARRAYAGG`) para a exportação
- MongoDB (`mongoimport` e `mongosh`)
- Java (`tools/ExportarJson.java`, que grava em disco o JSON montado pelo Oracle)

---

## Estrutura do Projeto

```txt
PETCARE-HUB-DATABASE
├── docs
│   ├── 2TDSPG_2026_Proj_BD.pdf     ← documentação técnica + prints de execução exigidos pela rubrica
│   ├── evidencias/                 ← os prints acima em PNG individual (12 arquivos numerados)
│   ├── MER e DER/                  ← diagrama exportado do Oracle Data Modeler (DER.png, MER.png)
│   └── modelo-descritivo.md
├── sql
│   ├── 2TDSPG_2026_CodigoSql_Alexander_Kelson.sql   ← script único com tudo, do zero aos packages
│   ├── ddl
│   │   ├── 01_create_tables.sql
│   │   ├── 02_create_sequences.sql
│   │   ├── 03_create_indexes.sql
│   │   ├── 04_add_defaults_sequences.sql
│   │   ├── 05_rename_responsavel_to_tutor.sql
│   │   ├── 06_add_auth_fields.sql
│   │   ├── 07_fix_defaults_sequences.sql
│   │   └── 08_split_leitura_sensor.sql
│   ├── inserts
│   │   ├── 01_insert_testes.sql
│   │   ├── 02_insert_extra_sprint3.sql
│   │   ├── 03_insert_complemento_carga.sql
│   │   ├── 04_insert_movimento_ana.sql
│   │   └── 05_insert_leituras_recentes.sql
│   ├── procedures
│   │   ├── 01_log_erros.sql
│   │   ├── 02_procedures_carga.sql
│   │   ├── 03_prc_ins_tutor.sql
│   │   └── 04_procedures_relatorios_sprint3.sql
│   ├── triggers
│   │   └── 01_trg_auditoria_tutor.sql
│   ├── functions
│   │   ├── 01_functions.sql
│   │   └── 02_functions_json_senha.sql
│   ├── packages                    ← Sprint 4: os objetos acima empacotados
│   │   ├── 01_pkg_log.sql          ← registro de erro; todo mundo depende dele
│   │   ├── 02_pkg_util.sql         ← 4 functions de cálculo e formatação
│   │   ├── 03_pkg_carga.sql        ← 12 procedures de inserção validada
│   │   ├── 04_pkg_relatorios.sql   ← 2 procedures de relatório (só leitura)
│   │   ├── 05_pkg_auditoria.sql    ← lógica do trigger + o trigger enxuto
│   │   └── 06_remover_objetos_soltos.sql ← remove as 19 versões soltas já empacotadas
│   ├── export                      ← Sprint 4: geram o JSON via SQL/JSON do Oracle
│   │   ├── 01_export_pets.sql
│   │   ├── 02_export_telemetria.sql
│   │   └── 03_export_alertas.sql
│   ├── manutencao                  ← correções de dado, fora do fluxo normal
│   │   └── 01_limpar_alertas_duplicados.sql
│   └── relatorios
│       ├── 01_joins_group_order.sql
│       ├── 02_lag_lead.sql
│       └── 03_cursores.sql
├── mongodb                         ← Sprint 4: destino do pipeline
│   ├── pets.json                   ← gerado — não editar à mão
│   ├── telemetria.json             ← gerado — não editar à mão
│   ├── alertas.json                ← gerado — não editar à mão
│   ├── 01_importar.ps1             ← mongoimport + criação dos índices
│   └── 02_consultas.mongodb.js     ← consultas que provam a importação
├── tools
│   └── ExportarJson.java           ← roda os 3 scripts de export e grava os .json
└── README.md
```

> `sql/2TDSPG_2026_CodigoSql_Alexander_Kelson.sql` é os arquivos modulares acima concatenados
> numa ordem só, para quem preferir rodar tudo de uma vez em vez de arquivo por arquivo — os
> comentários `-- PASSO N/29 - ...` dentro dele apontam de volta pro arquivo modular
> correspondente. Os dois precisam ficar em sincronia; se editar um lado, replique no outro.
>
> Os passos 24 a 29 são da Sprint 4, e vêm no fim de propósito: os passos de carga (15 a 19)
> chamam as procedures soltas, então elas precisam existir antes. Os passos 24 a 28 criam os
> packages — o 28 ainda substitui o `TRG_AUDITORIA_TUTOR` do passo 12 pela versão que delega ao
> `PKG_AUDITORIA` — e o 29 remove as 19 versões soltas que os packages substituíram.

---

## Modelo de Dados

O banco possui 14 tabelas:

| Tabela                 | Descrição                                                          |
| ---------------------- | ------------------------------------------------------------------- |
| `TUTOR`                | Armazena os tutores dos pets, incluindo credenciais de acesso ao app |
| `CLINICA`              | Armazena as clínicas veterinárias parceiras, incluindo credenciais  |
| `PET`                  | Armazena os dados dos animais acompanhados                          |
| `CONSULTA`             | Armazena o histórico de consultas clínicas                          |
| `PROTOCOLO_PREVENTIVO` | Armazena regras preventivas por espécie e raça                      |
| `EVENTO_PREVENTIVO`    | Armazena eventos como vacinas, check-ups e retornos                  |
| `DISPOSITIVO_IOT`      | Armazena dispositivos vinculados aos pets                            |
| `LEITURA_COLEIRA`      | Armazena leituras de atividade e bateria da coleira                  |
| `LEITURA_COMEDOURO`    | Armazena leituras de nível de ração e consumo do comedouro           |
| `LEITURA_AMBIENTE`     | Armazena leituras de temperatura, umidade e qualidade do ar          |
| `ALERTA_SAUDE`         | Armazena alertas gerados por risco                                   |
| `SCORE_SAUDE`          | Armazena o score de saúde calculado do pet                           |
| `LOG_ERROS`            | Armazena erros gerados durante execução das procedures               |
| `AUDITORIA_TUTOR`      | Armazena o histórico de INSERT/UPDATE/DELETE feitos em `TUTOR`       |

> A tabela se chamava `RESPONSAVEL` originalmente e foi renomeada para `TUTOR` para alinhar com a terminologia usada no restante do produto (app, Java, .NET).
>
> A tabela genérica `LEITURA_SENSOR` foi separada em `LEITURA_COLEIRA`, `LEITURA_COMEDOURO` e `LEITURA_AMBIENTE` para alinhar com as 3 entidades Java correspondentes (`sql/ddl/08_split_leitura_sensor.sql`).

---

## Relacionamentos Principais

```txt
TUTOR 1:N PET

CLINICA 1:N PET

PET 1:N CONSULTA
CLINICA 1:N CONSULTA

PET 1:N EVENTO_PREVENTIVO
PROTOCOLO_PREVENTIVO 1:N EVENTO_PREVENTIVO

PET 1:N DISPOSITIVO_IOT
PET 1:N LEITURA_COLEIRA
PET 1:N LEITURA_COMEDOURO
PET 1:N LEITURA_AMBIENTE

PET 1:N ALERTA_SAUDE

PET 1:N SCORE_SAUDE

TUTOR 1:N AUDITORIA_TUTOR
```

---

## Autenticação (Tutor e Clínica)

O app é fechado: não existe autocadastro livre de tutor. O fluxo é:

1. A **clínica pré-cadastra o tutor** (nome, e-mail, telefone, CPF) via `prc_ins_tutor`. O registro nasce com `status_acesso = 'PRE_CADASTRADO'` e `senha_hash` nulo.
2. O tutor baixa o app e **ativa a conta**, informando CPF + e-mail + nome batendo com o pré-cadastro e criando uma senha. Isso atualiza `senha_hash` e muda `status_acesso` para `'ATIVO'`.
3. `status_acesso` também pode assumir `'BLOQUEADO'` ou `'INATIVO'`.

Não existe uma entidade `Usuario` separada — a própria tabela `TUTOR` (e a própria `CLINICA`) armazena dado pessoal e credencial juntos. O papel do usuário (tutor vs. clínica) é decidido em tempo de login pela tabela onde o e-mail bateu, não por um campo salvo.

Campos adicionados:

```txt
TUTOR.senha_hash      VARCHAR2(255)  -- nulo até a ativação
TUTOR.status_acesso   VARCHAR2(20)   -- PRE_CADASTRADO | ATIVO | BLOQUEADO | INATIVO
CLINICA.senha_hash    VARCHAR2(255)  -- preenchido na criação, sem fluxo de ativação
```

---

## Trigger de Auditoria (30 pts)

Arquivo: `sql/triggers/01_trg_auditoria_tutor.sql`

O trigger `TRG_AUDITORIA_TUTOR` dispara `AFTER INSERT OR UPDATE OR DELETE ON TUTOR`, `FOR EACH ROW`, e grava em `AUDITORIA_TUTOR`:

- Operação (`INSERT`, `UPDATE` ou `DELETE`);
- Usuário do banco que executou (`USER`);
- Data e hora (`SYSTIMESTAMP`);
- `status_acesso` antes e depois;
- `email` antes e depois.

Esse trigger captura o momento mais importante do fluxo de negócio: a ativação de conta do tutor (`PRE_CADASTRADO` → `ATIVO`), com prova de quem mudou, quando, e o estado antes/depois.

---

## Functions Implementadas

Arquivo: `sql/functions/01_functions.sql`

| Function                                 | Retorno                                                     |
| ----------------------------------------- | ------------------------------------------------------------ |
| `fn_calcular_idade_pet(p_id_pet)`         | Idade do pet em meses, calculada a partir de `data_nascimento` |
| `fn_score_medio_pet(p_id_pet, p_dias)`    | Score de saúde médio do pet nos últimos N dias                |

> Desde a Sprint 4 estas functions vivem no `PKG_UTIL`, e as versões soltas são removidas no
> fim do script (ver o [passo 23](#23-criar-os-packages-sprint-4)). Chame pelo package:
> `pkg_util.fn_calcular_idade_pet(9)`.

---

## Requisitos da Rubrica Oficial — Sprint 3 (Mastering Relational and Non-Relational Database)

Além do trigger de auditoria e das duas functions de negócio acima, a disciplina de banco de dados da Sprint 3 exige, especificamente, **2 procedures** e **2 functions** com regras próprias (não são as mesmas do produto). Estão implementadas em `sql/functions/02_functions_json_senha.sql` e `sql/procedures/04_procedures_relatorios_sprint3.sql`.

### Função 1 — conversão relacional → JSON manual

```txt
fn_pet_para_json(p_id_pet, p_nome_pet, p_especie_pet, p_nome_tutor, p_email_tutor, p_nome_clinica)
```

Monta manualmente (concatenação de string) um objeto JSON a partir dos dados de `PET` + `TUTOR` + `CLINICA`. Não usa `TO_JSON`, `JSON_OBJECT`, `JSON_VALUE` nem nenhuma função built-in de JSON do Oracle (proibido pela rubrica). Escapa manualmente aspas, barra invertida, quebra de linha e tabulação. Trata 4 exceções distintas (`e_id_pet_nulo`, `e_nome_pet_nulo`, `VALUE_ERROR`, `OTHERS`).

### Função 2 — validação de senha (substitui um processo lógico do projeto)

```txt
fn_validar_forca_senha(p_senha)
```

Valida a senha usada na ativação de conta do `TUTOR` (mínimo 8 caracteres, com letra e número). Trata 4 exceções distintas (`e_senha_nula`, `e_senha_curta`, `e_senha_sem_numero`, `OTHERS`).

### Procedimento 1 — JOIN + JSON

```txt
prc_rel_pets_tutor_clinica_json
```

Faz `JOIN` entre `PET`, `TUTOR` e `CLINICA` e imprime um array JSON, montado chamando `fn_pet_para_json` linha a linha (sem função automática). Exige que cada uma das 3 tabelas tenha pelo menos 5 registros válidos — por isso existe o `sql/inserts/02_insert_extra_sprint3.sql`, que complementa a carga original até `TUTOR`, `CLINICA` e `PET` chegarem a 5 linhas cada. Trata 4 exceções distintas (`e_sem_registros`, `e_dados_incompletos`, `VALUE_ERROR`, `OTHERS`).

### Procedimento 2 — subtotal e total geral manuais

```txt
prc_rel_consultas_subtotal
```

Lê `CONSULTA` (tabela de fatos) categorizada por `CLINICA` (categoria 1) e `tipo_consulta` (categoria 2), com `valor` como coluna numérica. O cursor só traz as linhas **brutas** (uma por consulta, sem `SUM`/`GROUP BY`/`NVL` nenhum nele); é a procedure que trata o `valor` nulo com `NVL` e acumula tudo **manualmente** em variáveis dentro do loop — a combinação clínica+tipo, o subtotal por clínica e o total geral — sem `SUM`, `ROLLUP`, `CUBE`, `GROUPING SETS` ou `GROUPING`. Trata 4 exceções distintas (`e_sem_registros`, `e_valor_negativo`, `e_clinica_sem_nome`, `OTHERS`).

> Os prints de execução dessas 4 peças (incluindo os 5 casos de exceção controlados, já deixados
> prontos no bloco de teste de `sql/procedures/04_procedures_relatorios_sprint3.sql`) estão em
> `docs/evidencias/` e embutidos em `docs/2TDSPG_2026_Proj_BD.pdf`. Numa execução limpa (banco
> zerado, script rodado do zero uma única vez), `LOG_ERROS` deve terminar com **exatamente 5
> linhas** (3 validações de cadastro — `PRC_INS_TUTOR`, `PRC_INS_CLINICA`, `PRC_INS_PET` — mais
> os 2 casos de exceção dos relatórios acima). Os prints atuais de `docs/evidencias/09_*` e
> `docs/evidencias/12_*` mostram 7 e 12 linhas porque foram tirados depois de várias execuções
> de teste acumuladas (mistura de reruns com um erro real de chave duplicada) — valem a pena
> refazer numa execução limpa antes da entrega final, pra bater com o texto acima.

---

## Integração com Java

A API Java ([PetCare-HUB/java](https://github.com/PetCare-HUB/java), publicada em
https://petcare-hub-gokt.onrender.com) usa **este mesmo schema Oracle** e chama os packages
direto. A regra mora no banco e não é reescrita em Java: a inserção de leitura e o disparo de
alerta são o `PKG_CARGA`; o score médio e a idade do pet são o `PKG_UTIL`.

A ponte é o `PlSqlRepository`, com `SimpleJdbcCall` recebendo o package como *catalog*:

| Chamada no Java | Objeto no Oracle | Disparada por |
|---|---|---|
| `withCatalogName("PKG_CARGA")` `.withProcedureName("PRC_INS_LEITURA_COLEIRA")` | `PKG_CARGA.PRC_INS_LEITURA_COLEIRA` | `POST /leituras/coleira` — grava a leitura e, fora da faixa segura, abre o alerta por `PKG_CARGA.PRC_INS_ALERTA_SAUDE` |
| `withCatalogName("PKG_UTIL")` `.withFunctionName("FN_SCORE_MEDIO_PET")` | `PKG_UTIL.FN_SCORE_MEDIO_PET` | `GET /pets/{id}/score-saude/media` |
| `withCatalogName("PKG_UTIL")` `.withFunctionName("FN_CALCULAR_IDADE_PET")` | `PKG_UTIL.FN_CALCULAR_IDADE_PET` | `GET /pets/{id}/score-saude/media` |

Para mostrar que é chamada real e não reimplementação, o endpoint de média devolve quem fez o
cálculo. Conferido contra a API publicada em 04/11/2026:

```txt
GET /pets/9/score-saude/media?dias=365

{ "petId": 9, "periodoDias": 365, "scoreMedio": 70.3, "idadeMeses": 66.0,
  "calculadoPor": "PKG_UTIL.FN_SCORE_MEDIO_PET / PKG_UTIL.FN_CALCULAR_IDADE_PET (Oracle PL/SQL)" }
```

O `idadeMeses: 66` é o mesmo do Rex em `mongodb/pets.json`: os dois números saem da mesma
function, um pela API e o outro pelo export.

As contas de demonstração para chamar esses endpoints estão no README da API Java.

---

## Integração com .NET

A API .NET ([PetCare-HUB/.NET](https://github.com/PetCare-HUB/.NET), publicada em
https://petcarehub-dotnet.onrender.com) é o dashboard B2B da clínica, sobre **o mesmo schema
Oracle**. Pelo EF Core ela consulta pets, tutores, scores, alertas, consultas e indicadores por
clínica, e mantém alertas e consultas. Não chama PL/SQL.

Cadastro de clínica e de tutor não passa por ela: o credenciamento da clínica e o pré-cadastro
do tutor são fluxos da API Java. E a .NET não autentica ninguém — valida a assinatura dos
tokens emitidos pelo Java, com a mesma chave pública RSA.

No MongoDB as duas disciplinas dividem a instância e o database `petcarehub`, em coleções
separadas — ver [Instância compartilhada com o .NET](#instância-compartilhada-com-o-net).

---

## Ordem de Execução dos Scripts

Execute os arquivos nesta ordem no Oracle SQL Developer:

### 1. Criar tabelas

```txt
sql/ddl/01_create_tables.sql
```

Cria as 11 tabelas principais do banco (com o nome original `RESPONSAVEL`).

### 2. Criar sequences

```txt
sql/ddl/02_create_sequences.sql
```

Cria as sequences utilizadas para gerar os IDs das tabelas.

### 3. Criar índices

```txt
sql/ddl/03_create_indexes.sql
```

Cria índices auxiliares para melhorar consultas por chaves estrangeiras e filtros frequentes.

### 4. Configurar geração automática de IDs

```txt
sql/ddl/04_add_defaults_sequences.sql
```

Adiciona `DEFAULT seq_xxx.NEXTVAL` em cada coluna de chave primária. Isso permite que INSERTs sem ID gerem automaticamente o próximo valor da sequence, o que é especialmente útil para a integração com a API .NET (Entity Framework Core) e para qualquer ORM que delegue a geração de IDs ao banco.

### 5. Renomear RESPONSAVEL para TUTOR

```txt
sql/ddl/05_rename_responsavel_to_tutor.sql
```

Renomeia a tabela `RESPONSAVEL` para `TUTOR`, a coluna de PK, as constraints, a FK em `PET` e a sequence `seq_responsavel` → `seq_tutor`.

### 6. Adicionar campos de autenticação

```txt
sql/ddl/06_add_auth_fields.sql
```

Adiciona `senha_hash` e `status_acesso` em `TUTOR`, e `senha_hash` em `CLINICA`.

### 7. Corrigir defaults de sequence

```txt
sql/ddl/07_fix_defaults_sequences.sql
```

Reaplica `DEFAULT seq_xxx.NEXTVAL` em todas as colunas de PK. É obrigatório rodar esse passo depois do rename (passo 5), porque renomear a sequence invalida o `DEFAULT` configurado no passo 4.

### 8. Separar LEITURA_SENSOR em 3 tabelas

```txt
sql/ddl/08_split_leitura_sensor.sql
```

Remove a FK `id_leitura` de `ALERTA_SAUDE` e a tabela genérica `LEITURA_SENSOR`, e cria `LEITURA_COLEIRA`, `LEITURA_COMEDOURO` e `LEITURA_AMBIENTE` para alinhar com as 3 entidades Java correspondentes.

### 9. Criar procedure de log

```txt
sql/procedures/01_log_erros.sql
```

Cria a procedure `PRC_REGISTRAR_LOG_ERRO`, responsável por salvar erros na tabela `LOG_ERROS`.

### 10. Criar procedure de cadastro do tutor

```txt
sql/procedures/03_prc_ins_tutor.sql
```

Cria a procedure `PRC_INS_TUTOR` (pré-cadastro do tutor, feito pela clínica, sem senha) e remove a antiga `PRC_INS_RESPONSAVEL`.

### 11. Criar procedures de carga

```txt
sql/procedures/02_procedures_carga.sql
```

Cria as demais procedures de inserção de dados por parâmetro (`PRC_INS_CLINICA`, `PRC_INS_PET`, `PRC_INS_LEITURA_COLEIRA`, `PRC_INS_LEITURA_COMEDOURO`, `PRC_INS_LEITURA_AMBIENTE`, etc.).

### 12. Criar trigger de auditoria

```txt
sql/triggers/01_trg_auditoria_tutor.sql
```

Cria a tabela `AUDITORIA_TUTOR`, a sequence dela e o trigger `TRG_AUDITORIA_TUTOR`.

### 13. Criar functions

```txt
sql/functions/01_functions.sql
```

Cria `fn_calcular_idade_pet` e `fn_score_medio_pet`.

### 14. Criar functions da rubrica Sprint 3

```txt
sql/functions/02_functions_json_senha.sql
```

Cria `fn_pet_para_json` (Função 1 — conversão manual para JSON) e `fn_validar_forca_senha` (Função 2 — validação de senha). Precisa rodar antes do passo 18, que depende de `fn_pet_para_json`.

### 15. Inserir dados de teste

```txt
sql/inserts/01_insert_testes.sql
```

Executa a carga inicial de dados usando as procedures.

### 16. Inserir dados complementares da Sprint 3

```txt
sql/inserts/02_insert_extra_sprint3.sql
```

Garante que `TUTOR`, `CLINICA` e `PET` tenham pelo menos 5 registros cada, exigido pelo Procedimento 1 da rubrica.

### 17. Completar carga mínima das demais tabelas

```txt
sql/inserts/03_insert_complemento_carga.sql
```

Garante que `PROTOCOLO_PREVENTIVO`, `DISPOSITIVO_IOT`, `LEITURA_COMEDOURO`, `LEITURA_AMBIENTE` e `SCORE_SAUDE` também cheguem a pelo menos 5 registros cada. `ALERTA_SAUDE` chega a 5 como efeito automático das próprias procedures de leitura (uma leitura de ração abaixo de 20% e uma leitura de qualidade do ar acima de 500ppm), sem inserção direta na tabela.

### 18. Enriquecer movimento dos pets da Ana

```txt
sql/inserts/04_insert_movimento_ana.sql
```

Adiciona mais leituras de `LEITURA_COLEIRA` (movimento) para Rex e Luna, os dois pets da tutora Ana Souza, espalhadas em dois dias — a Luna tinha só 1 leitura contra as 5 do Rex, agora os dois ficam com 6 e 10 respectivamente. Também soma mais 1 leitura de comedouro e 1 de ambiente para a Luna.

### 18b. Adicionar leituras recentes (relativas a hoje)

```txt
sql/inserts/05_insert_leituras_recentes.sql
```

Adiciona mais leituras de coleira, comedouro e ambiente para Rex e Luna com timestamp relativo a `SYSDATE` (ontem + hoje), não datas fixas — assim o app sempre mostra dado "atual" para os dois pets, não importa quando o script for executado. Convive tanto com as leituras de teste antigas quanto com as leituras reais que a API/app grava neste mesmo banco.

### 19. Criar procedures de relatório da rubrica Sprint 3

```txt
sql/procedures/04_procedures_relatorios_sprint3.sql
```

Cria `prc_rel_pets_tutor_clinica_json` (Procedimento 1 — JOIN + JSON) e `prc_rel_consultas_subtotal` (Procedimento 2 — subtotal e total geral manuais, agrupado por clínica + tipo de consulta). Já executa e imprime os dois no final do script, incluindo um caso de exceção de cada um.

### 20. Executar relatórios com joins

```txt
sql/relatorios/01_joins_group_order.sql
```

Executa relatórios com `JOIN`, `GROUP BY` e `ORDER BY`.

### 21. Executar relatório LAG/LEAD

```txt
sql/relatorios/02_lag_lead.sql
```

Mostra valor anterior, atual e próximo de leituras da coleira (nível de bateria).

### 22. Executar relatórios com cursores

```txt
sql/relatorios/03_cursores.sql
```

Executa relatórios com cursores explícitos e tomada de decisão.

---

### 23. Criar os packages (Sprint 4)

```txt
sql/packages/01_pkg_log.sql
sql/packages/02_pkg_util.sql
sql/packages/03_pkg_carga.sql
sql/packages/04_pkg_relatorios.sql
sql/packages/05_pkg_auditoria.sql
sql/packages/06_remover_objetos_soltos.sql
```

Empacota os objetos dos passos 9 a 14 e 19. **A ordem importa**: `pkg_log` compila primeiro
porque todos os outros chamam a procedure de log, e `pkg_util` vem antes de `pkg_relatorios`
porque `prc_rel_pets_tutor_clinica_json` usa `fn_pet_para_json`.

Depois dos cinco packages, `06_remover_objetos_soltos.sql` remove as **19 versões soltas** que
eles substituem. Elas existem até ali porque as cargas de teste (passos 15 a 18b) as usam para
montar a massa de dados; com a carga feita, viram duplicata. Nada mais depende delas: os
packages se chamam entre si sempre com prefixo (`pkg_log.prc_registrar_log_erro`), a API Java
chama `PKG_CARGA` e `PKG_UTIL`, e o export para JSON não usa nenhuma. O schema termina só com os
packages e o trigger.

A lista de remoção é explícita, nunca `LIKE 'PRC_%'` — pelo mesmo motivo da conferência abaixo.

Conferência — precisa voltar **10 linhas** (5 specs + 5 bodies), todas `VALID`, e nada em
`USER_ERRORS`. O próprio `06_remover_objetos_soltos.sql` termina com uma terceira consulta, que
precisa voltar **vazia**: nenhuma das 19 versões soltas pode ter sobrado.

```sql
SELECT object_name, object_type, status
FROM user_objects
WHERE object_name IN ('PKG_LOG', 'PKG_UTIL', 'PKG_CARGA', 'PKG_RELATORIOS', 'PKG_AUDITORIA')
ORDER BY object_name, object_type;

SELECT name, type, line, text
FROM user_errors
WHERE name IN ('PKG_LOG', 'PKG_UTIL', 'PKG_CARGA', 'PKG_RELATORIOS', 'PKG_AUDITORIA');
```

> Filtre pelos cinco nomes, **não** por `object_name LIKE 'PKG%'`. O schema da FIAP é
> compartilhado entre as disciplinas: além dos nossos, ele tem `PKG_AULA_01`, `PKG_ESTOQUE`,
> `PKG_PEDIDOS` e `PKG_PHYCOCARBON` de outras matérias, e o `LIKE` traz 18 linhas em vez de 10.
> Vale o mesmo para as tabelas — há `CLIENTE`, `CIDADE` e a família `CP3_*` no mesmo schema.

### 23b. Limpar alertas duplicados (Sprint 4)

```txt
sql/manutencao/01_limpar_alertas_duplicados.sql
```

Roda **antes** do export. Até 30/10/2026 cada leitura IoT fora do limite abria uma linha nova
em `ALERTA_SAUDE`; com o simulador mandando leitura a cada poucos segundos, o pet 9 acumulou
197 alertas `BAIXA_ALIMENTACAO` idênticos em cerca de uma hora, e o export levava tudo junto:
197 dos 204 documentos de `mongodb/alertas.json` eram a mesma ocorrência repetida.

O script não dá `COMMIT`. Ele diagnostica, apaga e manda conferir antes de você efetivar.
Alertas já resolvidos não são tocados: dois episódios do mesmo tipo em meses diferentes são
dois fatos, não duplicata.

Rodado em 03/11/2026: 197 linhas excluídas, conferência vazia, `COMMIT`. Depois da limpeza o
export foi refeito e `alertas.json` caiu de 204 para 8 documentos — um por par pet/tipo em
aberto.

### 24. Exportar para JSON e importar no MongoDB (Sprint 4)

```txt
sql/export/01_export_pets.sql
sql/export/02_export_telemetria.sql
sql/export/03_export_alertas.sql
```

Cada um é um `SELECT` único que devolve o array JSON completo numa célula CLOB. Para gerar os
arquivos e importar no Mongo de uma vez, veja
[Pipeline Oracle → JSON → MongoDB](#pipeline-oracle--json--mongodb-sprint-4).

---

## Como Executar no SQL Developer

1. Abra o Oracle SQL Developer.
2. Conecte-se ao banco Oracle.
3. Abra cada arquivo `.sql` na ordem correta.
4. Selecione todo o conteúdo do arquivo (`Ctrl+A`) e execute usando **F5** (Run Script) — não use `Ctrl+Enter` (Run Statement), que roda só a instrução onde o cursor está.
5. Verifique a aba `Script Output` (não `Query Result`) e confira que não apareceu nenhum `ORA-` **fora dos blocos de teste de exceção do passo 18** (esses são esperados — ver abaixo).
6. Só então avance para o próximo arquivo.

Consulta para verificar erros:

```sql
SELECT *
FROM LOG_ERROS
ORDER BY data_ocorrencia DESC;
```

Numa execução limpa (banco zerado, script rodado do zero uma única vez), essa consulta deve
retornar **exatamente 5 linhas** — os 5 cenários de exceção controlados que o próprio script
dispara de propósito no passo 18 (`PRC_INS_TUTOR`, `PRC_INS_CLINICA`, `PRC_INS_PET`,
`PRC_REL_CONSULTAS_SUBTOTAL`, `PRC_REL_PETS_TUTOR_CLINICA_JSON`). Mais que 5 (rodou o passo 18
mais de uma vez sem zerar o banco) ou menos que 5 (algum cenário não disparou) indica que algo
não está batendo com uma execução limpa.

Para confirmar que os defaults de sequence foram aplicados corretamente:

```sql
SELECT table_name, column_name, data_default
FROM user_tab_columns
WHERE column_name LIKE 'ID\_%' ESCAPE '\'
  AND table_name IN (
    'TUTOR', 'CLINICA', 'PET', 'CONSULTA',
    'PROTOCOLO_PREVENTIVO', 'EVENTO_PREVENTIVO',
    'DISPOSITIVO_IOT', 'LEITURA_COLEIRA', 'LEITURA_COMEDOURO', 'LEITURA_AMBIENTE',
    'ALERTA_SAUDE', 'SCORE_SAUDE', 'LOG_ERROS'
  )
ORDER BY table_name;
```

Cada linha deve mostrar `seq_xxx.NEXTVAL` na coluna `DATA_DEFAULT`.

Para validar o trigger de auditoria de ponta a ponta:

```sql
EXEC pkg_carga.prc_ins_tutor('Teste Final', 'teste.final@petcare.com', '11988887777', '11122233344');
SELECT id_tutor, nome, status_acesso, senha_hash FROM TUTOR WHERE email = 'teste.final@petcare.com';
UPDATE TUTOR SET senha_hash = 'hash_fake_teste', status_acesso = 'ATIVO' WHERE email = 'teste.final@petcare.com';
COMMIT;
SELECT * FROM AUDITORIA_TUTOR ORDER BY data_hora DESC;
```

Deve aparecer uma linha com `operacao = UPDATE`, `status_anterior = PRE_CADASTRADO` e `status_novo = ATIVO`.

---

## Validações e Constraints

O banco utiliza constraints para garantir integridade dos dados.

### Tutor

```txt
status_acesso: PRE_CADASTRADO, ATIVO, BLOQUEADO ou INATIVO
ativo: S ou N
```

### Pet

```txt
especie: CAO, GATO ou OUTRO
sexo: M ou F
peso_kg: maior que zero
ativo: S ou N
```

### Consulta

```txt
tipo_consulta: CHECKUP, VACINA, EMERGENCIA, RETORNO ou EXAME
retorno_recomendado: S ou N
valor: maior ou igual a zero
```

### Evento Preventivo

```txt
status: PENDENTE, REALIZADO, ATRASADO ou CANCELADO
```

### Leitura Sensor

```txt
status_leitura: NORMAL, ATENCAO ou CRITICO
```

### Score de Saúde

```txt
score_total: valor entre 0 e 100
categoria: VERDE, AMARELO ou VERMELHO
```

### Auditoria Tutor

```txt
operacao: INSERT, UPDATE ou DELETE
```

---

## Procedures Criadas

> Estas são as procedures da Sprint 3, documentadas como foram criadas. Na Sprint 4 todas foram
> para packages — `PKG_LOG`, `PKG_CARGA` e `PKG_RELATORIOS` — e as versões soltas são removidas
> no fim do script. Chame sempre pelo package: `pkg_carga.prc_ins_tutor(...)`.

### Procedure de log

```txt
PRC_REGISTRAR_LOG_ERRO
```

Responsável por registrar erros na tabela `LOG_ERROS`.

### Procedure de cadastro do tutor

```txt
PRC_INS_TUTOR
```

Pré-cadastra o tutor (feito pela clínica) com `status_acesso = 'PRE_CADASTRADO'`.

### Procedures de carga

```txt
PRC_INS_CLINICA
PRC_INS_PET
PRC_INS_CONSULTA
PRC_INS_PROTOCOLO_PREVENTIVO
PRC_INS_EVENTO_PREVENTIVO
PRC_INS_DISPOSITIVO_IOT
PRC_INS_ALERTA_SAUDE
PRC_INS_LEITURA_COLEIRA
PRC_INS_LEITURA_COMEDOURO
PRC_INS_LEITURA_AMBIENTE
PRC_INS_SCORE_SAUDE
```

As procedures recebem dados por parâmetro e possuem tratamento de exceções.

### Procedures da rubrica Sprint 3

```txt
PRC_REL_PETS_TUTOR_CLINICA_JSON
PRC_REL_CONSULTAS_SUBTOTAL
```

Ver seção "Requisitos da Rubrica Oficial" acima.

---

## Regras Automáticas Implementadas

Algumas procedures possuem regras de negócio simples para simular o funcionamento do PetCare Hub.

### Leitura de nível de ração

Quando uma leitura de `LEITURA_COMEDOURO` possui `nivel_racao_pct` menor que `20`, o sistema gera um alerta automático:

```txt
RACAO_BAIXA
Nível: MEDIO
```

### Score de saúde

Quando o `score_total` do pet é menor que `50`, o sistema gera um alerta automático:

```txt
SCORE_BAIXO
Nível: ALTO
```

### Ativação de conta do tutor

Quando `status_acesso` do tutor muda, o trigger `TRG_AUDITORIA_TUTOR` registra automaticamente a mudança em `AUDITORIA_TUTOR`.

---

## Dados de Teste

Os três scripts de inserts (`01_insert_testes.sql`, `02_insert_extra_sprint3.sql` e `03_insert_complemento_carga.sql`) juntos cadastram:

```txt
5 tutores
5 clínicas
5 pets
5 protocolos preventivos
5 consultas
5 eventos preventivos
5 dispositivos IoT
17 leituras de sensores (7 coleira + 5 comedouro + 5 ambiente)
5 scores de saúde
5 alertas de saúde (todos gerados automaticamente pelas procedures)
```

`TUTOR`, `CLINICA`, `PET`, `PROTOCOLO_PREVENTIVO`, `DISPOSITIVO_IOT`, `LEITURA_COMEDOURO`, `LEITURA_AMBIENTE`, `SCORE_SAUDE` e `ALERTA_SAUDE` chegam a pelo menos 5 registros cada, conforme exigido pelo Procedimento 1 da rubrica da Sprint 3.

Após executar a carga, é possível conferir os totais com:

```sql
SELECT 'TUTOR' AS tabela, COUNT(*) AS total FROM TUTOR
UNION ALL
SELECT 'CLINICA', COUNT(*) FROM CLINICA
UNION ALL
SELECT 'PET', COUNT(*) FROM PET
UNION ALL
SELECT 'CONSULTA', COUNT(*) FROM CONSULTA
UNION ALL
SELECT 'PROTOCOLO_PREVENTIVO', COUNT(*) FROM PROTOCOLO_PREVENTIVO
UNION ALL
SELECT 'EVENTO_PREVENTIVO', COUNT(*) FROM EVENTO_PREVENTIVO
UNION ALL
SELECT 'DISPOSITIVO_IOT', COUNT(*) FROM DISPOSITIVO_IOT
UNION ALL
SELECT 'LEITURA_COLEIRA', COUNT(*) FROM LEITURA_COLEIRA
UNION ALL
SELECT 'LEITURA_COMEDOURO', COUNT(*) FROM LEITURA_COMEDOURO
UNION ALL
SELECT 'LEITURA_AMBIENTE', COUNT(*) FROM LEITURA_AMBIENTE
UNION ALL
SELECT 'ALERTA_SAUDE', COUNT(*) FROM ALERTA_SAUDE
UNION ALL
SELECT 'SCORE_SAUDE', COUNT(*) FROM SCORE_SAUDE
UNION ALL
SELECT 'LOG_ERROS', COUNT(*) FROM LOG_ERROS;
```

---

## Relatórios Implementados

### Relatórios com JOIN, GROUP BY e ORDER BY

Arquivo:

```txt
sql/relatorios/01_joins_group_order.sql
```

Relatórios incluídos:

```txt
Total de pets por clínica, tutor e espécie
Total de consultas por clínica, tutor e tipo
Média de score por clínica, tutor e espécie
Alertas abertos por clínica, tutor e nível
Eventos preventivos por clínica, pet e status
Leituras por clínica, pet e tipo
```

### Relatório com LAG e LEAD

Arquivo:

```txt
sql/relatorios/02_lag_lead.sql
```

Mostra:

```txt
Valor anterior
Valor atual
Próximo valor
```

Esse relatório usa as leituras de atividade do pet Rex.

### Relatórios com Cursores Explícitos

Arquivo:

```txt
sql/relatorios/03_cursores.sql
```

Relatórios incluídos:

```txt
Scores por categoria com subtotal e total geral
Alertas com ação recomendada
Eventos preventivos com tomada de decisão
Valor de consultas por clínica com subtotal e total geral
```

---

## Pipeline Oracle → JSON → MongoDB (Sprint 4)

O dado relacional sai do Oracle em JSON e entra no MongoDB como documento. **O Oracle
continua sendo a fonte da verdade** — nada é migrado. As duas APIs do projeto (Java e .NET)
continuam lendo do relacional; o Mongo recebe uma cópia modelada em documento.

### As três coleções

| Coleção | Documentos | O que é um documento | Por que modelado assim |
|---|---|---|---|
| `pets` | 7 | Um pet, com tutor, clínica, consultas, eventos preventivos, dispositivos e score embutidos | No relacional essa resposta custa 6 joins. Aqui é um `findOne`. |
| `telemetria` | 120 | Um *bucket*: as leituras de um pet, de um tipo de sensor, num dia | Série temporal. Documento por leitura daria 924 documentos minúsculos e um índice gigante. |
| `alertas` | 8 | Um alerta, com o pet, tutor e clínica congelados no estado do disparo | Aqui a desnormalização é correção, não otimização — ver abaixo. |

**Não é um dump das tabelas.** O schema relacional tem 13 tabelas; virar 13 coleções
seria mover tabelas de lugar sem usar nada do modelo de documento. As três coleções foram
desenhadas em cima das leituras que a aplicação faz de verdade.

Três decisões que valem explicar:

- **`pets` duplica o nome do tutor de propósito.** É dado que quase não muda, e o custo de
  repetir é menor que o de juntar em toda leitura. No relacional isso seria anomalia de
  atualização; aqui é a troca consciente que o modelo de documento permite.

- **`telemetria` junta o que o relacional foi obrigado a separar.** `LEITURA_COLEIRA`,
  `LEITURA_COMEDOURO` e `LEITURA_AMBIENTE` são tabelas distintas porque as colunas são
  diferentes — coleira tem bateria, comedouro tem peso de ração, ambiente tem umidade. Uma
  tabela única deixaria metade das colunas nulas em cada linha. No documento, o array
  `leituras` carrega o formato de cada tipo e o campo `tipo` diz qual esperar.

- **`alertas` congela o contexto.** No relacional, `ALERTA_SAUDE` guarda `id_pet` e o resto
  vem por join — se o pet trocar de tutor amanhã, o alerta de hoje passa a ser exibido com o
  tutor novo e o histórico mente. O documento guarda quem era o tutor no momento do disparo.

### Etapa 1 — exportar (Oracle gera o JSON)

Quem monta o JSON é o **Oracle**, com SQL/JSON (`JSON_OBJECT` + `JSON_ARRAYAGG`) nos scripts
de `sql/export/`. O programa Java só lê o CLOB e escreve no disco — a responsabilidade do
formato fica no banco.

```powershell
$env:ORACLE_USER     = 'seu_usuario'
$env:ORACLE_PASSWORD = 'sua_senha'
$env:ORACLE_DSN      = '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=oracle.fiap.com.br)(PORT=1521))(CONNECT_DATA=(SID=orcl)))'

java -cp "$env:USERPROFILE\.m2\repository\com\oracle\database\jdbc\ojdbc11\23.5.0.24.07\ojdbc11-23.5.0.24.07.jar" tools\ExportarJson.java
```

Saída esperada:

```txt
01_export_pets.sql         -> pets.json            7.911 bytes    7 documentos
02_export_telemetria.sql   -> telemetria.json    122.031 bytes  120 documentos
03_export_alertas.sql      -> alertas.json         3.458 bytes    8 documentos
```

Os scripts também rodam direto no SQL Developer, um por vez: cada um é um `SELECT` só, que
devolve o array JSON inteiro numa célula CLOB.

Dois detalhes do export:

- **As datas saem como `{"$date": "..."}`** (Extended JSON). Sem isso o `mongoimport` gravaria
  string, e nenhuma consulta por período funcionaria no Mongo.
- **`SENHA_HASH` não sai.** `TUTOR` e `CLINICA` têm a coluna; os scripts não a selecionam.
  Hash de senha não é dado de domínio e não tem o que fazer num arquivo versionado em
  repositório público.

### Etapa 2 — importar (JSON → MongoDB)

Pré-requisitos: MongoDB Server em `localhost:27017`, mais as ferramentas de linha de comando:

```powershell
winget install MongoDB.DatabaseTools MongoDB.Shell
```

```powershell
.\mongodb\01_importar.ps1
```

O script importa as três coleções e cria os índices. Usa `--mode upsert --upsertFields _id`
em vez de `--drop`: o `_id` de cada documento vem da chave primária do Oracle (`id_pet`,
`id_alerta`) ou de uma chave composta estável (`id_pet|tipo|dia` na telemetria), então **rodar
a importação duas vezes atualiza, não duplica**.

Os índices seguem as consultas reais da aplicação, não as chaves estrangeiras que existiam no
relacional:

| Coleção | Índice | Consulta que ele atende |
|---|---|---|
| `pets` | `{ "tutor.email": 1 }` | "quais pets são desta tutora" — tela inicial do app |
| `telemetria` | `{ "pet.id": 1, dia: -1 }` | "leituras deste pet no período" — gráfico do dashboard |
| `alertas` | `{ "pet.id": 1, resolvido: 1, dataAlerta: -1 }` | "alertas abertos deste pet, do mais novo" |
| `alertas` | `{ tipo: 1 }` | "quantos alertas de cada tipo" — relatório |

### Etapa 3 — provar que funcionou

```powershell
mongosh "mongodb://localhost:27017/petcarehub" --file mongodb\02_consultas.mongodb.js
```

Cada consulta prova uma coisa específica, com o número esperado no comentário:

| # | O que prova |
|---|---|
| 1 | Contagem por coleção bate com o Oracle: 7 / 120 / 8 |
| 2 | **Nenhuma leitura se perdeu**: 924 itens nos arrays = 325 coleira + 301 comedouro + 298 ambiente |
| 3 | As datas são `Date` de verdade — a agregação por mês só funciona se forem BSON date |
| 4 | O join de 6 tabelas virou um `findOne` |
| 5 | Os três formatos de leitura convivem na mesma coleção |
| 6 | O `GROUP BY` do relatório virou aggregation pipeline |
| 7 | Nenhum hash de senha vazou no export |

### Instância compartilhada com o .NET

O database é `petcarehub`, **o mesmo que a API .NET usa** para a coleção `resumos_pet_ia`
(resumos de contexto da camada de IA). As três coleções deste pipeline são novas e não
encostam nela.

Instância única, coleções separadas. Isso evita subir um segundo Mongo e deixa visível que as
duas disciplinas conversam — a .NET escreve dado que nasce no Mongo, a Database importa dado
que nasce no Oracle.

### Dado legado, e como foi limpo

Até 03/11/2026 a coleção `alertas` tinha **197 alertas `BAIXA_ALIMENTACAO` idênticos do pet
#9, todos de 2026-10-28** — 197 dos 204 documentos. Não era defeito do pipeline: eram linhas
que já estavam na `ALERTA_SAUDE`, criadas antes da correção de `prc_ins_alerta_saude` (commit
`b5920f0`, 2026-10-30), quando cada leitura fora do limite abria um alerta novo em vez de
atualizar o que já estava aberto.

O `sql/manutencao/01_limpar_alertas_duplicados.sql` apagou as 197 linhas e o export foi
refeito: a coleção passou a ter 8 documentos, um por par pet/tipo em aberto. Como a procedure
e o `AlertaSaudeService.criarInterno` já deduplicam, o acúmulo não volta.

---

## Evidências de Execução

Durante os testes, foram validados:

```txt
14 tabelas criadas (13 apos o split de LEITURA_SENSOR + AUDITORIA_TUTOR)
14 sequences criadas (13 apos o split de LEITURA_SENSOR + seq_auditoria_tutor)
15 índices criados
DEFAULT seq_xxx.NEXTVAL aplicado/corrigido nas 13 colunas de PK
1 procedure de log criada
1 procedure de cadastro de tutor criada
11 procedures de carga criadas
1 trigger de auditoria criado e validado (INSERT/UPDATE/DELETE, com print de cada operação)
2 functions de negócio criadas (idade do pet, score médio)
2 functions da rubrica Sprint 3 criadas (JSON manual com escape completo, validação de senha)
2 procedures da rubrica Sprint 3 criadas (JOIN+JSON, subtotal/total geral manual agrupado por clínica+tipo)
Dados de teste inseridos com sucesso (5+ registros em cada tabela exigida pela rubrica)
5 cenários de exceção controlados validados (3 na carga + 2 nos relatórios), gerando 5 linhas em LOG_ERROS numa execução limpa
Relatórios executados com sucesso
```

Na Sprint 4, conferido em 04/11/2026:

```txt
5 packages no script consolidado: PKG_LOG, PKG_UTIL, PKG_CARGA, PKG_RELATORIOS, PKG_AUDITORIA
Trigger de auditoria reescrito para delegar ao PKG_AUDITORIA
Passo 29 rodado no schema: 19 objetos soltos removidos, sem nenhum ORA-
Depois da remoção: os 5 packages (spec + body) e o trigger VALID -- 11 linhas
PKG_UTIL chamado pela API Java em produção: GET /pets/9/score-saude/media -> 200, scoreMedio 70.3
A mesma chamada seguiu respondendo depois da remoção: sem a versão solta da function, o que
  responde só pode ser o PKG_UTIL
3 arquivos JSON gerados pelo Oracle: 7 pets, 120 buckets de telemetria, 8 alertas
924 leituras dentro dos buckets = 325 coleira + 301 comedouro + 298 ambiente
MongoDB importado: as 7 consultas de 02_consultas.mongodb.js passam
Nenhum hash de senha no JSON exportado
```

---

## Observação sobre o Oracle Data Modeler

Os scripts SQL deste repositório servem como base de implementação e validação do banco.

Para a entrega acadêmica, o modelo deverá ser representado também no Oracle Data Modeler, contendo:

- Modelo lógico;
- Notação Barker;
- Modelo físico;
- Relacionamentos;
- Chaves primárias;
- Chaves estrangeiras;
- Constraints;
- DDL gerado pelo Data Modeler.

> Em `docs/MER e DER/`, o `DER.png` é o **modelo lógico** (notação Barker) e o `MER.png` é o
> **modelo físico** (tipos, chaves primárias e estrangeiras, índices). Os dois já refletem o
> rename `TUTOR`, os campos de autenticação (`senha_hash`/`status_acesso`) e a tabela
> `AUDITORIA_TUTOR`.

---

## 👥 Integrantes da Equipe

| Nome                           | RM     | Turma  | GitHub                                        | LinkedIn                                                            |
| ------------------------------- | ------ | ------ | ----------------------------------------------- | ---------------------------------------------------------------------- |
| Alexander Dennis Isidro Mamani | 565554 | 2TDSPG | [alex-isidro](https://github.com/alex-isidro) | [LinkedIn](https://www.linkedin.com/in/alexander-dennis-a3b48824b/) |
| Kelson Zhang                   | 563748 | 2TDSPG | [KelsonZh0](https://github.com/KelsonZh0)     | [LinkedIn](https://www.linkedin.com/in/kelson-zhang-211456323/)     |

---