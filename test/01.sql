-- Caso de excecao da Funcao 1 (id_pet nulo)
SELECT fn_pet_para_json(NULL, 'Teste', 'CAO', 'Tutor Teste', 'teste@teste.com', 'Clinica Teste') AS json_erro
FROM DUAL;

-- Casos de excecao da Funcao 2
SELECT fn_validar_forca_senha(NULL) AS resultado FROM DUAL;
SELECT fn_validar_forca_senha('abc') AS resultado FROM DUAL;
SELECT fn_validar_forca_senha('semnumero') AS resultado FROM DUAL;