------------------------------------------------------------
-- EXPORT 2/3 -- Colecao "telemetria"
------------------------------------------------------------
-- Um documento por pet + tipo de sensor + dia, com as leituras
-- daquele dia num array (padrao de bucket de serie temporal).
--
-- Por que bucket e nao um documento por leitura: sao ~920 leituras
-- hoje e crescem sem parar. Documento por leitura significa um
-- indice gigante e um documento minusculo cada -- o Mongo paga
-- overhead fixo por documento. Agrupando por dia, a leitura
-- natural ("as leituras do Rex ontem") e um unico documento.
--
-- O detalhe que importa na defesa: as tres tabelas de leitura
-- viram UMA colecao. No relacional elas tiveram que ser separadas
-- (LEITURA_COLEIRA, LEITURA_COMEDOURO, LEITURA_AMBIENTE) porque as
-- colunas sao diferentes -- coleira tem bateria, comedouro tem
-- peso de racao, ambiente tem umidade. Uma tabela unica obrigaria
-- a deixar metade das colunas nulas em cada linha. No documento
-- isso nao e problema: o array "leituras" carrega o formato de
-- cada tipo, e o campo "tipo" diz qual formato esperar.
------------------------------------------------------------

SELECT JSON_ARRAYAGG(doc FORMAT JSON ORDER BY id_pet, tipo, dia RETURNING CLOB) AS documentos
FROM (
    SELECT
        l.id_pet,
        l.tipo,
        l.dia,
        JSON_OBJECT(
            '_id'  VALUE l.id_pet || '|' || l.tipo || '|' || l.dia,
            'tipo' VALUE l.tipo,
            'dia'  VALUE JSON_OBJECT('$date' VALUE l.dia || 'T00:00:00Z') FORMAT JSON,
            'pet'  VALUE (
                SELECT JSON_OBJECT(
                           'id'      VALUE pe.id_pet,
                           'nome'    VALUE pe.nome,
                           'especie' VALUE pe.especie
                           RETURNING CLOB)
                FROM PET pe WHERE pe.id_pet = l.id_pet
            ) FORMAT JSON,
            'qtdLeituras' VALUE COUNT(*),
            'leituras'    VALUE JSON_ARRAYAGG(l.leitura FORMAT JSON ORDER BY l.ts RETURNING CLOB) FORMAT JSON
            RETURNING CLOB) AS doc
    FROM (
        ----------------------------------------------------------
        -- COLEIRA
        ----------------------------------------------------------
        SELECT
            lc.id_pet,
            'COLEIRA' AS tipo,
            TO_CHAR(lc.timestamp_leitura, 'YYYY-MM-DD') AS dia,
            lc.timestamp_leitura AS ts,
            JSON_OBJECT(
                'id'              VALUE lc.id_leitura_coleira,
                'instante'        VALUE JSON_OBJECT('$date' VALUE TO_CHAR(lc.timestamp_leitura, 'YYYY-MM-DD"T"HH24:MI:SS"Z"')) FORMAT JSON,
                'statusAtividade' VALUE lc.status_atividade,
                'nivelBateria'    VALUE lc.nivel_bateria
                RETURNING CLOB) AS leitura
        FROM LEITURA_COLEIRA lc

        UNION ALL
        ----------------------------------------------------------
        -- COMEDOURO
        ----------------------------------------------------------
        SELECT
            lm.id_pet,
            'COMEDOURO' AS tipo,
            TO_CHAR(lm.timestamp_leitura, 'YYYY-MM-DD') AS dia,
            lm.timestamp_leitura AS ts,
            JSON_OBJECT(
                'id'              VALUE lm.id_leitura_comedouro,
                'instante'        VALUE JSON_OBJECT('$date' VALUE TO_CHAR(lm.timestamp_leitura, 'YYYY-MM-DD"T"HH24:MI:SS"Z"')) FORMAT JSON,
                'nivelRacaoPct'   VALUE lm.nivel_racao_pct,
                'pesoConsumidoG'  VALUE lm.peso_consumido_g
                RETURNING CLOB) AS leitura
        FROM LEITURA_COMEDOURO lm

        UNION ALL
        ----------------------------------------------------------
        -- AMBIENTE
        ----------------------------------------------------------
        SELECT
            la.id_pet,
            'AMBIENTE' AS tipo,
            TO_CHAR(la.timestamp_leitura, 'YYYY-MM-DD') AS dia,
            la.timestamp_leitura AS ts,
            JSON_OBJECT(
                'id'                   VALUE la.id_leitura_ambiente,
                'instante'             VALUE JSON_OBJECT('$date' VALUE TO_CHAR(la.timestamp_leitura, 'YYYY-MM-DD"T"HH24:MI:SS"Z"')) FORMAT JSON,
                'temperaturaAmbiente'  VALUE la.temperatura_ambiente,
                'umidadePct'           VALUE la.umidade_pct,
                'qualidadeArPpm'       VALUE la.qualidade_ar_ppm,
                'petPresente'          VALUE CASE
                                                 WHEN la.pet_presente = 1 THEN 'true'
                                                 WHEN la.pet_presente = 0 THEN 'false'
                                                 ELSE NULL
                                             END FORMAT JSON
                RETURNING CLOB) AS leitura
        FROM LEITURA_AMBIENTE la
    ) l
    GROUP BY l.id_pet, l.tipo, l.dia
)
