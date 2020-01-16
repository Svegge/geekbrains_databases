DROP DATABASE p2;
CREATE DATABASE p2;
USE p2;

--                                      Таблица титулов
CREATE TABLE titles (
						id SERIAL        PRIMARY  KEY,
			     title_num CHAR(12)      NOT NULL UNIQUE,
		    title_name_eng VARCHAR(150)  NOT NULL,
			title_name_rus VARCHAR(300)  NOT NULL,
			  title_object CHAR(12)      NOT NULL,
	 title_object_name_eng VARCHAR(150)  NOT NULL,
     title_object_name_rus VARCHAR(300)  NOT NULL,
          start_up_complex CHAR(12)      NOT NULL,
 start_up_complex_name_eng VARCHAR(150)  NOT NULL,
 start_up_complex_name_rus VARCHAR(300)  NOT NULL,
         operating_complex CHAR(12)      NOT NULL,
operating_complex_name_eng VARCHAR(150)  NOT NULL,
operating_complex_name_rus VARCHAR(300)  NOT NULL,
                      unit ENUM('1-30', '2-30', '1-110', '2-110', '1-60', '1-70',
						  		'3-30', '3-110', '2-60', '2-70', '4-30', '4-110',
                                '5-30', '5-110', '3-60', '3-70', '6-30', '6-110' )
										 NOT NULL,
					 phase ENUM('1', '2', '3', '4', '5')
                                         NOT NULL
					)
COMMENT = 'Таблица полного сведения данных из титульного списка + номера установок и фаз';


--                                      Таблица пользователей
CREATE TABLE users (
				        id SERIAL         PRIMARY   KEY,
				 user_name VARCHAR(255)   NOT NULL,
			         email VARCHAR(255)   NOT NULL  UNIQUE,
				 is_active TINYINT        DEFAULT   '1' NOT NULL,
			    created_at DATETIME       DEFAULT   CURRENT_TIMESTAMP,
                updated_at DATETIME       DEFAULT   CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
                           );
       

--                                      Таблица чертежей
CREATE TABLE drawings (
				        id SERIAL        PRIMARY KEY,
				   user_id BIGINT        UNSIGNED NOT NULL,
                      draw VARCHAR(50)   NOT NULL UNIQUE,
				   package VARCHAR(50)   NOT NULL,
			   transmittal VARCHAR(50)   NOT NULL DEFAULT 'TBD',
			reference_link VARCHAR(255)  NOT NULL DEFAULT 'TBD',
			      title_id BIGINT        UNSIGNED NOT NULL ,
                   comment TEXT,
			  issue_reason ENUM ( 'AFC', 'IFC', 'IFR',
								  'VOID', 'SUPERSEEDED', 
                                  'FOR INFORMATION')
										 NOT NULL,
				  revision VARCHAR(5)    NOT NULL,
                    status ENUM ( 'APPROVED', 'UNCHECKED') DEFAULT 'UNCHECKED',
                  
									     CONSTRAINT drawings_title_id_fk 
									     FOREIGN KEY (title_id)
									     REFERENCES titles(id)
									     ON DELETE RESTRICT
									     ON UPDATE CASCADE,
                                         
									     CONSTRAINT drawings_user_id_fk 
									     FOREIGN KEY (user_id)
									     REFERENCES users(id)
									     ON DELETE RESTRICT
									     ON UPDATE CASCADE
					);

--                                      Таблица кодов работ
CREATE TABLE work_codes (
						id SERIAL        NOT NULL PRIMARY KEY,
				 work_code VARCHAR(25)   NOT NULL UNIQUE COMMENT 'идентификатор единицы работ',
		     work_name_eng VARCHAR(500)  NOT NULL,
			 work_name_rus VARCHAR(1000) NOT NULL,
				 work_cost DECIMAL(12,2) NOT NULL,
			       uom_eng ENUM('m', 'm2', 'm3', 'pc', 'kg', 'di')
										 NOT NULL,
                   uom_rus ENUM('м', 'м2', 'м3', 'шт', 'кг', 'дд')
										 NOT NULL,
                    source ENUM('contract', 'rfc', 'new')
                          )
COMMENT = 'Уникальный перечень кодов работ с наименованиями и ценами';


--                                      Таблица BoQ
CREATE TABLE boq_contract (
				        id SERIAL PRIMARY  KEY,
			  work_code_id BIGINT UNSIGNED NOT NULL,
                      unit ENUM('1-30', '2-30', '1-110', '2-110', '1-60', '1-70',
						  		'3-30', '3-110', '2-60', '2-70', '4-30', '4-110',
                                '5-30', '5-110', '3-60', '3-70', '6-30', '6-110' )
										   NOT NULL,
					 phase ENUM('1', '2', '3', '4', '5')
										   NOT NULL,
				  quantity DECIMAL(12,6)   NOT NULL,
					
										   CONSTRAINT boq_contract_work_code_id_fk 
										   FOREIGN KEY (work_code_id)
										   REFERENCES work_codes(id)
										   ON DELETE RESTRICT
										   ON UPDATE CASCADE
                           )
COMMENT = 'Таблица контрактных объемов в разрезе технологических установок';


--                                      Таблица элементов
CREATE TABLE elements (
				        id SERIAL        PRIMARY   KEY,
				   draw_id BIGINT        UNSIGNED  NOT NULL,
			       element VARCHAR(500),
			  work_code_id BIGINT        UNSIGNED  NOT NULL,
			    element_pc DECIMAL(12,6)           NOT NULL,
		  element_quantity DECIMAL(12,6)           NOT NULL,
            total_quantity DECIMAL(12,6) AS (element_pc * element_quantity) STORED,
                created_at DATETIME      DEFAULT   CURRENT_TIMESTAMP,
                updated_at DATETIME      DEFAULT   CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                created_by BIGINT        UNSIGNED  NOT NULL,
                updated_by BIGINT        UNSIGNED  NOT NULL,
                   comment TEXT,
                 
										 CONSTRAINT elements_draw_id_fk 
										 FOREIGN KEY(draw_id)
										 REFERENCES drawings(id)
										 ON DELETE RESTRICT
										 ON UPDATE CASCADE,
										   
										 CONSTRAINT elements_work_code_id_fk 
										 FOREIGN KEY(work_code_id)
										 REFERENCES work_codes(id)
										 ON DELETE RESTRICT
										 ON UPDATE CASCADE                           
                           );


--                                      Таблица фактических объемов для приемки выполненных работ
CREATE TABLE acceptance_quantities (
				        id SERIAL        PRIMARY   KEY,
				   draw_id BIGINT        UNSIGNED  NOT NULL,
				element_id BIGINT        UNSIGNED  NOT NULL,
			  work_code_id BIGINT        UNSIGNED  NOT NULL,
			    element_pc DECIMAL(12,6)           NOT NULL,
		  element_quantity DECIMAL(12,6)           NOT NULL,
            total_quantity DECIMAL(12,6) AS (element_pc * element_quantity) STORED,
                    period VARCHAR(50)   NOT NULL  COMMENT 'месяц и год отчетного периода из первичногшо акта',
                    ia_num VARCHAR(50)   NOT NULL  COMMENT 'номер первичного акта',
                created_at DATETIME      DEFAULT   CURRENT_TIMESTAMP,
                updated_at DATETIME      DEFAULT   CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                created_by BIGINT        UNSIGNED  NOT NULL,
                updated_by BIGINT        UNSIGNED  NOT NULL,
                   comment TEXT,
                 
										 CONSTRAINT acceptance_quantities_draw_id_fk 
										 FOREIGN KEY(draw_id)
										 REFERENCES drawings(id)
										 ON DELETE RESTRICT
										 ON UPDATE CASCADE,
 
 										 CONSTRAINT acceptance_quantities_element_id_fk 
										 FOREIGN KEY(element_id)
										 REFERENCES elements(id)
										 ON DELETE RESTRICT
										 ON UPDATE CASCADE,
										   
										 CONSTRAINT acceptance_quantities_work_code_id_fk 
										 FOREIGN KEY(work_code_id)
										 REFERENCES work_codes(id)
										 ON DELETE RESTRICT
										 ON UPDATE CASCADE                           
                           );

       
--                                      Таблица запросов на изменение      
CREATE TABLE rfc (
				        id SERIAL          PRIMARY  KEY,
				   user_id BIGINT          UNSIGNED NOT NULL,
			  work_code_id BIGINT          UNSIGNED NOT NULL,
	               rfc_num VARCHAR(50)     NOT NULL COMMENT 'Номер ЗНИ',
                   rev_num VARCHAR(5)      NOT NULL COMMENT 'Номер ревизии',
				qty_change DECIMAL(12, 6)  NOT NULL,
				  rfc_type ENUM('Новая ЕР', 'Увеличение объема',
                                'Расключение', 'Уменьшение объема') 
										   NOT NULL,
        
                      unit ENUM('1-30', '2-30', '1-110', '2-110', '1-60', '1-70',
						  		'3-30', '3-110', '2-60', '2-70', '4-30', '4-110',
                                '5-30', '5-110', '3-60', '3-70', '6-30', '6-110')
										   NOT NULL,
					 phase ENUM('1', '2', '3', '4', '5')
										   NOT NULL,
			   is_contract TINYINT         NOT NULL DEFAULT 0,
					
										   CONSTRAINT rfc_contract_work_code_id_fk 
										   FOREIGN KEY (work_code_id)
										   REFERENCES work_codes(id)
										   ON DELETE RESTRICT
										   ON UPDATE CASCADE,
										   
                                           CONSTRAINT rfc_contract_user_id_fk 
										   FOREIGN KEY (user_id)
										   REFERENCES users(id)
										   ON DELETE RESTRICT
										   ON UPDATE CASCADE
                           )
COMMENT = 'Таблица запросов на изменение контрактных объемов
			rfc = request for change';
            
drop table elements_log;
drop table drawings_log;
drop table rfc_log;

            
--                                      Журнал создания элементов            
CREATE TABLE elements_log (
					    id BIGINT         UNSIGNED AUTO_INCREMENT PRIMARY KEY,
				   user_id BIGINT         UNSIGNED NOT NULL,
				element_id BIGINT         UNSIGNED NOT NULL,
			    changed_at DATETIME       DEFAULT   CURRENT_TIMESTAMP,
			 activity_type ENUM('insert', 'update')
                           )
                           ENGINE = ARCHIVE;
                           
                           
--                                      Журнал создания чертежей            
CREATE TABLE drawings_log (
					    id BIGINT         UNSIGNED AUTO_INCREMENT PRIMARY KEY,
				   user_id BIGINT         UNSIGNED NOT NULL,
				   draw_id BIGINT         UNSIGNED NOT NULL,
			    changed_at DATETIME       DEFAULT   CURRENT_TIMESTAMP,
			 activity_type ENUM('insert', 'update')
                           )
                           ENGINE = ARCHIVE;
                           
                           
                           
--                                      Журнал создания ЗНИ            
CREATE TABLE rfc_log (
					    id BIGINT         UNSIGNED AUTO_INCREMENT PRIMARY KEY,
				   user_id BIGINT         UNSIGNED NOT NULL,
				    rfc_id BIGINT         UNSIGNED NOT NULL,
			    changed_at DATETIME       DEFAULT   CURRENT_TIMESTAMP,
		     activity_type ENUM('insert', 'update')
                           )
                           ENGINE = ARCHIVE;