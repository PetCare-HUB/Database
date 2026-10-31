------------------------------------------------------------
-- EXPORT 3/3 -- Colecao "alertas"
------------------------------------------------------------
-- Um documento por alerta de saude, com pet, tutor e clinica
-- embutidos no estado em que estavam quando o alerta abriu.
--
-- Aqui a desnormalizacao nao e otimizacao: e correcao. No
-- relacional, ALERTA_SAUDE guarda id_pet e o resto vem por join,
-- entao se o pet trocar de tutor amanha, o alerta de hoje passa a
-- ser exibido com o tutor novo -- e o historico mente. O documento
-- congela o contexto do disparo, que e o que um alerta precisa.
--
-- valorDetectado e limiteReferencia vem direto de PKG_CARGA:
-- quem abre o alerta e PRC_INS_LEITURA_COLEIRA quando a leitura
-- sai da faixa segura. A regra mora no banco, e este export so
-- mostra o resultado dela.
------------------------------------------------------------

SELECT JSON_ARRAYAGG(doc FORMAT JSON ORDER BY id_alerta RETURNING CLOB) AS documentos
FROM (
    SELECT
        a.id_alerta,
        JSON_OBJECT(
            '_id'               VALUE a.id_alerta,
            'tipo'              VALUE a.tipo_alerta,
            'nivel'             VALUE a.nivel_alerta,
            'mensagem'          VALUE a.mensagem,
            'valorDetectado'    VALUE a.valor_detectado,
            'limiteReferencia'  VALUE a.limite_referencia,
            'resolvido'         VALUE CASE WHEN a.resolvido = 'S' THEN 'true' ELSE 'false' END FORMAT JSON,
            'dataAlerta'        VALUE JSON_OBJECT('$date' VALUE TO_CHAR(a.data_alerta, 'YYYY-MM-DD"T"HH24:MI:SS"Z"')) FORMAT JSON,
            'dataResolucao'     VALUE CASE
                                          WHEN a.data_resolucao IS NULL THEN NULL
                                          ELSE JSON_OBJECT('$date' VALUE TO_CHAR(a.data_resolucao, 'YYYY-MM-DD"T"HH24:MI:SS"Z"'))
                                      END FORMAT JSON,

            'pet' VALUE (
                SELECT JSON_OBJECT(
                           'id'      VALUE p.id_pet,
                           'nome'    VALUE p.nome,
                           'especie' VALUE p.especie,
                           'raca'    VALUE p.raca
                           RETURNING CLOB)
                FROM PET p WHERE p.id_pet = a.id_pet
            ) FORMAT JSON,

            'tutor' VALUE (
                SELECT JSON_OBJECT(
                           'id'    VALUE t.id_tutor,
                           'nome'  VALUE t.nome,
                           'email' VALUE t.email
                           RETURNING CLOB)
                FROM PET p JOIN TUTOR t ON t.id_tutor = p.id_tutor
                WHERE p.id_pet = a.id_pet
            ) FORMAT JSON,

            'clinica' VALUE (
                SELECT JSON_OBJECT(
                           'id'   VALUE cl.id_clinica,
                           'nome' VALUE cl.nome
                           RETURNING CLOB)
                FROM PET p JOIN CLINICA cl ON cl.id_clinica = p.id_clinica
                WHERE p.id_pet = a.id_pet
            ) FORMAT JSON

            RETURNING CLOB) AS doc
    FROM ALERTA_SAUDE a
)
