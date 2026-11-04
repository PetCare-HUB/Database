------------------------------------------------------------
-- REMOCAO DOS OBJETOS SOLTOS -- fecha o empacotamento.
------------------------------------------------------------
-- Os passos 9 a 14 e 20 criaram as procedures e funcoes soltas da
-- Sprint 3, e as cargas (passos 15 a 19) usaram essas versoes para
-- montar a massa de teste. Com a carga feita e os cinco packages
-- compilados, cada objeto solto virou duplicata de um membro de
-- package -- mesma assinatura, mesma regra.
--
-- Nada mais depende deles:
--   - os packages se chamam entre si sempre com prefixo
--     (pkg_log.prc_registrar_log_erro, pkg_util.fn_pet_para_json),
--     entao nenhum resolve para a versao solta;
--   - a API Java chama PKG_CARGA e PKG_UTIL (catalog no SimpleJdbcCall);
--   - o export para JSON (sql/export) e os relatorios (sql/relatorios)
--     nao chamam nenhum deles;
--   - nao ha view, sinonimo ou job no schema que os referencie.
--
-- A lista e explicita de proposito. O schema da FIAP e compartilhado
-- com outras disciplinas, e um filtro por prefixo (LIKE 'PRC_%')
-- apagaria objetos que nao sao deste projeto.
--
-- Idempotente: so remove o que existe, entao rodar de novo nao gera
-- ORA-04043.
--
-- O TRG_AUDITORIA_TUTOR fica: trigger nao entra em package, e o passo
-- 28 ja o recriou delegando ao PKG_AUDITORIA.
------------------------------------------------------------

DECLARE
    v_removidos PLS_INTEGER := 0;
BEGIN
    FOR r IN (
        SELECT object_name, object_type
        FROM user_objects
        WHERE object_type IN ('PROCEDURE', 'FUNCTION')
          AND object_name IN (
              -- substituida por PKG_LOG
              'PRC_REGISTRAR_LOG_ERRO',
              -- substituidas por PKG_UTIL
              'FN_CALCULAR_IDADE_PET', 'FN_SCORE_MEDIO_PET',
              'FN_PET_PARA_JSON', 'FN_VALIDAR_FORCA_SENHA',
              -- substituidas por PKG_CARGA
              'PRC_INS_CLINICA', 'PRC_INS_TUTOR', 'PRC_INS_PET',
              'PRC_INS_CONSULTA', 'PRC_INS_PROTOCOLO_PREVENTIVO',
              'PRC_INS_EVENTO_PREVENTIVO', 'PRC_INS_DISPOSITIVO_IOT',
              'PRC_INS_ALERTA_SAUDE', 'PRC_INS_LEITURA_COLEIRA',
              'PRC_INS_LEITURA_COMEDOURO', 'PRC_INS_LEITURA_AMBIENTE',
              'PRC_INS_SCORE_SAUDE',
              -- substituidas por PKG_RELATORIOS
              'PRC_REL_PETS_TUTOR_CLINICA_JSON', 'PRC_REL_CONSULTAS_SUBTOTAL'
          )
        ORDER BY object_type, object_name
    ) LOOP
        EXECUTE IMMEDIATE 'DROP ' || r.object_type || ' "' || r.object_name || '"';
        DBMS_OUTPUT.PUT_LINE('Removido: ' || r.object_type || ' ' || r.object_name);
        v_removidos := v_removidos + 1;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Objetos soltos removidos: ' || v_removidos);
END;
/

------------------------------------------------------------
-- CONFERENCIA
------------------------------------------------------------

-- 1) Nenhum objeto solto sobrou. Esperado: 0 linhas.
SELECT object_name, object_type
FROM user_objects
WHERE object_type IN ('PROCEDURE', 'FUNCTION')
  AND object_name IN (
      'PRC_REGISTRAR_LOG_ERRO',
      'FN_CALCULAR_IDADE_PET', 'FN_SCORE_MEDIO_PET',
      'FN_PET_PARA_JSON', 'FN_VALIDAR_FORCA_SENHA',
      'PRC_INS_CLINICA', 'PRC_INS_TUTOR', 'PRC_INS_PET',
      'PRC_INS_CONSULTA', 'PRC_INS_PROTOCOLO_PREVENTIVO',
      'PRC_INS_EVENTO_PREVENTIVO', 'PRC_INS_DISPOSITIVO_IOT',
      'PRC_INS_ALERTA_SAUDE', 'PRC_INS_LEITURA_COLEIRA',
      'PRC_INS_LEITURA_COMEDOURO', 'PRC_INS_LEITURA_AMBIENTE',
      'PRC_INS_SCORE_SAUDE',
      'PRC_REL_PETS_TUTOR_CLINICA_JSON', 'PRC_REL_CONSULTAS_SUBTOTAL'
  );

-- 2) Os cinco packages (spec + body) e o trigger continuam VALID.
--    Esperado: 11 linhas, todas VALID. Se algum package tivesse
--    dependencia escondida de um objeto solto, ele apareceria
--    INVALID aqui.
SELECT object_name, object_type, status
FROM user_objects
WHERE object_name IN ('PKG_LOG', 'PKG_UTIL', 'PKG_CARGA',
                      'PKG_RELATORIOS', 'PKG_AUDITORIA',
                      'TRG_AUDITORIA_TUTOR')
ORDER BY object_name, object_type;

-- 3) Nada em USER_ERRORS. Esperado: 0 linhas.
SELECT name, type, line, text
FROM user_errors
WHERE name IN ('PKG_LOG', 'PKG_UTIL', 'PKG_CARGA',
               'PKG_RELATORIOS', 'PKG_AUDITORIA',
               'TRG_AUDITORIA_TUTOR');
