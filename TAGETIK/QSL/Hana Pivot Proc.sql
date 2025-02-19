/' 
Hana : Procedure stockée Pivot
https://community.sap.com/t5/technology-blogs-by-sap/how-to-pivot-unpivot-in-sap-hana/ba-p/13420392 

Postgres : cest la Demarche mais il faut elaborer une logique de procedure 
https://sqlpad.io/tutorial/mastering-pivot-tables-in-postgresql-for-interviews/#:~:text=In%20PostgreSQL%2C%20a%20pivot%20table,per%20product%20across%20different%20months.

Sql server :


'/


/' ##################  HANA PROCEDURE PIVOT ##################'/
CREATE OR REPLACE PROCEDURE P_PIVOT(
	IN table_name VARCHAR(127),
	IN schema_name VARCHAR(127) , 
	IN select_columns VARCHAR(2147483647),
	IN agg_typ VARCHAR(20),
	IN agg_column VARCHAR(127),
	IN pivot_column VARCHAR(2147483647),
	IN pivot_values VARCHAR(2147483647))
	LANGUAGE SQLSCRIPT
	SQL SECURITY INVOKER
	READS SQL DATA AS
BEGIN
	USING SQLSCRIPT_STRING AS lib;
	DECLARE v_table_name VARCHAR(127) = table_name;
	DECLARE v_schema_name VARCHAR(127) = schema_name;
	DECLARE v_select_columns VARCHAR(2147483647) = select_columns;
	DECLARE v_agg_typ VARCHAR(20) = agg_typ;
	DECLARE v_agg_column VARCHAR(127) = agg_column;
	DECLARE v_pivot_column VARCHAR(2147483647) = pivot_column;
	DECLARE v_pivot_values VARCHAR(2147483647) = pivot_values;

	DECLARE v_count INT= 0;
	DECLARE v_idx INT;
	DECLARE v_statement VARCHAR(2147483647);
	DECLARE a_pivot_values VARCHAR(127) ARRAY;

	/*
		if all columns needed, use * to get the column names except v_agg_column,v_pivot_column
	*/
	IF v_select_columns = '*'
		THEN
			SELECT string_agg(column_name,',' ORDER BY position) INTO v_select_columns FROM sys.columns 
			WHERE table_name = v_table_name
				AND schema_name = v_schema_name 
				AND column_name NOT IN (v_agg_column,v_pivot_column);
	END IF;	
	
	/*
		if all values in the pivot column should use for pivoting
	*/
	IF v_pivot_values = '*'
		THEN
			EXECUTE IMMEDIATE ('select string_agg('||:v_pivot_column ||', '','' order by ' || :v_pivot_column || ') from (select distinct ' || :v_pivot_column || ' from '|| :v_table_name || ')') into v_pivot_values;
	END IF;
	

	a_pivot_values := LIB:split_to_array( :v_pivot_values, ',' );
	v_count = cardinality(:a_pivot_values);
	v_statement = 'select ' || v_select_columns;

	/*
		generate the statement
	*/
	FOR v_idx IN 1.. v_count DO
		v_statement = v_statement || ', ' || v_agg_typ || '(case when ' || v_pivot_column || ' = ' || :a_pivot_values[:v_idx] || ' then ' || v_agg_column || ' end ) as ' || v_pivot_column || '_' || :a_pivot_values[:v_idx];
	END FOR;
	
	v_statement = v_statement || ' from ' || v_table_name || ' group by ' || v_select_columns;
	
	/*
		execute the statement
	*/
	EXECUTE IMMEDIATE v_statement;
END;


/' ##################  HANA PROCEDURE UNPIVOT ##################'/

/*
This script calls the stored procedure P_UNPIVOT to transform a table by unpivoting specified columns.

Arguments:
1. 'table_name_example' - The name of the table to be unpivoted.
2. 'schema_name_example' - The schema name where the table resides.
3. '*' - The columns to be included in the unpivot operation (use '*' for all columns).
4. 'unpivot_val_name_example' - The name for the unpivoted value column.
5. 'unpivot_col_name_example' - The name for the unpivoted column that will hold the original column names.
6. 'column1,column2,column3' - A comma-separated list of columns to be unpivoted.
7. 'value1,value2,value3' - A comma-separated list of values corresponding to the columns to be unpivoted.
8. TRUE - A boolean flag indicating whether to include NULL values in the unpivoted result.

CALL P_UNPIVOT(
	'table_name_example',
	'schema_name_example',
	'*',
	'unpivot_val_name_example',
	'unpivot_col_name_example',
	'column1,column2,column3',
	'value1,value2,value3',
	TRUE
);
*/

CREATE OR REPLACE PROCEDURE P_UNPIVOT(
	IN table_name VARCHAR(127),
	IN schema_name VARCHAR(127) , 
	IN select_columns VARCHAR(2147483647),
	IN unpivot_val_name VARCHAR(127),
	IN unpivot_col_name VARCHAR(127),
	IN unpivot_columns VARCHAR(2147483647),
	IN unpivot_column_values VARCHAR(2147483647),
	IN include_nulls BOOLEAN DEFAULT TRUE)
	LANGUAGE SQLSCRIPT
	SQL SECURITY INVOKER
	READS SQL DATA AS
BEGIN
	USING SQLSCRIPT_STRING AS lib;
	DECLARE v_table_name VARCHAR(127) = table_name;
	DECLARE v_schema_name VARCHAR(127) = schema_name;
	DECLARE v_select_columns VARCHAR(2147483647) = select_columns;
	DECLARE v_unpivot_val_name VARCHAR(127) = unpivot_val_name;
	DECLARE v_unpivot_col_name VARCHAR(127) = unpivot_col_name;
	DECLARE v_unpivot_columns VARCHAR(2147483647) = unpivot_columns;
	DECLARE v_unpivot_column_values VARCHAR(2147483647) = unpivot_column_values;
	DECLARE v_count INT= 0;
	DECLARE v_idx INT;
	DECLARE v_statement VARCHAR(2147483647);
	DECLARE v_statement_map1 VARCHAR(2147483647) = '';
	DECLARE v_statement_map2 VARCHAR(2147483647) = '';
	DECLARE v_include_nulls BOOLEAN = include_nulls;
	DECLARE a_unpivot_columns VARCHAR(127) array;
	DECLARE a_unpivot_column_values VARCHAR(100) array;

	a_unpivot_columns = LIB:split_to_array( :v_unpivot_columns, ',' );
	a_unpivot_column_values = LIB:split_to_array( :v_unpivot_column_values, ',' );
	v_count = cardinality(:a_unpivot_columns);
	tbl_pivot_columns = UNNEST(:a_unpivot_columns) AS ("EXCLUDE_COLUMNS");

	/*
		if all columns needed, use * to get the column names except tbl_pivot_columns
	*/
	IF v_select_columns = '*'
		THEN
			SELECT string_agg(column_name,',' ORDER BY position) INTO v_select_columns FROM sys.columns 
			WHERE table_name = v_table_name
				AND schema_name = v_schema_name 
				AND column_name NOT IN (SELECT EXCLUDE_COLUMNS FROM :tbl_pivot_columns	);
	end IF;	

	v_statement = 'select ' || v_select_columns || ', ' || 'map(element_number';

	/*
		generate the statement
	*/
	FOR v_idx IN 1.. v_count DO
		v_statement_map1 = v_statement_map1 || ',' || v_idx  || ',''' || :a_unpivot_column_values[:v_idx] || '''' ;
		v_statement_map2 = v_statement_map2 || ',' || v_idx  || ',' || :a_unpivot_columns[:v_idx]  ;
	END FOR;
	v_statement = v_statement || v_statement_map1 || ') as "'|| v_unpivot_col_name || '", map(element_number ' || v_statement_map2 || ') as "' || v_unpivot_val_name || '" from ' || v_table_name || ', SERIES_GENERATE_INTEGER(1,1,' || v_count+1 || ') order by element_number';

	IF v_include_nulls = FALSE
		THEN
		v_statement = 'select * from (' || v_statement || ' ) where ' || v_unpivot_val_name || ' is not null';
	END IF;

	EXECUTE IMMEDIATE v_statement;

END;