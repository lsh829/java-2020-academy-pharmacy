CREATE OR REPLACE PROCEDURE insertSale(
    productNum sale.pnum%TYPE,
    pDate sale.sdate%TYPE,
    pQTY sale.sqty%TYPE,
    pRRN customer.rrn%TYPE,
    pCName customer.cname%TYPE
)
IS
    stock NUMBER;
    group_a NUMBER;--1~5���
    group_b NUMBER;--6~0���
    
    customer_in_year NUMBER; --���� ���ڸ�
    today NUMBER;
    
    start_day DATE; --5���� ������
    end_day DATE; --5���� ������
    soldCount NUMBER; --�ش� �Ⱓ ���� �� ����ũ�� ����
    
    customerNum NUMBER; --������ȣ (rrn���� ã��)
    customerCount NUMBER; --���� �����ͺ��̽����� ��ȸ
    saleData sale%rowtype;
BEGIN
    --2�� �ʰ��ϴ� ������ �ֹ��Ͽ����� Ȯ��
    IF pQTY > 2 THEN --2�� �̻� ���Ÿ� ��û�ߴ��� Ȯ���ϱ�
        raise_application_error(-20031,'�����Ͽ� �δ� 2�ű����� ���Ű� �����մϴ�. ');
    END IF;
    IF stock-pQTY < 0 THEN -- ����� �ִ��� Ȯ��
        raise_application_error(-20041,'����� �����Ͽ� �Ǹ��� �� �����ϴ�. ' || '(���� ���: ' || stock || '��, ���ż���: ' || pQTY || '��)');
    END IF;
    SELECT stock INTO stock FROM product
    WHERE pnum=productNum;
    --TODO: ����ũ5������ ���Ͽ� ������ �������� �´��� Ȯ��
    SELECT to_char(pDate, 'd')-1 INTO today FROM dual; --������ ���� ��¥�Լ��� (1:�Ͽ���~7:�����)��� �ᱣ���� (0:�Ͽ���, 1:������, 5:�ݿ���, 6:�����)
    group_a := today; --1~5��� ���ϱ�
    group_b := MOD(today+5,10); --6~0��� ���ϱ�
--    DBMS_OUTPUT.PUT_LINE(group_a || ' ' || group_b || ' ' || today);
    SELECT SUBSTR(pRRN,2,1) INTO customer_in_year FROM dual; -- ���Ű����� ���� ���ڸ� ���ϱ�
    IF today > 1 OR today >5 THEN --�����̸� 5���� �˻�
        IF customer_in_year != group_a AND customer_in_year != group_b THEN
                    raise_application_error(-20011,'���� ���Ŵ���� �ƴմϴ�.');
        END IF;
    END IF;
    --ȸ������ Ȯ��
    --ȸ���� �ƴϸ� ȸ������� �� �� cnum�� �������� ȸ���̸� cnum�� �����´�.
    SELECT count(cnum) INTO customerCount FROM customer WHERE rrn=pRRN;
    IF customerCount = 0 THEN --������ �̷��� ������ ���
        INSERT INTO customer(cnum, cname, rrn) VALUES (customer_seq.NEXTVAL, pCName,pRRN);
        COMMIT;
        SELECT cnum INTO customerNum FROM customer WHERE rrn=pRRN;
    ELSE --������ �̷��� �־��� ���
         SELECT cnum INTO customerNum FROM customer WHERE rrn=pRRN;
        --������ �̳��� �����Ͽ����� Ȯ��
        ---������ ����ũ 5������ 2020�� 3�� 9�� (������)���� ���ԵǾ���.
        SELECT NEXT_DAY(SYSDATE-8,1)+1 INTO start_day FROM dual;
        SELECT NEXT_DAY(SYSDATE-8,1)+7 INTO end_day FROM dual;
        SELECT nvl(sum(sQTY),0) INTO soldCount from (
        SELECT snum,sqty FROM sale WHERE cnum=customerNum AND 
                (SYSDATE >=start_day
                AND SYSDATE <=end_day
        ));
    --    raise_application_error(-20021,customerNum || ' �����... ' || soldCount || '�� ���̳� �����ϼ̽��ϴ�..');
        DBMS_OUTPUT.PUT_LINE(start_day || ' ' || end_day || ' ' || soldCount);
        IF soldCount+pQTY >= 2 THEN --�̹��ֿ� �̹� ������ ������ 2�� �̻��̸� �� �� ���� 
            raise_application_error(-20021,'�� �ִ� 2�ű����� ���Ű� �����մϴ�. ����� �������\(��?��*\))');
        END IF;
    END IF;  
    --���ǿ� �����ϸ� ���� �߰�
    INSERT INTO sale(snum, pnum, sdate, sqty, cnum)
    VALUES (sale_seq.NEXTVAL,productNum, pDate, pQTY, customerNum);
    COMMIT;
END;
/

--�˻�
SELECT * FROM sale JOIN customer ON sale.cnum = customer.cnum;