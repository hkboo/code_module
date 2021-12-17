-- create shard table
CREATE TABLE IF NOT EXISTS db_name.tbl_name_shard ON CLUSTER clickhouse_cluster (
    `user_id` String, 
    `user_name` String,
    `one` Int64, 
    `leq5` UInt32, 
    `gt6` Int32, 
    `cal_end_date` String,
    `ins_timestamp` DateTime('Asia/Seoul') DEFAULT now())
ENGINE = ReplacingMergeTree(ins_timestamp)
PARTITION BY toYYYYMM(cal_end_date)
ORDER BY (user_id, user_name, cal_end_date)

-- create distributed table
CREATE TABLE IF NOT EXISTS dist_tbl_name AS tbl_name_shard
Engine=Distributed(clickhouse_cluster, db_name, tbl_name_shard, rand());

-- optimize 
-- ReplacingMergeTree() 엔진을 쓸 경우 맨 마지막에 최적화 쿼리를 날려야 함 / 일반 MergeTree()는 필요없음!!
OPTIMIZE TABLE ddb_name.tbl_name_shard ON CLUSTER clickhouse_cluster FINAL

-- rename
RENAME TABLE old_tbl_name_shard to new_tbl_name_shard ON CLUSTER clickhouse_cluster
RENAME TABLE old_tbl_name to new_tbl_name

-- add column
ALTER TABLE tbl_name_shard ON CLUSTER clickhouse_cluster
    ADD COLUMN new_col_name col_type default default_Val


-- insert
INSERT INTO tbl_name_shard VALUES ('hkboo', '부', 1, 1, 1, '2021-12-21', now())
INSERT INTO tbl_name_shard (user_id, user_name, one, leg6, gt6, cal_end_date) VALUES ('boohk', '부', 1, 1, 1, '2021-12-21'
INSERT INTO tbl_name_shard (* EXCEPT(ins_timestamp)) VALUES ('boohk', '부', 1, 1, 1, '2021-12-21')

--delete 
ALTER TABLE tbl_name_shard ON CLUSTER clickhouse_cluster
    DELETE WHERE (mall_id,shop_no,product_no) in (select * from {filter_tbl_name})
        

-- truncate 
TRUNCATE TABLE IF EXISTS tbl_name_shard ON CLUSTER clickhouse_cluster
TRUNCATE TABLE IF EXISTS dist_tbl_name

-- drop table
DROP TABLE IF EXISTS tbl_name_shard ON CLUSTER clickhouse_cluster
DROP TABLE IF EXISTS dist_tbl_name

-- add comments
ALTER TABLE tbl_name_shard ON CLUSTER clickhouse_cluster COMMENT COLUMN user_id '사용자 아이디'
            
-- create select
CREATE TABLE db_name.temp_table_but_not_temporary
ENGINE = Log() 
AS SELECT
    l_tbl.user_id,
    l_tbl.user_name,
    l_tbl.one,
    l_tbl.leq5,
    r_tbl.address,
    r_tbl.phone
FROM 
    (
        SELECT 
            user_id,
            user_name,
            one,
            leq5
        FROM db_name.dist_tbl_name
        GROUP BY
            user_id,
            user_name,
            one,
            leq5
    ) l_tbl
LEFT JOIN 
    (SELECT
        user_id,
        user_name,
        address,
        phone
    FROM 
        (
            SELECT 
                user_id,
                user_name,
                address,
                phone,
                login_date
            FROM db_name.dist_tbl_name_ohter
            WHERE address like '%서울%'
            GROUP BY
                user_id,
                user_name,
                address,
                phone
            ORDER BY
                user_id,
                user_name,
                address,
                phone,
                login_date desc
            )
        LIMIT 1 BY user_id, user_name, address, phone, login_date
    ) AS r_tbl using(muser_id, user_name)
    ORDER BY user_id, user_name


-- select
-- 분산 테이블의 경우 global in 으로 써야함
SELECT 
    *
FROM
    db_name.dist_tbl_name
WHERE (user_id, user_name) global in (
        SELECT
            user_id, user_name
        FROM
            db_name.dist_tbl_name
        WHERE
            one == 1
    )