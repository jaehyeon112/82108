SET SERVEROUTPUT ON;
SHOW SERVEROUTPUT;

--키워드
/*
함수

pl/sql을 쓰는 이유.

프로시저가 핵심이다!

객체 보는 법 존재
*/


-- FUNCTION 
CREATE or replace FUNCTION plus
(p_x NUMBER,
p_y NUMBER)
RETURN NUMBER
IS 
    v_result NUMBER; 
BEGIN
    v_result := p_x + p_y;
    RETURN v_result;
 
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN '데이터가 존재하지 않습니다.'; -- return 타입 맞춰야함.
    WHEN TOO_MANY_ROWS THEN
        RETURN '데이터가 요구한 것 보다 많습니다.';
END;
 /
 

-- function 실행방법
-- 1) 블록 내부에서 실행
DECLARE
    v_sum NUMBER;
    v_test NUMBER := 50;
BEGIN
    v_sum := plus(10,v_test);
    DBMS_OUTPUT.PUT_LINE(v_sum);
END;
/

-- 2) EXECUTE
EXECUTE DBMS_OUTPUT.PUT_LINE(plus(10,20));

-- 3) SQL문 실행
SELECT plus(10, 20) FROM DUAL;

-- 1 ~ n 까지 누적된 값을 돌려주는 함수

CREATE or replace FUNCTION y_factorial
(p_n NUMBER)
RETURN NUMBER
IS
    v_sum NUMBER := 0;
BEGIN
    FOR idx IN 1 .. p_n LOOP 
        v_sum := v_sum + idx;
    END LOOP;
    
    RETURN v_sum;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN -1;
    WHEN TOO_MANY_ROWS THEN
        RETURN 0;
END;
/

EXECUTE DBMS_OUTPUT.PUT_LINE(y_factorial(10));

/*
    1. 사원번호를 입력하면
    last_name + first_name이 출력되는
    y_yedam 함수를 생성하시오

실행) EXECUTE DBMS_OUTPUT.PUT_LINE(y_yedam(174));
출력 예 Adel Ellen

SELECT employee_id, y_yedam(employee_id)
FROM employees;
*/
 EXECUTE DBMS_OUTPUT.PUT_LINE(y_yedam(500));
 
SELECT employee_id, y_yedam(employee_id)
FROM employees;

CREATE or replace FUNCTION y_yedam
(v_empid NUMBER)
RETURN VARCHAR2
IS
    cursor emp_cursor IS
    SELECT last_name, first_name
    FROM employees
    WHERE employee_id = v_empid;
    
    emp_rec emp_cursor%ROWTYPE;
    
    v_name VARCHAR2(50);
    e_no_name EXCEPTION;
BEGIN

    OPEN emp_cursor;
    FETCH emp_cursor INTO emp_rec;
        v_name := emp_rec.last_name || ' ' || emp_rec.first_name;
        if emp_cursor%NOTFOUND THEN
            raise e_no_name;
        end if;
    CLOSE emp_cursor;
    
    RETURN v_name;
    
EXCEPTION
    WHEN e_no_name THEN
    RETURN '없는 사람 입니다.';
END;
/

/*

1.
사원번호를 입력하면 
last_name + first_name 이 출력되는 
y_yedam 함수를 생성하시오.

실행) EXECUTE DBMS_OUTPUT.PUT_LINE(y_yedam(174))
출력 예)  Abel Ellen

SELECT employee_id, y_yedam(employee_id)
FROM   employees;

*/

/*
2.
사원번호를 입력할 경우 다음 조건을 만족하는 결과가 출력되는 ydinc 함수를 생성하시오.
- 급여가 5000 이하이면 20% 인상된 급여 출력
- 급여가 10000 이하이면 15% 인상된 급여 출력
- 급여가 20000 이하이면 10% 인상된 급여 출력
- 급여가 20000 이상이면 급여 그대로 출력
실행) SELECT last_name, salary, YDINC(employee_id)
     FROM   employees;
*/

SELECT last_name, salary, YDINC(employee_id) as increase_salary
     FROM   employees;

CREATE or replace FUNCTION ydinc
(v_id NUMBER)
return number
IS
    v_sal NUMBER;

BEGIN
    SELECT salary
    INTO v_sal
    FROM employees
    WHERE employee_id = v_id;
    
    if v_sal > 20000 then
        v_sal := v_sal;
    elsif v_sal > 10000 then
        v_sal := v_sal * 1.10;
    elsif v_sal > 5000 then
        v_sal := v_sal * 1.15;
    else 
        v_sal := v_sal * .20;
    end if;
    
    return v_sal;
    
END;
/
/*

3.
사원번호를 입력하면 해당 사원의 연봉이 출력되는 yd_func 함수를 생성하시오.
->연봉계산 : (급여+(급여*인센티브퍼센트))*12
실행) SELECT last_name, salary, YD_FUNC(employee_id)
     FROM   employees;
     
*/
SELECT last_name, salary, YD_FUNC(employee_id)
     FROM   employees;

CREATE or replace FUNCTION yd_func
(v_id number)
RETURN NUMBER
IS
    cursor emp_cursor IS
        SELECT salary,commission_pct
        FROM employees
        WHERE employee_id = v_id;

emp_rec emp_cursor%ROWTYPE;
v_annual number;

BEGIN
    open emp_cursor;
    FETCH emp_cursor INTO emp_rec;
        v_annual := (emp_rec.salary+(emp_rec.salary*nvl(emp_rec.commission_pct,0)))*12;
    CLOSE emp_cursor;
    
    return v_annual;
    
END;
/


/*
4. 
SELECT last_name, subname(last_name)
FROM   employees;

LAST_NAME     SUBNAME(LA
------------ ------------
King         K***
Smith        S****
...
예제와 같이 출력되는 subname 함수를 작성하시오.
*/

SELECT last_name, subname(last_name)
FROM   employees;

CREATE or replace FUNCTION subname
(v_last_name VARCHAR2)
return varchar2
IS

BEGIN
   return   RPAD(substr(v_last_name,1,1), length(v_last_name),'*');
END;
/

/*
5. 
부서번호를 입력하면 해당 부서의 책임자 이름를 출력하는 y_dept 함수를 생성하시오.
(단, JOIN을 사용)
(단, 다음과 같은 경우 예외처리(exception)
 해당 부서가 없거나 부서의 책임자가 없는 경우 아래의 메세지를 출력
    
    해당 부서가 없는 경우 -> 해당 부서가 존재하지 않습니다.
	부서의 책임자가 없는 경우 -> 해당 부서의 책임자가 존재하지 않습니다.	)

실행) EXECUTE DBMS_OUTPUT.PUT_LINE(y_dept(110))
출력) Higgins
SELECT department_id, y_dept(department_id)
FROM   departments;
*/

EXECUTE DBMS_OUTPUT.PUT_LINE(y_dept(1100));

SELECT department_id, y_dept(department_id)
FROM   departments;

CREATE or replace FUNCTION y_dept
(v_dpetid NUMBER)
return VARchar2
IS
    e_no_manager EXCEPTION;
    
    cursor total_cursor IS
        select e.last_name
        FROM employees e left join departments d
        on e.employee_id = d.manager_id
        where d.department_id = v_dpetid;
    
    total_rec total_cursor%ROWTYPE;
    v_manager VARCHAR2(100);
    v_dept_id VARCHAR2(300);
BEGIN

    select department_id
    INTO v_dept_id
    FROM departments
    WHERE department_id = v_dpetid;

    OPEN total_cursor;
    FETCH total_cursor INTO total_rec;
        v_manager := total_rec.last_name;
        if total_cursor%ROWCOUNT = 0 THEN
            RAISE e_no_manager;
        end if;
    CLOSE total_cursor;
    
    return v_manager;


EXCEPTION
    WHEN NO_DATA_FOUND THEN
        return '부서가 없어요';
    WHEN e_no_manager THEN
        return '해당 부서의 책임자가 존재하지 않습니다.';
END;
/


-- 전 계정의 객체
SELECT *
FROM all_source;

-- 현재 계정의 객체
SELECT *
FROM user_source;

-- 특정 객체의 정보를 확인하고 싶을 경우
SELECT name, text
FROM user_source
WHERE type IN ('PROCEDURE','FUNCTION', 'PACKAGE', 'PACKAGE BODY');