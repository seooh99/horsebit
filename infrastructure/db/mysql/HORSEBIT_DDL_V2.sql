CREATE TABLE USER_INFO (
 user_no INT NOT NULL AUTO_INCREMENT,
 user_name VARCHAR(30) NOT NULL,
 nickname VARCHAR(50),
 birthday DATE,
 email VARCHAR(50), -- Google email
 alarm_push_flag BOOLEAN DEFAULT FALSE,
 bank_name VARCHAR(30),
 bank_account VARCHAR(100),
 PRIMARY KEY(user_no)
) CHARSET=utf8MB4;

CREATE TABLE HORSE_INFO (
 hr_no INT NOT NULL UNIQUE,
 hr_name VARCHAR(100) NOT NULL,
 birth_place VARCHAR(30),
 sex VARCHAR(1) NOT NULL,
 hr_birth DATE,
 ow_no VARCHAR(6),
 hr_last_amt BIGINT,
 father_hr_no INT,
 mother_hr_no INT,
 race_rank VARCHAR(10),
 race_horse_flag BOOLEAN DEFAULT FALSE,
 PRIMARY KEY(hr_no),
 FOREIGN KEY(father_hr_no) REFERENCES HORSE_INFO(hr_no),
 FOREIGN KEY(mother_hr_no) REFERENCES HORSE_INFO(hr_no),
 CONSTRAINT CHECK (sex IN ('F', 'M', 'G')) -- F:암, M:수, G:중성
) CHARSET=utf8MB4;

CREATE TABLE TRAINER_INFO (
 tr_no INT NOT NULL,
 tr_name VARCHAR(100) NOT NULL,
 part INT,
 st_date DATE,
 sp_date DATE default '2999-12-31',
 PRIMARY KEY(tr_no)
) CHARSET=utf8MB4;

CREATE TABLE JOCKEY_INFO (
 jk_no INT NOT NULL,
 jk_name VARCHAR(100) NOT NULL,
 part INT,
 st_date DATE,
 sp_date DATE default '2999-12-31',
 PRIMARY KEY(jk_no)
) CHARSET=utf8MB4;

CREATE TABLE TOKEN_INFO (
 token_no INT NOT NULL AUTO_INCREMENT,
 name VARCHAR(50) NOT NULL,
 code VARCHAR(8) NOT NULL,
 supply INT NOT NULL,
 publish_date DATETIME NOT NULL,
 PRIMARY KEY(token_no),
 CONSTRAINT CHECK (supply > 0)
) CHARSET=utf8MB4;
 
CREATE TABLE MATURING_SCHEDULE (
 maturing_plan_no INT NOT NULL AUTO_INCREMENT,
 maturing_date DATE,
 day_flag VARCHAR(1),
 ranch_name VARCHAR(30),
 father_hr_no INT,
 mother_hr_no INT,
 PRIMARY KEY(maturing_plan_no),
 FOREIGN KEY(father_hr_no) REFERENCES HORSE_INFO(hr_no),
 FOREIGN KEY(mother_hr_no) REFERENCES HORSE_INFO(hr_no),
 CONSTRAINT CHECK (day_flag IN ('D', 'N')) -- D:오전, N:오후
) CHARSET=utf8MB4;

CREATE TABLE MATURING_RESULT (
 maturing_no INT NOT NULL AUTO_INCREMENT,
 maturing_plan_no INT NOT NULL,
 result_code VARCHAR(1),
 son_hr_no VARCHAR(6) DEFAULT '-',
 son_hr_name VARCHAR(100) DEFAULT '-',
 PRIMARY KEY(maturing_no),
 FOREIGN KEY(maturing_plan_no) REFERENCES MATURING_SCHEDULE(maturing_plan_no),
 CONSTRAINT CHECK (result_code IN ('B', 'P', 'F')) -- B:출생, P:임신중, F:실패
) CHARSET=utf8MB4;

CREATE TABLE RACING_SCHEDULE (
 rc_no INT NOT NULL AUTO_INCREMENT,
 rc_date DATE NOT NULL,
 meet VARCHAR(100) NOT NULL,
 rc_name VARCHAR(100),
 rc_dist INT,
 `rank` VARCHAR(10),
 rating VARCHAR(10),
 PRIMARY KEY(rc_no)
) CHARSET=utf8MB4;

CREATE TABLE SCHEDULE_RESULT (
 rc_content_no INT NOT NULL AUTO_INCREMENT,
 rc_no INT NOT NULL,
 jk_no INT NOT NULL,
 hr_no INT NOT NULL,
 hr_rc_time DOUBLE,
 hr_rc_ord INT,
 PRIMARY KEY(rc_content_no),
 FOREIGN KEY(rc_no) REFERENCES RACING_SCHEDULE(rc_no),
 FOREIGN KEY(jk_no) REFERENCES JOCKEY_INFO(jk_no),
 FOREIGN KEY(hr_no) REFERENCES HORSE_INFO(hr_no)
) CHARSET=utf8MB4;

CREATE TABLE ACCOUNT_HISTORY (
 acc_history_no INT NOT NULL AUTO_INCREMENT,
 user_no INT NOT NULL,
 amount BIGINT NOT NULL, -- +:입금, -:출금
 `timestamp` DATETIME NOT NULL,
 PRIMARY KEY(acc_history_no),
 FOREIGN KEY(user_no) REFERENCES USER_INFO(user_no)
) CHARSET=utf8MB4;

CREATE TABLE VOTE_INFO (
 vote_no INT NOT NULL AUTO_INCREMENT,
 token_no INT NOT NULL,
 vote_title VARCHAR(30) NOT NULL,
 vote_content TEXT NOT NULL,
 vote_st_date DATETIME NOT NULL,
 vote_sp_date DATETIME NOT NULL,
 response BOOLEAN,
 PRIMARY KEY(vote_no),
 FOREIGN KEY(token_no) REFERENCES TOKEN_INFO(token_no)
) CHARSET=utf8MB4;

CREATE TABLE VOTE_STATUS (
 vote_st_no INT NOT NULL AUTO_INCREMENT,
 vote_no INT NOT NULL,
 token_no INT NOT NULL,
 user_no INT NOT NULL,
 token_cnt INT NOT NULL,
 PRIMARY KEY(vote_st_no),
 FOREIGN KEY(vote_no) REFERENCES VOTE_INFO(vote_no),
 FOREIGN KEY(token_no) REFERENCES VOTE_INFO(token_no),
 FOREIGN KEY(user_no) REFERENCES USER_INFO(user_no)
) CHARSET=utf8MB4;

CREATE TABLE TOKEN_STATUS (
 share_no INT NOT NULL AUTO_INCREMENT,
 token_no INT NOT NULL,
 user_no INT NOT NULL,
 quantity DOUBLE NOT NULL,
 total_amount_of_purchase DOUBLE NOT NULL,
 PRIMARY KEY(share_no),
 FOREIGN KEY(token_no) REFERENCES TOKEN_INFO(token_no),
 FOREIGN KEY(user_no) REFERENCES USER_INFO(user_no),
 CONSTRAINT CHECK (quantity > 0)
) CHARSET=utf8MB4;

CREATE TABLE PUBLIC_OFFERING_INFO (
 offering_no INT NOT NULL AUTO_INCREMENT,
 token_no INT NOT NULL,
 offer_st_date DATETIME NOT NULL,
 offer_sp_date DATETIME NOT NULL,
 total_token_cnt INT NOT NULL,
 PRIMARY KEY(offering_no),
 FOREIGN KEY(token_no) REFERENCES TOKEN_INFO(token_no)
) CHARSET=utf8MB4;

CREATE TABLE SUBSCRIPTION_INFO (
 sub_no INT NOT NULL AUTO_INCREMENT,
 offering_no INT NOT NULL,
 token_no INT NOT NULL,
 user_no INT NOT NULL,
 sub_token_cnt INT NOT NULL,
 used_token_cnt INT NOT NULL,
 `timestamp` DATETIME NOT NULL,
 PRIMARY KEY(sub_no),
 FOREIGN KEY(offering_no) REFERENCES PUBLIC_OFFERING_INFO(offering_no),
 FOREIGN KEY(token_no) REFERENCES PUBLIC_OFFERING_INFO(token_no),
 FOREIGN KEY(user_no) REFERENCES USER_INFO(user_no)
) CHARSET=utf8MB4;

CREATE TABLE ORDER_HISTORY (
 order_no INT NOT NULL AUTO_INCREMENT,
 user_no INT NOT NULL,
 hr_no INT NOT NULL,
 token_no INT NOT NULL,
 price INT NOT NULL,
 quantity DOUBLE NOT NULL,
 order_time DATETIME NOT NULL,
 PRIMARY KEY(order_no),
 FOREIGN KEY(user_no) REFERENCES USER_INFO(user_no),
 FOREIGN KEY(hr_no) REFERENCES HORSE_INFO(hr_no),
 FOREIGN KEY(token_no) REFERENCES TOKEN_INFO(token_no)
) CHARSET=utf8MB4;

CREATE TABLE TRADE_HISTORY (
 execution_no INT NOT NULL AUTO_INCREMENT,
 token_no INT NOT NULL,
 price INT NOT NULL,
 quantity DOUBLE NOT NULL,
 `timestamp` DATETIME NOT NULL,
 seller_order_no INT NOT NULL,
 seller_user_no INT NOT NULL,
 buyer_order_no INT NOT NULL,
 buyer_user_no INT NOT NULL,
 PRIMARY KEY(execution_no),
 FOREIGN KEY(seller_order_no) REFERENCES ORDER_HISTORY(order_no),
 FOREIGN KEY(seller_user_no) REFERENCES ORDER_HISTORY(user_no),
 FOREIGN KEY(buyer_order_no) REFERENCES ORDER_HISTORY(order_no),
 FOREIGN KEY(buyer_user_no) REFERENCES ORDER_HISTORY(user_no)
) CHARSET=utf8MB4;

CREATE TABLE `LIKE` (
 user_no INT NOT NULL,
 token_no INT NOT NULL,
 FOREIGN KEY(user_no) REFERENCES USER_INFO(user_no),
 FOREIGN KEY(token_no) REFERENCES TOKEN_INFO(token_no)
) CHARSET=utf8MB4;

CREATE TABLE ALARM_LIST (
 user_no INT NOT NULL,
 token_no INT NOT NULL,
 FOREIGN KEY(user_no) REFERENCES USER_INFO(user_no),
 FOREIGN KEY(token_no) REFERENCES TOKEN_INFO(token_no)
) CHARSET=utf8MB4;

CREATE TABLE REL_HORSE_TOKEN (
 token_no INT NOT NULL,
 hr_no INT NULL,
 FOREIGN KEY(token_no) REFERENCES TOKEN_INFO(token_no),
 FOREIGN KEY(hr_no) REFERENCES HORSE_INFO(hr_no)
) CHARSET=utf8MB4;

CREATE TABLE REL_HORSE_TRAINER (
 hr_no INT NULL,
 tr_no INT NOT NULL,
 FOREIGN KEY(hr_no) REFERENCES HORSE_INFO(hr_no),
 FOREIGN KEY(tr_no) REFERENCES TRAINER_INFO(tr_no)
) CHARSET=utf8MB4;
