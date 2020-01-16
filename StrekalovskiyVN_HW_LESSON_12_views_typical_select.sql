-- Представления

-- Таблица общих Контрактных объемов, BoQ Контракт + согласованные ЗНИ
CREATE  VIEW total_quantities
	    AS
		SELECT DISTINCT work_code,
			   CONCAT(work_name_eng, " / ", work_name_rus)
			   AS name,
			   CONCAT(uom_eng, " / ", uom_rus)
			   AS uom,
			   boq_contract.unit,
			   boq_contract.quantity
			   AS contract_qty,
			   SUM(rfc.qty_change)
			   AS rfc_qty,
			   IFNULL(boq_contract.quantity + SUM(rfc.qty_change), boq_contract.quantity)
			   AS total_contract_qty
		  FROM work_codes
			   JOIN boq_contract
				 ON work_codes.id = boq_contract.work_code_id
			   LEFT JOIN rfc
				 ON rfc.work_code_id = work_codes.id
				 AND rfc.unit = boq_contract.unit
				 AND rfc.is_contract = '1'
		 GROUP BY work_code, unit;
 
-- Таблица остатков
 CREATE  VIEW leftovers
		 AS
		 SELECT DISTINCT drawings.draw,
						 work_codes.work_code,
						 elements.element,
						 SUM(elements.total_quantity)
						 AS draw_qty,
						 SUM(acceptance_quantities.total_quantity)
						 AS accepted_qty,
						 IFNULL(SUM(elements.total_quantity) - SUM(acceptance_quantities.total_quantity), SUM(elements.total_quantity))
						 AS difference
				FROM elements
					 JOIN drawings
					   ON drawings.id = elements.draw_id
					 JOIN work_codes
					   ON work_codes.id = elements.work_code_id
					 LEFT JOIN acceptance_quantities
					   ON acceptance_quantities.element_id = elements.id
		   GROUP BY elements.id;
 
 -- Выборка с использованием оконных функций.
 SELECT DISTINCT phase,
				 unit,
                 title_num,
                 draw,
                 work_code,
                 element,
                 SUM(elements.element_quantity) OVER(PARTITION BY elements.id)
                 AS total_qty,
                 SUM(acceptance_quantities.total_quantity) OVER(PARTITION BY acceptance_quantities.id)
                 AS accepted_qty
				   FROM elements
						JOIN work_codes
						  ON work_codes.id = elements.work_code_id
						JOIN drawings
						  ON drawings.id = elements.draw_id
						JOIN titles
						  ON titles.id = drawings.title_id
						LEFT JOIN acceptance_quantities
						  ON acceptance_quantities.element_id = elements.id
	ORDER BY draw, work_code, element;
          
       
    