-- Триггеры
DELIMITER //

-- Журнал обновления чертежей
CREATE TRIGGER drawings_data_insert_log AFTER INSERT ON drawings
   FOR EACH ROW
 BEGIN
	   INSERT INTO drawings_log VALUES(NULL, NEW.user_id, NEW.id, NOW(), 'insert');
 END//
 
 CREATE TRIGGER drawings_data_update_log AFTER UPDATE ON drawings
   FOR EACH ROW
 BEGIN
	   INSERT INTO drawings_log VALUES(NULL, NEW.user_id, NEW.id, NOW(), 'update');
 END//
 
-- Журнал обновления элементов
-- INSERT
CREATE TRIGGER elements_data_insert_log AFTER INSERT ON elements
   FOR EACH ROW
 BEGIN
	   INSERT INTO drawings_log VALUES(NULL, NEW.created_by, NEW.id, NOW(), 'insert');
 END//
 
 -- UPDATE
 CREATE TRIGGER elements_data_update_log AFTER UPDATE ON elements
   FOR EACH ROW
 BEGIN
	   INSERT INTO drawings_log VALUES(NULL, NEW.updated_by, NEW.id, NOW(), 'update');
 END//
 
 -- Журнал обновления реестра ЗНИ
 -- INSERT
 CREATE TRIGGER rfc_data_insert_log AFTER INSERT ON rfc
   FOR EACH ROW
 BEGIN
	   INSERT INTO rfc_log VALUES(NULL, NEW.user_id, NEW.id, NOW(), 'insert');
 END//
 
 -- UPDATE
 CREATE TRIGGER rfc_data_update_log AFTER UPDATE ON rfc
   FOR EACH ROW
 BEGIN
	   INSERT INTO rfc_log VALUES(NULL, NEW.user_id, NEW.id, NOW(), 'update');
 END//
 
DELIMITER ;