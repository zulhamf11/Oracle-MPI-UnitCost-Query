SELECT 
 HAOU.NAME "CABANG"
, ESIB.ITEM_NUMBER "ITEM"
, NVL(ROUND (CPC.unit_cost_average, 5), 0) "UNIT COST"
, ESIT.DESCRIPTION "ITEM DESC"
, ESIB.PRIMARY_UOM_CODE "UOM"
, SUM(CT.QUANTITY) "QUANTITY"
, SUM(CT.QUANTITY) * NVL(ROUND (CPC.unit_cost_average, 5), 0) "COSTED VALUE"
-- , SUM(CPC.QUANTITY_NEW) * NVL(ROUND (CPC.unit_cost_average, 5), 0) "COSTED VALUE"
FROM EGP_SYSTEM_ITEMS_B ESIB 

, EGP_SYSTEM_ITEMS_TL ESIT
-- , CST_LAYER_COSTS CLC
, CST_TRANSACTIONS CT 
, CST_INV_TRANSACTIONS CIT
, INV_MATERIAL_TXNS IMT
, HR_ALL_ORGANIZATION_UNITS HAOU
, CST_PERPAVG_COST CPC

WHERE ESIB.ORGANIZATION_ID = ESIT.ORGANIZATION_ID
AND HAOU.ORGANIZATION_ID = IMT.ORGANIZATION_ID
AND IMT.ORGANIZATION_ID = '300000005480001'
AND ESIB.ORGANIZATION_ID = IMT.ORGANIZATION_ID
AND ESIB.INVENTORY_ITEM_ID = ESIT.INVENTORY_ITEM_ID
AND ESIB.INVENTORY_ITEM_ID = IMT.INVENTORY_ITEM_ID
AND IMT.TRANSACTION_ID  = CIT.EXTERNAL_SYSTEM_REF_ID (+) 
-- AND CT.TRANSACTION_ID  = CLC.TRANSACTION_ID (+)
AND CT.CST_INV_TRANSACTION_ID (+) = CIT.CST_INV_TRANSACTION_ID
AND CPC.TRANSACTION_ID = CT.TRANSACTION_ID
AND CIT.EXTERNAL_SYSTEM_REFERENCE = 'FUSION'
AND ESIB.ITEM_NUMBER = '0V0100'

GROUP BY 'UNIT COSTS'
, HAOU.NAME
, ESIB.ITEM_NUMBER
, NVL(ROUND (CPC.unit_cost_average, 5), 0) 
, ESIT.DESCRIPTION 
, ESIB.PRIMARY_UOM_CODE  






------------------------------------------- fixed ------------------------------------------------
select c.name Cost_org, 
c.COST_BOOK_DESC cost_book, 
a.inventory_item_id item_id, 
d.item_number, e.val_unit_code val_unit, 
NVL(ROUND(unit_cost_average,5),0) unit_cost,
d.description,
d.PRIMARY_UOM_CODE,
f.quantity,
NVL(ROUND(f.quantity * unit_cost_average, 2),0) "Costed Value"

from fusion.cst_perpavg_cost b,

(select max(perpavg_cost_id)perpavg_cost_id, cost_org_id, cost_book_id, inventory_item_id, val_unit_id 
from fusion.cst_perpavg_cost
group by cost_org_id, cost_book_id, inventory_item_id, val_unit_id)a, 

(select cb.cost_book_id, cost_book_desc, cob.cost_org_id, org.name, org.organization_id
from fusion.cst_cost_books_tl cb,  fusion.cst_cost_org_books cob, fusion.hr_organization_units_f_tl org
where cb.cost_book_id = cob.cost_book_id
and cob.cost_org_id = org.organization_id
and cb.language = org.language
and cb.language = 'US')c, 

(select distinct inventory_item_id, item_number, description, PRIMARY_UOM_CODE  from fusion.egp_system_items)d, 

(select val_unit_id, val_unit_code from fusion.cst_val_units_b) e, 

(select sum(transaction_quantity) quantity, inventory_item_id, organization_id
from INV_MATERIAL_TXNS

group by
inventory_item_id, organization_id)f,

(select TRANSACTION_ID, inventory_org_id
from CST_TRANSACTIONS) g

where b.perpavg_cost_id = a.perpavg_cost_id
and a.cost_org_id = c.cost_org_id
and b.cost_org_id = c.cost_org_id
and a.cost_book_id = c.cost_book_id
and b.cost_book_id = c.cost_book_id
and a.inventory_item_id = d.inventory_item_id
and b.inventory_item_id = d.inventory_item_id
and a.val_unit_id = e.val_unit_id
and b.val_unit_id = e.val_unit_id
AND d.inventory_item_id = f.inventory_item_id
and f.organization_id = g.inventory_org_id
and b.transaction_id = g.transaction_id
and c.name = 'Costing Gudang Cabang Jakarta 1'
and d.item_number = '0V0100'

-------------------------------------------------------------------------------------------------------------------------------

-- test --

--  HAOU.NAME "CABANG"
SELECT
, ESIB.ITEM_NUMBER "ITEM"
, NVL(ROUND (CLC.unit_cost_average, 5), 0) "UNIT COST"
, ESIT.DESCRIPTION "ITEM DESC"
, ESIB.PRIMARY_UOM_CODE "UOM"
, SUM(CT.QUANTITY) "QUANTITY"
, SUM(CT.QUANTITY) * NVL(ROUND (CLC.unit_cost_average, 5), 0) "COSTED VALUE"
 
FROM EGP_SYSTEM_ITEMS_B ESIB 

, EGP_SYSTEM_ITEMS_TL ESIT
, CST_LAYER_COSTS CLC
, CST_TRANSACTIONS CT 
, CST_INV_TRANSACTIONS CIT
, INV_MATERIAL_TXNS IMT
, HR_ALL_ORGANIZATION_UNITS HAOU

WHERE ESIB.ORGANIZATION_ID = ESIT.ORGANIZATION_ID
AND HAOU.ORGANIZATION_ID = CT.COST_ORG_ID
AND HAOU.ORGANIZATION_ID = CLC.COST_ORG_ID
AND ESIB.ORGANIZATION_ID = IMT.ORGANIZATION_ID
AND ESIB.INVENTORY_ITEM_ID = ESIT.INVENTORY_ITEM_ID
AND ESIB.INVENTORY_ITEM_ID = IMT.INVENTORY_ITEM_ID
AND IMT.TRANSACTION_ID  = CIT.EXTERNAL_SYSTEM_REF_ID (+) 
AND CT.TRANSACTION_ID  = CLC.TRANSACTION_ID (+)
AND CT.CST_INV_TRANSACTION_ID (+) = CIT.CST_INV_TRANSACTION_ID
AND CIT.EXTERNAL_SYSTEM_REFERENCE = 'FUSION'
AND ESIB.ITEM_NUMBER = '0V0100'
AND HAOU.NAME = 'Costing Gudang Cabang Jakarta 1'

GROUP BY 'UNIT COSTS'
, HAOU.NAME
, ESIB.ITEM_NUMBER
, NVL(ROUND (CLC.unit_cost_average, 5), 0) 
, ESIT.DESCRIPTION 
, ESIB.PRIMARY_UOM_CODE 