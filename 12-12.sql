set serveroutput on;
show serveroutput;

/*
 치환변수(&)를 사용하면 숫자를 입력하면 해당 구구단이 출력되도록 하시오... ㅠㅠ
*/

DECLARE
    v_left number := &단; 
    v_count number := 1;
BEGIN
    LOOP
        DBMS_OUTPUT.PUT_LINE(v_left || ' * ' || v_count || ' = ' || v_left*v_count );
        v_count := v_count + 1;
        EXIT WHEN v_count > 9;
    END LOOP;
END;
/

DECLARE
    v_left number := &단; 
    v_count number := 1;
BEGIN
    while v_count <= 9 LOOP
        DBMS_OUTPUT.PUT_LINE(v_left || ' * ' || v_count || ' = ' || v_left*v_count );
        v_count := v_count + 1;
    END LOOP;
END;
/

DECLARE
    v_left number := &단; 
BEGIN
    for i in 1..9 LOOP
        DBMS_OUTPUT.PUT_LINE(v_left || ' * ' || i || ' = ' || v_left * i );
    END LOOP;
END;
/


/*
3. 구구단 2~9단 까지 출력되도록 하시오~~
*/
DECLARE
    v_left number := 2;
    v_right number := 1;
    v_msg VARCHAR2(1000);
BEGIN
    for i in 2..9 loop
        v_right := 1;
        
        for i in 1..9 loop
        v_msg := v_right || ' * ' || v_left || ' = ' || v_left*v_right || ' ';
        DBMS_OUTPUT.PUT(RPAD(v_msg, 13, ' '));
        v_right := v_right + 1;
        end loop;
        DBMS_OUTPUT.PUT_LINE('');
        v_left := v_left + 1;
    end loop;
END;
/



/*
4. 구구단 1~9단 까지 출력되도록 하시오~~ (단, 홀수단만 출력하세요~)
*/

DECLARE
    v_out NUMBER := 1;
    v_in NUMBER := 1;
    v_msg varchar(1000);
BEGIN
    LOOP 
       v_in := 1; 
            LOOP 
                 v_msg := v_in || ' * ' ||   v_out || ' = ' || v_out*v_in || '   ';
                 IF mod(v_in,2)=1 THEN
                 DBMS_OUTPUT.PUT(RPAD(v_msg,15,' '));
                 end if;
                 v_in := v_in + 1;
                 EXIT WHEN v_in > 9;
             END LOOP;
        DBMS_OUTPUT.PUT_LINE('');
         v_out := v_out + 1;
         
        EXIT WHEN v_out > 9;
    END LOOP;
END;
/

-- RECORD // 사용자 정의 유형,,, 자바의 클래스와 비슷하다!
-- 블럭이 바뀌면 또 정의해줘야한다.. ㅠ
DECLARE
    -- 레코드 타입이라는걸 명시하게 이름_타입_type 이라고 명칭 정하자!
    TYPE info_rec_type IS RECORD
        ( no NUMBER NOT NULL := 1,
          name VARCHAR2(1000) := 'No Name',
          birth DATE );
          
    user_info info_rec_type; -- 변수 선언한것임.
BEGIN
    
    user_info.birth := sysdate;
    DBMS_OUTPUT.PUT_LINE(user_info.birth);
    
END;
/

-- %ROWTYPE
DECLARE
    emp_info_rec employees%ROWTYPE;
BEGIN
    SELECT *
    INTO emp_info_rec
    FROM employees
    where employee_id = &사원번호;
    
    DBMS_OUTPUT.PUT_LINE(emp_info_rec.last_name || '님의 월급은 ' || emp_info_rec.salary || '달러 입니다!');
    
END;
/

--근데 만약 조인이나 서브쿼리가 필요한 경우의 값들을vc 불러와야한다면?
--ex) 사원번호, 이름, 부서이름
DECLARE
    TYPE emp_rec_type IS RECORD
        ( eid employees.employee_id%TYPE, -- NUMBER
          ename employees.last_name%TYPE, -- VARCHAR2
          deptname departments.department_name%TYPE); -- VARCHAR2
          
    emp_rec emp_rec_type;
BEGIN
    --데이터 타입의 순서만 잘 지키자!
    SELECT employee_id, last_name, department_id
    INTO emp_rec
    FROM employees JOIN departments
                   on(employees.deparment_id = departments.department_id)
    WHERE employee_id = &사원번호;
    
    DBMS_OUTPUT.PUT_LINE(emp_rec.ename);
END;
/

-- TABLE
DECLARE
    -- 1) 정의
    TYPE num_table_type IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;
    
    -- 2) 선언
    num_list num_table_type;
BEGIN
    -- array[0] => table(0)
    num_list( -1000) := 1;
    num_list(  1234) := 2;
    num_list(111111) := 3;
    
    DBMS_OUTPUT.PUT_LINE(num_list.count); -- 내부의 값이 몇 개인지..
    
END;
/


DECLARE
    -- 1) 정의
    TYPE num_table_type IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;
    
    -- 2) 선언
    num_list num_table_type;
BEGIN
    FOR i IN 1..9 LOOP
        num_list(i) := 2 * i;
    END LOOP;
    
    FOR idx IN num_list.FIRST .. num_list.LAST LOOP
        if num_list.EXISTS(idx) THEN
            DBMS_OUTPUT.PUT_LINE(2 || ' * ' || idx || ' = ' || num_list(idx));
        END IF;
    END LOOP;    
END;
/

DECLARE
    v_max NUMBER := 0;
    v_min NUMBER := 0;
    TYPE emp_table_type IS TABLE OF employees%ROWTYPE
        INDEX BY BINARY_INTEGER;
        
    emp_table emp_table_type;
    emp_rec employees%ROWTYPE;
BEGIN
    
    SELECT MAX(employee_id), MIN(employee_id)
    INTO v_max, v_min
    FROM employees;
    
   

    FOR eid IN v_min .. v_max LOOP
        SELECT *
        INTO emp_rec
        FROM employees
        WHERE employee_id = eid;
        
        emp_table(eid) := emp_rec;
    END LOOP;
    
     
    
    FOR idx IN emp_table.FIRST .. emp_table.LAST LOOP
        DBMS_OUTPUT.PUT_LINE('사원번호 : ' || emp_table(idx).employee_id || '       사원이름 : ' || emp_table(idx).last_name);
    
    end loop; 
END;
/


-- 정답은?

DECLARE
    v_min employees.employee_id%TYPE; -- 최소 사원번호
    v_MAX employees.employee_id%TYPE; -- 최대 사원번호
    v_result NUMBER(1,0);             -- 사원의 존재유무를 확인
    emp_record employees%ROWTYPE;     -- Employees 테이블의 한 행에 대응
    
    TYPE emp_table_type IS TABLE OF emp_record%TYPE
        INDEX BY PLS_INTEGER;
    
    emp_table emp_table_type;
BEGIN
    -- 최소 사원번호, 최대 사원번호
    SELECT MIN(employee_id), MAX(employee_id)
    INTO v_min, v_max
    FROM employees;
    
    FOR eid IN v_min .. v_max LOOP
        SELECT COUNT(*)
        INTO v_result
        FROM employees
        WHERE employee_id = eid;
        
        IF v_result = 0 THEN
            CONTINUE;
        END IF;
        
        SELECT *
        INTO emp_record
        FROM employees
        WHERE employee_id = eid;
        
        emp_table(eid) := emp_record;     
    END LOOP;
    
    FOR eid IN emp_table.FIRST .. emp_table.LAST LOOP
        IF emp_table.EXISTS(eid) THEN
            DBMS_OUTPUT.PUT(emp_table(eid).employee_id || ', ');
            DBMS_OUTPUT.PUT_LINE(emp_table(eid).last_name);
        END IF;
    END LOOP;    
END;
/

--cursor 간단하게 만들어보자

DECLARE
    CURSOR emp_dept_cursor IS
        SELECT employee_id, last_name
        FROM employees
        WHERE department_id = &부서번호;
        
    -- fetch Into에 들어갈 변수 선언
    v_eid employees.employee_id%type;
    v_ename employees.last_name%type;
BEGIN
    OPEN emp_dept_cursor;
    
    FETCH emp_dept_cursor INTO v_eid, v_ename;
    
    
    DBMS_OUTPUT.PUT_LINE(v_eid);
    DBMS_OUTPUT.PUT_LINE(v_ename);
    
    CLOSE emp_dept_cursor; -- close된 커서에는 접근 불가임!
END;
/

-- 메모리에 올라가있는 데이터
        SELECT employee_id, last_name
        FROM employees
        WHERE department_id = 50;
 
 
 DECLARE
    CURSOR emp_info_cursor IS
        SELECT employee_id as eid, last_name ename ,hire_date hdate
        FROM employees
        WHERE department_id = &부서번호
        ORDER BY hire_date DESC;
    emp_rec emp_info_cursor%ROWTYPE;
 BEGIN
    OPEN emp_info_cursor;
    
    
    LOOP
        FETCH emp_info_cursor INTO emp_rec;
--        EXIT WHEN emp_info_cursor%ROWCOUNT > 10; -- 부서번호 조건을 주니까 총 데이터가 어차피 10개가 될 수 없으면 무한루프 돈다..
        EXIT WHEN emp_info_cursor%NOTFOUND or emp_info_cursor%ROWCOUNT > 10 ; -- 보통은 notfound로 조건 줄 수 있지만 같이 줄 수 도 있음~
        DBMS_OUTPUT.PUT(emp_info_cursor%ROWCOUNT || ', ');        
        DBMS_OUTPUT.PUT(emp_rec.eid || ', ');
        DBMS_OUTPUT.PUT(emp_rec.ename || ', ');
        DBMS_OUTPUT.PUT_LINE(emp_rec.hdate);    
    END LOOP;
    
    IF emp_info_cursor%ROWCOUNT <= 0 THEN
        DBMS_OUTPUT.PUT_LINE('현재 커서의 데이터는 존재하지 않아요');
    end if;
    
    CLOSE emp_info_cursor; 
 END;
 /

-- 1) 커서를 이용하여 모든 사원의 사원번호, 이름, 부서이름 출력하시오

DECLARE
    CURSOR emp_cursor IS 
        SELECT employee_id, last_name, d.department_name
        FROM employees e LEFT JOIN departments d
        ON e.department_id = d.department_id;
    emp_rec emp_cursor%ROWTYPE;
    
    
BEGIN
    OPEN emp_cursor;
    
    LOOP
        FETCH emp_cursor INTO emp_rec;
        EXIT WHEN emp_cursor%NOTFOUND;
        
        DBMS_OUTPUT.PUT('사원 번호 : '|| emp_rec.employee_id );
        DBMS_OUTPUT.PUT('   사원 이름 : '|| emp_rec.last_name );
        DBMS_OUTPUT.PUT_LINE('      부서 이름 : '|| NVL(emp_rec.department_name, '부서가 없습니다!') );
        
    END LOOP;
    
    CLOSE emp_cursor;
END;
/

-- 2) 부서번호가 50이거나 80인 사원들의 사원이름, 급여, 연봉 출력
-- 연봉 : (급여 * 12 + NVL(급여, 0) * NVL(커미션, 0) * 12 )




DECLARE
    CURSOR emp_cursor IS 
        SELECT employee_id, salary, (salary * 12 + ( NVL( SALARY ,0) * NVL(commission_pct,0) * 12)) AS annual
        FROM employees
        where department_id in (50,80);
    emp_rec emp_cursor%ROWTYPE; 
    -- 앗싸리 그냥 변수 선언해서 다 값 넣어도댐
BEGIN
    IF NOT emp_cursor%ISOPEN THEN -- 열려있다면 그냥 고~ 닫혀있으면 오픈하고,
        OPEN emp_cursor;
    END IF;
    
    LOOP 
        FETCH emp_cursor INTO emp_rec;
        EXIT WHEN emp_cursor%NOTFOUND;
        
        DBMS_OUTPUT.PUT('사원 이름 : ' || emp_rec.employee_id);
        DBMS_OUTPUT.PUT('   월급 : $' || emp_rec.salary);
        DBMS_OUTPUT.PUT_LINE('  연봉 : $'|| emp_rec.annual);
   
    END LOOP;
    
    CLOSE emp_cursor;

END;
/


