# PetCare Hub — Banco de Dados Oracle

Projeto de banco de dados relacional desenvolvido para o Challenge FIAP 2026 — CLYVO VET.

A proposta do PetCare Hub é apoiar a jornada contínua de cuidado do pet, armazenando dados de tutor, clínicas, pets, consultas, protocolos preventivos, dispositivos IoT, leituras de sensores, alertas de saúde e score de saúde.

O banco foi modelado para servir como base para as APIs Java e .NET do projeto.

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

---

## Estrutura do Projeto

```txt
PETCARE-HUB-DATABASE
├── docs
│   └── modelo-descritivo.md
│   └── arquivos do Oracle Data Modeler
├── sql
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
│   │   └── 02_insert_extra_sprint3.sql
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
│   └── relatorios
│       ├── 01_joins_group_order.sql
│       ├── 02_lag_lead.sql
│       └── 03_cursores.sql
└── README.md
```

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

---

## Requisitos da Rubrica Oficial — Sprint 3 (Mastering Relational and Non-Relational Database)

Além do trigger de auditoria e das duas functions de negócio acima, a disciplina de banco de dados da Sprint 3 exige, especificamente, **2 procedures** e **2 functions** com regras próprias (não são as mesmas do produto). Estão implementadas em `sql/functions/02_functions_json_senha.sql` e `sql/procedures/04_procedures_relatorios_sprint3.sql`.

### Função 1 — conversão relacional → JSON manual

```txt
fn_pet_para_json(p_id_pet, p_nome_pet, p_especie_pet, p_nome_tutor, p_email_tutor, p_nome_clinica)
```

Monta manualmente (concatenação de string) um objeto JSON a partir dos dados de `PET` + `TUTOR` + `CLINICA`. Não usa `TO_JSON`, `JSON_OBJECT`, `JSON_VALUE` nem nenhuma função built-in de JSON do Oracle (proibido pela rubrica). Trata 4 exceções distintas (`e_id_pet_nulo`, `e_nome_pet_nulo`, `VALUE_ERROR`, `OTHERS`).

### Função 2 — validação de senha (substitui um processo lógico do projeto)

```txt
fn_validar_forca_senha(p_senha)
```

Valida a senha usada na ativação de conta do `TUTOR` (mínimo 8 caracteres, com letra e número). Trata 4 exceções distintas (`e_senha_nula`, `e_senha_curta`, `e_senha_sem_numero`, `OTHERS`).

### Procedimento 1 — JOIN + JSON

```txt
prc_rel_pets_tutor_clinica_json
```

Faz `JOIN` entre `PET`, `TUTOR` e `CLINICA` e imprime um array JSON, montado chamando `fn_pet_para_json` linha a linha (sem função automática). Exige que cada uma das 3 tabelas tenha pelo menos 5 registros válidos — por isso existe o `sql/inserts/02_insert_extra_sprint3.sql`, que complementa a carga original até `TUTOR`, `CLINICA` e `PET` chegarem a 5 linhas cada. Trata 3 exceções distintas.

### Procedimento 2 — subtotal e total geral manuais

```txt
prc_rel_consultas_subtotal
```

Lê `CONSULTA` (tabela de fatos) categorizada por `CLINICA` (categoria 1) e `tipo_consulta` (categoria 2), com `valor` como coluna numérica. Calcula subtotal por clínica e total geral **manualmente**, acumulando em variáveis dentro de um cursor — sem `ROLLUP`, `CUBE`, `GROUPING SETS` ou `GROUPING`. Trata 3 exceções distintas.

> Pra fechar a entrega da Sprint 3, tire prints da execução de cada uma dessas 4 peças (incluindo pelo menos um caso de exceção de cada, já deixados prontos nos blocos de teste dos próprios arquivos `.sql`) para o PDF de documentação técnica exigido pela rubrica.

---

## Integração com Java

A API Java será responsável pela regra principal do sistema, incluindo:

- Autenticação de tutor e clínica;
- Cadastro do tutor (pré-cadastro feito pela clínica) e ativação de conta;
- Cadastro de clínica;
- Cadastro de pet;
- Registro de leituras de sensores;
- Cálculo do score de saúde;
- Geração de alertas;
- Consulta do histórico longitudinal do pet.

Entidades esperadas na API Java:

```txt
Tutor
Clinica
Pet
Consulta
ProtocoloPreventivo
EventoPreventivo
DispositivoIot
LeituraSensor
AlertaSaude
ScoreSaude
```

> A entidade JPA deve se chamar `Tutor`, mapeada para a tabela `tutor`, com a coluna de PK `id_tutor`.

---

## Integração com .NET

A API .NET será usada como base para o dashboard da clínica (B2B).

Ela poderá consultar:

- Pets da clínica;
- Pets em risco;
- Alertas abertos;
- Consultas realizadas;
- Eventos preventivos;
- Scores de saúde;
- Métricas por clínica.

O cadastro de clínica é feito direto pelo .NET via EF Core. O cadastro de tutor é feito via chamada HTTP para a API Java, para não duplicar regra de negócio.

Entidades principais esperadas na API .NET:

```txt
Clinica
Pet
Consulta
EventoPreventivo
LeituraColeira
LeituraComedouro
LeituraAmbiente
AlertaSaude
ScoreSaude
```

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

### 17. Criar procedures de relatório da rubrica Sprint 3

```txt
sql/procedures/04_procedures_relatorios_sprint3.sql
```

Cria `prc_rel_pets_tutor_clinica_json` (Procedimento 1 — JOIN + JSON) e `prc_rel_consultas_subtotal` (Procedimento 2 — subtotal e total geral manuais). Já executa e imprime os dois no final do script.

### 18. Executar relatórios com joins

```txt
sql/relatorios/01_joins_group_order.sql
```

Executa relatórios com `JOIN`, `GROUP BY` e `ORDER BY`.

### 19. Executar relatório LAG/LEAD

```txt
sql/relatorios/02_lag_lead.sql
```

Mostra valor anterior, atual e próximo de leituras da coleira (nível de bateria).

### 20. Executar relatórios com cursores

```txt
sql/relatorios/03_cursores.sql
```

Executa relatórios com cursores explícitos e tomada de decisão.

---

## Como Executar no SQL Developer

1. Abra o Oracle SQL Developer.
2. Conecte-se ao banco Oracle.
3. Abra cada arquivo `.sql` na ordem correta.
4. Selecione todo o conteúdo do arquivo (`Ctrl+A`) e execute usando **F5** (Run Script) — não use `Ctrl+Enter` (Run Statement), que roda só a instrução onde o cursor está.
5. Verifique a aba `Script Output` (não `Query Result`) e confira que não apareceu nenhum `ORA-`.
6. Só então avance para o próximo arquivo.

Consulta para verificar erros:

```sql
SELECT *
FROM LOG_ERROS;
```

Se a consulta não retornar registros, significa que a carga foi executada sem erros.

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
EXEC prc_ins_tutor('Teste Final', 'teste.final@petcare.com', '11988887777', '11122233344');
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

O script de inserts cria dados iniciais para testar o banco.

São cadastrados:

```txt
3 tutores
2 clínicas
3 pets
4 protocolos preventivos
5 consultas
5 eventos preventivos
4 dispositivos IoT
10 leituras de sensores (7 coleira + 2 comedouro + 1 ambiente)
3 scores de saúde
alertas gerados automaticamente
```

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

## Evidências de Execução

Durante os testes, foram validados:

```txt
12 tabelas criadas (11 + AUDITORIA_TUTOR)
12 sequences criadas (11 + seq_auditoria_tutor)
15 índices criados
DEFAULT seq_xxx.NEXTVAL aplicado/corrigido nas 11 colunas de PK
1 procedure de log criada
1 procedure de cadastro de tutor criada
9 procedures de carga criadas
1 trigger de auditoria criado e validado (INSERT/UPDATE/DELETE)
2 functions de negócio criadas (idade do pet, score médio)
2 functions da rubrica Sprint 3 criadas (JSON manual, validação de senha)
2 procedures da rubrica Sprint 3 criadas (JOIN+JSON, subtotal/total geral manual)
Dados de teste inseridos com sucesso
Relatórios executados com sucesso
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

> O modelo no Data Modeler ainda precisa ser atualizado para refletir o rename `TUTOR` e os novos campos/objetos (auth, trigger, functions).

---

## 👥 Integrantes da Equipe

| Nome                           | RM     | Turma  | GitHub                                        | LinkedIn                                                            |
| ------------------------------- | ------ | ------ | ----------------------------------------------- | ---------------------------------------------------------------------- |
| Alexander Dennis Isidro Mamani | 565554 | 2TDSPG | [alex-isidro](https://github.com/alex-isidro) | [LinkedIn](https://www.linkedin.com/in/alexander-dennis-a3b48824b/) |
| Kelson Zhang                   | 563748 | 2TDSPG | [KelsonZh0](https://github.com/KelsonZh0)     | [LinkedIn](https://www.linkedin.com/in/kelson-zhang-211456323/)     |

---

## Status do Projeto

```txt
Banco de dados: concluído para Sprint 3
Rename RESPONSAVEL -> TUTOR: concluído
Campos de autenticação (senha_hash / status_acesso): concluído
Trigger de auditoria: concluído e validado
Functions de negócio: concluídas
Rubrica oficial Sprint 3 (2 procedures + 2 functions específicas): concluída
Scripts SQL: concluídos
Carga de teste: concluída
Relatórios: concluídos
Integração Java/.NET: próxima etapa
```
