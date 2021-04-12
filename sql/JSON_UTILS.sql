SET TERM ^ ;

CREATE OR ALTER PACKAGE JSON_UTILS
AS
begin
  -- экранирование строк
  function Escape_String(AString varchar(8191) character set utf8)
  returns varchar(8191) character set utf8;

  -- строковое значение
  function String_Value(AValue varchar(8191) character set utf8)
  returns varchar(8191) character set utf8;

  -- целое значение
  function Integer_Value(AValue int)
  returns varchar(12) character set utf8;

  -- вещественное значение
  function Float_Value(AValue double precision)
  returns varchar(40) character set utf8;

  -- значение c фиксированной точкой
  function Numeric_Value(AValue varchar(20))
  returns varchar(20) character set utf8;

  -- значение дата-время
  function Timestamp_Value(AValue timestamp)
  returns varchar(40) character set utf8;

  -- значение boolean
  function Boolean_Value(AValue boolean)
  returns varchar(5) character set utf8;

  -- пара ключ-строковое значение
  function String_Pair(
    AKey varchar(255) character set utf8,
    AValue varchar(8191) character set utf8)
  returns varchar(8191) character set utf8;

  -- пара ключ-целое значение
  function Integer_Pair(
    AKey varchar(255) character set utf8,
    AValue int
  )
  returns varchar(300) character set utf8;

  -- пара ключ-вещественное значение
  function Float_Pair(
    AKey varchar(255) character set utf8,
    AValue double precision
  )
  returns varchar(300) character set utf8;

  -- пара ключ-число с фиксированной точкой
  function Numeric_Pair(
    AKey varchar(255) character set utf8,
    AValue varchar(20)
  )
  returns varchar(300) character set utf8;

  -- пара ключ-дата время
  function Timestamp_Pair(
    AKey varchar(255) character set utf8,
    AValue timestamp
  )
  returns varchar(300) character set utf8;

  -- пара ключ-логическое значение
  function Boolean_Pair(
    AKey varchar(255) character set utf8,
    AValue boolean
  )
  returns varchar(300) character set utf8;
end^

RECREATE PACKAGE BODY JSON_UTILS
AS
begin
  -- экранирование строк
  function Escape_String(AString varchar(8191) character set utf8)
  returns varchar(8191) character set utf8
  as
  begin
    AString = REPLACE(AString, '\', '\\');
    AString = REPLACE(AString, ASCII_CHAR(0x08), '\b');
    AString = REPLACE(AString, ASCII_CHAR(0x09), '\t');
    AString = REPLACE(AString, ASCII_CHAR(0x0A), '\r');
    AString = REPLACE(AString, ASCII_CHAR(0x0C), '\f');
    AString = REPLACE(AString, ASCII_CHAR(0x0D), '\n');
    AString = REPLACE(AString, '"', '\"');
    AString = REPLACE(AString, '/', '\/');
    RETURN AString;
  end

  -- строковое значение
  function String_Value(AValue varchar(8191) character set utf8)
  returns varchar(8191) character set utf8
  as
  begin
    if (AValue is null) then
      return 'null';
    else
      return '"' || JSON_UTILS.Escape_String(AValue) || '"';
  end

  -- целое значение
  function Integer_Value(AValue int)
  returns varchar(12) character set utf8
  as
  begin
    if (AValue is null) then
      return 'null';
    else
      return AValue;
  end

  function Float_Value(AValue double precision)
  returns varchar(40) character set utf8
  as
  begin
    if (AValue is null) then
      return 'null';
    else
      return AValue;
  end

  -- значение c фиксированной точкой
  function Numeric_Value(AValue varchar(20))
  returns varchar(20) character set utf8
  as
  begin
    if (AValue is null) then
      return 'null';
    else
      return AValue;
  end

  -- значение дата-время
  function Timestamp_Value(AValue timestamp)
  returns varchar(40) character set utf8
  as
  begin
    if (AValue is null) then
      return 'null';
    else
      return '"' || AValue || '"';
  end

  -- значение boolean
  function Boolean_Value(AValue boolean)
  returns varchar(5) character set utf8
  as
  begin
    return
      case AValue
        when true then 'true'
        when false then 'false'
        else 'null'
      end;
  end

  -- пара ключ-значение
  -- используется для внутренних нужд
  -- значение не экранируется
  function Raw_Pair(
    AKey varchar(255) character set utf8,
    AValue varchar(8191) character set utf8)
  returns varchar(8191) character set utf8
  as
  begin
    return '"' || JSON_UTILS.Escape_String(AKey) || '"' || ':' || AValue;
  end

  -- пара ключ-строковое значение
  function String_Pair(
    AKey varchar(255) character set utf8,
    AValue varchar(8191) character set utf8)
  returns varchar(8191) character set utf8
  as
  begin
    return JSON_UTILS.Raw_Pair(AKey, JSON_UTILS.String_Value(AValue));
  end

  -- пара ключ-целое значение
  function Integer_Pair(
    AKey varchar(255) character set utf8,
    AValue int
  )
  returns varchar(300) character set utf8
  as
  begin
    return JSON_UTILS.Raw_Pair(AKey, JSON_UTILS.Integer_Value(AValue));
  end

  -- пара ключ-вещественное значение
  function Float_Pair(
    AKey varchar(255) character set utf8,
    AValue double precision
  )
  returns varchar(300) character set utf8
  as
  begin
    return JSON_UTILS.Raw_Pair(AKey, JSON_UTILS.Float_Value(AValue));
  end

  -- пара ключ-число с фиксированной точкой
  function Numeric_Pair(
    AKey varchar(255) character set utf8,
    AValue varchar(20)
  )
  returns varchar(300) character set utf8
  as
  begin
    return JSON_UTILS.Raw_Pair(AKey, JSON_UTILS.Numeric_Value(AValue));
  end

  -- пара ключ-дата время
  function Timestamp_Pair(
    AKey varchar(255) character set utf8,
    AValue timestamp
  )
  returns varchar(300) character set utf8
  as
  begin
    return JSON_UTILS.Raw_Pair(AKey, JSON_UTILS.Timestamp_Value(AValue));
  end

  -- пара ключ-логическое значение
  function Boolean_Pair(
    AKey varchar(255) character set utf8,
    AValue boolean
  )
  returns varchar(300) character set utf8
  as
  begin
    return JSON_UTILS.Raw_Pair(AKey, JSON_UTILS.Boolean_Value(AValue));
  end
end^

SET TERM ; ^

/* Существующие привилегии на этот пакет */

GRANT EXECUTE ON PACKAGE JSON_UTILS TO SYSDBA;