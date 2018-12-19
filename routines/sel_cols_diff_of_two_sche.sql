
#查询两个数据库中不同的字段及其类型、注释
# 入参：
#   sche_name_a  数据库名A
#   sche_name_b  数据库名B
#------------------------------------------------------------------------------------------------

CREATE PROCEDURE sel_cols_diff_of_two_sche(IN sche_name_a VARCHAR(50),IN sche_name_b VARCHAR(50))
  BEGIN
    DECLARE c_no INT;
    DECLARE tableName VARCHAR(50);
    DECLARE cur_tables_name CURSOR FOR SELECT table_name
                                       FROM information_schema.`TABLES` a
                                       WHERE a.`TABLE_SCHEMA` = sche_name_a
                                             AND table_name IN
                                                 (
                                                   SELECT table_name
                                                   FROM information_schema.`TABLES` a
                                                   WHERE a.`TABLE_SCHEMA` = sche_name_b
                                                 )
                                             AND a.`TABLE_TYPE` = 'BASE TABLE';
    #当读到数据的最后一条时,设置c_no变量为1
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET c_no = 1; 
    SET c_no = 0;
    truncate temp_diff_colum;
    OPEN cur_tables_name;
    WHILE c_no = 0
    DO
      FETCH cur_tables_name
      INTO tableName;
      INSERT INTO temp_diff_colum
        SELECT
          c.table_name,
          c.`COLUMN_NAME`,
          c.column_type,
          c.column_comment,
          c.column_default
        FROM information_schema.`COLUMNS` c
        WHERE c.`TABLE_SCHEMA` = sche_name_a
              AND c.table_name = tableName
              AND c.column_name NOT IN
                  (
                    SELECT d.column_name
                    FROM information_schema.`COLUMNS` d
                    WHERE d.`TABLE_SCHEMA` = sche_name_b
                          AND d.table_name = tableName
                  );
    END WHILE;
  END;

#------------------------------------------------------------------------------------------------

