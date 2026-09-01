SET SERVEROUTPUT ON;

------------------------------------------------------------
-- PETCARE HUB - CARGA COMPLEMENTAR (SPRINT 3)
-- Garante pelo menos 5 registros validos em TUTOR, CLINICA
-- e PET, exigidos pelo Procedimento 1 (JOIN + JSON manual)
-- da rubrica de "Mastering Relational and Non-Relational Database".
-- Roda DEPOIS de 01_insert_testes.sql, sem apagar nada.
------------------------------------------------------------

DECLARE
    v_tutor_diego    NUMBER;
    v_tutor_elaine   NUMBER;

    v_clinica_feliz     NUMBER;
    v_clinica_bemestar  NUMBER;
    v_clinica_amigo     NUMBER;
BEGIN
    --------------------------------------------------------
    -- 2 TUTORES A MAIS (total: 5)
    --------------------------------------------------------

    prc_ins_tutor(
        'Diego Ferreira',
        'diego.ferreira@email.com',
        '11999990004',
        '44444444444'
    );

    prc_ins_tutor(
        'Elaine Costa',
        'elaine.costa@email.com',
        '11999990005',
        '55555555555'
    );

    SELECT id_tutor INTO v_tutor_diego
    FROM TUTOR
    WHERE email = 'diego.ferreira@email.com';

    SELECT id_tutor INTO v_tutor_elaine
    FROM TUTOR
    WHERE email = 'elaine.costa@email.com';

    --------------------------------------------------------
    -- 3 CLINICAS A MAIS (total: 5)
    --------------------------------------------------------

    prc_ins_clinica(
        'Clinica Pet Feliz',
        '33333333000133',
        'contato@petfeliz.com',
        '1130000003',
        'Rua C, 300'
    );

    prc_ins_clinica(
        'Hospital Bem Estar Animal',
        '44444444000144',
        'contato@bemestaranimal.com',
        '1130000004',
        'Rua D, 400'
    );

    prc_ins_clinica(
        'Clinica Amigo Fiel',
        '55555555000155',
        'contato@amigofiel.com',
        '1130000005',
        'Rua E, 500'
    );

    SELECT id_clinica INTO v_clinica_feliz
    FROM CLINICA
    WHERE cnpj = '33333333000133';

    SELECT id_clinica INTO v_clinica_bemestar
    FROM CLINICA
    WHERE cnpj = '44444444000144';

    SELECT id_clinica INTO v_clinica_amigo
    FROM CLINICA
    WHERE cnpj = '55555555000155';

    --------------------------------------------------------
    -- 2 PETS A MAIS (total: 5)
    --------------------------------------------------------

    prc_ins_pet(
        v_tutor_diego,
        v_clinica_feliz,
        'Mel',
        'CAO',
        'Vira-lata',
        TO_DATE('2023-02-14', 'YYYY-MM-DD'),
        12.30,
        'F',
        NULL
    );

    prc_ins_pet(
        v_tutor_elaine,
        v_clinica_bemestar,
        'Nina',
        'GATO',
        'Persa',
        TO_DATE('2022-11-05', 'YYYY-MM-DD'),
        3.80,
        'F',
        NULL
    );

    DBMS_OUTPUT.PUT_LINE('Carga complementar da Sprint 3 finalizada com sucesso.');
END;
/

------------------------------------------------------------
-- CONFERENCIA: cada tabela precisa ter >= 5 registros
------------------------------------------------------------
SELECT 'TUTOR' AS tabela, COUNT(*) AS total FROM TUTOR
UNION ALL
SELECT 'CLINICA', COUNT(*) FROM CLINICA
UNION ALL
SELECT 'PET', COUNT(*) FROM PET;
