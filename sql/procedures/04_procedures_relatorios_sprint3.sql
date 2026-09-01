SET SERVEROUTPUT ON;

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

    e_sem_registros EXCEPTION;
BEGIN
    FOR r IN c_pets LOOP
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

    WHEN VALUE_ERROR THEN
        prc_registrar_log_erro('PRC_REL_PETS_TUTOR_CLINICA_JSON', SQLCODE, SQLERRM);

    WHEN OTHERS THEN
        prc_registrar_log_erro('PRC_REL_PETS_TUTOR_CLINICA_JSON', SQLCODE, SQLERRM);
END;
/

------------------------------------------------------------
-- PROCEDIMENTO 2: le CONSULTA (fato) categorizada por
-- CLINICA (categoria 1) e TIPO_CONSULTA (categoria 2), com
-- VALOR (numerico). Subtotal por clinica e total geral
-- calculados manualmente, sem ROLLUP/CUBE/GROUPING SETS.
------------------------------------------------------------

CREATE OR REPLACE PROCEDURE prc_rel_consultas_subtotal AS
    CURSOR c_consultas IS
        SELECT c.nome AS categoria1_clinica,
               co.tipo_consulta AS categoria2_tipo,
               co.valor
        FROM CONSULTA co
        JOIN CLINICA c ON c.id_clinica = co.id_clinica
        ORDER BY c.nome, co.tipo_consulta;

    v_categoria1_atual  VARCHAR2(120) := NULL;
    v_subtotal          NUMBER := 0;
    v_total_geral        NUMBER := 0;
    v_qtd_linhas         NUMBER := 0;

    e_sem_registros      EXCEPTION;
    e_valor_negativo     EXCEPTION;
BEGIN
    DBMS_OUTPUT.PUT_LINE('===== RELATORIO - CONSULTAS POR CLINICA E TIPO (SUBTOTAL MANUAL) =====');
    DBMS_OUTPUT.PUT_LINE(RPAD('CLINICA', 28) || RPAD('TIPO', 15) || 'VALOR');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------');

    FOR r IN c_consultas LOOP
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

    WHEN OTHERS THEN
        prc_registrar_log_erro('PRC_REL_CONSULTAS_SUBTOTAL', SQLCODE, SQLERRM);
END;
/

------------------------------------------------------------
-- TESTE / EVIDENCIA (tirar print desses resultados)
------------------------------------------------------------

EXEC prc_rel_pets_tutor_clinica_json;
EXEC prc_rel_consultas_subtotal;
