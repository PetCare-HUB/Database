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
-- CLINICA (categoria 1, identificada por id_clinica para nao
-- misturar clinicas homonimas) e TIPO_CONSULTA (categoria 2),
-- com VALOR (numerico). O cursor traz as linhas BRUTAS (uma
-- por consulta, sem SUM/GROUP BY) e a procedure calcula e
-- exibe, tudo acumulado MANUALMENTE em variaveis dentro do
-- loop (sem SUM, ROLLUP, CUBE, GROUPING SETS ou GROUPING):
--   1) os valores somados por COMBINACAO COMPLETA das
--      categorias (clinica, tipo) - varias consultas da mesma
--      clinica+tipo viram uma unica linha com o valor somado;
--   2) um subtotal por grupo da categoria 1 (clinica);
--   3) um total geral ao final da listagem.
-- VALOR nulo e tratado com NVL antes de acumular.
--
-- Formato de saida segue o modelo oficial da rubrica (relatorio
-- Agencia/Conta/Saldo, pagina 25/26): a categoria 1 se repete em
-- toda linha de combinacao (nunca fica em branco nelas), a ordem
-- de exibicao segue a hierarquia das categorias, e os valores de
-- agrupamento ficam ausentes (em branco) SOMENTE nas linhas de
-- Sub Total e Total Geral.
------------------------------------------------------------

CREATE OR REPLACE PROCEDURE prc_rel_consultas_subtotal AS
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
            -- clinica anterior e imprime o Sub Total dela (com
            -- as colunas de categoria em branco, igual ao
            -- exemplo oficial).
            DBMS_OUTPUT.PUT_LINE(
                RPAD(v_nome_clinica_atual, 28) || RPAD(v_tipo_atual, 15) || TO_CHAR(v_valor_combo, '999G990D00')
            );
            DBMS_OUTPUT.PUT_LINE(
                RPAD(' ', 28) || RPAD('Sub Total', 15) || TO_CHAR(v_subtotal, '999G990D00')
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
        RPAD(' ', 28) || RPAD('Sub Total', 15) || TO_CHAR(v_subtotal, '999G990D00')
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



