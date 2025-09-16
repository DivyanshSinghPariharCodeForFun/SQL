SET SERVEROUTPUT ON SIZE 1000000;

DECLARE
    v_search_value   VARCHAR2(4000) := '&search_value';  -- Enter your search value here or at runtime
    v_sql            CLOB;
    v_found          NUMBER;
    v_owner          VARCHAR2(30) := 'FORTIS';  -- Your schema name
    
    CURSOR col_cursor IS
        SELECT owner, table_name, column_name, data_type
        FROM all_tab_columns
        WHERE owner = v_owner
          AND data_type IN ('VARCHAR2', 'CHAR', 'NVARCHAR2', 'NCHAR', 'NUMBER', 'DATE')
        ORDER BY table_name, column_name;

BEGIN
    FOR rec IN col_cursor LOOP
        BEGIN
            v_sql := 'SELECT COUNT(*) FROM "' || rec.owner || '"."' || rec.table_name || '" WHERE ';
            
            IF rec.data_type = 'DATE' THEN
                v_sql := v_sql || 'TO_CHAR("' || rec.column_name || '", ''YYYY-MM-DD HH24:MI:SS'') LIKE :val';
            ELSE
                v_sql := v_sql || 'TO_CHAR("' || rec.column_name || '") LIKE :val';
            END IF;
            
            EXECUTE IMMEDIATE v_sql INTO v_found USING '%' || v_search_value || '%';
            
            IF v_found > 0 THEN
                DBMS_OUTPUT.PUT_LINE('Found in ' || rec.owner || '.' || rec.table_name || '.' || rec.column_name || ' (' || rec.data_type || ')');
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                NULL; -- Skip columns that can’t be searched
        END;
    END LOOP;
END;
/
