------------------------------------------------------------------------------
-- PETCARE HUB - SCRIPT COMPLETO E CONSOLIDADO
-- Challenge FIAP 2026 - CLYVO VET
--
-- Este arquivo junta, na ordem correta de execucao, todos os
-- scripts individuais do projeto (pasta sql/), para facilitar
-- a entrega e a correcao. Rode do inicio ao fim em um schema
-- Oracle vazio (F5 - Run Script), conferindo a aba "Script
-- Output" apos cada bloco.
--
-- Os arquivos originais continuam em sql/ddl, sql/procedures,
-- sql/triggers, sql/functions, sql/inserts e sql/relatorios,
-- caso seja necessario executar/conferir um passo isoladamente.
--
-- ORDEM:
--  1. sql/ddl/01_create_tables.sql
--  2. sql/ddl/02_create_sequences.sql
--  3. sql/ddl/03_create_indexes.sql
--  4. sql/ddl/04_add_defaults_sequences.sql
--  5. sql/ddl/05_rename_responsavel_to_tutor.sql
--  6. sql/ddl/06_add_auth_fields.sql
--  7. sql/ddl/07_fix_defaults_sequences.sql
--  8. sql/ddl/08_split_leitura_sensor.sql
--  9. sql/procedures/01_log_erros.sql
-- 10. sql/procedures/03_prc_ins_tutor.sql
-- 11. sql/procedures/02_procedures_carga.sql
-- 12. sql/triggers/01_trg_auditoria_tutor.sql
-- 13. sql/functions/01_functions.sql
-- 14. sql/functions/02_functions_json_senha.sql
-- 15. sql/inserts/01_insert_testes.sql
-- 16. sql/inserts/02_insert_extra_sprint3.sql
-- 17. sql/inserts/03_insert_complemento_carga.sql
-- 18. sql/procedures/04_procedures_relatorios_sprint3.sql
-- 19. sql/relatorios/01_joins_group_order.sql
-- 20. sql/relatorios/02_lag_lead.sql
-- 21. sql/relatorios/03_cursores.sql
------------------------------------------------------------------------------

SET SERVEROUTPUT ON;

-- ================================================================================
-- PASSO 1/21 - sql/ddl/01_create_tables.sql
-- Cria as 11 tabelas principais do banco (com o nome original RESPONSAVEL)
-- ================================================================================

------------------------------------------------------------
-- PETCARE HUB - CREATE TABLES
-- Challenge CLYVO VET
-- Banco base para Java + .NET
------------------------------------------------------------

------------------------------------------------------------
-- LIMPEZA OPCIONAL
-- Execute essa parte se quiser apagar e recriar as tabelas.
--
-- Cobre tambem os nomes que so existem depois de outros
-- scripts rodarem (TUTOR e AUDITORIA_TUTOR apos o rename do
-- passo 5/12, LEITURA_COLEIRA/COMEDOURO/AMBIENTE apos o split
-- do passo 8), para que este script sozinho consiga resetar o
-- banco do zero em qualquer "geracao" do schema, sem depender
-- de rodar sql/00_limpeza_schema_compartilhado.sql antes.
--
-- Tambem dropa direto os indices PK_RESPONSAVEL/UK_RESPONSAVEL_*
-- que ficam orfaos quando TUTOR ja existe: ALTER TABLE ...
-- RENAME CONSTRAINT renomeia a constraint mas NAO renomeia o
-- indice que a sustenta, entao ele sobrevive com o nome antigo
-- e bloqueia um novo CREATE TABLE RESPONSAVEL (ORA-00955) se
-- nao for removido aqui.
------------------------------------------------------------

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE AUDITORIA_TUTOR CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TUTOR CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX PK_RESPONSAVEL';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX UK_RESPONSAVEL_EMAIL';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX UK_RESPONSAVEL_CPF';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE LEITURA_COLEIRA CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE LEITURA_COMEDOURO CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE LEITURA_AMBIENTE CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE ALERTA_SAUDE CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE SCORE_SAUDE CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE LEITURA_SENSOR CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE DISPOSITIVO_IOT CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE EVENTO_PREVENTIVO CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE PROTOCOLO_PREVENTIVO CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE CONSULTA CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE PET CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE CLINICA CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE RESPONSAVEL CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE LOG_ERROS CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

------------------------------------------------------------
-- 1. RESPONSAVEL
------------------------------------------------------------

CREATE TABLE RESPONSAVEL (
    id_responsavel  NUMBER(10)      NOT NULL,
    nome           VARCHAR2(100)   NOT NULL,
    email          VARCHAR2(120)   NOT NULL,
    telefone       VARCHAR2(20),
    cpf            VARCHAR2(11),
    data_cadastro  DATE            DEFAULT SYSDATE NOT NULL,
    ativo          CHAR(1)         DEFAULT 'S' NOT NULL,

    CONSTRAINT pk_responsavel PRIMARY KEY (id_responsavel),
    CONSTRAINT uk_responsavel_email UNIQUE (email),
    CONSTRAINT uk_responsavel_cpf UNIQUE (cpf),
    CONSTRAINT ck_responsavel_ativo CHECK (ativo IN ('S', 'N'))
);

------------------------------------------------------------
-- 2. CLINICA
------------------------------------------------------------

CREATE TABLE CLINICA (
    id_clinica     NUMBER(10)      NOT NULL,
    nome           VARCHAR2(120)   NOT NULL,
    cnpj           VARCHAR2(14)    NOT NULL,
    email          VARCHAR2(120),
    telefone       VARCHAR2(20),
    endereco       VARCHAR2(200),
    ativo          CHAR(1)         DEFAULT 'S' NOT NULL,

    CONSTRAINT pk_clinica PRIMARY KEY (id_clinica),
    CONSTRAINT uk_clinica_cnpj UNIQUE (cnpj),
    CONSTRAINT ck_clinica_ativo CHECK (ativo IN ('S', 'N'))
);

------------------------------------------------------------
-- 3. PET
------------------------------------------------------------

CREATE TABLE PET (
    id_pet              NUMBER(10)      NOT NULL,
    id_responsavel      NUMBER(10)      NOT NULL,
    id_clinica          NUMBER(10)      NOT NULL,
    nome                VARCHAR2(80)    NOT NULL,
    especie             VARCHAR2(20)    NOT NULL,
    raca                VARCHAR2(80),
    data_nascimento     DATE,
    peso_kg             NUMBER(5,2)     NOT NULL,
    sexo                CHAR(1),
    condicoes_cronicas  VARCHAR2(300),
    data_cadastro       DATE            DEFAULT SYSDATE NOT NULL,
    ativo               CHAR(1)         DEFAULT 'S' NOT NULL,

    CONSTRAINT pk_pet PRIMARY KEY (id_pet),

    CONSTRAINT fk_pet_responsavel FOREIGN KEY (id_responsavel)
        REFERENCES RESPONSAVEL (id_responsavel),

    CONSTRAINT fk_pet_clinica FOREIGN KEY (id_clinica)
        REFERENCES CLINICA (id_clinica),

    CONSTRAINT ck_pet_especie CHECK (especie IN ('CAO', 'GATO', 'OUTRO')),
    CONSTRAINT ck_pet_peso CHECK (peso_kg > 0),
    CONSTRAINT ck_pet_sexo CHECK (sexo IN ('M', 'F')),
    CONSTRAINT ck_pet_ativo CHECK (ativo IN ('S', 'N'))
);

------------------------------------------------------------
-- 4. CONSULTA
------------------------------------------------------------

CREATE TABLE CONSULTA (
    id_consulta          NUMBER(10)      NOT NULL,
    id_pet               NUMBER(10)      NOT NULL,
    id_clinica           NUMBER(10)      NOT NULL,
    data_consulta        DATE            NOT NULL,
    tipo_consulta        VARCHAR2(30)    NOT NULL,
    descricao            VARCHAR2(500),
    diagnostico          VARCHAR2(500),
    valor                NUMBER(10,2),
    retorno_recomendado  CHAR(1)         DEFAULT 'N' NOT NULL,
    data_retorno         DATE,

    CONSTRAINT pk_consulta PRIMARY KEY (id_consulta),

    CONSTRAINT fk_consulta_pet FOREIGN KEY (id_pet)
        REFERENCES PET (id_pet),

    CONSTRAINT fk_consulta_clinica FOREIGN KEY (id_clinica)
        REFERENCES CLINICA (id_clinica),

    CONSTRAINT ck_consulta_tipo CHECK (
        tipo_consulta IN ('CHECKUP', 'VACINA', 'EMERGENCIA', 'RETORNO', 'EXAME')
    ),

    CONSTRAINT ck_consulta_retorno CHECK (retorno_recomendado IN ('S', 'N')),
    CONSTRAINT ck_consulta_valor CHECK (valor IS NULL OR valor >= 0)
);

------------------------------------------------------------
-- 5. PROTOCOLO_PREVENTIVO
------------------------------------------------------------

CREATE TABLE PROTOCOLO_PREVENTIVO (
    id_protocolo              NUMBER(10)      NOT NULL,
    especie                   VARCHAR2(20)    NOT NULL,
    raca                      VARCHAR2(80),
    tipo_evento               VARCHAR2(30)    NOT NULL,
    descricao                 VARCHAR2(300)   NOT NULL,
    idade_meses_recomendada   NUMBER(3),
    intervalo_dias            NUMBER(5),
    ativo                     CHAR(1)         DEFAULT 'S' NOT NULL,

    CONSTRAINT pk_protocolo_preventivo PRIMARY KEY (id_protocolo),

    CONSTRAINT ck_protocolo_especie CHECK (especie IN ('CAO', 'GATO', 'OUTRO')),

    CONSTRAINT ck_protocolo_tipo CHECK (
        tipo_evento IN ('VACINA', 'CHECKUP', 'VERMIFUGO', 'RETORNO')
    ),

    CONSTRAINT ck_protocolo_idade CHECK (
        idade_meses_recomendada IS NULL OR idade_meses_recomendada >= 0
    ),

    CONSTRAINT ck_protocolo_intervalo CHECK (
        intervalo_dias IS NULL OR intervalo_dias > 0
    ),

    CONSTRAINT ck_protocolo_ativo CHECK (ativo IN ('S', 'N'))
);

------------------------------------------------------------
-- 6. EVENTO_PREVENTIVO
------------------------------------------------------------

CREATE TABLE EVENTO_PREVENTIVO (
    id_evento         NUMBER(10)      NOT NULL,
    id_pet            NUMBER(10)      NOT NULL,
    id_protocolo      NUMBER(10),
    tipo_evento       VARCHAR2(30)    NOT NULL,
    descricao         VARCHAR2(300)   NOT NULL,
    data_prevista     DATE            NOT NULL,
    data_realizacao   DATE,
    status            VARCHAR2(20)    DEFAULT 'PENDENTE' NOT NULL,

    CONSTRAINT pk_evento_preventivo PRIMARY KEY (id_evento),

    CONSTRAINT fk_evento_pet FOREIGN KEY (id_pet)
        REFERENCES PET (id_pet),

    CONSTRAINT fk_evento_protocolo FOREIGN KEY (id_protocolo)
        REFERENCES PROTOCOLO_PREVENTIVO (id_protocolo),

    CONSTRAINT ck_evento_tipo CHECK (
        tipo_evento IN ('VACINA', 'CHECKUP', 'VERMIFUGO', 'RETORNO')
    ),

    CONSTRAINT ck_evento_status CHECK (
        status IN ('PENDENTE', 'REALIZADO', 'ATRASADO', 'CANCELADO')
    )
);

------------------------------------------------------------
-- 7. DISPOSITIVO_IOT
------------------------------------------------------------

CREATE TABLE DISPOSITIVO_IOT (
    id_dispositivo    NUMBER(10)      NOT NULL,
    id_pet            NUMBER(10)      NOT NULL,
    tipo_dispositivo  VARCHAR2(30)    NOT NULL,
    codigo_serie      VARCHAR2(80)    NOT NULL,
    data_ativacao     DATE            DEFAULT SYSDATE NOT NULL,
    ativo             CHAR(1)         DEFAULT 'S' NOT NULL,

    CONSTRAINT pk_dispositivo_iot PRIMARY KEY (id_dispositivo),

    CONSTRAINT fk_dispositivo_pet FOREIGN KEY (id_pet)
        REFERENCES PET (id_pet),

    CONSTRAINT uk_dispositivo_codigo UNIQUE (codigo_serie),

    CONSTRAINT ck_dispositivo_tipo CHECK (
        tipo_dispositivo IN ('COLEIRA', 'COMEDOURO', 'AMBIENTE')
    ),

    CONSTRAINT ck_dispositivo_ativo CHECK (ativo IN ('S', 'N'))
);

------------------------------------------------------------
-- 8. LEITURA_SENSOR
------------------------------------------------------------

CREATE TABLE LEITURA_SENSOR (
    id_leitura       NUMBER(10)      NOT NULL,
    id_pet           NUMBER(10)      NOT NULL,
    id_dispositivo   NUMBER(10)      NOT NULL,
    tipo_leitura     VARCHAR2(40)    NOT NULL,
    valor            NUMBER(10,2)    NOT NULL,
    unidade          VARCHAR2(20)    NOT NULL,
    data_leitura     TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    status_leitura   VARCHAR2(20)    DEFAULT 'NORMAL' NOT NULL,

    CONSTRAINT pk_leitura_sensor PRIMARY KEY (id_leitura),

    CONSTRAINT fk_leitura_pet FOREIGN KEY (id_pet)
        REFERENCES PET (id_pet),

    CONSTRAINT fk_leitura_dispositivo FOREIGN KEY (id_dispositivo)
        REFERENCES DISPOSITIVO_IOT (id_dispositivo),

    CONSTRAINT ck_leitura_tipo CHECK (
        tipo_leitura IN (
            'ATIVIDADE',
            'NIVEL_RACAO',
            'PESO_CONSUMIDO',
            'TEMPERATURA_AMBIENTE',
            'UMIDADE',
            'QUALIDADE_AR'
        )
    ),

    CONSTRAINT ck_leitura_status CHECK (
        status_leitura IN ('NORMAL', 'ATENCAO', 'CRITICO')
    )
);

------------------------------------------------------------
-- 9. ALERTA_SAUDE
------------------------------------------------------------

CREATE TABLE ALERTA_SAUDE (
    id_alerta          NUMBER(10)      NOT NULL,
    id_pet             NUMBER(10)      NOT NULL,
    id_leitura         NUMBER(10),
    tipo_alerta        VARCHAR2(40)    NOT NULL,
    nivel_alerta       VARCHAR2(20)    NOT NULL,
    mensagem           VARCHAR2(300)   NOT NULL,
    valor_detectado    NUMBER(10,2),
    limite_referencia  NUMBER(10,2),
    resolvido          CHAR(1)         DEFAULT 'N' NOT NULL,
    data_alerta        TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    data_resolucao     TIMESTAMP,

    CONSTRAINT pk_alerta_saude PRIMARY KEY (id_alerta),

    CONSTRAINT fk_alerta_pet FOREIGN KEY (id_pet)
        REFERENCES PET (id_pet),

    CONSTRAINT fk_alerta_leitura FOREIGN KEY (id_leitura)
        REFERENCES LEITURA_SENSOR (id_leitura),

    CONSTRAINT ck_alerta_nivel CHECK (
        nivel_alerta IN ('BAIXO', 'MEDIO', 'ALTO', 'CRITICO')
    ),

    CONSTRAINT ck_alerta_resolvido CHECK (resolvido IN ('S', 'N'))
);

------------------------------------------------------------
-- 10. SCORE_SAUDE
------------------------------------------------------------

CREATE TABLE SCORE_SAUDE (
    id_score            NUMBER(10)    NOT NULL,
    id_pet              NUMBER(10)    NOT NULL,
    score_total         NUMBER(3)     NOT NULL,
    score_atividade     NUMBER(3)     NOT NULL,
    score_alimentacao   NUMBER(3)     NOT NULL,
    score_ambiente      NUMBER(3)     NOT NULL,
    score_consulta      NUMBER(3)     NOT NULL,
    score_preventivo    NUMBER(3)     NOT NULL,
    categoria           VARCHAR2(20)  NOT NULL,
    data_calculo        TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,

    CONSTRAINT pk_score_saude PRIMARY KEY (id_score),

    CONSTRAINT fk_score_pet FOREIGN KEY (id_pet)
        REFERENCES PET (id_pet),

    CONSTRAINT ck_score_total CHECK (score_total BETWEEN 0 AND 100),
    CONSTRAINT ck_score_atividade CHECK (score_atividade BETWEEN 0 AND 100),
    CONSTRAINT ck_score_alimentacao CHECK (score_alimentacao BETWEEN 0 AND 100),
    CONSTRAINT ck_score_ambiente CHECK (score_ambiente BETWEEN 0 AND 100),
    CONSTRAINT ck_score_consulta CHECK (score_consulta BETWEEN 0 AND 100),
    CONSTRAINT ck_score_preventivo CHECK (score_preventivo BETWEEN 0 AND 100),

    CONSTRAINT ck_score_categoria CHECK (
        categoria IN ('VERDE', 'AMARELO', 'VERMELHO')
    )
);

------------------------------------------------------------
-- 11. LOG_ERROS
------------------------------------------------------------

CREATE TABLE LOG_ERROS (
    id_log           NUMBER(10)      NOT NULL,
    nome_procedure   VARCHAR2(100)   NOT NULL,
    nome_usuario     VARCHAR2(100)   NOT NULL,
    data_ocorrencia  TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    codigo_erro      NUMBER          NOT NULL,
    mensagem_erro    VARCHAR2(1000)  NOT NULL,

    CONSTRAINT pk_log_erros PRIMARY KEY (id_log)
);

------------------------------------------------------------
-- TESTE FINAL: LISTAR TABELAS CRIADAS
------------------------------------------------------------

SELECT table_name
FROM user_tables
WHERE table_name IN (
    'RESPONSAVEL',
    'CLINICA',
    'PET',
    'CONSULTA',
    'PROTOCOLO_PREVENTIVO',
    'EVENTO_PREVENTIVO',
    'DISPOSITIVO_IOT',
    'LEITURA_SENSOR',
    'ALERTA_SAUDE',
    'SCORE_SAUDE',
    'LOG_ERROS'
)
ORDER BY table_name;

-- ================================================================================
-- PASSO 2/21 - sql/ddl/02_create_sequences.sql
-- Cria as sequences utilizadas para gerar os IDs das tabelas
-- ================================================================================

------------------------------------------------------------
-- PETCARE HUB - CREATE SEQUENCES
-- Sequences para gerar IDs das tabelas
------------------------------------------------------------

------------------------------------------------------------
-- LIMPEZA OPCIONAL
-- Remove as sequences caso já existam
--
-- Cobre tambem seq_tutor e seq_auditoria_tutor (nomes que so
-- existem apos o rename/trigger rodarem em execucoes
-- anteriores) e as sequences de leitura splitadas, para o
-- script conseguir resetar do zero em qualquer "geracao" do
-- schema sem deixar `RENAME seq_responsavel TO seq_tutor` do
-- passo 5 falhar com ORA-00955 por causa de um seq_tutor
-- orfao de uma execucao anterior.
------------------------------------------------------------

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_tutor';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_auditoria_tutor';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_leitura_coleira';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_leitura_comedouro';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_leitura_ambiente';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_responsavel';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_clinica';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_pet';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_consulta';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_protocolo_preventivo';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_evento_preventivo';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_dispositivo_iot';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_leitura_sensor';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_alerta_saude';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_score_saude';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_log_erros';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

------------------------------------------------------------
-- CRIAÇÃO DAS SEQUENCES
------------------------------------------------------------

CREATE SEQUENCE seq_responsavel
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE seq_clinica
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE seq_pet
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE seq_consulta
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE seq_protocolo_preventivo
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE seq_evento_preventivo
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE seq_dispositivo_iot
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE seq_leitura_sensor
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE seq_alerta_saude
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE seq_score_saude
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE seq_log_erros
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

------------------------------------------------------------
-- TESTE FINAL: LISTAR SEQUENCES CRIADAS
------------------------------------------------------------

SELECT sequence_name
FROM user_sequences
WHERE sequence_name IN (
    'SEQ_RESPONSAVEL',
    'SEQ_CLINICA',
    'SEQ_PET',
    'SEQ_CONSULTA',
    'SEQ_PROTOCOLO_PREVENTIVO',
    'SEQ_EVENTO_PREVENTIVO',
    'SEQ_DISPOSITIVO_IOT',
    'SEQ_LEITURA_SENSOR',
    'SEQ_ALERTA_SAUDE',
    'SEQ_SCORE_SAUDE',
    'SEQ_LOG_ERROS'
)
ORDER BY sequence_name;

-- ================================================================================
-- PASSO 3/21 - sql/ddl/03_create_indexes.sql
-- Cria índices auxiliares para FKs e filtros frequentes
-- ================================================================================

------------------------------------------------------------
-- PETCARE HUB - CREATE INDEXES
-- Índices auxiliares para melhorar buscas por FK e filtros
------------------------------------------------------------

------------------------------------------------------------
-- LIMPEZA OPCIONAL
-- Remove os índices caso já existam
------------------------------------------------------------

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX idx_pet_responsavel';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX idx_pet_clinica';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX idx_consulta_pet';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX idx_consulta_clinica';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX idx_evento_pet';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX idx_evento_protocolo';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX idx_dispositivo_pet';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX idx_leitura_pet';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX idx_leitura_dispositivo';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX idx_alerta_pet';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX idx_alerta_leitura';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX idx_score_pet';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX idx_alerta_resolvido';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX idx_evento_status';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX idx_score_categoria';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

------------------------------------------------------------
-- ÍNDICES DE RELACIONAMENTO
------------------------------------------------------------

CREATE INDEX idx_pet_responsavel
ON PET (id_responsavel);

CREATE INDEX idx_pet_clinica
ON PET (id_clinica);

CREATE INDEX idx_consulta_pet
ON CONSULTA (id_pet);

CREATE INDEX idx_consulta_clinica
ON CONSULTA (id_clinica);

CREATE INDEX idx_evento_pet
ON EVENTO_PREVENTIVO (id_pet);

CREATE INDEX idx_evento_protocolo
ON EVENTO_PREVENTIVO (id_protocolo);

CREATE INDEX idx_dispositivo_pet
ON DISPOSITIVO_IOT (id_pet);

CREATE INDEX idx_leitura_pet
ON LEITURA_SENSOR (id_pet);

CREATE INDEX idx_leitura_dispositivo
ON LEITURA_SENSOR (id_dispositivo);

CREATE INDEX idx_alerta_pet
ON ALERTA_SAUDE (id_pet);

CREATE INDEX idx_alerta_leitura
ON ALERTA_SAUDE (id_leitura);

CREATE INDEX idx_score_pet
ON SCORE_SAUDE (id_pet);

------------------------------------------------------------
-- ÍNDICES PARA FILTROS FREQUENTES
------------------------------------------------------------

CREATE INDEX idx_alerta_resolvido
ON ALERTA_SAUDE (resolvido);

CREATE INDEX idx_evento_status
ON EVENTO_PREVENTIVO (status);

CREATE INDEX idx_score_categoria
ON SCORE_SAUDE (categoria);

------------------------------------------------------------
-- TESTE FINAL: LISTAR ÍNDICES CRIADOS
------------------------------------------------------------

SELECT index_name, table_name
FROM user_indexes
WHERE index_name IN (
    'IDX_PET_RESPONSAVEL',
    'IDX_PET_CLINICA',
    'IDX_CONSULTA_PET',
    'IDX_CONSULTA_CLINICA',
    'IDX_EVENTO_PET',
    'IDX_EVENTO_PROTOCOLO',
    'IDX_DISPOSITIVO_PET',
    'IDX_LEITURA_PET',
    'IDX_LEITURA_DISPOSITIVO',
    'IDX_ALERTA_PET',
    'IDX_ALERTA_LEITURA',
    'IDX_SCORE_PET',
    'IDX_ALERTA_RESOLVIDO',
    'IDX_EVENTO_STATUS',
    'IDX_SCORE_CATEGORIA'
)
ORDER BY table_name, index_name;

-- ================================================================================
-- PASSO 4/21 - sql/ddl/04_add_defaults_sequences.sql
-- Adiciona DEFAULT seq_xxx.NEXTVAL em cada coluna de PK
-- ================================================================================

ALTER TABLE RESPONSAVEL          MODIFY id_responsavel  DEFAULT seq_responsavel.NEXTVAL;
ALTER TABLE CLINICA              MODIFY id_clinica      DEFAULT seq_clinica.NEXTVAL;
ALTER TABLE PET                  MODIFY id_pet          DEFAULT seq_pet.NEXTVAL;
ALTER TABLE CONSULTA             MODIFY id_consulta     DEFAULT seq_consulta.NEXTVAL;
ALTER TABLE PROTOCOLO_PREVENTIVO MODIFY id_protocolo    DEFAULT seq_protocolo_preventivo.NEXTVAL;
ALTER TABLE EVENTO_PREVENTIVO    MODIFY id_evento       DEFAULT seq_evento_preventivo.NEXTVAL;
ALTER TABLE DISPOSITIVO_IOT      MODIFY id_dispositivo  DEFAULT seq_dispositivo_iot.NEXTVAL;
ALTER TABLE LEITURA_SENSOR       MODIFY id_leitura      DEFAULT seq_leitura_sensor.NEXTVAL;
ALTER TABLE ALERTA_SAUDE         MODIFY id_alerta       DEFAULT seq_alerta_saude.NEXTVAL;
ALTER TABLE SCORE_SAUDE          MODIFY id_score        DEFAULT seq_score_saude.NEXTVAL;
ALTER TABLE LOG_ERROS            MODIFY id_log          DEFAULT seq_log_erros.NEXTVAL;

------------------------------------------------------------
-- TESTE: confere que os defaults foram aplicados
------------------------------------------------------------

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

-- ================================================================================
-- PASSO 5/21 - sql/ddl/05_rename_responsavel_to_tutor.sql
-- Renomeia RESPONSAVEL -> TUTOR (tabela, PK, constraints, FK, sequence)
-- ================================================================================

ALTER TABLE RESPONSAVEL RENAME TO TUTOR;

ALTER TABLE TUTOR RENAME COLUMN id_responsavel TO id_tutor;

ALTER TABLE TUTOR RENAME CONSTRAINT pk_responsavel TO pk_tutor;
ALTER TABLE TUTOR RENAME CONSTRAINT uk_responsavel_email TO uk_tutor_email;
ALTER TABLE TUTOR RENAME CONSTRAINT uk_responsavel_cpf TO uk_tutor_cpf;
ALTER TABLE TUTOR RENAME CONSTRAINT ck_responsavel_ativo TO ck_tutor_ativo;

-- PET referencia RESPONSAVEL via id_responsavel — só ela tem essa FK
ALTER TABLE PET RENAME COLUMN id_responsavel TO id_tutor;
ALTER TABLE PET RENAME CONSTRAINT fk_pet_responsavel TO fk_pet_tutor;

-- Sequence
RENAME seq_responsavel TO seq_tutor;

------------------------------------------------------------
-- TESTE: confirmar que ficou tudo certo
------------------------------------------------------------
SELECT table_name FROM user_tables WHERE table_name = 'TUTOR';
SELECT column_name FROM user_tab_columns WHERE table_name = 'PET' AND column_name = 'ID_TUTOR';
SELECT sequence_name FROM user_sequences WHERE sequence_name = 'SEQ_TUTOR';

-- ================================================================================
-- PASSO 6/21 - sql/ddl/06_add_auth_fields.sql
-- Adiciona senha_hash e status_acesso em TUTOR, e senha_hash em CLINICA
-- ================================================================================

------------------------------------------------------------
-- CAMPOS DE AUTENTICAÇÃO
------------------------------------------------------------

ALTER TABLE TUTOR ADD (
    senha_hash     VARCHAR2(255),
    status_acesso  VARCHAR2(20) DEFAULT 'PRE_CADASTRADO' NOT NULL
);

ALTER TABLE TUTOR ADD CONSTRAINT ck_tutor_status_acesso
    CHECK (status_acesso IN ('PRE_CADASTRADO', 'ATIVO', 'BLOQUEADO', 'INATIVO'));

ALTER TABLE CLINICA ADD (
    senha_hash VARCHAR2(255)
);

------------------------------------------------------------
-- TESTE
------------------------------------------------------------
SELECT column_name, data_type, nullable
FROM user_tab_columns
WHERE table_name = 'TUTOR' AND column_name IN ('SENHA_HASH', 'STATUS_ACESSO');

-- ================================================================================
-- PASSO 7/21 - sql/ddl/07_fix_defaults_sequences.sql
-- Reaplica DEFAULT seq_xxx.NEXTVAL apos o rename (passo 5 invalida o passo 4)
-- ================================================================================

ALTER TABLE TUTOR                MODIFY id_tutor        DEFAULT seq_tutor.NEXTVAL;
ALTER TABLE CLINICA              MODIFY id_clinica      DEFAULT seq_clinica.NEXTVAL;
ALTER TABLE PET                  MODIFY id_pet          DEFAULT seq_pet.NEXTVAL;
ALTER TABLE CONSULTA             MODIFY id_consulta     DEFAULT seq_consulta.NEXTVAL;
ALTER TABLE PROTOCOLO_PREVENTIVO MODIFY id_protocolo    DEFAULT seq_protocolo_preventivo.NEXTVAL;
ALTER TABLE EVENTO_PREVENTIVO    MODIFY id_evento       DEFAULT seq_evento_preventivo.NEXTVAL;
ALTER TABLE DISPOSITIVO_IOT      MODIFY id_dispositivo  DEFAULT seq_dispositivo_iot.NEXTVAL;
ALTER TABLE LEITURA_SENSOR       MODIFY id_leitura      DEFAULT seq_leitura_sensor.NEXTVAL;
ALTER TABLE ALERTA_SAUDE         MODIFY id_alerta       DEFAULT seq_alerta_saude.NEXTVAL;
ALTER TABLE SCORE_SAUDE          MODIFY id_score        DEFAULT seq_score_saude.NEXTVAL;
ALTER TABLE LOG_ERROS            MODIFY id_log          DEFAULT seq_log_erros.NEXTVAL;

SELECT table_name, column_name, data_default
FROM user_tab_columns
WHERE column_name LIKE 'ID\_%' ESCAPE '\'
  AND table_name IN (
    'TUTOR', 'CLINICA', 'PET', 'CONSULTA',
    'PROTOCOLO_PREVENTIVO', 'EVENTO_PREVENTIVO',
    'DISPOSITIVO_IOT', 'LEITURA_SENSOR',
    'ALERTA_SAUDE', 'SCORE_SAUDE', 'LOG_ERROS'
  )
ORDER BY table_name;

-- ================================================================================
-- PASSO 8/21 - sql/ddl/08_split_leitura_sensor.sql
-- Separa LEITURA_SENSOR em LEITURA_COLEIRA, LEITURA_COMEDOURO, LEITURA_AMBIENTE
-- ================================================================================

------------------------------------------------------------
-- PETCARE HUB - SEPARA LEITURA_SENSOR EM 3 TABELAS
-- Alinha o schema com as 3 entidades Java (LeituraColeira,
-- LeituraComedouro, LeituraAmbiente) em vez da tabela
-- genérica LEITURA_SENSOR (tipo_leitura/valor/unidade).
------------------------------------------------------------

------------------------------------------------------------
-- 1. Efeito colateral: ALERTA_SAUDE tinha FK obrigatória
-- para LEITURA_SENSOR. O Java nunca mapeou esse campo,
-- então o alerta passa a existir sem apontar para uma
-- leitura específica.
------------------------------------------------------------

BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE ALERTA_SAUDE DROP CONSTRAINT fk_alerta_leitura';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX idx_alerta_leitura';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE ALERTA_SAUDE DROP COLUMN id_leitura';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

------------------------------------------------------------
-- 2. Remove a tabela genérica antiga
------------------------------------------------------------

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE LEITURA_SENSOR CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_leitura_sensor';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

------------------------------------------------------------
-- 3. LEITURA_COLEIRA
------------------------------------------------------------

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE LEITURA_COLEIRA CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE LEITURA_COLEIRA (
    id_leitura_coleira  NUMBER(10)   NOT NULL,
    id_pet              NUMBER(10)   NOT NULL,
    status_atividade    VARCHAR2(30) NOT NULL,
    nivel_bateria       NUMBER(3)    NOT NULL,
    timestamp_leitura   TIMESTAMP    DEFAULT SYSTIMESTAMP NOT NULL,

    CONSTRAINT pk_leitura_coleira PRIMARY KEY (id_leitura_coleira),
    CONSTRAINT fk_leitura_coleira_pet FOREIGN KEY (id_pet) REFERENCES PET (id_pet),
    CONSTRAINT ck_leitura_coleira_status CHECK (
        status_atividade IN ('ATIVO', 'MODERADO', 'SEDENTARIO')
    ),
    CONSTRAINT ck_leitura_coleira_bateria CHECK (nivel_bateria BETWEEN 0 AND 100)
);

CREATE SEQUENCE seq_leitura_coleira START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
ALTER TABLE LEITURA_COLEIRA MODIFY id_leitura_coleira DEFAULT seq_leitura_coleira.NEXTVAL;

CREATE INDEX idx_leitura_coleira_pet ON LEITURA_COLEIRA (id_pet);

------------------------------------------------------------
-- 4. LEITURA_COMEDOURO
------------------------------------------------------------

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE LEITURA_COMEDOURO CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE LEITURA_COMEDOURO (
    id_leitura_comedouro  NUMBER(10)    NOT NULL,
    id_pet                NUMBER(10)    NOT NULL,
    nivel_racao_pct       NUMBER(3)     NOT NULL,
    peso_consumido_g      NUMBER(8,2)   NOT NULL,
    timestamp_leitura     TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,

    CONSTRAINT pk_leitura_comedouro PRIMARY KEY (id_leitura_comedouro),
    CONSTRAINT fk_leitura_comedouro_pet FOREIGN KEY (id_pet) REFERENCES PET (id_pet),
    CONSTRAINT ck_leitura_comedouro_racao CHECK (nivel_racao_pct BETWEEN 0 AND 100),
    CONSTRAINT ck_leitura_comedouro_peso CHECK (peso_consumido_g >= 0)
);

CREATE SEQUENCE seq_leitura_comedouro START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
ALTER TABLE LEITURA_COMEDOURO MODIFY id_leitura_comedouro DEFAULT seq_leitura_comedouro.NEXTVAL;

CREATE INDEX idx_leitura_comedouro_pet ON LEITURA_COMEDOURO (id_pet);

------------------------------------------------------------
-- 5. LEITURA_AMBIENTE
------------------------------------------------------------

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE LEITURA_AMBIENTE CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE LEITURA_AMBIENTE (
    id_leitura_ambiente   NUMBER(10)   NOT NULL,
    id_pet                NUMBER(10)   NOT NULL,
    temperatura_ambiente  NUMBER(5,2)  NOT NULL,
    umidade_pct           NUMBER(3)    NOT NULL,
    qualidade_ar_ppm      NUMBER(6)    NOT NULL,
    pet_presente          NUMBER(1)    NOT NULL,
    timestamp_leitura     TIMESTAMP    DEFAULT SYSTIMESTAMP NOT NULL,

    CONSTRAINT pk_leitura_ambiente PRIMARY KEY (id_leitura_ambiente),
    CONSTRAINT fk_leitura_ambiente_pet FOREIGN KEY (id_pet) REFERENCES PET (id_pet),
    CONSTRAINT ck_leitura_ambiente_umidade CHECK (umidade_pct BETWEEN 0 AND 100),
    CONSTRAINT ck_leitura_ambiente_ar CHECK (qualidade_ar_ppm >= 0),
    CONSTRAINT ck_leitura_ambiente_presente CHECK (pet_presente IN (0,1))
);

CREATE SEQUENCE seq_leitura_ambiente START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
ALTER TABLE LEITURA_AMBIENTE MODIFY id_leitura_ambiente DEFAULT seq_leitura_ambiente.NEXTVAL;

CREATE INDEX idx_leitura_ambiente_pet ON LEITURA_AMBIENTE (id_pet);

------------------------------------------------------------
-- TESTE FINAL: confirma que as 3 tabelas novas existem
-- e que LEITURA_SENSOR sumiu
------------------------------------------------------------

SELECT table_name
FROM user_tables
WHERE table_name IN ('LEITURA_COLEIRA', 'LEITURA_COMEDOURO', 'LEITURA_AMBIENTE', 'LEITURA_SENSOR')
ORDER BY table_name;

-- ================================================================================
-- PASSO 9/21 - sql/procedures/01_log_erros.sql
-- Cria a procedure PRC_REGISTRAR_LOG_ERRO
-- ================================================================================

------------------------------------------------------------
-- PETCARE HUB - PROCEDURE DE LOG DE ERROS
-- Essa procedure será usada pelas outras procedures de carga
------------------------------------------------------------

CREATE OR REPLACE PROCEDURE prc_registrar_log_erro (
    p_nome_procedure IN VARCHAR2,
    p_codigo_erro    IN NUMBER,
    p_mensagem_erro  IN VARCHAR2
) AS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    INSERT INTO LOG_ERROS (
        id_log,
        nome_procedure,
        nome_usuario,
        data_ocorrencia,
        codigo_erro,
        mensagem_erro
    ) VALUES (
        seq_log_erros.NEXTVAL,
        p_nome_procedure,
        USER,
        SYSTIMESTAMP,
        p_codigo_erro,
        SUBSTR(p_mensagem_erro, 1, 1000)
    );

    COMMIT;
END;
/

------------------------------------------------------------
-- TESTE: verificar se a procedure foi criada
------------------------------------------------------------

SELECT object_name, object_type, status
FROM user_objects
WHERE object_name = 'PRC_REGISTRAR_LOG_ERRO';

-- ================================================================================
-- PASSO 10/21 - sql/procedures/03_prc_ins_tutor.sql
-- Cria a procedure PRC_INS_TUTOR (pré-cadastro, feito pela clínica, sem senha)
-- ================================================================================

------------------------------------------------------------
-- REMOVE A PROCEDURE ANTIGA
------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE 'DROP PROCEDURE prc_ins_responsavel';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

------------------------------------------------------------
-- PROCEDURE: INSERIR TUTOR (pré-cadastro feito pela clínica, sem senha)
------------------------------------------------------------

CREATE OR REPLACE PROCEDURE prc_ins_tutor (
    p_nome      IN VARCHAR2,
    p_email     IN VARCHAR2,
    p_telefone  IN VARCHAR2,
    p_cpf       IN VARCHAR2
) AS
BEGIN
    IF p_nome IS NULL OR p_email IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nome e email do tutor sao obrigatorios.');
    END IF;

    INSERT INTO TUTOR (
        id_tutor,
        nome,
        email,
        telefone,
        cpf,
        data_cadastro,
        ativo,
        status_acesso
    ) VALUES (
        seq_tutor.NEXTVAL,
        p_nome,
        p_email,
        p_telefone,
        p_cpf,
        SYSDATE,
        'S',
        'PRE_CADASTRADO'
    );

    COMMIT;

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        prc_registrar_log_erro('PRC_INS_TUTOR', SQLCODE, SQLERRM);

    WHEN VALUE_ERROR THEN
        prc_registrar_log_erro('PRC_INS_TUTOR', SQLCODE, SQLERRM);

    WHEN OTHERS THEN
        prc_registrar_log_erro('PRC_INS_TUTOR', SQLCODE, SQLERRM);
END;
/

-- ================================================================================
-- PASSO 11/21 - sql/procedures/02_procedures_carga.sql
-- Cria as demais procedures de insercao de dados por parametro
-- ================================================================================

------------------------------------------------------------
-- PETCARE HUB - PROCEDURES DE CARGA
-- Usam parâmetros e registram erros na tabela LOG_ERROS
------------------------------------------------------------

------------------------------------------------------------
-- 2. PROCEDURE: INSERIR CLINICA
------------------------------------------------------------

CREATE OR REPLACE PROCEDURE prc_ins_clinica (
    p_nome      IN VARCHAR2,
    p_cnpj      IN VARCHAR2,
    p_email     IN VARCHAR2,
    p_telefone  IN VARCHAR2,
    p_endereco  IN VARCHAR2
) AS
BEGIN
    IF p_nome IS NULL OR p_cnpj IS NULL THEN
        RAISE_APPLICATION_ERROR(-20002, 'Nome e CNPJ da clinica sao obrigatorios.');
    END IF;

    INSERT INTO CLINICA (
        id_clinica,
        nome,
        cnpj,
        email,
        telefone,
        endereco,
        ativo
    ) VALUES (
        seq_clinica.NEXTVAL,
        p_nome,
        p_cnpj,
        p_email,
        p_telefone,
        p_endereco,
        'S'
    );

    COMMIT;

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        prc_registrar_log_erro('PRC_INS_CLINICA', SQLCODE, SQLERRM);

    WHEN VALUE_ERROR THEN
        prc_registrar_log_erro('PRC_INS_CLINICA', SQLCODE, SQLERRM);

    WHEN OTHERS THEN
        prc_registrar_log_erro('PRC_INS_CLINICA', SQLCODE, SQLERRM);
END;
/

------------------------------------------------------------
-- 3. PROCEDURE: INSERIR PET
------------------------------------------------------------

CREATE OR REPLACE PROCEDURE prc_ins_pet (
    p_id_tutor            IN NUMBER,
    p_id_clinica          IN NUMBER,
    p_nome                IN VARCHAR2,
    p_especie             IN VARCHAR2,
    p_raca                IN VARCHAR2,
    p_data_nascimento     IN DATE,
    p_peso_kg             IN NUMBER,
    p_sexo                IN CHAR,
    p_condicoes_cronicas  IN VARCHAR2
) AS
    v_total_tutor    NUMBER;
    v_total_clinica  NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_total_tutor
    FROM TUTOR
    WHERE id_tutor = p_id_tutor;

    SELECT COUNT(*)
    INTO v_total_clinica
    FROM CLINICA
    WHERE id_clinica = p_id_clinica;

    IF v_total_tutor = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Tutor nao encontrado.');
    END IF;

    IF v_total_clinica = 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Clinica nao encontrada.');
    END IF;

    IF p_nome IS NULL OR p_especie IS NULL OR p_peso_kg IS NULL THEN
        RAISE_APPLICATION_ERROR(-20005, 'Nome, especie e peso do pet sao obrigatorios.');
    END IF;

    INSERT INTO PET (
        id_pet,
        id_tutor,
        id_clinica,
        nome,
        especie,
        raca,
        data_nascimento,
        peso_kg,
        sexo,
        condicoes_cronicas,
        data_cadastro,
        ativo
    ) VALUES (
        seq_pet.NEXTVAL,
        p_id_tutor,
        p_id_clinica,
        p_nome,
        p_especie,
        p_raca,
        p_data_nascimento,
        p_peso_kg,
        p_sexo,
        p_condicoes_cronicas,
        SYSDATE,
        'S'
    );

    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        prc_registrar_log_erro('PRC_INS_PET', SQLCODE, SQLERRM);

    WHEN VALUE_ERROR THEN
        prc_registrar_log_erro('PRC_INS_PET', SQLCODE, SQLERRM);

    WHEN OTHERS THEN
        prc_registrar_log_erro('PRC_INS_PET', SQLCODE, SQLERRM);
END;
/

------------------------------------------------------------
-- 4. PROCEDURE: INSERIR CONSULTA
------------------------------------------------------------

CREATE OR REPLACE PROCEDURE prc_ins_consulta (
    p_id_pet               IN NUMBER,
    p_id_clinica           IN NUMBER,
    p_data_consulta        IN DATE,
    p_tipo_consulta        IN VARCHAR2,
    p_descricao            IN VARCHAR2,
    p_diagnostico          IN VARCHAR2,
    p_valor                IN NUMBER,
    p_retorno_recomendado  IN CHAR,
    p_data_retorno         IN DATE
) AS
    v_total_pet      NUMBER;
    v_total_clinica  NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_total_pet
    FROM PET
    WHERE id_pet = p_id_pet;

    SELECT COUNT(*)
    INTO v_total_clinica
    FROM CLINICA
    WHERE id_clinica = p_id_clinica;

    IF v_total_pet = 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'Pet nao encontrado.');
    END IF;

    IF v_total_clinica = 0 THEN
        RAISE_APPLICATION_ERROR(-20007, 'Clinica nao encontrada.');
    END IF;

    IF p_data_consulta IS NULL OR p_tipo_consulta IS NULL THEN
        RAISE_APPLICATION_ERROR(-20008, 'Data e tipo da consulta sao obrigatorios.');
    END IF;

    INSERT INTO CONSULTA (
        id_consulta,
        id_pet,
        id_clinica,
        data_consulta,
        tipo_consulta,
        descricao,
        diagnostico,
        valor,
        retorno_recomendado,
        data_retorno
    ) VALUES (
        seq_consulta.NEXTVAL,
        p_id_pet,
        p_id_clinica,
        p_data_consulta,
        p_tipo_consulta,
        p_descricao,
        p_diagnostico,
        p_valor,
        p_retorno_recomendado,
        p_data_retorno
    );

    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        prc_registrar_log_erro('PRC_INS_CONSULTA', SQLCODE, SQLERRM);

    WHEN VALUE_ERROR THEN
        prc_registrar_log_erro('PRC_INS_CONSULTA', SQLCODE, SQLERRM);

    WHEN OTHERS THEN
        prc_registrar_log_erro('PRC_INS_CONSULTA', SQLCODE, SQLERRM);
END;
/

------------------------------------------------------------
-- 5. PROCEDURE: INSERIR PROTOCOLO PREVENTIVO
------------------------------------------------------------

CREATE OR REPLACE PROCEDURE prc_ins_protocolo_preventivo (
    p_especie                  IN VARCHAR2,
    p_raca                     IN VARCHAR2,
    p_tipo_evento              IN VARCHAR2,
    p_descricao                IN VARCHAR2,
    p_idade_meses_recomendada  IN NUMBER,
    p_intervalo_dias           IN NUMBER
) AS
BEGIN
    IF p_especie IS NULL OR p_tipo_evento IS NULL OR p_descricao IS NULL THEN
        RAISE_APPLICATION_ERROR(-20009, 'Especie, tipo de evento e descricao sao obrigatorios.');
    END IF;

    INSERT INTO PROTOCOLO_PREVENTIVO (
        id_protocolo,
        especie,
        raca,
        tipo_evento,
        descricao,
        idade_meses_recomendada,
        intervalo_dias,
        ativo
    ) VALUES (
        seq_protocolo_preventivo.NEXTVAL,
        p_especie,
        p_raca,
        p_tipo_evento,
        p_descricao,
        p_idade_meses_recomendada,
        p_intervalo_dias,
        'S'
    );

    COMMIT;

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        prc_registrar_log_erro('PRC_INS_PROTOCOLO_PREVENTIVO', SQLCODE, SQLERRM);

    WHEN VALUE_ERROR THEN
        prc_registrar_log_erro('PRC_INS_PROTOCOLO_PREVENTIVO', SQLCODE, SQLERRM);

    WHEN OTHERS THEN
        prc_registrar_log_erro('PRC_INS_PROTOCOLO_PREVENTIVO', SQLCODE, SQLERRM);
END;
/

------------------------------------------------------------
-- 6. PROCEDURE: INSERIR EVENTO PREVENTIVO
------------------------------------------------------------

CREATE OR REPLACE PROCEDURE prc_ins_evento_preventivo (
    p_id_pet           IN NUMBER,
    p_id_protocolo     IN NUMBER,
    p_tipo_evento      IN VARCHAR2,
    p_descricao        IN VARCHAR2,
    p_data_prevista    IN DATE,
    p_data_realizacao  IN DATE,
    p_status           IN VARCHAR2
) AS
    v_total_pet        NUMBER;
    v_total_protocolo  NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_total_pet
    FROM PET
    WHERE id_pet = p_id_pet;

    IF v_total_pet = 0 THEN
        RAISE_APPLICATION_ERROR(-20010, 'Pet nao encontrado.');
    END IF;

    IF p_id_protocolo IS NOT NULL THEN
        SELECT COUNT(*)
        INTO v_total_protocolo
        FROM PROTOCOLO_PREVENTIVO
        WHERE id_protocolo = p_id_protocolo;

        IF v_total_protocolo = 0 THEN
            RAISE_APPLICATION_ERROR(-20011, 'Protocolo preventivo nao encontrado.');
        END IF;
    END IF;

    IF p_tipo_evento IS NULL OR p_descricao IS NULL OR p_data_prevista IS NULL THEN
        RAISE_APPLICATION_ERROR(-20012, 'Tipo, descricao e data prevista sao obrigatorios.');
    END IF;

    INSERT INTO EVENTO_PREVENTIVO (
        id_evento,
        id_pet,
        id_protocolo,
        tipo_evento,
        descricao,
        data_prevista,
        data_realizacao,
        status
    ) VALUES (
        seq_evento_preventivo.NEXTVAL,
        p_id_pet,
        p_id_protocolo,
        p_tipo_evento,
        p_descricao,
        p_data_prevista,
        p_data_realizacao,
        p_status
    );

    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        prc_registrar_log_erro('PRC_INS_EVENTO_PREVENTIVO', SQLCODE, SQLERRM);

    WHEN VALUE_ERROR THEN
        prc_registrar_log_erro('PRC_INS_EVENTO_PREVENTIVO', SQLCODE, SQLERRM);

    WHEN OTHERS THEN
        prc_registrar_log_erro('PRC_INS_EVENTO_PREVENTIVO', SQLCODE, SQLERRM);
END;
/

------------------------------------------------------------
-- 7. PROCEDURE: INSERIR DISPOSITIVO IOT
------------------------------------------------------------

CREATE OR REPLACE PROCEDURE prc_ins_dispositivo_iot (
    p_id_pet            IN NUMBER,
    p_tipo_dispositivo  IN VARCHAR2,
    p_codigo_serie      IN VARCHAR2,
    p_data_ativacao     IN DATE
) AS
    v_total_pet NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_total_pet
    FROM PET
    WHERE id_pet = p_id_pet;

    IF v_total_pet = 0 THEN
        RAISE_APPLICATION_ERROR(-20013, 'Pet nao encontrado.');
    END IF;

    IF p_tipo_dispositivo IS NULL OR p_codigo_serie IS NULL THEN
        RAISE_APPLICATION_ERROR(-20014, 'Tipo do dispositivo e codigo de serie sao obrigatorios.');
    END IF;

    INSERT INTO DISPOSITIVO_IOT (
        id_dispositivo,
        id_pet,
        tipo_dispositivo,
        codigo_serie,
        data_ativacao,
        ativo
    ) VALUES (
        seq_dispositivo_iot.NEXTVAL,
        p_id_pet,
        p_tipo_dispositivo,
        p_codigo_serie,
        NVL(p_data_ativacao, SYSDATE),
        'S'
    );

    COMMIT;

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        prc_registrar_log_erro('PRC_INS_DISPOSITIVO_IOT', SQLCODE, SQLERRM);

    WHEN VALUE_ERROR THEN
        prc_registrar_log_erro('PRC_INS_DISPOSITIVO_IOT', SQLCODE, SQLERRM);

    WHEN OTHERS THEN
        prc_registrar_log_erro('PRC_INS_DISPOSITIVO_IOT', SQLCODE, SQLERRM);
END;
/

------------------------------------------------------------
-- 8. PROCEDURE: INSERIR ALERTA SAUDE
-- id_leitura foi removido (a FK para LEITURA_SENSOR nao
-- existe mais desde a separacao em LEITURA_COLEIRA /
-- LEITURA_COMEDOURO / LEITURA_AMBIENTE - ver ddl 08).
------------------------------------------------------------

CREATE OR REPLACE PROCEDURE prc_ins_alerta_saude (
    p_id_pet             IN NUMBER,
    p_tipo_alerta        IN VARCHAR2,
    p_nivel_alerta       IN VARCHAR2,
    p_mensagem           IN VARCHAR2,
    p_valor_detectado    IN NUMBER,
    p_limite_referencia  IN NUMBER
) AS
    v_total_pet      NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_total_pet
    FROM PET
    WHERE id_pet = p_id_pet;

    IF v_total_pet = 0 THEN
        RAISE_APPLICATION_ERROR(-20015, 'Pet nao encontrado.');
    END IF;

    IF p_tipo_alerta IS NULL OR p_nivel_alerta IS NULL OR p_mensagem IS NULL THEN
        RAISE_APPLICATION_ERROR(-20017, 'Tipo, nivel e mensagem do alerta sao obrigatorios.');
    END IF;

    INSERT INTO ALERTA_SAUDE (
        id_alerta,
        id_pet,
        tipo_alerta,
        nivel_alerta,
        mensagem,
        valor_detectado,
        limite_referencia,
        resolvido,
        data_alerta,
        data_resolucao
    ) VALUES (
        seq_alerta_saude.NEXTVAL,
        p_id_pet,
        p_tipo_alerta,
        p_nivel_alerta,
        p_mensagem,
        p_valor_detectado,
        p_limite_referencia,
        'N',
        SYSTIMESTAMP,
        NULL
    );

    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        prc_registrar_log_erro('PRC_INS_ALERTA_SAUDE', SQLCODE, SQLERRM);

    WHEN VALUE_ERROR THEN
        prc_registrar_log_erro('PRC_INS_ALERTA_SAUDE', SQLCODE, SQLERRM);

    WHEN OTHERS THEN
        prc_registrar_log_erro('PRC_INS_ALERTA_SAUDE', SQLCODE, SQLERRM);
END;
/

------------------------------------------------------------
-- 9a. PROCEDURE: INSERIR LEITURA COLEIRA
------------------------------------------------------------

CREATE OR REPLACE PROCEDURE prc_ins_leitura_coleira (
    p_id_pet             IN NUMBER,
    p_status_atividade   IN VARCHAR2,
    p_nivel_bateria      IN NUMBER,
    p_timestamp_leitura  IN TIMESTAMP
) AS
    v_total_pet  NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_total_pet
    FROM PET
    WHERE id_pet = p_id_pet;

    IF v_total_pet = 0 THEN
        RAISE_APPLICATION_ERROR(-20018, 'Pet nao encontrado.');
    END IF;

    IF p_status_atividade IS NULL OR p_nivel_bateria IS NULL THEN
        RAISE_APPLICATION_ERROR(-20020, 'Status de atividade e nivel de bateria sao obrigatorios.');
    END IF;

    INSERT INTO LEITURA_COLEIRA (
        id_leitura_coleira,
        id_pet,
        status_atividade,
        nivel_bateria,
        timestamp_leitura
    ) VALUES (
        seq_leitura_coleira.NEXTVAL,
        p_id_pet,
        p_status_atividade,
        p_nivel_bateria,
        NVL(p_timestamp_leitura, SYSTIMESTAMP)
    );

    IF p_status_atividade = 'SEDENTARIO' THEN
        prc_ins_alerta_saude(
            p_id_pet,
            'ATIVIDADE_BAIXA',
            'ALTO',
            'Nivel de atividade abaixo do esperado.',
            NULL,
            NULL
        );
    END IF;

    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        prc_registrar_log_erro('PRC_INS_LEITURA_COLEIRA', SQLCODE, SQLERRM);

    WHEN VALUE_ERROR THEN
        prc_registrar_log_erro('PRC_INS_LEITURA_COLEIRA', SQLCODE, SQLERRM);

    WHEN OTHERS THEN
        prc_registrar_log_erro('PRC_INS_LEITURA_COLEIRA', SQLCODE, SQLERRM);
END;
/

------------------------------------------------------------
-- 9b. PROCEDURE: INSERIR LEITURA COMEDOURO
------------------------------------------------------------

CREATE OR REPLACE PROCEDURE prc_ins_leitura_comedouro (
    p_id_pet             IN NUMBER,
    p_nivel_racao_pct    IN NUMBER,
    p_peso_consumido_g   IN NUMBER,
    p_timestamp_leitura  IN TIMESTAMP
) AS
    v_total_pet  NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_total_pet
    FROM PET
    WHERE id_pet = p_id_pet;

    IF v_total_pet = 0 THEN
        RAISE_APPLICATION_ERROR(-20018, 'Pet nao encontrado.');
    END IF;

    IF p_nivel_racao_pct IS NULL OR p_peso_consumido_g IS NULL THEN
        RAISE_APPLICATION_ERROR(-20020, 'Nivel de racao e peso consumido sao obrigatorios.');
    END IF;

    INSERT INTO LEITURA_COMEDOURO (
        id_leitura_comedouro,
        id_pet,
        nivel_racao_pct,
        peso_consumido_g,
        timestamp_leitura
    ) VALUES (
        seq_leitura_comedouro.NEXTVAL,
        p_id_pet,
        p_nivel_racao_pct,
        p_peso_consumido_g,
        NVL(p_timestamp_leitura, SYSTIMESTAMP)
    );

    IF p_nivel_racao_pct < 20 THEN
        prc_ins_alerta_saude(
            p_id_pet,
            'RACAO_BAIXA',
            'MEDIO',
            'Nivel de racao abaixo do recomendado.',
            p_nivel_racao_pct,
            20
        );
    END IF;

    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        prc_registrar_log_erro('PRC_INS_LEITURA_COMEDOURO', SQLCODE, SQLERRM);

    WHEN VALUE_ERROR THEN
        prc_registrar_log_erro('PRC_INS_LEITURA_COMEDOURO', SQLCODE, SQLERRM);

    WHEN OTHERS THEN
        prc_registrar_log_erro('PRC_INS_LEITURA_COMEDOURO', SQLCODE, SQLERRM);
END;
/

------------------------------------------------------------
-- 9c. PROCEDURE: INSERIR LEITURA AMBIENTE
------------------------------------------------------------

CREATE OR REPLACE PROCEDURE prc_ins_leitura_ambiente (
    p_id_pet              IN NUMBER,
    p_temperatura_ambiente IN NUMBER,
    p_umidade_pct         IN NUMBER,
    p_qualidade_ar_ppm    IN NUMBER,
    p_pet_presente        IN NUMBER,
    p_timestamp_leitura   IN TIMESTAMP
) AS
    v_total_pet  NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_total_pet
    FROM PET
    WHERE id_pet = p_id_pet;

    IF v_total_pet = 0 THEN
        RAISE_APPLICATION_ERROR(-20018, 'Pet nao encontrado.');
    END IF;

    IF p_temperatura_ambiente IS NULL OR p_umidade_pct IS NULL
       OR p_qualidade_ar_ppm IS NULL OR p_pet_presente IS NULL THEN
        RAISE_APPLICATION_ERROR(-20020, 'Temperatura, umidade, qualidade do ar e presenca do pet sao obrigatorios.');
    END IF;

    INSERT INTO LEITURA_AMBIENTE (
        id_leitura_ambiente,
        id_pet,
        temperatura_ambiente,
        umidade_pct,
        qualidade_ar_ppm,
        pet_presente,
        timestamp_leitura
    ) VALUES (
        seq_leitura_ambiente.NEXTVAL,
        p_id_pet,
        p_temperatura_ambiente,
        p_umidade_pct,
        p_qualidade_ar_ppm,
        p_pet_presente,
        NVL(p_timestamp_leitura, SYSTIMESTAMP)
    );

    IF p_temperatura_ambiente < 10 OR p_temperatura_ambiente > 35 THEN
        prc_ins_alerta_saude(
            p_id_pet,
            'AMBIENTE_INADEQUADO',
            'MEDIO',
            'Temperatura ambiente fora da faixa recomendada.',
            p_temperatura_ambiente,
            CASE WHEN p_temperatura_ambiente < 10 THEN 10 ELSE 35 END
        );
    END IF;

    IF p_qualidade_ar_ppm > 500 THEN
        prc_ins_alerta_saude(
            p_id_pet,
            'QUALIDADE_AR_RUIM',
            'MEDIO',
            'Qualidade do ar acima do limite recomendado.',
            p_qualidade_ar_ppm,
            500
        );
    END IF;

    IF p_umidade_pct < 30 OR p_umidade_pct > 80 THEN
        prc_ins_alerta_saude(
            p_id_pet,
            'UMIDADE_INADEQUADA',
            'MEDIO',
            'Umidade ambiente fora da faixa recomendada.',
            p_umidade_pct,
            CASE WHEN p_umidade_pct < 30 THEN 30 ELSE 80 END
        );
    END IF;

    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        prc_registrar_log_erro('PRC_INS_LEITURA_AMBIENTE', SQLCODE, SQLERRM);

    WHEN VALUE_ERROR THEN
        prc_registrar_log_erro('PRC_INS_LEITURA_AMBIENTE', SQLCODE, SQLERRM);

    WHEN OTHERS THEN
        prc_registrar_log_erro('PRC_INS_LEITURA_AMBIENTE', SQLCODE, SQLERRM);
END;
/

------------------------------------------------------------
-- 10. PROCEDURE: INSERIR SCORE SAUDE
------------------------------------------------------------

CREATE OR REPLACE PROCEDURE prc_ins_score_saude (
    p_id_pet             IN NUMBER,
    p_score_total        IN NUMBER,
    p_score_atividade    IN NUMBER,
    p_score_alimentacao  IN NUMBER,
    p_score_ambiente     IN NUMBER,
    p_score_consulta     IN NUMBER,
    p_score_preventivo   IN NUMBER
) AS
    v_total_pet  NUMBER;
    v_categoria  VARCHAR2(20);
BEGIN
    SELECT COUNT(*)
    INTO v_total_pet
    FROM PET
    WHERE id_pet = p_id_pet;

    IF v_total_pet = 0 THEN
        RAISE_APPLICATION_ERROR(-20021, 'Pet nao encontrado.');
    END IF;

    IF p_score_total IS NULL THEN
        RAISE_APPLICATION_ERROR(-20022, 'Score total e obrigatorio.');
    END IF;

    IF p_score_total >= 80 THEN
        v_categoria := 'VERDE';

    ELSIF p_score_total >= 50 THEN
        v_categoria := 'AMARELO';

    ELSE
        v_categoria := 'VERMELHO';
    END IF;

    INSERT INTO SCORE_SAUDE (
        id_score,
        id_pet,
        score_total,
        score_atividade,
        score_alimentacao,
        score_ambiente,
        score_consulta,
        score_preventivo,
        categoria,
        data_calculo
    ) VALUES (
        seq_score_saude.NEXTVAL,
        p_id_pet,
        p_score_total,
        p_score_atividade,
        p_score_alimentacao,
        p_score_ambiente,
        p_score_consulta,
        p_score_preventivo,
        v_categoria,
        SYSTIMESTAMP
    );

    IF p_score_total < 50 THEN
        INSERT INTO ALERTA_SAUDE (
            id_alerta,
            id_pet,
            tipo_alerta,
            nivel_alerta,
            mensagem,
            valor_detectado,
            limite_referencia,
            resolvido,
            data_alerta,
            data_resolucao
        ) VALUES (
            seq_alerta_saude.NEXTVAL,
            p_id_pet,
            'SCORE_BAIXO',
            'ALTO',
            'Score de saude abaixo do limite recomendado.',
            p_score_total,
            50,
            'N',
            SYSTIMESTAMP,
            NULL
        );
    END IF;

    COMMIT;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        prc_registrar_log_erro('PRC_INS_SCORE_SAUDE', SQLCODE, SQLERRM);

    WHEN VALUE_ERROR THEN
        prc_registrar_log_erro('PRC_INS_SCORE_SAUDE', SQLCODE, SQLERRM);

    WHEN OTHERS THEN
        prc_registrar_log_erro('PRC_INS_SCORE_SAUDE', SQLCODE, SQLERRM);
END;
/

------------------------------------------------------------
-- TESTE FINAL: LISTAR PROCEDURES CRIADAS
------------------------------------------------------------

SELECT object_name, object_type, status
FROM user_objects
WHERE object_name IN (
    'PRC_INS_TUTOR',
    'PRC_INS_CLINICA',
    'PRC_INS_PET',
    'PRC_INS_CONSULTA',
    'PRC_INS_PROTOCOLO_PREVENTIVO',
    'PRC_INS_EVENTO_PREVENTIVO',
    'PRC_INS_DISPOSITIVO_IOT',
    'PRC_INS_ALERTA_SAUDE',
    'PRC_INS_LEITURA_COLEIRA',
    'PRC_INS_LEITURA_COMEDOURO',
    'PRC_INS_LEITURA_AMBIENTE',
    'PRC_INS_SCORE_SAUDE'
)
ORDER BY object_name;

-- ================================================================================
-- PASSO 12/21 - sql/triggers/01_trg_auditoria_tutor.sql
-- Cria AUDITORIA_TUTOR, a sequence dela e o trigger TRG_AUDITORIA_TUTOR
-- ================================================================================

------------------------------------------------------------
-- TABELA DE AUDITORIA
------------------------------------------------------------

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE AUDITORIA_TUTOR CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE AUDITORIA_TUTOR (
    id_auditoria     NUMBER(10)      NOT NULL,
    id_tutor         NUMBER(10),
    operacao         VARCHAR2(10)    NOT NULL,
    usuario_bd       VARCHAR2(60)    NOT NULL,
    data_hora        TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    status_anterior  VARCHAR2(20),
    status_novo      VARCHAR2(20),
    email_anterior   VARCHAR2(120),
    email_novo       VARCHAR2(120),

    CONSTRAINT pk_auditoria_tutor PRIMARY KEY (id_auditoria),
    CONSTRAINT ck_auditoria_operacao CHECK (operacao IN ('INSERT', 'UPDATE', 'DELETE'))
);

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_auditoria_tutor';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE SEQUENCE seq_auditoria_tutor START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

------------------------------------------------------------
-- TRIGGER DE AUDITORIA (INSERT / UPDATE / DELETE em TUTOR)
------------------------------------------------------------

CREATE OR REPLACE TRIGGER trg_auditoria_tutor
AFTER INSERT OR UPDATE OR DELETE ON TUTOR
FOR EACH ROW
DECLARE
    v_operacao VARCHAR2(10);
BEGIN
    IF INSERTING THEN
        v_operacao := 'INSERT';
    ELSIF UPDATING THEN
        v_operacao := 'UPDATE';
    ELSE
        v_operacao := 'DELETE';
    END IF;

    INSERT INTO AUDITORIA_TUTOR (
        id_auditoria, id_tutor, operacao, usuario_bd, data_hora,
        status_anterior, status_novo, email_anterior, email_novo
    ) VALUES (
        seq_auditoria_tutor.NEXTVAL,
        NVL(:NEW.id_tutor, :OLD.id_tutor),
        v_operacao,
        USER,
        SYSTIMESTAMP,
        :OLD.status_acesso,
        :NEW.status_acesso,
        :OLD.email,
        :NEW.email
    );
END;
/

------------------------------------------------------------
-- TESTE / EVIDENCIA (tirar print para o PDF)
-- Demonstra a auditoria capturando INSERT, UPDATE e DELETE
-- num tutor de teste, com usuario, operacao, data/hora e
-- valores anteriores/novos. O tutor de teste e removido no
-- final, entao nao conta para o minimo de 5 tutores exigido
-- pelo Procedimento 1 da rubrica.
------------------------------------------------------------

INSERT INTO TUTOR (
    id_tutor, nome, email, telefone, cpf, data_cadastro, ativo, status_acesso
) VALUES (
    seq_tutor.NEXTVAL, 'Teste Auditoria', 'auditoria@teste.com',
    '11900000000', '00000000000', SYSDATE, 'S', 'PRE_CADASTRADO'
);
COMMIT;

UPDATE TUTOR
SET status_acesso = 'ATIVO', senha_hash = 'hash_teste_auditoria'
WHERE email = 'auditoria@teste.com';
COMMIT;

DELETE FROM TUTOR WHERE email = 'auditoria@teste.com';
COMMIT;

SELECT id_auditoria, id_tutor, operacao, usuario_bd, data_hora,
       status_anterior, status_novo, email_anterior, email_novo
FROM AUDITORIA_TUTOR
WHERE email_anterior = 'auditoria@teste.com' OR email_novo = 'auditoria@teste.com'
ORDER BY data_hora;
-- Esperado: 3 linhas (INSERT, UPDATE, DELETE) para esse tutor,
-- com status_anterior/status_novo mostrando PRE_CADASTRADO -> ATIVO
-- no UPDATE, e id_tutor/email preenchidos em todas as 3 linhas.

-- ================================================================================
-- PASSO 13/21 - sql/functions/01_functions.sql
-- Cria fn_calcular_idade_pet e fn_score_medio_pet
-- ================================================================================

------------------------------------------------------------
-- FUNCTION 1: Calcula idade do pet em meses
------------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_calcular_idade_pet (
    p_id_pet IN NUMBER
) RETURN NUMBER
IS
    v_data_nascimento DATE;
    v_idade_meses      NUMBER;
BEGIN
    SELECT data_nascimento
    INTO v_data_nascimento
    FROM PET
    WHERE id_pet = p_id_pet;

    IF v_data_nascimento IS NULL THEN
        RETURN NULL;
    END IF;

    v_idade_meses := MONTHS_BETWEEN(SYSDATE, v_data_nascimento);

    RETURN TRUNC(v_idade_meses);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END;
/

------------------------------------------------------------
-- FUNCTION 2: Score médio do pet nos últimos N dias
------------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_score_medio_pet (
    p_id_pet IN NUMBER,
    p_dias   IN NUMBER
) RETURN NUMBER
IS
    v_media NUMBER;
BEGIN
    SELECT AVG(score_total)
    INTO v_media
    FROM SCORE_SAUDE
    WHERE id_pet = p_id_pet
      AND data_calculo >= SYSTIMESTAMP - p_dias;

    RETURN ROUND(NVL(v_media, 0), 1);

EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
/

------------------------------------------------------------
-- TESTE
------------------------------------------------------------
-- SELECT fn_calcular_idade_pet(1) FROM DUAL;
-- SELECT fn_score_medio_pet(1, 30) FROM DUAL;

-- ================================================================================
-- PASSO 14/21 - sql/functions/02_functions_json_senha.sql
-- Cria fn_pet_para_json e fn_validar_forca_senha (rubrica Sprint 3)
-- ================================================================================

------------------------------------------------------------
-- PETCARE HUB - FUNCTIONS DA RUBRICA (SPRINT 3)
-- "Mastering Relational and Non-Relational Database"
------------------------------------------------------------

------------------------------------------------------------
-- FUNCAO 1: converte um registro relacional (PET + TUTOR +
-- CLINICA) em uma string JSON, montada manualmente.
-- PROIBIDO usar TO_JSON / JSON_OBJECT / JSON_VALUE / etc.
------------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_pet_para_json (
    p_id_pet        IN NUMBER,
    p_nome_pet      IN VARCHAR2,
    p_especie_pet   IN VARCHAR2,
    p_nome_tutor    IN VARCHAR2,
    p_email_tutor   IN VARCHAR2,
    p_nome_clinica  IN VARCHAR2
) RETURN VARCHAR2
IS
    e_id_pet_nulo    EXCEPTION;
    e_nome_pet_nulo  EXCEPTION;
    v_json           VARCHAR2(4000);

    -- Escapa manualmente os caracteres que quebrariam o JSON:
    -- barra invertida, aspas, quebra de linha e tabulacao.
    -- A ordem importa: a barra invertida precisa ser escapada
    -- primeiro, senao as barras inseridas pelos escapes
    -- seguintes seriam escapadas de novo.
    FUNCTION escapar_json(p_valor IN VARCHAR2) RETURN VARCHAR2 IS
        v_escapado VARCHAR2(4000);
    BEGIN
        v_escapado := REPLACE(p_valor, '\', '\\');
        v_escapado := REPLACE(v_escapado, '"', '\"');
        v_escapado := REPLACE(v_escapado, CHR(10), '\n');
        v_escapado := REPLACE(v_escapado, CHR(13), '');
        v_escapado := REPLACE(v_escapado, CHR(9), '\t');
        RETURN v_escapado;
    END escapar_json;
BEGIN
    IF p_id_pet IS NULL THEN
        RAISE e_id_pet_nulo;
    END IF;

    IF p_nome_pet IS NULL THEN
        RAISE e_nome_pet_nulo;
    END IF;

    v_json :=
        '{"id_pet":' || p_id_pet
        || ',"nome_pet":"' || escapar_json(p_nome_pet) || '"'
        || ',"especie":"' || escapar_json(NVL(p_especie_pet, '')) || '"'
        || ',"tutor":{'
            || '"nome":"' || escapar_json(NVL(p_nome_tutor, '')) || '"'
            || ',"email":"' || escapar_json(NVL(p_email_tutor, '')) || '"'
        || '}'
        || ',"clinica":"' || escapar_json(NVL(p_nome_clinica, '')) || '"'
        || '}';

    RETURN v_json;

EXCEPTION
    WHEN e_id_pet_nulo THEN
        RETURN '{"erro":"id_pet obrigatorio para gerar JSON"}';
    WHEN e_nome_pet_nulo THEN
        RETURN '{"erro":"nome_pet obrigatorio para gerar JSON"}';
    WHEN VALUE_ERROR THEN
        RETURN '{"erro":"valor invalido ao montar JSON"}';
    WHEN OTHERS THEN
        RETURN '{"erro":"erro inesperado ao montar JSON"}';
END;
/

------------------------------------------------------------
-- FUNCAO 2: substitui o processo de validacao de senha do
-- fluxo de ativacao de conta do TUTOR (regra de negocio:
-- minimo 8 caracteres, pelo menos 1 letra e 1 numero).
------------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_validar_forca_senha (
    p_senha IN VARCHAR2
) RETURN VARCHAR2
IS
    e_senha_nula        EXCEPTION;
    e_senha_curta       EXCEPTION;
    e_senha_sem_numero  EXCEPTION;
BEGIN
    IF p_senha IS NULL THEN
        RAISE e_senha_nula;
    END IF;

    IF LENGTH(p_senha) < 8 THEN
        RAISE e_senha_curta;
    END IF;

    IF NOT REGEXP_LIKE(p_senha, '[0-9]') THEN
        RAISE e_senha_sem_numero;
    END IF;

    IF NOT REGEXP_LIKE(p_senha, '[A-Za-z]') THEN
        RETURN 'INVALIDA: senha precisa conter ao menos uma letra.';
    END IF;

    RETURN 'VALIDA';

EXCEPTION
    WHEN e_senha_nula THEN
        RETURN 'INVALIDA: senha nao informada.';
    WHEN e_senha_curta THEN
        RETURN 'INVALIDA: senha deve ter no minimo 8 caracteres.';
    WHEN e_senha_sem_numero THEN
        RETURN 'INVALIDA: senha deve conter ao menos um numero.';
    WHEN OTHERS THEN
        RETURN 'INVALIDA: erro inesperado na validacao.';
END;
/

------------------------------------------------------------
-- TESTE / EVIDENCIA (tirar print desses resultados)
------------------------------------------------------------

-- Caso de sucesso da Funcao 1 (usa o pet 'Rex' ja carregado)
SELECT fn_pet_para_json(
    p.id_pet, p.nome, p.especie, t.nome, t.email, c.nome
) AS json_pet
FROM PET p
JOIN TUTOR t ON t.id_tutor = p.id_tutor
JOIN CLINICA c ON c.id_clinica = p.id_clinica
WHERE p.nome = 'Rex';

-- Caso de excecao da Funcao 1 (id_pet nulo)
SELECT fn_pet_para_json(NULL, 'Teste', 'CAO', 'Tutor Teste', 'teste@teste.com', 'Clinica Teste') AS json_erro
FROM DUAL;

-- Caso de escape manual (barra invertida, aspas, quebra de
-- linha e tabulacao no mesmo valor) - print para a documentacao
SELECT fn_pet_para_json(
    99,
    'Nome com "aspas" e barra \ contra' || CHR(10) || 'quebra de linha' || CHR(9) || 'tab',
    'CAO', 'Tutor Teste', 'teste@teste.com', 'Clinica Teste'
) AS json_escape_teste
FROM DUAL;

-- Caso de sucesso da Funcao 2
SELECT fn_validar_forca_senha('Senha123') AS resultado FROM DUAL;

-- Casos de excecao da Funcao 2 (print para a documentacao)
SELECT fn_validar_forca_senha(NULL) AS resultado FROM DUAL;
SELECT fn_validar_forca_senha('abc') AS resultado FROM DUAL;
SELECT fn_validar_forca_senha('semnumero') AS resultado FROM DUAL;

-- ================================================================================
-- PASSO 15/21 - sql/inserts/01_insert_testes.sql
-- Executa a carga inicial de dados usando as procedures
-- ================================================================================

------------------------------------------------------------
-- PETCARE HUB - INSERTS DE TESTE
-- Carga de dados usando procedures
------------------------------------------------------------

------------------------------------------------------------
-- LIMPEZA DOS DADOS
-- Mantém as tabelas, mas apaga os registros anteriores.
------------------------------------------------------------

BEGIN
    DELETE FROM ALERTA_SAUDE;
    DELETE FROM SCORE_SAUDE;
    DELETE FROM LEITURA_COLEIRA;
    DELETE FROM LEITURA_COMEDOURO;
    DELETE FROM LEITURA_AMBIENTE;
    DELETE FROM DISPOSITIVO_IOT;
    DELETE FROM EVENTO_PREVENTIVO;
    DELETE FROM CONSULTA;
    DELETE FROM PET;
    DELETE FROM PROTOCOLO_PREVENTIVO;
    DELETE FROM CLINICA;
    DELETE FROM TUTOR;
    DELETE FROM LOG_ERROS;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Dados antigos removidos com sucesso.');
END;
/

------------------------------------------------------------
-- CARGA PRINCIPAL
------------------------------------------------------------

DECLARE
    v_tutor_ana    NUMBER;
    v_tutor_bruno  NUMBER;
    v_tutor_carla  NUMBER;

    v_clinica_vida       NUMBER;
    v_clinica_hospital   NUMBER;

    v_pet_rex            NUMBER;
    v_pet_luna           NUMBER;
    v_pet_thor           NUMBER;

    v_prot_vacina_cao    NUMBER;
    v_prot_vacina_gato   NUMBER;
    v_prot_checkup_cao   NUMBER;
    v_prot_checkup_gato  NUMBER;
BEGIN
    --------------------------------------------------------
    -- 1. TUTOR
    --------------------------------------------------------

    prc_ins_tutor(
        'Ana Souza',
        'ana.souza@email.com',
        '11999990001',
        '11111111111'
    );

    prc_ins_tutor(
        'Bruno Lima',
        'bruno.lima@email.com',
        '11999990002',
        '22222222222'
    );

    prc_ins_tutor(
        'Carla Mendes',
        'carla.mendes@email.com',
        '11999990003',
        '33333333333'
    );

    SELECT id_tutor INTO v_tutor_ana
    FROM TUTOR
    WHERE email = 'ana.souza@email.com';

    SELECT id_tutor INTO v_tutor_bruno
    FROM TUTOR
    WHERE email = 'bruno.lima@email.com';

    SELECT id_tutor INTO v_tutor_carla
    FROM TUTOR
    WHERE email = 'carla.mendes@email.com';

    --------------------------------------------------------
    -- 2. CLINICAS
    --------------------------------------------------------

    prc_ins_clinica(
        'Clinica Vida Pet',
        '11111111000111',
        'contato@vidapet.com',
        '1130000001',
        'Rua A, 100'
    );

    prc_ins_clinica(
        'Hospital Animal Care',
        '22222222000122',
        'contato@animalcare.com',
        '1130000002',
        'Rua B, 200'
    );

    SELECT id_clinica INTO v_clinica_vida
    FROM CLINICA
    WHERE cnpj = '11111111000111';

    SELECT id_clinica INTO v_clinica_hospital
    FROM CLINICA
    WHERE cnpj = '22222222000122';

    --------------------------------------------------------
    -- 3. PETS
    --------------------------------------------------------

    prc_ins_pet(
        v_tutor_ana,
        v_clinica_vida,
        'Rex',
        'CAO',
        'Golden Retriever',
        TO_DATE('2021-04-10', 'YYYY-MM-DD'),
        28.50,
        'M',
        'Alergia de pele'
    );

    prc_ins_pet(
        v_tutor_ana,
        v_clinica_vida,
        'Luna',
        'GATO',
        'Siames',
        TO_DATE('2022-08-20', 'YYYY-MM-DD'),
        4.20,
        'F',
        NULL
    );

    prc_ins_pet(
        v_tutor_bruno,
        v_clinica_hospital,
        'Thor',
        'CAO',
        'Bulldog',
        TO_DATE('2020-01-15', 'YYYY-MM-DD'),
        22.00,
        'M',
        'Problema respiratorio'
    );

    SELECT id_pet INTO v_pet_rex
    FROM PET
    WHERE nome = 'Rex';

    SELECT id_pet INTO v_pet_luna
    FROM PET
    WHERE nome = 'Luna';

    SELECT id_pet INTO v_pet_thor
    FROM PET
    WHERE nome = 'Thor';

    --------------------------------------------------------
    -- 4. PROTOCOLOS PREVENTIVOS
    --------------------------------------------------------

    prc_ins_protocolo_preventivo(
        'CAO',
        NULL,
        'VACINA',
        'Vacina anual obrigatoria para caes',
        12,
        365
    );

    prc_ins_protocolo_preventivo(
        'GATO',
        NULL,
        'VACINA',
        'Vacina anual obrigatoria para gatos',
        12,
        365
    );

    prc_ins_protocolo_preventivo(
        'CAO',
        NULL,
        'CHECKUP',
        'Check-up semestral para caes adultos',
        6,
        180
    );

    prc_ins_protocolo_preventivo(
        'GATO',
        NULL,
        'CHECKUP',
        'Check-up semestral para gatos adultos',
        6,
        180
    );

    SELECT id_protocolo INTO v_prot_vacina_cao
    FROM PROTOCOLO_PREVENTIVO
    WHERE especie = 'CAO'
      AND tipo_evento = 'VACINA';

    SELECT id_protocolo INTO v_prot_vacina_gato
    FROM PROTOCOLO_PREVENTIVO
    WHERE especie = 'GATO'
      AND tipo_evento = 'VACINA';

    SELECT id_protocolo INTO v_prot_checkup_cao
    FROM PROTOCOLO_PREVENTIVO
    WHERE especie = 'CAO'
      AND tipo_evento = 'CHECKUP';

    SELECT id_protocolo INTO v_prot_checkup_gato
    FROM PROTOCOLO_PREVENTIVO
    WHERE especie = 'GATO'
      AND tipo_evento = 'CHECKUP';

    --------------------------------------------------------
    -- 5. CONSULTAS
    --------------------------------------------------------

    prc_ins_consulta(
        v_pet_rex,
        v_clinica_vida,
        TO_DATE('2026-03-10', 'YYYY-MM-DD'),
        'CHECKUP',
        'Consulta preventiva',
        'Pet em bom estado geral',
        180.00,
        'S',
        TO_DATE('2026-09-10', 'YYYY-MM-DD')
    );

    prc_ins_consulta(
        v_pet_rex,
        v_clinica_vida,
        TO_DATE('2026-04-01', 'YYYY-MM-DD'),
        'VACINA',
        'Aplicacao de vacina anual',
        'Sem reacao adversa',
        120.00,
        'N',
        NULL
    );

    prc_ins_consulta(
        v_pet_luna,
        v_clinica_vida,
        TO_DATE('2026-04-05', 'YYYY-MM-DD'),
        'EXAME',
        'Exame de sangue',
        'Acompanhamento preventivo',
        220.00,
        'S',
        TO_DATE('2026-05-05', 'YYYY-MM-DD')
    );

    prc_ins_consulta(
        v_pet_thor,
        v_clinica_hospital,
        TO_DATE('2026-04-12', 'YYYY-MM-DD'),
        'EMERGENCIA',
        'Dificuldade respiratoria',
        'Necessita acompanhamento',
        350.00,
        'S',
        TO_DATE('2026-04-20', 'YYYY-MM-DD')
    );

    prc_ins_consulta(
        v_pet_thor,
        v_clinica_hospital,
        TO_DATE('2026-04-20', 'YYYY-MM-DD'),
        'RETORNO',
        'Retorno da emergencia',
        'Melhora parcial',
        150.00,
        'S',
        TO_DATE('2026-05-20', 'YYYY-MM-DD')
    );

    --------------------------------------------------------
    -- 6. EVENTOS PREVENTIVOS
    --------------------------------------------------------

    prc_ins_evento_preventivo(
        v_pet_rex,
        v_prot_vacina_cao,
        'VACINA',
        'Vacina anual do Rex',
        TO_DATE('2026-04-01', 'YYYY-MM-DD'),
        TO_DATE('2026-04-01', 'YYYY-MM-DD'),
        'REALIZADO'
    );

    prc_ins_evento_preventivo(
        v_pet_rex,
        v_prot_checkup_cao,
        'CHECKUP',
        'Proximo check-up do Rex',
        TO_DATE('2026-09-10', 'YYYY-MM-DD'),
        NULL,
        'PENDENTE'
    );

    prc_ins_evento_preventivo(
        v_pet_luna,
        v_prot_vacina_gato,
        'VACINA',
        'Vacina anual da Luna',
        TO_DATE('2026-08-20', 'YYYY-MM-DD'),
        NULL,
        'PENDENTE'
    );

    prc_ins_evento_preventivo(
        v_pet_thor,
        v_prot_checkup_cao,
        'CHECKUP',
        'Check-up atrasado do Thor',
        TO_DATE('2026-02-01', 'YYYY-MM-DD'),
        NULL,
        'ATRASADO'
    );

    prc_ins_evento_preventivo(
        v_pet_thor,
        NULL,
        'RETORNO',
        'Retorno pos-emergencia do Thor',
        TO_DATE('2026-05-20', 'YYYY-MM-DD'),
        NULL,
        'PENDENTE'
    );

    --------------------------------------------------------
    -- 7. DISPOSITIVOS IOT
    --------------------------------------------------------

    prc_ins_dispositivo_iot(
        v_pet_rex,
        'COLEIRA',
        'COL-RX-001',
        TO_DATE('2026-04-01', 'YYYY-MM-DD')
    );

    prc_ins_dispositivo_iot(
        v_pet_rex,
        'COMEDOURO',
        'COM-RX-001',
        TO_DATE('2026-04-01', 'YYYY-MM-DD')
    );

    prc_ins_dispositivo_iot(
        v_pet_luna,
        'COLEIRA',
        'COL-LU-001',
        TO_DATE('2026-04-02', 'YYYY-MM-DD')
    );

    prc_ins_dispositivo_iot(
        v_pet_thor,
        'COLEIRA',
        'COL-TH-001',
        TO_DATE('2026-04-03', 'YYYY-MM-DD')
    );

    --------------------------------------------------------
    -- 8. LEITURAS DE SENSOR
    -- Leituras de coleira (atividade/bateria), comedouro
    -- (ração/consumo) e ambiente (temperatura/umidade/ar).
    -- Nivel_bateria e os campos de ambiente nao existiam no
    -- desenho antigo (LEITURA_SENSOR generica) - valores
    -- abaixo sao sinteticos, so para ter carga de teste;
    -- ajuste se quiser refletir hardware real.
    --------------------------------------------------------

    -- Leituras de atividade pela coleira do Rex
    prc_ins_leitura_coleira(
        v_pet_rex, 'ATIVO', 95,
        TO_TIMESTAMP('2026-05-01 08:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    prc_ins_leitura_coleira(
        v_pet_rex, 'ATIVO', 93,
        TO_TIMESTAMP('2026-05-01 10:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    prc_ins_leitura_coleira(
        v_pet_rex, 'MODERADO', 91,
        TO_TIMESTAMP('2026-05-01 12:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    prc_ins_leitura_coleira(
        v_pet_rex, 'ATIVO', 89,
        TO_TIMESTAMP('2026-05-01 14:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    prc_ins_leitura_coleira(
        v_pet_rex, 'ATIVO', 87,
        TO_TIMESTAMP('2026-05-01 16:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    -- Leituras do comedouro do Rex (nível de ração + consumo)
    prc_ins_leitura_comedouro(
        v_pet_rex, 45, 120.50,
        TO_TIMESTAMP('2026-05-01 14:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    prc_ins_leitura_comedouro(
        v_pet_rex, 15, 80.00,
        TO_TIMESTAMP('2026-05-01 08:30:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    -- Leitura de ambiente do Rex
    prc_ins_leitura_ambiente(
        v_pet_rex, 24.50, 55, 400, 1,
        TO_TIMESTAMP('2026-05-01 16:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    -- Leituras de atividade dos outros pets
    prc_ins_leitura_coleira(
        v_pet_luna, 'ATIVO', 90,
        TO_TIMESTAMP('2026-05-01 09:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    prc_ins_leitura_coleira(
        v_pet_thor, 'SEDENTARIO', 60,
        TO_TIMESTAMP('2026-05-01 09:30:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    --------------------------------------------------------
    -- 9. SCORES DE SAUDE
    -- O score do Thor gera alerta automaticamente.
    --------------------------------------------------------

    prc_ins_score_saude(
        v_pet_rex,
        72,
        70,
        65,
        80,
        75,
        70
    );

    prc_ins_score_saude(
        v_pet_luna,
        88,
        90,
        85,
        88,
        90,
        87
    );

    prc_ins_score_saude(
        v_pet_thor,
        42,
        30,
        45,
        60,
        40,
        35
    );

    DBMS_OUTPUT.PUT_LINE('Carga de dados de teste finalizada com sucesso.');
END;
/

------------------------------------------------------------
-- CONFERENCIA FINAL
------------------------------------------------------------

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

-- ================================================================================
-- PASSO 16/21 - sql/inserts/02_insert_extra_sprint3.sql
-- Garante que TUTOR, CLINICA e PET cheguem a 5 registros cada
-- ================================================================================

------------------------------------------------------------
-- PETCARE HUB - CARGA COMPLEMENTAR (SPRINT 3)
-- Garante pelo menos 5 registros validos em TUTOR, CLINICA
-- e PET, exigidos pelo Procedimento 1 (JOIN + JSON manual)
-- da rubrica de "Mastering Relational and Non-Relational Database".
-- Roda DEPOIS de 01_insert_testes.sql, sem apagar nada.
------------------------------------------------------------

DECLARE
    v_tutor_diego    NUMBER;
    v_tutor_elaine   NUMBER;

    v_clinica_feliz     NUMBER;
    v_clinica_bemestar  NUMBER;
    v_clinica_amigo     NUMBER;
BEGIN
    --------------------------------------------------------
    -- 2 TUTORES A MAIS (total: 5)
    --------------------------------------------------------

    prc_ins_tutor(
        'Diego Ferreira',
        'diego.ferreira@email.com',
        '11999990004',
        '44444444444'
    );

    prc_ins_tutor(
        'Elaine Costa',
        'elaine.costa@email.com',
        '11999990005',
        '55555555555'
    );

    SELECT id_tutor INTO v_tutor_diego
    FROM TUTOR
    WHERE email = 'diego.ferreira@email.com';

    SELECT id_tutor INTO v_tutor_elaine
    FROM TUTOR
    WHERE email = 'elaine.costa@email.com';

    --------------------------------------------------------
    -- 3 CLINICAS A MAIS (total: 5)
    --------------------------------------------------------

    prc_ins_clinica(
        'Clinica Pet Feliz',
        '33333333000133',
        'contato@petfeliz.com',
        '1130000003',
        'Rua C, 300'
    );

    prc_ins_clinica(
        'Hospital Bem Estar Animal',
        '44444444000144',
        'contato@bemestaranimal.com',
        '1130000004',
        'Rua D, 400'
    );

    prc_ins_clinica(
        'Clinica Amigo Fiel',
        '55555555000155',
        'contato@amigofiel.com',
        '1130000005',
        'Rua E, 500'
    );

    SELECT id_clinica INTO v_clinica_feliz
    FROM CLINICA
    WHERE cnpj = '33333333000133';

    SELECT id_clinica INTO v_clinica_bemestar
    FROM CLINICA
    WHERE cnpj = '44444444000144';

    SELECT id_clinica INTO v_clinica_amigo
    FROM CLINICA
    WHERE cnpj = '55555555000155';

    --------------------------------------------------------
    -- 2 PETS A MAIS (total: 5)
    --------------------------------------------------------

    prc_ins_pet(
        v_tutor_diego,
        v_clinica_feliz,
        'Mel',
        'CAO',
        'Vira-lata',
        TO_DATE('2023-02-14', 'YYYY-MM-DD'),
        12.30,
        'F',
        NULL
    );

    prc_ins_pet(
        v_tutor_elaine,
        v_clinica_bemestar,
        'Nina',
        'GATO',
        'Persa',
        TO_DATE('2022-11-05', 'YYYY-MM-DD'),
        3.80,
        'F',
        NULL
    );

    DBMS_OUTPUT.PUT_LINE('Carga complementar da Sprint 3 finalizada com sucesso.');
END;
/

------------------------------------------------------------
-- CONFERENCIA: cada tabela precisa ter >= 5 registros
------------------------------------------------------------
SELECT 'TUTOR' AS tabela, COUNT(*) AS total FROM TUTOR
UNION ALL
SELECT 'CLINICA', COUNT(*) FROM CLINICA
UNION ALL
SELECT 'PET', COUNT(*) FROM PET;

-- ================================================================================
-- PASSO 17/21 - sql/inserts/03_insert_complemento_carga.sql
-- Completa >= 5 registros em PROTOCOLO_PREVENTIVO, DISPOSITIVO_IOT,
-- LEITURA_COMEDOURO, LEITURA_AMBIENTE e SCORE_SAUDE (ALERTA_SAUDE
-- chega a 5 automaticamente por efeito das procedures)
-- ================================================================================

------------------------------------------------------------
-- PETCARE HUB - CARGA COMPLEMENTAR 2 (fechamento Sprint 3)
-- Completa o minimo de 5 registros validos exigido em
-- PROTOCOLO_PREVENTIVO, DISPOSITIVO_IOT, LEITURA_COMEDOURO,
-- LEITURA_AMBIENTE e SCORE_SAUDE.
--
-- ALERTA_SAUDE chega a 5 como efeito automatico das proprias
-- procedures (uma leitura de comedouro abaixo de 20% e uma
-- leitura de ambiente com qualidade do ar acima de 500ppm),
-- em vez de inserido direto - assim o teste tambem exercita
-- as regras automaticas descritas no README
-- ("Regras Automaticas Implementadas").
--
-- Roda DEPOIS de 02_insert_extra_sprint3.sql, sem apagar nada.
------------------------------------------------------------

DECLARE
    v_pet_rex   NUMBER;
    v_pet_luna  NUMBER;
    v_pet_thor  NUMBER;
    v_pet_mel   NUMBER;
    v_pet_nina  NUMBER;
BEGIN
    SELECT id_pet INTO v_pet_rex  FROM PET WHERE nome = 'Rex';
    SELECT id_pet INTO v_pet_luna FROM PET WHERE nome = 'Luna';
    SELECT id_pet INTO v_pet_thor FROM PET WHERE nome = 'Thor';
    SELECT id_pet INTO v_pet_mel  FROM PET WHERE nome = 'Mel';
    SELECT id_pet INTO v_pet_nina FROM PET WHERE nome = 'Nina';

    --------------------------------------------------------
    -- 1 PROTOCOLO_PREVENTIVO A MAIS (total: 5)
    --------------------------------------------------------

    prc_ins_protocolo_preventivo(
        'CAO',
        NULL,
        'VERMIFUGO',
        'Vermifugacao semestral para caes',
        3,
        180
    );

    --------------------------------------------------------
    -- 1 DISPOSITIVO_IOT A MAIS (total: 5)
    --------------------------------------------------------

    prc_ins_dispositivo_iot(
        v_pet_rex,
        'AMBIENTE',
        'AMB-RX-001',
        TO_DATE('2026-05-01', 'YYYY-MM-DD')
    );

    --------------------------------------------------------
    -- 3 LEITURA_COMEDOURO A MAIS (total: 5)
    -- A leitura do Thor fica abaixo de 20% de proposito para
    -- gerar o alerta automatico RACAO_BAIXA.
    --------------------------------------------------------

    prc_ins_leitura_comedouro(
        v_pet_luna, 65, 90.00,
        TO_TIMESTAMP('2026-05-02 09:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    prc_ins_leitura_comedouro(
        v_pet_thor, 18, 60.00,
        TO_TIMESTAMP('2026-05-02 10:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    prc_ins_leitura_comedouro(
        v_pet_rex, 70, 130.00,
        TO_TIMESTAMP('2026-05-02 14:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    --------------------------------------------------------
    -- 4 LEITURA_AMBIENTE A MAIS (total: 5)
    -- A leitura da Nina fica com qualidade do ar acima de
    -- 500ppm de proposito para gerar o alerta automatico
    -- QUALIDADE_AR_RUIM.
    --------------------------------------------------------

    prc_ins_leitura_ambiente(
        v_pet_luna, 23.00, 50, 380, 1,
        TO_TIMESTAMP('2026-05-02 09:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    prc_ins_leitura_ambiente(
        v_pet_thor, 25.50, 60, 420, 1,
        TO_TIMESTAMP('2026-05-02 10:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    prc_ins_leitura_ambiente(
        v_pet_mel, 22.00, 55, 350, 1,
        TO_TIMESTAMP('2026-05-02 11:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    prc_ins_leitura_ambiente(
        v_pet_nina, 24.00, 58, 560, 1,
        TO_TIMESTAMP('2026-05-02 12:00:00', 'YYYY-MM-DD HH24:MI:SS')
    );

    --------------------------------------------------------
    -- 2 SCORE_SAUDE A MAIS (total: 5)
    --------------------------------------------------------

    prc_ins_score_saude(
        v_pet_mel, 78, 75, 80, 70, 80, 75
    );

    prc_ins_score_saude(
        v_pet_nina, 91, 92, 90, 88, 93, 90
    );

    DBMS_OUTPUT.PUT_LINE('Carga complementar 2 finalizada com sucesso.');
END;
/

------------------------------------------------------------
-- CONFERENCIA: cada tabela precisa ter >= 5 registros
------------------------------------------------------------

SELECT 'PROTOCOLO_PREVENTIVO' AS tabela, COUNT(*) AS total FROM PROTOCOLO_PREVENTIVO
UNION ALL
SELECT 'DISPOSITIVO_IOT', COUNT(*) FROM DISPOSITIVO_IOT
UNION ALL
SELECT 'LEITURA_COMEDOURO', COUNT(*) FROM LEITURA_COMEDOURO
UNION ALL
SELECT 'LEITURA_AMBIENTE', COUNT(*) FROM LEITURA_AMBIENTE
UNION ALL
SELECT 'SCORE_SAUDE', COUNT(*) FROM SCORE_SAUDE
UNION ALL
SELECT 'ALERTA_SAUDE', COUNT(*) FROM ALERTA_SAUDE;

-- ================================================================================
-- PASSO 18/21 - sql/procedures/04_procedures_relatorios_sprint3.sql
-- Cria prc_rel_pets_tutor_clinica_json e prc_rel_consultas_subtotal
-- (as 2 procedures da rubrica Sprint 3), ja executando sucesso + excecao
-- ================================================================================

------------------------------------------------------------
-- PETCARE HUB - PROCEDURES DA RUBRICA (SPRINT 3)
-- "Mastering Relational and Non-Relational Database"
-- Depende de: fn_pet_para_json (sql/functions/02_functions_json_senha.sql)
--             prc_registrar_log_erro (sql/procedures/01_log_erros.sql)
------------------------------------------------------------

------------------------------------------------------------
-- PROCEDIMENTO 1: JOIN entre PET, TUTOR e CLINICA, convertido
-- manualmente para JSON via fn_pet_para_json (sem TO_JSON/
-- JSON_OBJECT). Exige >= 5 registros validos em cada tabela.
------------------------------------------------------------

CREATE OR REPLACE PROCEDURE prc_rel_pets_tutor_clinica_json AS
    CURSOR c_pets IS
        SELECT p.id_pet,
               p.nome AS nome_pet,
               p.especie,
               t.nome AS nome_tutor,
               t.email AS email_tutor,
               c.nome AS nome_clinica
        FROM PET p
        JOIN TUTOR t ON t.id_tutor = p.id_tutor
        JOIN CLINICA c ON c.id_clinica = p.id_clinica
        ORDER BY p.id_pet;

    v_json_array    VARCHAR2(32767) := '[';
    v_primeiro      BOOLEAN := TRUE;
    v_total_linhas  NUMBER := 0;

    e_sem_registros     EXCEPTION;
    e_dados_incompletos EXCEPTION;
BEGIN
    FOR r IN c_pets LOOP
        IF TRIM(r.nome_pet) IS NULL OR TRIM(r.nome_tutor) IS NULL OR TRIM(r.nome_clinica) IS NULL THEN
            RAISE e_dados_incompletos;
        END IF;

        IF NOT v_primeiro THEN
            v_json_array := v_json_array || ',';
        END IF;

        v_json_array := v_json_array || fn_pet_para_json(
            r.id_pet, r.nome_pet, r.especie, r.nome_tutor, r.email_tutor, r.nome_clinica
        );

        v_primeiro := FALSE;
        v_total_linhas := v_total_linhas + 1;
    END LOOP;

    v_json_array := v_json_array || ']';

    IF v_total_linhas = 0 THEN
        RAISE e_sem_registros;
    END IF;

    DBMS_OUTPUT.PUT_LINE('===== JSON GERADO (PET + TUTOR + CLINICA) =====');
    DBMS_OUTPUT.PUT_LINE(v_json_array);
    DBMS_OUTPUT.PUT_LINE('Total de registros: ' || v_total_linhas);

EXCEPTION
    WHEN e_sem_registros THEN
        prc_registrar_log_erro('PRC_REL_PETS_TUTOR_CLINICA_JSON', -20201, 'Nenhum pet encontrado para gerar JSON.');
        DBMS_OUTPUT.PUT_LINE('Nenhum registro encontrado para gerar o JSON.');

    WHEN e_dados_incompletos THEN
        prc_registrar_log_erro('PRC_REL_PETS_TUTOR_CLINICA_JSON', -20204, 'Registro com nome de pet, tutor ou clinica em branco.');
        DBMS_OUTPUT.PUT_LINE('Registro com dado obrigatorio em branco encontrado ao montar o JSON.');

    WHEN VALUE_ERROR THEN
        prc_registrar_log_erro('PRC_REL_PETS_TUTOR_CLINICA_JSON', SQLCODE, SQLERRM);

    WHEN OTHERS THEN
        prc_registrar_log_erro('PRC_REL_PETS_TUTOR_CLINICA_JSON', SQLCODE, SQLERRM);
END;
/

------------------------------------------------------------
-- PROCEDIMENTO 2: le CONSULTA (fato) categorizada por
-- CLINICA (categoria 1) e TIPO_CONSULTA (categoria 2), com
-- VALOR (numerico). Agrupa combinacoes repetidas de
-- clinica+tipo (SUM manual) e trata VALOR nulo com NVL antes
-- de somar, para nao invalidar o subtotal/total geral.
-- Subtotal por clinica e total geral calculados manualmente,
-- sem ROLLUP/CUBE/GROUPING SETS.
------------------------------------------------------------

CREATE OR REPLACE PROCEDURE prc_rel_consultas_subtotal AS
    CURSOR c_consultas IS
        SELECT c.nome AS categoria1_clinica,
               co.tipo_consulta AS categoria2_tipo,
               SUM(NVL(co.valor, 0)) AS valor
        FROM CONSULTA co
        JOIN CLINICA c ON c.id_clinica = co.id_clinica
        GROUP BY c.nome, co.tipo_consulta
        ORDER BY c.nome, co.tipo_consulta;

    v_categoria1_atual  VARCHAR2(120) := NULL;
    v_subtotal          NUMBER := 0;
    v_total_geral        NUMBER := 0;
    v_qtd_linhas         NUMBER := 0;

    e_sem_registros      EXCEPTION;
    e_valor_negativo     EXCEPTION;
    e_clinica_sem_nome   EXCEPTION;
BEGIN
    DBMS_OUTPUT.PUT_LINE('===== RELATORIO - CONSULTAS POR CLINICA E TIPO (SUBTOTAL MANUAL) =====');
    DBMS_OUTPUT.PUT_LINE(RPAD('CLINICA', 28) || RPAD('TIPO', 15) || 'VALOR');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------');

    FOR r IN c_consultas LOOP
        IF TRIM(r.categoria1_clinica) IS NULL THEN
            RAISE e_clinica_sem_nome;
        END IF;

        IF r.valor < 0 THEN
            RAISE e_valor_negativo;
        END IF;

        IF v_categoria1_atual IS NOT NULL AND v_categoria1_atual <> r.categoria1_clinica THEN
            DBMS_OUTPUT.PUT_LINE(
                RPAD(v_categoria1_atual, 28) || RPAD('Sub Total', 15) || TO_CHAR(v_subtotal, '999G990D00')
            );
            v_subtotal := 0;
        END IF;

        v_categoria1_atual := r.categoria1_clinica;

        DBMS_OUTPUT.PUT_LINE(
            RPAD(r.categoria1_clinica, 28) || RPAD(r.categoria2_tipo, 15) || TO_CHAR(r.valor, '999G990D00')
        );

        v_subtotal := v_subtotal + r.valor;
        v_total_geral := v_total_geral + r.valor;
        v_qtd_linhas := v_qtd_linhas + 1;
    END LOOP;

    IF v_qtd_linhas = 0 THEN
        RAISE e_sem_registros;
    END IF;

    DBMS_OUTPUT.PUT_LINE(
        RPAD(v_categoria1_atual, 28) || RPAD('Sub Total', 15) || TO_CHAR(v_subtotal, '999G990D00')
    );
    DBMS_OUTPUT.PUT_LINE(
        RPAD(' ', 28) || RPAD('Total Geral', 15) || TO_CHAR(v_total_geral, '999G990D00')
    );

EXCEPTION
    WHEN e_sem_registros THEN
        prc_registrar_log_erro('PRC_REL_CONSULTAS_SUBTOTAL', -20202, 'Nenhuma consulta encontrada para o relatorio.');
        DBMS_OUTPUT.PUT_LINE('Nenhuma consulta encontrada.');

    WHEN e_valor_negativo THEN
        prc_registrar_log_erro('PRC_REL_CONSULTAS_SUBTOTAL', -20203, 'Valor de consulta negativo detectado.');
        DBMS_OUTPUT.PUT_LINE('Valor de consulta invalido (negativo) encontrado.');

    WHEN e_clinica_sem_nome THEN
        prc_registrar_log_erro('PRC_REL_CONSULTAS_SUBTOTAL', -20205, 'Clinica sem nome valido (em branco) encontrada.');
        DBMS_OUTPUT.PUT_LINE('Clinica com nome em branco encontrada no relatorio.');

    WHEN OTHERS THEN
        prc_registrar_log_erro('PRC_REL_CONSULTAS_SUBTOTAL', SQLCODE, SQLERRM);
END;
/

------------------------------------------------------------
-- TESTE / EVIDENCIA (tirar print desses resultados)
------------------------------------------------------------

EXEC prc_rel_pets_tutor_clinica_json;
EXEC prc_rel_consultas_subtotal;

------------------------------------------------------------
-- TESTE / EVIDENCIA DE EXCECAO (tirar print para o PDF)
--
-- Cada bloco insere um registro com nome em branco (passa pelo
-- NOT NULL da tabela porque nao e string vazia, so espacos) ja
-- ligado por FK ao resto da carga, para forcar de verdade a
-- excecao especifica de cada procedimento. No final, desfaz os
-- inserts de teste para nao sujar a carga oficial.
------------------------------------------------------------

-- 1) Excecao de PRC_REL_CONSULTAS_SUBTOTAL (e_clinica_sem_nome)
-- Precisa de uma CONSULTA vinculada, senao o INNER JOIN nunca
-- traz essa clinica pro cursor.
INSERT INTO CLINICA (id_clinica, nome, cnpj, ativo)
VALUES (seq_clinica.NEXTVAL, '   ', '99999999000199', 'S');

INSERT INTO CONSULTA (id_consulta, id_pet, id_clinica, data_consulta, tipo_consulta, valor, retorno_recomendado)
SELECT seq_consulta.NEXTVAL, p.id_pet, c.id_clinica, SYSDATE, 'CHECKUP', 100.00, 'N'
FROM PET p, CLINICA c
WHERE p.nome = 'Rex' AND c.cnpj = '99999999000199';
COMMIT;

EXEC prc_rel_consultas_subtotal;
-- Esperado: "Clinica com nome em branco encontrada no relatorio."

DELETE FROM CONSULTA WHERE id_clinica = (SELECT id_clinica FROM CLINICA WHERE cnpj = '99999999000199');
DELETE FROM CLINICA WHERE cnpj = '99999999000199';
COMMIT;

-- 2) Excecao de PRC_REL_PETS_TUTOR_CLINICA_JSON (e_dados_incompletos)
INSERT INTO PET (id_pet, id_tutor, id_clinica, nome, especie, peso_kg, ativo)
SELECT seq_pet.NEXTVAL, t.id_tutor, c.id_clinica, '   ', 'CAO', 5.00, 'S'
FROM TUTOR t, CLINICA c
WHERE t.email = 'ana.souza@email.com' AND c.cnpj = '11111111000111';
COMMIT;

EXEC prc_rel_pets_tutor_clinica_json;
-- Esperado: "Registro com dado obrigatorio em branco encontrado ao montar o JSON."

DELETE FROM PET
WHERE TRIM(nome) IS NULL
  AND id_tutor = (SELECT id_tutor FROM TUTOR WHERE email = 'ana.souza@email.com');
COMMIT;

SELECT * FROM LOG_ERROS ORDER BY data_ocorrencia DESC;

-- ================================================================================
-- PASSO 19/21 - sql/relatorios/01_joins_group_order.sql
-- Relatorios com JOIN, GROUP BY e ORDER BY
-- ================================================================================

------------------------------------------------------------
-- PETCARE HUB - RELATÓRIOS COM JOIN, GROUP BY E ORDER BY
-- Arquivo 01_joins_group_order.sql
--
-- Ajuste:
-- Cada consulta abaixo usa pelo menos 3 JOINs reais.
-- 4 tabelas conectadas = 3 JOINs.
------------------------------------------------------------

------------------------------------------------------------
-- BLOCO ANÔNIMO 1
------------------------------------------------------------

DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('RELATÓRIO 1 - TOTAL DE PETS POR CLÍNICA, TUTOR E ESPÉCIE');
    DBMS_OUTPUT.PUT_LINE('====================================================');

    FOR r IN (
        SELECT
            c.nome AS clinica,
            resp.nome AS tutor,
            p.especie,
            COUNT(DISTINCT p.id_pet) AS total_pets,
            COUNT(DISTINCT co.id_consulta) AS total_consultas
        FROM CLINICA c
        JOIN PET p
            ON p.id_clinica = c.id_clinica
        JOIN TUTOR resp
            ON resp.id_tutor = p.id_tutor
        JOIN CONSULTA co
            ON co.id_pet = p.id_pet
        GROUP BY
            c.nome,
            resp.nome,
            p.especie
        ORDER BY
            c.nome,
            resp.nome,
            p.especie
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Clínica: ' || r.clinica ||
            ' | Tutor: ' || r.tutor ||
            ' | Espécie: ' || r.especie ||
            ' | Total de pets: ' || r.total_pets ||
            ' | Total de consultas: ' || r.total_consultas
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(CHR(10));
    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('RELATÓRIO 2 - TOTAL DE CONSULTAS POR CLÍNICA, TUTOR E TIPO');
    DBMS_OUTPUT.PUT_LINE('====================================================');

    FOR r IN (
        SELECT
            c.nome AS clinica,
            resp.nome AS tutor,
            co.tipo_consulta,
            COUNT(co.id_consulta) AS total_consultas,
            SUM(co.valor) AS valor_total
        FROM CLINICA c
        JOIN CONSULTA co
            ON co.id_clinica = c.id_clinica
        JOIN PET p
            ON p.id_pet = co.id_pet
        JOIN TUTOR resp
            ON resp.id_tutor = p.id_tutor
        GROUP BY
            c.nome,
            resp.nome,
            co.tipo_consulta
        ORDER BY
            c.nome,
            total_consultas DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Clínica: ' || r.clinica ||
            ' | Tutor: ' || r.tutor ||
            ' | Tipo: ' || r.tipo_consulta ||
            ' | Total: ' || r.total_consultas ||
            ' | Valor total: R$ ' || NVL(r.valor_total, 0)
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(CHR(10));
    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('RELATÓRIO 3 - MÉDIA DE SCORE POR CLÍNICA, TUTOR E ESPÉCIE');
    DBMS_OUTPUT.PUT_LINE('====================================================');

    FOR r IN (
        SELECT
            c.nome AS clinica,
            resp.nome AS tutor,
            p.especie,
            ROUND(AVG(s.score_total), 2) AS media_score,
            COUNT(DISTINCT p.id_pet) AS total_pets
        FROM CLINICA c
        JOIN PET p
            ON p.id_clinica = c.id_clinica
        JOIN TUTOR resp
            ON resp.id_tutor = p.id_tutor
        JOIN SCORE_SAUDE s
            ON s.id_pet = p.id_pet
        GROUP BY
            c.nome,
            resp.nome,
            p.especie
        ORDER BY
            media_score DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Clínica: ' || r.clinica ||
            ' | Tutor: ' || r.tutor ||
            ' | Espécie: ' || r.especie ||
            ' | Média de score: ' || r.media_score ||
            ' | Total de pets avaliados: ' || r.total_pets
        );
    END LOOP;
END;
/

------------------------------------------------------------
-- BLOCO ANÔNIMO 2
------------------------------------------------------------

DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('RELATÓRIO 4 - ALERTAS ABERTOS POR CLÍNICA, TUTOR E NÍVEL');
    DBMS_OUTPUT.PUT_LINE('====================================================');

    FOR r IN (
        SELECT
            c.nome AS clinica,
            resp.nome AS tutor,
            a.nivel_alerta,
            COUNT(a.id_alerta) AS total_alertas
        FROM CLINICA c
        JOIN PET p
            ON p.id_clinica = c.id_clinica
        JOIN TUTOR resp
            ON resp.id_tutor = p.id_tutor
        JOIN ALERTA_SAUDE a
            ON a.id_pet = p.id_pet
        WHERE a.resolvido = 'N'
        GROUP BY
            c.nome,
            resp.nome,
            a.nivel_alerta
        ORDER BY
            total_alertas DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Clínica: ' || r.clinica ||
            ' | Tutor: ' || r.tutor ||
            ' | Nível: ' || r.nivel_alerta ||
            ' | Total de alertas: ' || r.total_alertas
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(CHR(10));
    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('RELATÓRIO 5 - EVENTOS PREVENTIVOS POR CLÍNICA, PET E STATUS');
    DBMS_OUTPUT.PUT_LINE('====================================================');

    FOR r IN (
        SELECT
            c.nome AS clinica,
            resp.nome AS tutor,
            p.nome AS pet,
            ep.status,
            COUNT(ep.id_evento) AS total_eventos
        FROM CLINICA c
        JOIN PET p
            ON p.id_clinica = c.id_clinica
        JOIN TUTOR resp
            ON resp.id_tutor = p.id_tutor
        JOIN EVENTO_PREVENTIVO ep
            ON ep.id_pet = p.id_pet
        GROUP BY
            c.nome,
            resp.nome,
            p.nome,
            ep.status
        ORDER BY
            c.nome,
            p.nome,
            ep.status
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Clínica: ' || r.clinica ||
            ' | Tutor: ' || r.tutor ||
            ' | Pet: ' || r.pet ||
            ' | Status: ' || r.status ||
            ' | Total de eventos: ' || r.total_eventos
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(CHR(10));
    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('RELATÓRIO 6 - LEITURAS POR CLÍNICA, PET E TIPO');
    DBMS_OUTPUT.PUT_LINE('====================================================');

    FOR r IN (
        SELECT
            c.nome AS clinica,
            resp.nome AS tutor,
            p.nome AS pet,
            ls.tipo_leitura,
            COUNT(*) AS total_leituras,
            ROUND(AVG(ls.valor), 2) AS media_valor
        FROM CLINICA c
        JOIN PET p
            ON p.id_clinica = c.id_clinica
        JOIN TUTOR resp
            ON resp.id_tutor = p.id_tutor
        JOIN (
            SELECT id_pet, 'NIVEL_BATERIA_COLEIRA' AS tipo_leitura, nivel_bateria AS valor
            FROM LEITURA_COLEIRA
            UNION ALL
            SELECT id_pet, 'NIVEL_RACAO' AS tipo_leitura, nivel_racao_pct AS valor
            FROM LEITURA_COMEDOURO
            UNION ALL
            SELECT id_pet, 'TEMPERATURA_AMBIENTE' AS tipo_leitura, temperatura_ambiente AS valor
            FROM LEITURA_AMBIENTE
        ) ls
            ON ls.id_pet = p.id_pet
        GROUP BY
            c.nome,
            resp.nome,
            p.nome,
            ls.tipo_leitura
        ORDER BY
            c.nome,
            p.nome,
            ls.tipo_leitura
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Clínica: ' || r.clinica ||
            ' | Tutor: ' || r.tutor ||
            ' | Pet: ' || r.pet ||
            ' | Tipo leitura: ' || r.tipo_leitura ||
            ' | Total: ' || r.total_leituras ||
            ' | Média: ' || r.media_valor
        );
    END LOOP;
END;
/

-- ================================================================================
-- PASSO 20/21 - sql/relatorios/02_lag_lead.sql
-- Relatorio com LAG e LEAD (leituras de bateria da coleira do Rex)
-- ================================================================================

------------------------------------------------------------
-- PETCARE HUB - RELATÓRIO COM LAG E LEAD
-- Arquivo 02_lag_lead.sql
--
-- Objetivo:
-- Mostrar, na mesma linha:
-- valor anterior, valor atual e próximo valor.
--
-- Base usada:
-- Leituras de nível de bateria da coleira do pet Rex.
--
-- Observação:
-- O insert de teste precisa ter pelo menos 5 leituras
-- de coleira para o Rex.
------------------------------------------------------------

DECLARE
    v_total_linhas NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('RELATORIO - BATERIA DA COLEIRA DO PET COM LAG E LEAD');
    DBMS_OUTPUT.PUT_LINE('ANTERIOR | ATUAL | PROXIMA');
    DBMS_OUTPUT.PUT_LINE('====================================================');

    FOR r IN (
        SELECT
            p.nome AS nome_pet,
            ls.timestamp_leitura,
            LAG(ls.nivel_bateria) OVER (
                PARTITION BY ls.id_pet
                ORDER BY ls.timestamp_leitura
            ) AS valor_anterior,
            ls.nivel_bateria AS valor_atual,
            LEAD(ls.nivel_bateria) OVER (
                PARTITION BY ls.id_pet
                ORDER BY ls.timestamp_leitura
            ) AS valor_proximo
        FROM LEITURA_COLEIRA ls
        JOIN PET p
            ON p.id_pet = ls.id_pet
        WHERE p.nome = 'Rex'
        ORDER BY ls.timestamp_leitura
    ) LOOP
        v_total_linhas := v_total_linhas + 1;

        DBMS_OUTPUT.PUT_LINE(
            'Pet: ' || r.nome_pet ||
            ' | Data: ' || TO_CHAR(r.timestamp_leitura, 'DD/MM/YYYY HH24:MI') ||
            ' | Anterior: ' || NVL(TO_CHAR(r.valor_anterior), 'Vazio') ||
            ' | Atual: ' || TO_CHAR(r.valor_atual) ||
            ' | Proxima: ' || NVL(TO_CHAR(r.valor_proximo), 'Vazio') ||
            ' | Unidade: %'
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('Total de linhas exibidas: ' || v_total_linhas);

    IF v_total_linhas < 5 THEN
        DBMS_OUTPUT.PUT_LINE('ATENCAO: o relatorio precisa exibir pelo menos 5 linhas.');
        DBMS_OUTPUT.PUT_LINE('Verifique se existem 5 leituras de coleira para o pet Rex.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('OK: relatorio com pelo menos 5 linhas.');
    END IF;

    DBMS_OUTPUT.PUT_LINE('====================================================');
END;
/

-- ================================================================================
-- PASSO 21/21 - sql/relatorios/03_cursores.sql
-- Relatorios com cursores explicitos e tomada de decisao
-- ================================================================================

------------------------------------------------------------
-- PETCARE HUB - RELATÓRIOS COM CURSOR EXPLÍCITO
-- Arquivo 03_cursores.sql
------------------------------------------------------------


------------------------------------------------------------
-- BLOCO 1
-- Lista scores, calcula subtotal por categoria e total geral
------------------------------------------------------------

DECLARE
    CURSOR c_scores IS
        SELECT
            s.categoria,
            p.nome AS nome_pet,
            s.score_total,
            s.score_atividade,
            s.score_alimentacao,
            s.score_ambiente,
            s.score_consulta,
            s.score_preventivo,
            s.data_calculo
        FROM SCORE_SAUDE s
        JOIN PET p ON p.id_pet = s.id_pet
        ORDER BY s.categoria, s.score_total DESC;

    v_categoria_atual  VARCHAR2(20) := NULL;
    v_subtotal_score   NUMBER := 0;
    v_qtd_categoria    NUMBER := 0;
    v_total_geral      NUMBER := 0;
    v_qtd_geral        NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('RELATÓRIO 1 - SCORES POR CATEGORIA');
    DBMS_OUTPUT.PUT_LINE('====================================================');

    FOR r IN c_scores LOOP

        IF v_categoria_atual IS NOT NULL
           AND v_categoria_atual <> r.categoria THEN

            DBMS_OUTPUT.PUT_LINE(
                'Subtotal categoria ' || v_categoria_atual ||
                ' | Quantidade: ' || v_qtd_categoria ||
                ' | Média score: ' || ROUND(v_subtotal_score / v_qtd_categoria, 2)
            );

            DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');

            v_subtotal_score := 0;
            v_qtd_categoria := 0;
        END IF;

        v_categoria_atual := r.categoria;

        DBMS_OUTPUT.PUT_LINE(
            'Categoria: ' || r.categoria ||
            ' | Pet: ' || r.nome_pet ||
            ' | Score total: ' || r.score_total ||
            ' | Atividade: ' || r.score_atividade ||
            ' | Alimentação: ' || r.score_alimentacao ||
            ' | Ambiente: ' || r.score_ambiente ||
            ' | Consulta: ' || r.score_consulta ||
            ' | Preventivo: ' || r.score_preventivo
        );

        v_subtotal_score := v_subtotal_score + r.score_total;
        v_qtd_categoria := v_qtd_categoria + 1;

        v_total_geral := v_total_geral + r.score_total;
        v_qtd_geral := v_qtd_geral + 1;
    END LOOP;

    IF v_qtd_categoria > 0 THEN
        DBMS_OUTPUT.PUT_LINE(
            'Subtotal categoria ' || v_categoria_atual ||
            ' | Quantidade: ' || v_qtd_categoria ||
            ' | Média score: ' || ROUND(v_subtotal_score / v_qtd_categoria, 2)
        );
    END IF;

    DBMS_OUTPUT.PUT_LINE('====================================================');

    IF v_qtd_geral > 0 THEN
        DBMS_OUTPUT.PUT_LINE(
            'Total geral de registros: ' || v_qtd_geral ||
            ' | Média geral de score: ' || ROUND(v_total_geral / v_qtd_geral, 2)
        );
    END IF;
END;
/


------------------------------------------------------------
-- BLOCO 2
-- Alertas com tomada de decisão
------------------------------------------------------------

DECLARE
    CURSOR c_alertas IS
        SELECT
            p.nome AS nome_pet,
            a.tipo_alerta,
            a.nivel_alerta,
            a.mensagem,
            a.valor_detectado,
            a.limite_referencia,
            a.resolvido
        FROM ALERTA_SAUDE a
        JOIN PET p ON p.id_pet = a.id_pet
        ORDER BY a.nivel_alerta, p.nome;

    v_acao VARCHAR2(200);
BEGIN
    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('RELATÓRIO 2 - ALERTAS E AÇÃO RECOMENDADA');
    DBMS_OUTPUT.PUT_LINE('====================================================');

    FOR r IN c_alertas LOOP

        IF r.nivel_alerta = 'CRITICO' THEN
            v_acao := 'Acionar a clínica imediatamente';

        ELSIF r.nivel_alerta = 'ALTO' THEN
            v_acao := 'Priorizar contato com o tutor';

        ELSIF r.nivel_alerta = 'MEDIO' THEN
            v_acao := 'Monitorar nas próximas horas';

        ELSE
            v_acao := 'Acompanhar rotina';
        END IF;

        DBMS_OUTPUT.PUT_LINE(
            'Pet: ' || r.nome_pet ||
            ' | Tipo: ' || r.tipo_alerta ||
            ' | Nível: ' || r.nivel_alerta ||
            ' | Valor: ' || NVL(TO_CHAR(r.valor_detectado), 'N/A') ||
            ' | Limite: ' || NVL(TO_CHAR(r.limite_referencia), 'N/A') ||
            ' | Resolvido: ' || r.resolvido ||
            ' | Ação: ' || v_acao
        );
    END LOOP;
END;
/


------------------------------------------------------------
-- BLOCO 3
-- Eventos preventivos com tomada de decisão
------------------------------------------------------------

DECLARE
    CURSOR c_eventos IS
        SELECT
            p.nome AS nome_pet,
            ep.tipo_evento,
            ep.descricao,
            ep.data_prevista,
            ep.data_realizacao,
            ep.status
        FROM EVENTO_PREVENTIVO ep
        JOIN PET p ON p.id_pet = ep.id_pet
        ORDER BY ep.data_prevista;

    v_situacao VARCHAR2(200);
BEGIN
    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('RELATÓRIO 3 - EVENTOS PREVENTIVOS');
    DBMS_OUTPUT.PUT_LINE('====================================================');

    FOR r IN c_eventos LOOP

        IF r.status = 'ATRASADO' THEN
            v_situacao := 'Evento atrasado. Tutor deve ser notificado.';

        ELSIF r.status = 'PENDENTE'
              AND r.data_prevista <= SYSDATE + 30 THEN
            v_situacao := 'Evento próximo. Enviar lembrete.';

        ELSIF r.status = 'REALIZADO' THEN
            v_situacao := 'Evento concluído.';

        ELSIF r.status = 'CANCELADO' THEN
            v_situacao := 'Evento cancelado.';

        ELSE
            v_situacao := 'Acompanhar normalmente.';
        END IF;

        DBMS_OUTPUT.PUT_LINE(
            'Pet: ' || r.nome_pet ||
            ' | Evento: ' || r.tipo_evento ||
            ' | Descrição: ' || r.descricao ||
            ' | Previsto: ' || TO_CHAR(r.data_prevista, 'DD/MM/YYYY') ||
            ' | Status: ' || r.status ||
            ' | Situação: ' || v_situacao
        );
    END LOOP;
END;
/


------------------------------------------------------------
-- BLOCO 4
-- Consultas por clínica com subtotal e total geral
------------------------------------------------------------

DECLARE
    CURSOR c_consultas IS
        SELECT
            c.nome AS nome_clinica,
            co.tipo_consulta,
            co.valor
        FROM CONSULTA co
        JOIN CLINICA c ON c.id_clinica = co.id_clinica
        ORDER BY c.nome, co.tipo_consulta;

    v_clinica_atual VARCHAR2(120) := NULL;
    v_subtotal      NUMBER := 0;
    v_total_geral   NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('RELATÓRIO 4 - VALOR DE CONSULTAS POR CLÍNICA');
    DBMS_OUTPUT.PUT_LINE('====================================================');

    FOR r IN c_consultas LOOP

        IF v_clinica_atual IS NOT NULL
           AND v_clinica_atual <> r.nome_clinica THEN

            DBMS_OUTPUT.PUT_LINE(
                'Subtotal da clínica ' || v_clinica_atual ||
                ': R$ ' || TO_CHAR(v_subtotal, '999G999G990D00')
            );

            DBMS_OUTPUT.PUT_LINE('----------------------------------------------------');

            v_subtotal := 0;
        END IF;

        v_clinica_atual := r.nome_clinica;

        DBMS_OUTPUT.PUT_LINE(
            'Clínica: ' || r.nome_clinica ||
            ' | Tipo consulta: ' || r.tipo_consulta ||
            ' | Valor: R$ ' || TO_CHAR(NVL(r.valor, 0), '999G999G990D00')
        );

        v_subtotal := v_subtotal + NVL(r.valor, 0);
        v_total_geral := v_total_geral + NVL(r.valor, 0);
    END LOOP;

    IF v_clinica_atual IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE(
            'Subtotal da clínica ' || v_clinica_atual ||
            ': R$ ' || TO_CHAR(v_subtotal, '999G999G990D00')
        );
    END IF;

    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE(
        'Total geral das consultas: R$ ' ||
        TO_CHAR(v_total_geral, '999G999G990D00')
    );
END;
/

------------------------------------------------------------------------------
-- FIM DO SCRIPT COMPLETO
-- Se chegou ate aqui sem nenhum ORA- no meio do caminho, rode:
--   SELECT * FROM LOG_ERROS;
-- e confirme que so aparecem as 2 linhas de teste de excecao do
-- PASSO 18 (codigos -20204 e -20205), sem nenhum erro inesperado.
------------------------------------------------------------------------------
