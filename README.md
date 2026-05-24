# PetCare Hub — Banco de Dados Oracle

Projeto de banco de dados relacional desenvolvido para o Challenge FIAP 2026 — CLYVO VET.

A proposta do PetCare Hub é apoiar a jornada contínua de cuidado do pet, armazenando dados de responsavel, clínicas, pets, consultas, protocolos preventivos, dispositivos IoT, leituras de sensores, alertas de saúde e score de saúde.

O banco foi modelado para servir como base para as APIs Java e .NET do projeto.

---

## Objetivo

O banco de dados tem como objetivo centralizar as informações do ecossistema PetCare Hub, permitindo:

- Cadastro do responsavel, clínicas e pets;
- Registro de consultas veterinárias;
- Controle de protocolos e eventos preventivos;
- Armazenamento de leituras vindas de dispositivos IoT;
- Geração de alertas de saúde;
- Registro do score de saúde do pet;
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
│   │   └── 04_add_defaults_sequences.sql
│   ├── inserts
│   │   └── 01_insert_testes.sql
│   ├── procedures
│   │   ├── 01_log_erros.sql
│   │   └── 02_procedures_carga.sql
│   └── relatorios
│       ├── 01_joins_group_order.sql
│       ├── 02_lag_lead.sql
│       └── 03_cursores.sql
└── README.md
```

---

## Modelo de Dados

O banco possui 11 tabelas principais:

| Tabela                 | Descrição                                              |
| ---------------------- | ------------------------------------------------------ |
| `RESPONSAVEL`          | Armazena os responsavel pelos pets                     |
| `CLINICA`              | Armazena as clínicas veterinárias parceiras            |
| `PET`                  | Armazena os dados dos animais acompanhados             |
| `CONSULTA`             | Armazena o histórico de consultas clínicas             |
| `PROTOCOLO_PREVENTIVO` | Armazena regras preventivas por espécie e raça         |
| `EVENTO_PREVENTIVO`    | Armazena eventos como vacinas, check-ups e retornos    |
| `DISPOSITIVO_IOT`      | Armazena dispositivos vinculados aos pets              |
| `LEITURA_SENSOR`       | Armazena dados coletados por sensores IoT              |
| `ALERTA_SAUDE`         | Armazena alertas gerados por risco                     |
| `SCORE_SAUDE`          | Armazena o score de saúde calculado do pet             |
| `LOG_ERROS`            | Armazena erros gerados durante execução das procedures |

---

## Relacionamentos Principais

```txt
RESPONSAVEL 1:N PET

CLINICA 1:N PET

PET 1:N CONSULTA
CLINICA 1:N CONSULTA

PET 1:N EVENTO_PREVENTIVO
PROTOCOLO_PREVENTIVO 1:N EVENTO_PREVENTIVO

PET 1:N DISPOSITIVO_IOT
DISPOSITIVO_IOT 1:N LEITURA_SENSOR
PET 1:N LEITURA_SENSOR

PET 1:N ALERTA_SAUDE
LEITURA_SENSOR 0:N ALERTA_SAUDE

PET 1:N SCORE_SAUDE
```

---

## Integração com Java

A API Java será responsável pela regra principal do sistema, incluindo:

- Cadastro do responsavel;
- Cadastro de clínica;
- Cadastro de pet;
- Registro de leituras de sensores;
- Cálculo do score de saúde;
- Geração de alertas;
- Consulta do histórico longitudinal do pet.

Entidades esperadas na API Java:

```txt
Responsavel
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

---

## Integração com .NET

A API .NET será usada como base para o dashboard da clínica.

Ela poderá consultar:

- Pets da clínica;
- Pets em risco;
- Alertas abertos;
- Consultas realizadas;
- Eventos preventivos;
- Scores de saúde;
- Métricas por clínica.

Entidades principais esperadas na API .NET:

```txt
Clinica
Pet
Consulta
EventoPreventivo
LeituraSensor
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

Cria as 11 tabelas principais do banco.

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

> Esse passo precisa ser executado depois das tabelas e das sequences, pois faz `ALTER TABLE ... MODIFY ... DEFAULT seq_xxx.NEXTVAL` em cada coluna PK.

### 5. Criar procedure de log

```txt
sql/procedures/01_log_erros.sql
```

Cria a procedure `PRC_REGISTRAR_LOG_ERRO`, responsável por salvar erros na tabela `LOG_ERROS`.

### 6. Criar procedures de carga

```txt
sql/procedures/02_procedures_carga.sql
```

Cria as procedures de inserção de dados por parâmetro.

### 7. Inserir dados de teste

```txt
sql/inserts/01_insert_testes.sql
```

Executa a carga inicial de dados usando as procedures.

### 8. Executar relatórios com joins

```txt
sql/relatorios/01_joins_group_order.sql
```

Executa relatórios com `JOIN`, `GROUP BY` e `ORDER BY`.

### 9. Executar relatório LAG/LEAD

```txt
sql/relatorios/02_lag_lead.sql
```

Mostra valor anterior, atual e próximo de leituras do sensor.

### 10. Executar relatórios com cursores

```txt
sql/relatorios/03_cursores.sql
```

Executa relatórios com cursores explícitos e tomada de decisão.

---

## Como Executar no SQL Developer

1. Abra o Oracle SQL Developer.
2. Conecte-se ao banco Oracle.
3. Abra cada arquivo `.sql` na ordem correta.
4. Execute usando `F5`, para rodar como script.
5. Verifique a aba `Script Output`.
6. Confirme se não existem erros na tabela `LOG_ERROS`.

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
    'RESPONSAVEL', 'CLINICA', 'PET', 'CONSULTA',
    'PROTOCOLO_PREVENTIVO', 'EVENTO_PREVENTIVO',
    'DISPOSITIVO_IOT', 'LEITURA_SENSOR',
    'ALERTA_SAUDE', 'SCORE_SAUDE', 'LOG_ERROS'
  )
ORDER BY table_name;
```

Cada linha deve mostrar `seq_xxx.NEXTVAL` na coluna `DATA_DEFAULT`.

---

## Validações e Constraints

O banco utiliza constraints para garantir integridade dos dados.

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

---

## Procedures Criadas

### Procedure de log

```txt
PRC_REGISTRAR_LOG_ERRO
```

Responsável por registrar erros na tabela `LOG_ERROS`.

### Procedures de carga

```txt
PRC_INS_RESPONSAVEL
PRC_INS_CLINICA
PRC_INS_PET
PRC_INS_CONSULTA
PRC_INS_PROTOCOLO_PREVENTIVO
PRC_INS_EVENTO_PREVENTIVO
PRC_INS_DISPOSITIVO_IOT
PRC_INS_ALERTA_SAUDE
PRC_INS_LEITURA_SENSOR
PRC_INS_SCORE_SAUDE
```

As procedures recebem dados por parâmetro e possuem tratamento de exceções.

---

## Regras Automáticas Implementadas

Algumas procedures possuem regras de negócio simples para simular o funcionamento do PetCare Hub.

### Leitura de nível de ração

Quando uma leitura do tipo `NIVEL_RACAO` possui valor menor que `20`, o sistema gera um alerta automático:

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

---

## Dados de Teste

O script de inserts cria dados iniciais para testar o banco.

São cadastrados:

```txt
3 responsavel
2 clínicas
3 pets
4 protocolos preventivos
5 consultas
5 eventos preventivos
4 dispositivos IoT
10 leituras de sensores
3 scores de saúde
alertas gerados automaticamente
```

Após executar a carga, é possível conferir os totais com:

```sql
SELECT 'RESPONSAVEL' AS tabela, COUNT(*) AS total FROM RESPONSAVEL
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
SELECT 'LEITURA_SENSOR', COUNT(*) FROM LEITURA_SENSOR
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
Total de pets por clínica e espécie
Total de consultas por clínica e tipo
Média de score por clínica
Alertas abertos por clínica e nível
Eventos preventivos por pet e status
Leituras por pet e tipo
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
11 tabelas criadas
11 sequences criadas
15 índices criados
DEFAULT seq_xxx.NEXTVAL aplicado nas 11 colunas de PK
1 procedure de log criada
10 procedures de carga criadas
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

---

## 👥 Integrantes da Equipe

| Nome                           | RM     | Turma  | GitHub                                        | LinkedIn                                                            |
| ------------------------------ | ------ | ------ | --------------------------------------------- | ------------------------------------------------------------------- |
| Alexander Dennis Isidro Mamani | 565554 | 2TDSPG | [alex-isidro](https://github.com/alex-isidro) | [LinkedIn](https://www.linkedin.com/in/alexander-dennis-a3b48824b/) |
| Kelson Zhang                   | 563748 | 2TDSPG | [KelsonZh0](https://github.com/KelsonZh0)     | [LinkedIn](https://www.linkedin.com/in/kelson-zhang-211456323/)     |

---

## Status do Projeto

```txt
Banco de dados: concluído para Sprint 1
Scripts SQL: concluídos
Carga de teste: concluída
Relatórios: concluídos
Integração Java/.NET: próxima etapa
```