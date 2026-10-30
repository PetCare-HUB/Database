------------------------------------------------------------
-- PKG_UTIL -- Funcoes de calculo e formatacao reutilizadas pelo resto do sistema.
------------------------------------------------------------

CREATE OR REPLACE PACKAGE pkg_util AS

    -- Sao funcoes puras de leitura: recebem parametros, consultam e devolvem um
    -- valor, sem gravar nada. Duas delas (fn_score_medio_pet e
    -- fn_calcular_idade_pet) sao chamadas pela API Java em
    -- GET /pets/{id}/score-saude/media.

    FUNCTION fn_calcular_idade_pet (
        p_id_pet IN NUMBER
    ) RETURN NUMBER;

    FUNCTION fn_score_medio_pet (
        p_id_pet IN NUMBER,
        p_dias   IN NUMBER
    ) RETURN NUMBER;

    FUNCTION fn_pet_para_json (
        p_id_pet        IN NUMBER,
        p_nome_pet      IN VARCHAR2,
        p_especie_pet   IN VARCHAR2,
        p_nome_tutor    IN VARCHAR2,
        p_email_tutor   IN VARCHAR2,
        p_nome_clinica  IN VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION fn_validar_forca_senha (
        p_senha IN VARCHAR2
    ) RETURN VARCHAR2;

END pkg_util;
/

CREATE OR REPLACE PACKAGE BODY pkg_util AS

    -- Origem: 01_functions.sql:7
    FUNCTION fn_calcular_idade_pet (
        p_id_pet IN NUMBER
    ) RETURN NUMBER AS
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

    -- Origem: 01_functions.sql:37
    FUNCTION fn_score_medio_pet (
        p_id_pet IN NUMBER,
        p_dias   IN NUMBER
    ) RETURN NUMBER AS
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

    -- Origem: 02_functions_json_senha.sql:14
    FUNCTION fn_pet_para_json (
        p_id_pet        IN NUMBER,
        p_nome_pet      IN VARCHAR2,
        p_especie_pet   IN VARCHAR2,
        p_nome_tutor    IN VARCHAR2,
        p_email_tutor   IN VARCHAR2,
        p_nome_clinica  IN VARCHAR2
    ) RETURN VARCHAR2 AS
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

    -- Origem: 02_functions_json_senha.sql:82
    FUNCTION fn_validar_forca_senha (
        p_senha IN VARCHAR2
    ) RETURN VARCHAR2 AS
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

END pkg_util;
/
