EXECUTE BLOCK
RETURNS (
    JSON_STR BLOB SUB_TYPE TEXT CHARACTER SET UTF8)
AS
  DECLARE JSON_M BLOB SUB_TYPE TEXT CHARACTER SET UTF8;
BEGIN
  JSON_STR = '';
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
          '{' ||
          JSON_UTILS.NUMERIC_PAIR('age', MEASURE.AGE) ||
          ',' ||
          JSON_UTILS.NUMERIC_PAIR('height', MEASURE.HEIGHT_HORSE) ||
          ',' ||
          JSON_UTILS.NUMERIC_PAIR('length', MEASURE.LENGTH_HORSE) ||
          ',' ||
          JSON_UTILS.NUMERIC_PAIR('chestaround', MEASURE.CHESTAROUND) ||
          ',' ||
          JSON_UTILS.NUMERIC_PAIR('wristaround', MEASURE.WRISTAROUND) ||
          ',' ||
          JSON_UTILS.NUMERIC_PAIR('weight', MEASURE.WEIGHT_HORSE) ||
          '}'
      ) AS JSON_M
    FROM MEASURE
    WHERE MEASURE.CODE_HORSE = :C.CODE_HORSE
    INTO JSON_M;

    JSON_STR =
      JSON_STR ||
      IIF(JSON_STR = '', '[', ',' || ascii_char(13)) ||
      '{' ||
      JSON_UTILS.INTEGER_PAIR('code_horse', C.CODE_HORSE) ||
      ',' ||
      JSON_UTILS.STRING_PAIR('name', C.NAME) ||
      ',' ||
      JSON_UTILS.TIMESTAMP_PAIR('birthday', C.BIRTHDAY) ||
      ',' ||
      JSON_UTILS.STRING_VALUE('measures') || ':[' || COALESCE(JSON_M, '') || ']' ||
      '}'
    ;
  END
  JSON_STR = JSON_STR || ']';
  SUSPEND;
END

/*
------ Информация о производительности ------
Время подготовки запроса = 0ms
Время выполнения запроса = 26s 364ms
Среднее время на получение одной записи = 26 364,00 ms
Current memory = 580 331 952
Max memory = 585 289 472
Memory buffers = 32 768
Reads from disk to cache = 287
Writes from cache to disk = 53 492
Чтений из кэша = 222 546
*/