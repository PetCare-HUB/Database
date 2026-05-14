SET SERVEROUTPUT ON;

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
            v_acao := 'Priorizar contato com o responsavel';

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
            v_situacao := 'Evento atrasado. Responsavel deve ser notificado.';

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