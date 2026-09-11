SET SERVEROUTPUT ON;

------------------------------------------------------------
-- PETCARE HUB - CREATE SEQUENCES
-- Sequences para gerar IDs das tabelas
------------------------------------------------------------

------------------------------------------------------------
-- LIMPEZA OPCIONAL
-- Remove as sequences caso já existam
--
-- Cobre tambem seq_tutor e seq_auditoria_tutor (nomes que so
-- existem apos o rename/trigger rodarem em execucoes
-- anteriores) e as sequences de leitura splitadas, para o
-- script conseguir resetar do zero em qualquer "geracao" do
-- schema sem deixar `RENAME seq_responsavel TO seq_tutor` do
-- passo 5 falhar com ORA-00955 por causa de um seq_tutor
-- orfao de uma execucao anterior.
------------------------------------------------------------

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_tutor';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_auditoria_tutor';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_leitura_coleira';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_leitura_comedouro';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_leitura_ambiente';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_responsavel';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_clinica';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_pet';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_consulta';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_protocolo_preventivo';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_evento_preventivo';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_dispositivo_iot';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_leitura_sensor';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_alerta_saude';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_score_saude';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_log_erros';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

------------------------------------------------------------
-- CRIAÇÃO DAS SEQUENCES
------------------------------------------------------------

CREATE SEQUENCE seq_responsavel
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE seq_clinica
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE seq_pet
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE seq_consulta
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE seq_protocolo_preventivo
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE seq_evento_preventivo
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE seq_dispositivo_iot
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE seq_leitura_sensor
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE seq_alerta_saude
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE seq_score_saude
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE seq_log_erros
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

------------------------------------------------------------
-- TESTE FINAL: LISTAR SEQUENCES CRIADAS
------------------------------------------------------------

SELECT sequence_name
FROM user_sequences
WHERE sequence_name IN (
    'SEQ_RESPONSAVEL',
    'SEQ_CLINICA',
    'SEQ_PET',
    'SEQ_CONSULTA',
    'SEQ_PROTOCOLO_PREVENTIVO',
    'SEQ_EVENTO_PREVENTIVO',
    'SEQ_DISPOSITIVO_IOT',
    'SEQ_LEITURA_SENSOR',
    'SEQ_ALERTA_SAUDE',
    'SEQ_SCORE_SAUDE',
    'SEQ_LOG_ERROS'
)
ORDER BY sequence_name;