------------------------------------------------------------
-- EXPORT 1/3 -- Colecao "pets"
------------------------------------------------------------
-- Um documento por pet, com tutor, clinica, consultas, eventos
-- preventivos, dispositivos e score embutidos.
--
-- No relacional esse mesmo dado esta normalizado em 7 tabelas e
-- custa 6 joins para montar. Aqui ele vira um documento que o
-- app le com um findOne. A duplicacao do nome do tutor dentro do
-- pet e intencional: e dado que quase nao muda, e o custo de
-- repetir e menor que o custo de juntar em toda leitura.
--
-- SENHA_HASH de TUTOR e CLINICA NAO sai no export de proposito:
-- hash de senha nao e dado de dominio e nao tem o que fazer num
-- arquivo que vai ser aberto e importado em outro banco.
--
-- As datas saem como {"$date": "..."} (Extended JSON) para o
-- mongoimport gravar BSON date de verdade, e nao string -- sem
-- isso nenhuma consulta por periodo funciona no Mongo.
--
-- idadeMeses e scoreSaude.medio30d vem de PKG_UTIL: o calculo
-- mora no banco e o export consome o package, nao reimplementa.
------------------------------------------------------------

SELECT JSON_ARRAYAGG(doc FORMAT JSON ORDER BY id_pet RETURNING CLOB) AS documentos
FROM (
    SELECT
        p.id_pet,
        JSON_OBJECT(
            '_id'               VALUE p.id_pet,
            'nome'              VALUE p.nome,
            'especie'           VALUE p.especie,
            'raca'              VALUE p.raca,
            'sexo'              VALUE p.sexo,
            'pesoKg'            VALUE p.peso_kg,
            'condicoesCronicas' VALUE p.condicoes_cronicas,
            'ativo'             VALUE CASE WHEN p.ativo = 'S' THEN 'true' ELSE 'false' END FORMAT JSON,
            'idadeMeses'        VALUE pkg_util.fn_calcular_idade_pet(p.id_pet),
            'dataNascimento'    VALUE CASE
                                        WHEN p.data_nascimento IS NULL THEN NULL
                                        ELSE JSON_OBJECT('$date' VALUE TO_CHAR(p.data_nascimento, 'YYYY-MM-DD"T00:00:00Z"'))
                                     END FORMAT JSON,
            'dataCadastro'      VALUE JSON_OBJECT('$date' VALUE TO_CHAR(p.data_cadastro, 'YYYY-MM-DD"T00:00:00Z"')) FORMAT JSON,

            'tutor' VALUE (
                SELECT JSON_OBJECT(
                           'id'           VALUE t.id_tutor,
                           'nome'         VALUE t.nome,
                           'email'        VALUE t.email,
                           'telefone'     VALUE t.telefone,
                           'statusAcesso' VALUE t.status_acesso
                           RETURNING CLOB)
                FROM TUTOR t WHERE t.id_tutor = p.id_tutor
            ) FORMAT JSON,

            'clinica' VALUE (
                SELECT JSON_OBJECT(
                           'id'       VALUE cl.id_clinica,
                           'nome'     VALUE cl.nome,
                           'cnpj'     VALUE cl.cnpj,
                           'endereco' VALUE cl.endereco
                           RETURNING CLOB)
                FROM CLINICA cl WHERE cl.id_clinica = p.id_clinica
            ) FORMAT JSON,

            'consultas' VALUE (
                SELECT NVL(JSON_ARRAYAGG(
                           JSON_OBJECT(
                               'id'                 VALUE c.id_consulta,
                               'data'               VALUE JSON_OBJECT('$date' VALUE TO_CHAR(c.data_consulta, 'YYYY-MM-DD"T00:00:00Z"')) FORMAT JSON,
                               'tipo'               VALUE c.tipo_consulta,
                               'descricao'          VALUE c.descricao,
                               'diagnostico'        VALUE c.diagnostico,
                               'valor'              VALUE c.valor,
                               'retornoRecomendado' VALUE CASE WHEN c.retorno_recomendado = 'S' THEN 'true' ELSE 'false' END FORMAT JSON,
                               'idClinica'          VALUE c.id_clinica
                               RETURNING CLOB)
                           FORMAT JSON ORDER BY c.data_consulta RETURNING CLOB),
                       TO_CLOB('[]'))
                FROM CONSULTA c WHERE c.id_pet = p.id_pet
            ) FORMAT JSON,

            'eventosPreventivos' VALUE (
                SELECT NVL(JSON_ARRAYAGG(
                           JSON_OBJECT(
                               'id'             VALUE e.id_evento,
                               'tipo'           VALUE e.tipo_evento,
                               'descricao'      VALUE e.descricao,
                               'status'         VALUE e.status,
                               'dataPrevista'   VALUE JSON_OBJECT('$date' VALUE TO_CHAR(e.data_prevista, 'YYYY-MM-DD"T00:00:00Z"')) FORMAT JSON,
                               'dataRealizacao' VALUE CASE
                                                          WHEN e.data_realizacao IS NULL THEN NULL
                                                          ELSE JSON_OBJECT('$date' VALUE TO_CHAR(e.data_realizacao, 'YYYY-MM-DD"T00:00:00Z"'))
                                                      END FORMAT JSON,
                               'protocolo'      VALUE (
                                   SELECT JSON_OBJECT(
                                              'id'                    VALUE pr.id_protocolo,
                                              'tipoEvento'            VALUE pr.tipo_evento,
                                              'idadeMesesRecomendada' VALUE pr.idade_meses_recomendada,
                                              'intervaloDias'         VALUE pr.intervalo_dias
                                              RETURNING CLOB)
                                   FROM PROTOCOLO_PREVENTIVO pr WHERE pr.id_protocolo = e.id_protocolo
                               ) FORMAT JSON
                               RETURNING CLOB)
                           FORMAT JSON ORDER BY e.data_prevista RETURNING CLOB),
                       TO_CLOB('[]'))
                FROM EVENTO_PREVENTIVO e WHERE e.id_pet = p.id_pet
            ) FORMAT JSON,

            'dispositivos' VALUE (
                SELECT NVL(JSON_ARRAYAGG(
                           JSON_OBJECT(
                               'id'           VALUE d.id_dispositivo,
                               'tipo'         VALUE d.tipo_dispositivo,
                               'codigoSerie'  VALUE d.codigo_serie,
                               'dataAtivacao' VALUE JSON_OBJECT('$date' VALUE TO_CHAR(d.data_ativacao, 'YYYY-MM-DD"T00:00:00Z"')) FORMAT JSON,
                               'ativo'        VALUE CASE WHEN d.ativo = 'S' THEN 'true' ELSE 'false' END FORMAT JSON
                               RETURNING CLOB)
                           FORMAT JSON ORDER BY d.id_dispositivo RETURNING CLOB),
                       TO_CLOB('[]'))
                FROM DISPOSITIVO_IOT d WHERE d.id_pet = p.id_pet
            ) FORMAT JSON,

            'scoreSaude' VALUE JSON_OBJECT(
                'medio30d' VALUE pkg_util.fn_score_medio_pet(p.id_pet, 30),
                'ultimo'   VALUE (
                    SELECT JSON_OBJECT(
                               'total'       VALUE s.score_total,
                               'atividade'   VALUE s.score_atividade,
                               'alimentacao' VALUE s.score_alimentacao,
                               'ambiente'    VALUE s.score_ambiente,
                               'consulta'    VALUE s.score_consulta,
                               'preventivo'  VALUE s.score_preventivo,
                               'categoria'   VALUE s.categoria,
                               'dataCalculo' VALUE JSON_OBJECT('$date' VALUE TO_CHAR(s.data_calculo, 'YYYY-MM-DD"T"HH24:MI:SS"Z"')) FORMAT JSON
                               RETURNING CLOB)
                    FROM SCORE_SAUDE s
                    WHERE s.id_pet = p.id_pet
                    ORDER BY s.data_calculo DESC
                    FETCH FIRST 1 ROWS ONLY
                ) FORMAT JSON
                RETURNING CLOB) FORMAT JSON

            RETURNING CLOB) AS doc
    FROM PET p
)
