EXECUTE BLOCK
RETURNS (
    JSON_STR BLOB SUB_TYPE TEXT CHARACTER SET UTF8)
AS
  DECLARE JSON_M BLOB SUB_TYPE TEXT CHARACTER SET UTF8;
BEGIN
  FOR
      SELECT
          HORSE.CODE_HORSE,
          HORSE.NAME,
          HORSE.BIRTHDAY
      FROM HORSE
      WHERE HORSE.CODE_DEPARTURE = 15
      FETCH FIRST 1000 ROW ONLY
      AS CURSOR C
  DO
  BEGIN
    SELECT
      LIST(
        BLOB_APPEND(
          '{',
          JSON_UTILS.NUMERIC_PAIR('age', MEASURE.AGE),
          ',',
          JSON_UTILS.NUMERIC_PAIR('height', MEASURE.HEIGHT_HORSE),
          ',',
          JSON_UTILS.NUMERIC_PAIR('length', MEASURE.LENGTH_HORSE),
          ',',
          JSON_UTILS.NUMERIC_PAIR('chestaround', MEASURE.CHESTAROUND),
          ',',
          JSON_UTILS.NUMERIC_PAIR('wristaround', MEASURE.WRISTAROUND),
          ',',
          JSON_UTILS.NUMERIC_PAIR('weight', MEASURE.WEIGHT_HORSE),
          '}'
        )
      ) AS JSON_M
    FROM MEASURE
    WHERE MEASURE.CODE_HORSE = :C.CODE_HORSE
    INTO JSON_M;

    JSON_STR = BLOB_APPEND(
      JSON_STR,
      IIF(JSON_STR IS NULL, '[', ',' || ascii_char(13)),
      '{',
      JSON_UTILS.INTEGER_PAIR('code_horse', C.CODE_HORSE),
      ',',
      JSON_UTILS.STRING_PAIR('name', C.NAME),
      ',',
      JSON_UTILS.TIMESTAMP_PAIR('birthday', C.BIRTHDAY),
      ',',
      JSON_UTILS.STRING_VALUE('measures') || ':[', JSON_M, ']',
      '}'
    );
  END
  JSON_STR = BLOB_APPEND(JSON_STR, ']');
  SUSPEND;
END

/*
------ Информация о производительности ------
Время подготовки запроса = 16ms
Время выполнения запроса = 1s 61ms
Среднее время на получение одной записи = 1 061,00 ms
Current memory = 565 435 744
Max memory = 585 289 472
Memory buffers = 32 768
Reads from disk to cache = 0
Writes from cache to disk = 8
Чтений из кэша = 4 546
*/