--create1
CREATE TABLE IF NOT EXISTS db_name.history_tbl_name (
    id BIGINT NOT NULL auto_increment,
    user_id varchar(100) NOT NULL,
    user_name varchar(100) NOT NULL,
    l_value DECIMAL(20,0) NOT NULL,
    r_value DECIMAL(12,0) NOT NULL,
    flag INT NOT NULL,
    cal_end_date DATE NOT NULL,
    ins_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
)
ENGINE=MyISAM
DEFAULT CHARSET=utf8
COLLATE=utf8_general_ci 
AUTO_INCREMENT=1

--create2
CREATE TABLE IF NOT EXISTS db_name.new_tbl_name (
    id BIGINT NOT NULL auto_increment,
    user_id varchar(100) NOT NULL,
    user_name varchar(100) NOT NULL,
    l_value DECIMAL(20,0) NOT NULL,
    r_value DECIMAL(12,0) NOT NULL,
    flag INT NOT NULL,
    cal_end_date DATE NOT NULL,
    ins_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
)
ENGINE=MyISAM
DEFAULT CHARSET=utf8
COLLATE=utf8_general_ci 
AUTO_INCREMENT=1

--drop1
DROP TABLE IF EXISTS db_name.history_tbl_name

--drop2
DROP TABLE IF EXISTS db_name.new_tbl_name

--truncate
truncate db_name.new_tbl_name

-- insert select 
insert ignore into db_name.new_tbl_name
select id, user_id, user_name, l_value, r_value, flag, cal_end_date, max(ins_timestamp) as ins_timestamp
from db_name.history_tbl_name
where cal_end_date = subdate(curdate(), 1)
group by user_id, user_name, cal_end_date


