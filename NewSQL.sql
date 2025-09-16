DECLARE
    v_search_value   VARCHAR2(4000) := 'A317010179.JPG';  -- value to search
    v_count          NUMBER;
    v_sql            VARCHAR2(4000);
    v_table_name     VARCHAR2(128);
BEGIN
    -- Pick just 1 table from schema FORTIS
    SELECT table_name
    INTO v_table_name
    FROM (
        SELECT table_name
        FROM all_tables
        WHERE owner = 'FORTIS'
        ORDER BY table_name
    )
    WHERE ROWNUM = 1;

    DBMS_OUTPUT.PUT_LINE('Scanning table: ' || v_table_name);

    FOR c IN (
        SELECT column_name, data_type
        FROM all_tab_columns
        WHERE owner = 'FORTIS'
          AND table_name = v_table_name
          AND data_type IN ('VARCHAR2','CHAR','NVARCHAR2','NCHAR','NUMBER','DATE')
        ORDER BY column_id
    ) LOOP
        BEGIN
            -- Faster check: only test if at least 1 row exists
            v_sql := 'SELECT 1 FROM FORTIS.' || v_table_name ||
                     ' WHERE UPPER(TO_CHAR(' || c.column_name || ')) LIKE :1 AND ROWNUM = 1';

            EXECUTE IMMEDIATE v_sql INTO v_count USING '%' || UPPER(v_search_value) || '%';

            IF v_count = 1 THEN
                DBMS_OUTPUT.PUT_LINE('Match found in column: ' || c.column_name);
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL; -- no match in this column
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Skipped column: ' || c.column_name ||
                                     ' (Error: ' || SQLERRM || ')');
        END;
    END LOOP;
END;
/
