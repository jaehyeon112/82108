set serveroutput on;
show serveroutput;

-- select의 사용
DECLARE
    v_eid number;
    v_ename e.first_name%type;
    v_job VARCHAR2(1000);
BEGIN
    SELECT employee_id, first_name, job_id
    INTO v_eid, v_ename, v_job
    FROM employees e
    WHERE employee_id = 100;
    
    DBMS_OUTPUT.PUT_LINE('사원번호 : ' || v_eid);
    DBMS_OUTPUT.PUT_LINE('사원이름 : ' || v_ename);
    DBMS_OUTPUT.PUT_LINE('업무 : ' || v_job);

END;
/


-- 치환변수의 사용 ( := &치환변수 ) declare, begin 어느 곳에서나 사용가능. 어차피 컴파일 하기 전에 사용되니까
-- 치환변수 사용할때 데이터 타입이 문자열이면 입력할때 ' ', 혹은 치환변수에 ' ' 사용하기, ex) 주민번호같은 경우 0이 먼저 시작되는 경우도 있으므로..
DECLARE
    v_eid e.employee_id%TYPE := &사원번호;
    v_ename e.last_name%TYPE;
BEGIN
    SELECT first_name || ', ' || last_name
    INTO v_ename
    FROM employees e
    WHERE employee_id = v_eid;
    
    DBMS_OUTPUT.PUT_LINE('사원번호 : ' || v_eid);
    DBMS_OUTPUT.PUT_LINE('사원이름 : ' || v_ename);
END;
/

-- 1) 특정 사원의 매니저에 해당하는 사원번호를 출력하시오. (특정 사원은 치환변수를 사용해서~~)
DECLARE
    v_id employees.employee_id%TYPE := &사원번호;
    v_manager employees.manager_ID%TYPE;
BEGIN
    SELECT manager_id
    INTO v_manager
    FROM employees 
    WHERE employee_id = v_id;
    
    DBMS_OUTPUT.PUT_LINE('사원 이름 : ' || v_id);
    DBMS_OUTPUT.PUT_LINE('사원의 매니저 번호 : ' || v_manager);

END;
/

--employees => manager_id => 매니저;
-- departments => manager_id => 부서장;


-- implicit curser
DECLARE
    v_deptno departments.department_id%TYPE;
    v_comm employees.commission_pct%TYPE := 0.2;
    
BEGIN
    SELECT department_id
    INTO v_deptno
    FROM employees
    where employee_id = &사원번호;
    
    INSERT INTO employees (employee_id, last_name, email, hire_date, job_id, department_id)
    values(1000, 'Hong', 'hkd@google.com', sysdate, 'IT_PROG'  ,v_deptno);
    
    DBMS_OUTPUT.PUT_LINE('등록 결과 : ' || SQL%ROWCOUNT);
    
    UPDATE employees
    SET salary = (NVL(salary,0) + 10000) * v_comm
    where employee_id = 1000;
    
    DBMS_OUTPUT.PUT_LINE('수정 결과 : ' || SQL%ROWCOUNT);
    
END;
/

rollback;

select * from employees where employee_id = 1000;



-- DML의 확인을 위해선 IF문을 같이 쓰면 된다.
BEGIN
    DELETE FROM employees
    WHERE employee_id = &사원번호;
    
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('해당 사원은 존재하지 않습니다.');
    END IF;
END;
/


/* 
    1. 사원번호를 입력할 경우
    사원번호, 사원이름, 부서이름을 
    출력하는 PL/SQL을 작성하시오.
    사원번호는 치환변수를 통해 입력받습니다.
*/
DECLARE
    v_empid employees.employee_id%type;
    v_empname employees.last_name%type;
    v_deptname departments.department_name%type;
BEGIN
    SELECT e.employee_id, e.last_name, d.department_name
    INTO v_empid, v_empname, v_deptname
    from employees e left join departments d
    ON (e.department_id = d.department_id)
    where e.employee_id = &사원번호;
    
    DBMS_OUTPUT.PUT_LINE('사원번호 : ' || v_empid);
    DBMS_OUTPUT.PUT_LINE('사원이름 : ' || v_empname);
    DBMS_OUTPUT.PUT_LINE('부서이름 : ' || v_deptname);
    
END;
/

/* 
    2. 사원번호를 입력할 경우
    사원이름, 급여, 연봉을 
    출력하는 PL/SQL을 작성하시오.
    사원번호는 치환변수를 사용하고
    연봉은 아래의 공식을 기반으로 연산하시오.
    (급여 * 12 + ( NVL(급여,0) * NVL(커미션, 0) * 12 )  )  연봉은 앞으로 이 공식을 사용함.
*/
DECLARE
    v_empname employees.last_name%type;
    v_salary employees.salary%type;
    v_annual v_salary%type;
BEGIN
    SELECT last_name,
           salary, 
           (salary * 12 + (NVL ( salary, 0) * NVL (commission_pct,0)*12) ) as annual
    INTO v_empname, v_salary, v_annual
    FROM employees
    WHERE employee_id = &사원번호;
    
    DBMS_OUTPUT.PUT_LINE('사원이름 : ' || v_empname);
    DBMS_OUTPUT.PUT_LINE('급여 : ' || v_salary);
    DBMS_OUTPUT.PUT_LINE('연봉 : ' || v_annual);
END;
/

-- if문 실습
BEGIN
    DELETE FROM employees
    WHERE employee_id = &사원번호;
    
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('정상적으로 실행되지 않았습니다.');
        DBMS_OUTPUT.PUT_LINE('해당 사원은 존재하지 않습니다.');
    END IF;
END;
/

-- IF~ ELSE 문 : 팀장급, 그룹함수 중 count만 유일하게 값이 없더라도 파악가능한 함수..
DECLARE
    v_count NUMBER;
BEGIN
    SELECT  COUNT(employee_id)
    INTO v_count
    FROM employees
    WHERE manager_id = &eid;
    
    IF v_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('일반 사원입니다.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('팀장입니다.');
    END IF;
END;
/

-- IF~ ELSIF ~ ELSE 문 : 연차
DECLARE
    v_hdate NUMBER;
BEGIN
    SELECT TRUNC(MONTHS_BETWEEN(sysdate, hire_date)/12)
    INTO v_hdate
    FROM employees
    where employee_id = &사원번호;
    
    DBMS_OUTPUT.PUT_LINE(v_hdate || '년차 이긴 한데~~');
    
    IF v_hdate < 5 THEN -- 입사 ~5
        DBMS_OUTPUT.PUT_LINE('입사한지 5년 미만입니다.');
    ELSIF v_hdate < 10 THEN -- 입사 5~9
        DBMS_OUTPUT.PUT_LINE('입사한지 10년 미만입니다.');
    ELSIF v_hdate < 15 THEN -- 입사 10~14 
        DBMS_OUTPUT.PUT_LINE('입사한지 15년 미만입니다.');
    ELSIF v_hdate < 20 THEN -- 입사 15~19
        DBMS_OUTPUT.PUT_LINE('입사한지 20년 미만입니다.');
    ELSE -- 그 외~
        DBMS_OUTPUT.PUT_LINE('ㄷㄷ~~ 입사한지 ' || v_hdate || '년 입니다.');
    END IF;
END;
/

select count(employee_id) from employees where employee_id = 300;


/*
    3-1
    사원번호를 입력 ( 치환변수 사용 ) 할 경우
    입사일이 2005년 이후 (2005년 포함)이면 New employee 출력,
            2005년 이전이면 'Career employee' 출력
*/
--rr, yy 구분해서 사용해야함. 2자리 사용한다면 rr, 
DECLARE
    v_hdate DATE;
BEGIN
    SELECT hire_date
    INTO v_hdate
    FROM employees
    WHERE employee_id = &사원번호;
    
    DBMS_OUTPUT.PUT_LINE(v_hdate);
    
    IF v_hdate >= to_date('2005-01-01','yyyy-MM-dd') THEN
        DBMS_OUTPUT.PUT_LINE('New employee');
        
    ELSE DBMS_OUTPUT.PUT_LINE('Career employee');
    END IF;
END;
/

--만약 년도만 비교하려는 경우 (상반기, 하반기를 나눌때도 to_char)
SELECT TO_CHAR(hire_date,'yyyy')from employees;


/*
    3-2
    3-1에서,, 단 DMBS_OUTPUT.PUT_LINE()은 코드 상 한번만 작성
*/
DECLARE
    v_hdate DATE;
    v_check VARCHAR2(100) := 'Carrer employee';
BEGIN
    SELECT hire_date
    INTO v_hdate
    FROM employees
    WHERE employee_id = &사원번호;
    
    IF v_hdate >= to_date('2005-01-01','yyyy-MM-dd') THEN
        v_check := 'New employee';
    END IF;
    DBMS_OUTPUT.PUT_LINE(v_check);
END;
/

/* 
    4.
    급여가  5000이하면 20% 인상된 급여
    급여가 10000이하면 15% 인상된 급여
    급여가 15000이하면 10% 인상된 급여
    급여가 20000이상이면 급여 동결
    
    사원번호를 입력(치환변수)하면 사원이름, 급여, 인상된 급여가 출력되도록
    PL/SQL 블록을 생성하시오~~!~!~~!
*/

DECLARE
    v_empname varchar2(100);
    v_salary NUMBER;
    v_upsalary NUMBER := 0;
    
BEGIN

    SELECT last_name, salary 
    INTO v_empname, v_salary 
    FROM employees
    WHERE employee_id = &사원번호;
        
    IF v_salary <= 5000 THEN
        v_upsalary := 20;
    ELSIF v_salary <= 10000 THEN
        v_upsalary := 15;
    ELSIF v_salary <= 15000 THEN
        v_upsalary := 10;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('사원이름 : ' || v_empname);
    DBMS_OUTPUT.PUT_LINE('급여 : ' || v_salary);
    DBMS_OUTPUT.PUT_LINE('인상된 급여 : ' || (v_salary * ( 1 + v_upsalary/100)));
END;
/

-- 1에서 10까지 정수값을 더한 결과를 출력
-- 기본 loop
DECLARE
    v_num NUMBER(2,0) := 1;
    v_sum NUMBER(2,0) := 0;
BEGIN
    LOOP
        v_sum := v_sum+v_num;
        v_num := v_num + 1;

        exit when v_num > 10; -- v_num이 넘는 순간 루프 종료
    END LOOP;
        DBMS_OUTPUT.PUT_LINE(v_sum);

END;
/

--while loop 문
DECLARE
    v_num NUMBER(2,0) := 1;
    v_sum NUMBER(2,0) := 0;
BEGIN
    while v_num <= 10 LOOP
        v_sum := v_sum+v_num;
        v_num := v_num + 1;

    END LOOP;
        DBMS_OUTPUT.PUT_LINE(v_sum);

END;
/

--for loop * 임시변수가 DECLARE 절에 정의된 변수이름과 같으면 안된다!
--         * FOR LOOP는 기본적으로 오름차순정렬이다. 내림차순으로 하고 싶으면 in 옆에 REVERSE
declare
    v_sum NUMBER(2,0) := 0;
begin
--  FOR n in reverse 1..10  loop
    FOR num in  1..10  loop
        v_sum := num + v_sum;
        DBMS_OUTPUT.PUT_LINE(num);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('result : ' || v_sum);
end;
/
/*
    1.다음과 같이 출력되도록 하시오.
    *
    **
    ***
    ****
    *****
*/

DECLARE
    v_count NUMBER(1) := 1;
    v_star varchar2(100);
BEGIN
    LOOP
    v_count := v_count + 1;
    v_star := v_star || '*';
    
    DBMS_OUTPUT.PUT_LINE(v_star);

    exit when v_count > 5;
    END LOOP;
END;
/

DECLARE
    v_count number(2,0) := 1;
    v_star varchar2(10);
BEGIN
    WHILE v_count <= 5 Loop
    v_count := v_count + 1;
    v_star := v_star || '*';
    DBMS_OUTPUT.PUT_LINE(v_star);
    end loop;
    
END;
/

DECLARE
    v_sum VARCHAR2(10);
BEGIN
    for i in 1..5 loop
    v_sum := v_sum || '*';
    DBMS_OUTPUT.PUT_LINE(v_sum);
    end loop;
END;
/

-- 2중 loop?
DECLARE
    v_count NUMBER := 1;
BEGIN
    loop 
    
        loop DBMS_OUTPUT.PUT_line('*');
                v_count := v_count + 1;
                exit when v_count > 1;
        end loop;
    DBMS_OUTPUT.PUT('*');
    v_count := v_count + 1;
    exit when v_count > 3;
    END loop;
END;
/