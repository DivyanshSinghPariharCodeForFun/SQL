DECLARE
    v_search_value   VARCHAR2(4000) := 'A317010179.JPG';  -- value to search
    v_limit_tables   PLS_INTEGER     := 4;                -- NULL = all tables
    v_count          NUMBER;
    v_sql            VARCHAR2(4000);
BEGIN
    FOR t IN (
        SELECT table_name
        FROM all_tables
        WHERE owner = 'FORTIS'
          AND (v_limit_tables IS NULL OR ROWNUM <= v_limit_tables)
        ORDER BY table_name
    ) LOOP
        FOR c IN (
            SELECT column_name, data_type
            FROM all_tab_columns
            WHERE owner = 'FORTIS'
              AND table_name = t.table_name
              AND data_type IN ('VARCHAR2','CHAR','NVARCHAR2','NCHAR','NUMBER','DATE')
            ORDER BY column_id
        ) LOOP
            BEGIN
                v_sql := 'SELECT COUNT(*) FROM FORTIS.' || t.table_name ||
                         ' WHERE UPPER(TO_CHAR(' || c.column_name || ')) LIKE :1';

                EXECUTE IMMEDIATE v_sql INTO v_count USING '%' || UPPER(v_search_value) || '%';

                IF v_count > 0 THEN
                    DBMS_OUTPUT.PUT_LINE('Match found: ' || t.table_name || '.' || c.column_name ||
                                         ' (Rows=' || v_count || ')');
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Skipped: ' || t.table_name || '.' || c.column_name ||
                                         ' (Error: ' || SQLERRM || ')');
            END;
        END LOOP;
    END LOOP;
END;
/
