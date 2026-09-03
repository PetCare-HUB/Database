SET SERVEROUTPUT ON;

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