set serveroutput on;
show serveroutput;

-- 키워드
/*
커서 for 루프 : 커서(open, fetch, close)를 일괄적으로 묶어서 한번에 빢!

매개변수 사용 커서

for update 절

EXCEPTION              
1. 미리 정의된 예외 트랩
DECLARE   : X
BEGIN     : X
EXCEPTION : WHEN 이름 THEN

2. 미리 정의하지 않은 예외 트랩
DECLARE   : e_name EXCEPTION;
            PRAGMA EXCEPTION_INIT(e_name, code)
BEGIN     : X
EXCEPTION : WHEN e_name THEN

3. 사용자 정의 예외 트랩
DECLARE   : e_name EXCEPTION;
BEGIN     : IF ~~ THEN
                RAISE e_name; (예외 사항 명시적 발생시킴)
            END IF;
EXCEPTION : WHEN e_name THEN

프로시저
*/

-- 커서 for 루프 예제
DECLARE
    CURSOR emp_cursor IS
        SELECT employee_id, last_name, job_id
        FROM employees
        WHERE department_id = &사원번호;
BEGIN
    FOR emp_rec IN emp_cursor LOOP
        DBMS_OUTPUT.put(emp_cursor%ROWCOUNT);
        DBMS_OUTPUT.PUT(', ' || emp_rec.employee_id);
        DBMS_OUTPUT.PUT(', ' || emp_rec.last_name);
        DBMS_OUTPUT.PUT_LINE(', '|| emp_rec.job_id);
    END LOOP;
    -- DBMS_OUTPUT.PUT_LINE(emp_cursor%ROWCOUNT) 이미 일괄적으로 close도 실행되어 안됨. 즉, 커서에 데이터가 없으면 의미가 없당;;
END;
/

-- 서브쿼리 커서 FOR 루프
BEGIN
    FOR emp_rec IN (SELECT employee_id, last_name, job_id
                    FROM employees
                    WHERE department_id = &부서번호) LOOP
        --  DBMS_OUTPUT.put(emp_cursor%ROWCOUNT); 서브쿼리로 커서를 사용하면 커서속성 사용 불가
            DBMS_OUTPUT.PUT(emp_rec.employee_id);
            DBMS_OUTPUT.PUT(', ' || emp_rec.last_name);
            DBMS_OUTPUT.PUT_LINE(', '|| emp_rec.job_id);
    END LOOP;
END;
/

-- 커서 for 루프로 간단하게 작업
/*  
    1) 모든 사원의 부서번호, 이름, 부서이름 출력
    2) 부서번호가 50이거나 80인 사원들의 사원이름. 급여, 연봉 출력
    -- 연봉은 ( 급여 * 12 + (NVL(급여,0) + NVL(커미션,0) * 12) )
*/

--1)
DECLARE
    CURSOR emp_cursor IS
        SELECT employee_id, last_name, department_name
        FROM employees JOIN departments
        on (employees.department_id = departments.department_id);
    
BEGIN
    FOR emp_rec IN emp_cursor LOOP
    
        DBMS_OUTPUT.PUT(emp_rec.employee_id || ' ,');
        DBMS_OUTPUT.PUT(emp_rec.last_name|| ' ,');
        DBMS_OUTPUT.PUT_LINE(emp_rec.department_name);
        
    END LOOP;

END;
/

--2)
BEGIN
    FOR emp IN (SELECT last_name, 
                        salary, 
                        ( salary * 12 + (NVL(salary,0) + NVL(commission_pct,0) * 12) ) as annual 
                FROM employees
                where department_id in (50,80))LOOP
        DBMS_OUTPUT.PUT(emp.last_name || ' ,');
        DBMS_OUTPUT.PUT(emp.salary || ' ,');
        DBMS_OUTPUT.PUT_LINE(emp.annual);
    END LOOP;
END;
/


-- 매개변수 사용 커서
DECLARE
    CURSOR emp_cursor
        (p_deptno NUMBER) IS
        SELECT last_name, hire_date
        FROM employees
        WHERE department_id = p_deptno;

    emp_info emp_cursor%ROWTYPE;
BEGIN
    OPEN emp_cursor(60);
   
    FETCH emp_cursor INTO emp_info;
        DBMS_OUTPUT.PUT_LINE(emp_info.last_name);
    OPEN emp_cursor(50);
    CLOSE emp_cursor;
END;
/

-- 현재 존재하는 모든 부서에 각 소속 사원을 출력하고 없는 경우 '현재 소속원이 없습니다.' 라고 출력
/* format
=== 부서명 : 부서 풀네임
1. 사원번호, 사원이름, 입사일, 업무
2. 사원번호, 사원이름, 입사일, 업무

*/

-- 부서를 출력하는 커서, 그리고 부서이름을 입력받아 사원번호, 사원이름, 입사일, 업무를 출력하는 커서
DECLARE
    CURSOR emp_cursor
        (p_department_id VARCHAR2) IS
         SELECT employee_id, last_name, hire_date, job_id
         FROM employees
         WHERE department_id = p_department_id;
    
    CURSOR dept_cursor IS
        select department_id, department_name from departments;

    emp_rec emp_cursor%ROWTYPE;
    dept_rec dept_cursor%ROWTYPE;
BEGIN
    OPEN dept_cursor;
        loop
            FETCH  dept_cursor INTO dept_rec;
            EXIT WHEN dept_cursor%NOTFOUND;
                DBMS_OUTPUT.PUT_LINE('===부서명 : '|| dept_rec.department_name);
                OPEN emp_cursor(dept_rec.department_id);
                    LOOP 
                        FETCH emp_cursor INTO emp_rec;
                        EXIT WHEN emp_cursor%NOTFOUND;
                            DBMS_OUTPUT.PUT(rpad(emp_cursor%ROWCOUNT,2,' ') || '.');                
                            DBMS_OUTPUT.PUT('사원 이름 : ' || RPAD(emp_rec.last_name,15,' '));
                            DBMS_OUTPUT.PUT('사원 번호 : ' || RPAD(emp_rec.employee_id,4,' '));
                            DBMS_OUTPUT.PUT('사원 이름 : ' || RPAD(emp_rec.last_name,10,' '));
                            DBMS_OUTPUT.PUT('  입사일 : ' || emp_rec.hire_date);
                            DBMS_OUTPUT.PUT_LINE('  업무 : ' || emp_rec.job_id);
                    END LOOP;
                        if emp_cursor%ROWCOUNT = 0 THEN
                            DBMS_OUTPUT.PUT_LINE('현재 소속원이 없습니다.');
                        END IF;
                CLOSE emp_cursor;
        end loop;
    CLOSE dept_cursor;    
END;
/

-- FOR UPDATE, WHERE CURRENT OF
DECLARE
    CURSOR sal_info_cursor IS
        SELECT salary, commission_pct -- PK 없이도 가능
        FROM employees
        WHERE department_id = 60
        FOR UPDATE OF salary, commission_pct NOWAIT;
BEGIN
    FOR sal_info IN sal_info_cursor LOOP
        IF sal_info.commission_pct IS NULL THEN
            UPDATE employees
            SET salary = sal_info.salary * 1.1
            WHERE CURRENT OF sal_info_cursor;
        ELSE
            UPDATE employees
            SET salary = sal_info.salary + sal_info.salary * sal_info.commission_pct
            WHERE CURRENT OF sal_info_cursor;
        END IF;
    END LOOP;
END;
/

-- 1) 미리 정의된 예외
DECLARE
    v_ename employees.last_name%TYPE;
BEGIN
    SELECT last_name
    INTO v_ename
    FROM employees
    WHERE department_id = &부서번호;
    
    DBMS_OUTPUT.PUT_LINE(v_ename);
EXCEPTION
    WHEN NO_DATA_FOUND then
        DBMS_OUTPUT.PUT_LINE('값 없음');
    WHEN TOO_MANY_ROWS then
        DBMS_OUTPUT.PUT_LINE('행 초과');
END;
/

-- 2) 미리 정의 되어있지 않은 예외
DECLARE
    e_fk EXCEPTION;
    PRAGMA EXCEPTION_INIT (e_fK, -02292);
BEGIN
    DELETE FROM departments
    WHERE department_id = &부서번호; 
    
EXCEPTION
    WHEN e_fk THEN
        DBMS_OUTPUT.PUT_LINE('해당 부서에 속한 사원이 존재한대요');
END;
/

-- 3) 사용자 정의 예외 ex) 예금 잔액이 - 인 경우,, (데이터 타입 자체는 -는 상관없으니까 오라클은 몰라도 됨)
DECLARE
    e_no_deptno EXCEPTION;
    v_error_code NUMBER;
    v_error_msg VARCHAR2(255);
BEGIN
    DELETE FROM departments
    WHERE department_id = &부서번호;
    
    IF SQL%ROWCOUNT = 0 THEN -- 암시적 커서 ROWCOUNT로 확인
        RAISE e_no_deptno; -- 발생시키려면 RAISE
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('부서 번호가 삭제 되었습니다!');
EXCEPTION
    WHEN e_no_deptno THEN
        DBMS_OUTPUT.PUT_LINE('해당 부서번호는 존재하지 않습니다.');
    WHEN OTHERS THEN
        v_error_code := SQLCODE;
        v_error_msg := SQLERRM;
        DBMS_OUTPUT.PUT_LINE(v_error_code);
        DBMS_OUTPUT.PUT_LINE(v_error_msg);
END;
/

-- 제약 조건을 끊고 테스트를 하기 위함
CREATE TABLE test_employee
AS
    SELECT *
    FROM employees;


-- test_employee 테이블의 특정 사원을 삭제하려고 한다.
-- 치환변수를 받아 입력 받고, 해당 사원이 없는 경우 '해당 사원이 존재하지 않습니다.'를 출력하라. 
-- 생각해보니까 이건 사용자 지정 에러 였음;;

DECLARE
    v_eid employees.employee_id%type := &사원번호;
    e_no_error EXCEPTION;
BEGIN
    delete FROM test_employee
    WHERE employee_id = v_eid;
    
    IF SQL%ROWCOUNT = 0 THEN
        RAISE e_no_error;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE(v_eid || '가 삭제되었습니다.');
    
EXCEPTION
    WHEN e_no_error THEN
        DBMS_OUTPUT.PUT(v_eid || ', ');
        DBMS_OUTPUT.PUT_LINE('해당 사원이 존재하지 않습니다.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('기타 에러 입니다.');
END;
/

--procedure의 구조 
CREATE or replace PROCEDURE test_pro
-- () cursor의 매개변수가 들어가는 자리와 비슷함.
IS
-- DECLARE : 선언부 숨어있음 그래도 있음
-- 지역변수 , 레코드, 커서, EXCEPTION 
BEGIN
    DBMS_OUTPUT.PUT_LINE('First Procedure');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ㅋㅋ;;');
END;
/

-- 1) 블록 내부에서 호출하는 방식 (여러개의 프로시저를 실행 시킬 수 있음.)
BEGIN
    test_pro;   
END;
/

-- 2) EXECUTE 명령어 사용
EXECUTE test_pro;


-- in mode - default임!
CREATE or replace PROCEDURE raise_salary
(p_eid IN NUMBER)
IS
 
BEGIN
   -- p_eid := 100;  이거 in모드에서 가져온 값이라 readonly
    DBMS_OUTPUT.PUT_LINE(p_eid);
    UPDATE employees
    SET salary = salary * 1.1
    WHERE employee_id = p_eid;
END;
/

DECLARE
    v_id employees.employee_id%type := &사원번호;
    v_num CONSTANT NUMBER := v_id;
BEGIN
    RAISE_SALARY(v_id);
    RAISE_SALARY(v_num);
    RAISE_SALARY(v_num + 100);
    RAISE_SALARY(200);
        
END;
/

EXECUTE RAISE_SALARY(100);

-- out 모드 == in 기반으로 넘어온 데이터를 내부 연산 끝에 돌려준다?
-- 결과 값을 받는 용도라고 생각하자.
CREATE or replace PROCEDURE pro_plus
(p_x NUMBER,
 p_y NUMBER,
 p_result OUT NUMBER)
is
    v_sum number;
BEGIN
    DBMS_OUTPUT.PUT(p_x);
    DBMS_OUTPUT.PUT(' + ' || p_y);
    DBMS_OUTPUT.PUT_LINE(' = ' || p_result);
    
    -- v_sum := p_x + p_y + p_result;  10+ 12+ null == null이 되어버림; 즉, out모드로 진행되는 경우에는 연산식에서 사용하면 안되는거임;.. 그냥 값을 받는 용도로만 쓰자 (왼쪽에서 값을 할당받는 역할)
    p_result := p_x + p_y;
    v_sum := p_result + 100; 
    DBMS_OUTPUT.PUT_LINE('v_sum : ' ||v_sum || ' p_result도 더한 값' );
END;
/

DECLARE
    v_first NUMBER := 10;
    v_second NUMBER := 12;
    v_result NUMBER := 100;
BEGIN
    DBMS_OUTPUT.PUT_LINE('before ' || v_result);
    pro_plus(v_first,v_second,v_result);
    DBMS_OUTPUT.PUT_LINE('after ' || v_result);
    
END;
/

-- in out 모드
-- 주로 포맷 변경으로 많이 쓴다. ex ) 01012341234 => 010-1234-1234

CREATE or replace PROCEDURE format_phone
(p_phone_no IN OUT VARCHAR2) -- 넘버로 받아버리면 0이 생략이 되어버리니까 varchar2로 받차~!
IS

BEGIN
    p_phone_no := SUBSTR(p_phone_no , 1, 3)
                || '-' || SUBSTR(p_phone_no , 4, 4)
                || '-' || SUBSTR(p_phone_no, 8);
END;
/

DECLARE
    v_no VARCHAR2(50) := '01012341234';
BEGIN
    DBMS_OUTPUT.PUT_LINE('before : ' || v_no);
    format_phone(v_no);
    DBMS_OUTPUT.PUT_LINE('after  : ' || v_no);
END;
/

/*
주민등록번호를 입력하면
다음과 같이 출력되도록 yedam_ju 프로시저를 작성하시오.

EXECUTE yedam_ju(9501011667777);

    -> 950101-1******
    
추가) 해당 주민번호를 기준으로 실제 생년 월일을 출력하는 부분도 추가하라!
 해당 주민등록번호를 기준으로 실제 생년월일을 출력하는 부분도 추가
 9501011667777 => 1995년 01월 01일
 1511013679977 => 2015년 11월 01일
*/


CREATE or replace PROCEDURE yedam_ju
(v_num IN VARCHAR2)
IS
    v_sum VARCHAR2(100);
    v_gender char(1);
    v_birth VARCHAR2(100);
BEGIN
    v_sum := SUBSTR(v_num, 1,6) || '-' || SUBSTR(v_num , 7, 1) || '******';
    DBMS_OUTPUT.PUT_LINE(v_sum);
    
    v_gender := SUBSTR(v_num ,7,1);
    
    if v_gender in ('1','2','5','6') THEN
        
        v_birth := '19'|| SUBSTR(v_num,1,2) || '년 ' 
                        || SUBSTR(v_num,3,2) || '월 '
                        || SUBSTR(v_num,5,2) || '일 ';
    elsif v_gender in ('3','4','7','8') THEN
        v_birth := '20'|| SUBSTR(v_num,1,2) || '년 ' 
                        || SUBSTR(v_num,3,2) || '월 '
                        || SUBSTR(v_num,5,2) || '일 ';
    else 
        v_birth := '외계인 입니다.';
    END IF;
        DBMS_OUTPUT.PUT_LINE(v_birth);
        

END;
/

execute yedam_ju('9501011667777');
execute yedam_ju('1511013689977');



/*
1.
주민등록번호를 입력하면 
다음과 같이 출력되도록 yedam_ju 프로시저를 작성하시오.

EXECUTE yedam_ju(9501011667777)
EXECUTE yedam_ju(1511013689977)

  -> 950101-1******
추가)
 해당 주민등록번호를 기준으로 실제 생년월일을 출력하는 부분도 추가
 9501011667777 => 1995년01월01일
 1511013689977 => 2015년11월01일
*/

/*
2.
사원번호를 입력할 경우
삭제하는 TEST_PRO 프로시저를 생성하시오.
단, 해당사원이 없는 경우 "해당사원이 없습니다." 출력
예) EXECUTE TEST_PRO(176)
*/
CREATE or replace PROCEDURE test_pro
(v_id NUMBER)
IS
    e_error EXCEPTION;
BEGIN
    DELETE FROM test_employee
    WHERE employee_id = v_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE e_error;
    END IF;

    DBMS_OUTPUT.PUT_LINE('회원 삭제 완료');
    
EXCEPTION
    WHEN e_error THEN
        DBMS_OUTPUT.PUT_LINE('해당 사원이 없습니다.');

END;
/
EXECUTE TEST_PRO(176);

/*
3.
다음과 같이 PL/SQL 블록을 실행할 경우 
사원번호를 입력할 경우 사원의 이름(last_name)의 첫번째 글자를 제외하고는
'*'가 출력되도록 yedam_emp 프로시저를 생성하시오.

실행) EXECUTE yedam_emp(176)
실행결과) TAYLOR -> T*****  <- 이름 크기만큼 별표(*) 출력
*/

CREATE or replace PROCEDURE yedam_emp
(v_id NUMBER)
IS
    CURSOR emp_cur IS
        SELECT last_name
        FROM test_employee
        where employee_id = v_id;

    v_name test_employee.last_name%TYPE;
    
BEGIN
    OPEN emp_cur;
    
    FETCH emp_cur INTO v_name;
    
    CLOSE emp_cur;
    
    
    DBMS_OUTPUT.PUT_LINE(v_name);
    
    v_name := replace();
    
    
END;
/

EXECUTE yedam_emp(177);


/*
4.
직원들의 사번, 급여 증가치만 입력하면 Employees테이블에 쉽게 사원의 급여를 갱신할 수 있는 y_update 프로시저를 작성하세요. 
만약 입력한 사원이 없는 경우에는 ‘No search employee!!’라는 메시지를 출력하세요.(예외처리)
실행) EXECUTE y_update(200, 10)
*/
/*
5.
다음과 같이 테이블을 생성하시오.
create table yedam01
(y_id number(10),
 y_name varchar2(20));

create table yedam02
(y_id number(10),
 y_name varchar2(20));
5-1.
부서번호를 입력하면 사원들 중에서 입사년도가 2005년 이전 입사한 사원은 yedam01 테이블에 입력하고,
입사년도가 2005년(포함) 이후 입사한 사원은 yedam02 테이블에 입력하는 y_proc 프로시저를 생성하시오.
 
5-2.
1. 단, 부서번호가 없을 경우 "해당부서가 없습니다" 예외처리
2. 단, 해당하는 부서에 사원이 없을 경우 "해당부서에 사원이 없습니다" 예외처리
*/

