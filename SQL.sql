-- ====================================================================
-- PL/SQL Script: Search All Tables/Columns in Schema FORTIS for a Value
-- Environment:   Oracle (tested with Toad for Oracle)
-- Author:        <your name>
-- ====================================================================
-- HOW TO USE:
-- 1. Set the variable v_search_value to the string you want to search.
--    Example: 'A317010179.JPG'
-- 2. Set v_limit_tables to NULL to scan all tables,
--    or to a number (e.g., 4) for testing with that many tables only.
-- 3. Run in Toad with DBMS_OUTPUT enabled (View > DBMS Output).
-- ====================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

DECLARE
    v_search_value   VARCHAR2(4000) := 'A317010179.JPG';  -- value to search (case-insensitive)
    v_limit_tables   PLS_INTEGER     := 4;                -- set to NULL for all tables, or e.g. 4 for testing
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
                -- Build dynamic SQL to count matches
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
