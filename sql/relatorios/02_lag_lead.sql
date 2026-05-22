SET SERVEROUTPUT ON;

------------------------------------------------------------
-- PETCARE HUB - RELATÓRIO COM LAG E LEAD
-- Arquivo 02_lag_lead.sql
--
-- Objetivo:
-- Mostrar, na mesma linha:
-- valor anterior, valor atual e próximo valor.
--
-- Base usada:
-- Leituras de ATIVIDADE do pet Rex.
--
-- Observação:
-- O insert de teste precisa ter pelo menos 5 leituras
-- de ATIVIDADE para o Rex.
------------------------------------------------------------

DECLARE
    v_total_linhas NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('RELATORIO - ATIVIDADE DO PET COM LAG E LEAD');
    DBMS_OUTPUT.PUT_LINE('ANTERIOR | ATUAL | PROXIMA');
    DBMS_OUTPUT.PUT_LINE('====================================================');

    FOR r IN (
        SELECT
            p.nome AS nome_pet,
            ls.data_leitura,
            LAG(ls.valor) OVER (
                PARTITION BY ls.id_pet
                ORDER BY ls.data_leitura
            ) AS valor_anterior,
            ls.valor AS valor_atual,
            LEAD(ls.valor) OVER (
                PARTITION BY ls.id_pet
                ORDER BY ls.data_leitura
            ) AS valor_proximo,
            ls.unidade
        FROM LEITURA_SENSOR ls
        JOIN PET p 
            ON p.id_pet = ls.id_pet
        WHERE p.nome = 'Rex'
          AND ls.tipo_leitura = 'ATIVIDADE'
        ORDER BY ls.data_leitura
    ) LOOP
        v_total_linhas := v_total_linhas + 1;

        DBMS_OUTPUT.PUT_LINE(
            'Pet: ' || r.nome_pet ||
            ' | Data: ' || TO_CHAR(r.data_leitura, 'DD/MM/YYYY HH24:MI') ||
            ' | Anterior: ' || NVL(TO_CHAR(r.valor_anterior), 'Vazio') ||
            ' | Atual: ' || TO_CHAR(r.valor_atual) ||
            ' | Proxima: ' || NVL(TO_CHAR(r.valor_proximo), 'Vazio') ||
            ' | Unidade: ' || r.unidade
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('Total de linhas exibidas: ' || v_total_linhas);

    IF v_total_linhas < 5 THEN
        DBMS_OUTPUT.PUT_LINE('ATENCAO: o relatorio precisa exibir pelo menos 5 linhas.');
        DBMS_OUTPUT.PUT_LINE('Verifique se existem 5 leituras de ATIVIDADE para o pet Rex.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('OK: relatorio com pelo menos 5 linhas.');
    END IF;

    DBMS_OUTPUT.PUT_LINE('====================================================');
END;
/