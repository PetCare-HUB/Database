SELECT table_name, column_name, data_type, nullable, data_default, column_id
FROM user_tab_columns
WHERE table_name IN (
    'PET',
    'CONSULTA',
    'EVENTO_PREVENTIVO',
    'LEITURA_SENSOR',
    'ALERTA_SAUDE',
    'SCORE_SAUDE'
)
ORDER BY table_name, column_id;