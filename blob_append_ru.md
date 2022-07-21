Функция blob_append
===================


*Доступно в*: DSQL, PSQL.

Синтаксис:

`BLOB_APPEND(<blob> [, <value1>, ... <valueN]>`


| Параметр | Описание              |
|----------|-----------------------|
| blob     | BLOB или NULL.        |
| value    | Значение любого типа. |



*Тип возвращаемого результата*: временный не закрытый BLOB с флагом
`BLB_close_on_read`.

Функция `BLOB_APPEND` предназначена для конкатенации BLOB без создания
промежуточных BLOB. Обычная операция конкатенации с аргументами типа BLOB всегда создаст столько временных BLOB,
сколько раз используется.

Входные аргументы:

- Для первого аргумента в зависимости от его значения определено следующее поведение функции:
	- NULL: будет создан новый пустой не закрытый BLOB
	- постоянный BLOB (из таблицы) или временный уже закрытый BLOB:
	будет создан новый пустой не закрытый BLOB и содержимое
	первого BLOB будет в него добавлено
	- временный не закрытый BLOB: он будет использован далее
	- другие типы данных преобразуются в строку, будет создан временный не закрытый BLOB с содержимым этой строки
- остальные аргументы могут быть любого типа. Для них определено следующее поведение:
    - NULL игнорируется
    - не BLOB преобразуются в строки (по обычным правилам) и добавляются к содержимому
     результата
    - BLOB при необходимости транслитерируются к набору символов первого аргумента и их
     содержимое добавляется к результату

В качестве выходного значения функция `BLOB_APPEND` возвращает временный не закрытый BLOB с флагом `BLB_close_on_read`.
Это или новый BLOB, или тот же, что был в первом аргументе. Таким образом ряд операций вида
`blob = BLOB_APPEND(blob, ...)` приведёт к созданию не более одного BLOB (если не пытаться добавить BLOB к самому себе).
Этот BLOB будет автоматически закрыт движком при попытке прочитать его клиентом, записать в таблицу или использовать в других выражениях, требующих чтения содержимого.

Замечание

Проверка BLOB на значение NULL с помощью оператора `IS [NOT] NULL` не читает его, а следовательно временный BLOB
с флагом `BLB_close_on_read` не будет закрыт при таких проверках.

```
execute block
returns (b blob sub_type text)
as
begin
  -- создаст новый временный не закрытый BLOB
  -- и запишет в него строку из 2-ого аргумента
  b = blob_append(null, 'Hello ');
  -- добавляет во временный BLOB две строки не закрывая его
  b = blob_append(b, 'World', '!');
  -- сравнение BLOB со строкой закроет его, ибо для этого надо прочитать BLOB
  if (b = 'Hello World!') then
  begin
  -- ...
  end
  -- создаст временный закрытый BLOB добавив в него строку
  b = b || 'Close';
  suspend;
end
```

Совет

Используйте функции LIST и BLOB_APPEND для конкатенации BLOB. Это позволит сэкономить объём потребляемой памяти, 
дисковый ввод/вывод, а также предотвратит разрастание базы данных из-за создания множества временных BLOB при использовании операторов конкатенации.

Пример:

Предположим вам надо собрать JSON на стороне сервера. У нас есть PSQL пакет JSON_UTILS с набором функций для
преобразования элементарных типов данных в JSON нотацию. Тогда сборка JSON с использованием функции `BLOB_APPEND` будет выглядеть 
следующим образом:

```
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
```

Аналогичный пример с использованием обычного оператора конкатенации || 
работает в 18 раз медленнее (на моём сервере), и делает в 1000 раз больше операций записи на диск.