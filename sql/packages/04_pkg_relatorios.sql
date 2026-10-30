------------------------------------------------------------
-- PKG_RELATORIOS -- Relatorios exigidos pela rubrica, com saida por DBMS_OUTPUT.
------------------------------------------------------------

CREATE OR REPLACE PACKAGE pkg_relatorios AS

    -- Separado da carga porque so le: nenhuma rotina daqui escreve em tabela do
    -- dominio. Quem precisa de relatorio nao precisa de permissao de escrita.

    PROCEDURE prc_rel_pets_tutor_clinica_json;

    PROCEDURE prc_rel_consultas_subtotal;

END pkg_relatorios;
/

CREATE OR REPLACE PACKAGE BODY pkg_relatorios AS

    -- Origem: 04_procedures_relatorios_sprint3.sql:16
    PROCEDURE prc_rel_pets_tutor_clinica_json AS
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

            v_json_array := v_json_array || pkg_util.fn_pet_para_json(
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
            pkg_log.prc_registrar_log_erro('PKG_RELATORIOS.PRC_REL_PETS_TUTOR_CLINICA_JSON', -20201, 'Nenhum pet encontrado para gerar JSON.');
            DBMS_OUTPUT.PUT_LINE('Nenhum registro encontrado para gerar o JSON.');

        WHEN e_dados_incompletos THEN
            pkg_log.prc_registrar_log_erro('PKG_RELATORIOS.PRC_REL_PETS_TUTOR_CLINICA_JSON', -20204, 'Registro com nome de pet, tutor ou clinica em branco.');
            DBMS_OUTPUT.PUT_LINE('Registro com dado obrigatorio em branco encontrado ao montar o JSON.');

        WHEN VALUE_ERROR THEN
            pkg_log.prc_registrar_log_erro('PKG_RELATORIOS.PRC_REL_PETS_TUTOR_CLINICA_JSON', SQLCODE, SQLERRM);

        WHEN OTHERS THEN
            pkg_log.prc_registrar_log_erro('PKG_RELATORIOS.PRC_REL_PETS_TUTOR_CLINICA_JSON', SQLCODE, SQLERRM);
    END;

    -- Origem: 04_procedures_relatorios_sprint3.sql:103
    PROCEDURE prc_rel_consultas_subtotal AS
        CURSOR c_consultas IS
            SELECT c.id_clinica,
                   c.nome AS categoria1_clinica,
                   co.tipo_consulta AS categoria2_tipo,
                   co.valor
            FROM CONSULTA co
            JOIN CLINICA c ON c.id_clinica = co.id_clinica
            ORDER BY c.id_clinica, co.tipo_consulta;

        v_id_clinica_atual   NUMBER := NULL;
        v_tipo_atual         VARCHAR2(30);
        v_nome_clinica_atual VARCHAR2(120);
        v_valor              NUMBER;
        v_valor_combo        NUMBER := 0;
        v_subtotal           NUMBER := 0;
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

            v_valor := NVL(r.valor, 0);

            IF v_valor < 0 THEN
                RAISE e_valor_negativo;
            END IF;

            IF v_id_clinica_atual IS NOT NULL AND r.id_clinica <> v_id_clinica_atual THEN
                -- QUEBRA DE CATEGORIA 1 (clinica): fecha a ultima
                -- combinacao (categoria1+categoria2) pendente da
                -- clinica anterior e imprime o Sub Total dela. O
                -- rotulo "Sub Total" ocupa a 1a coluna (categoria1)
                -- e a 2a coluna (categoria2) fica em branco, igual
                -- ao exemplo oficial da rubrica.
                DBMS_OUTPUT.PUT_LINE(
                    RPAD(v_nome_clinica_atual, 28) || RPAD(v_tipo_atual, 15) || TO_CHAR(v_valor_combo, '999G990D00')
                );
                DBMS_OUTPUT.PUT_LINE(
                    RPAD('Sub Total', 28) || RPAD(' ', 15) || TO_CHAR(v_subtotal, '999G990D00')
                );
                v_valor_combo := 0;
                v_subtotal := 0;
            ELSIF v_tipo_atual IS NOT NULL AND r.categoria2_tipo <> v_tipo_atual THEN
                -- QUEBRA DE CATEGORIA 2 (tipo) dentro da mesma
                -- clinica: fecha a combinacao anterior e imprime a
                -- soma completa dela (categoria1 continua repetida,
                -- nunca em branco numa linha de combinacao).
                DBMS_OUTPUT.PUT_LINE(
                    RPAD(v_nome_clinica_atual, 28) || RPAD(v_tipo_atual, 15) || TO_CHAR(v_valor_combo, '999G990D00')
                );
                v_valor_combo := 0;
            END IF;

            -- ACUMULACAO MANUAL (sem SUM/GROUP BY): soma o valor
            -- desta linha na combinacao categoria1+categoria2 atual,
            -- no subtotal da categoria 1 (clinica) e no total geral.
            -- Varias consultas da mesma clinica+tipo (ex.: 3 do tipo
            -- CHECKUP na mesma clinica) se acumulam na mesma
            -- combinacao e saem como uma unica linha somada.
            v_valor_combo := v_valor_combo + v_valor;
            v_subtotal := v_subtotal + v_valor;
            v_total_geral := v_total_geral + v_valor;

            v_id_clinica_atual := r.id_clinica;
            v_tipo_atual := r.categoria2_tipo;
            v_nome_clinica_atual := r.categoria1_clinica;
            v_qtd_linhas := v_qtd_linhas + 1;
        END LOOP;

        IF v_qtd_linhas = 0 THEN
            RAISE e_sem_registros;
        END IF;

        -- Fecha a ultima combinacao e o ultimo subtotal pendentes,
        -- depois imprime o total geral.
        DBMS_OUTPUT.PUT_LINE(
            RPAD(v_nome_clinica_atual, 28) || RPAD(v_tipo_atual, 15) || TO_CHAR(v_valor_combo, '999G990D00')
        );
        DBMS_OUTPUT.PUT_LINE(
            RPAD('Sub Total', 28) || RPAD(' ', 15) || TO_CHAR(v_subtotal, '999G990D00')
        );
        DBMS_OUTPUT.PUT_LINE(
            RPAD('Total Geral', 28) || RPAD(' ', 15) || TO_CHAR(v_total_geral, '999G990D00')
        );

    EXCEPTION
        WHEN e_sem_registros THEN
            pkg_log.prc_registrar_log_erro('PKG_RELATORIOS.PRC_REL_CONSULTAS_SUBTOTAL', -20202, 'Nenhuma consulta encontrada para o relatorio.');
            DBMS_OUTPUT.PUT_LINE('Nenhuma consulta encontrada.');

        WHEN e_valor_negativo THEN
            pkg_log.prc_registrar_log_erro('PKG_RELATORIOS.PRC_REL_CONSULTAS_SUBTOTAL', -20203, 'Valor de consulta negativo detectado.');
            DBMS_OUTPUT.PUT_LINE('Valor de consulta invalido (negativo) encontrado.');

        WHEN e_clinica_sem_nome THEN
            pkg_log.prc_registrar_log_erro('PKG_RELATORIOS.PRC_REL_CONSULTAS_SUBTOTAL', -20205, 'Clinica sem nome valido (em branco) encontrada.');
            DBMS_OUTPUT.PUT_LINE('Clinica com nome em branco encontrada no relatorio.');

        WHEN OTHERS THEN
            pkg_log.prc_registrar_log_erro('PKG_RELATORIOS.PRC_REL_CONSULTAS_SUBTOTAL', SQLCODE, SQLERRM);
    END;

END pkg_relatorios;
/
