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