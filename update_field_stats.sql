UPDATE oilgas_fields_lam SET prod_gas = (SELECT prod_gas FROM field_stats WHERE oilgas_fields_lam.field_kid = field_stats.field_kid);

UPDATE oilgas_fields_lam SET prod_oil = (SELECT prod_oil FROM field_stats WHERE oilgas_fields_lam.field_kid = field_stats.field_kid);

UPDATE oilgas_fields_lam SET lastgdate = (SELECT lastgdate FROM field_stats WHERE oilgas_fields_lam.field_kid = field_stats.field_kid);

UPDATE oilgas_fields_lam SET lastodate = (SELECT lastodate FROM field_stats WHERE oilgas_fields_lam.field_kid = field_stats.field_kid);

UPDATE oilgas_fields_lam SET cumm_gas = (SELECT cumm_gas FROM field_stats WHERE oilgas_fields_lam.field_kid = field_stats.field_kid);

UPDATE oilgas_fields_lam SET cumm_oil = (SELECT cumm_oil FROM field_stats WHERE oilgas_fields_lam.field_kid = field_stats.field_kid);

UPDATE oilgas_fields_lam SET lastoilpro = (SELECT lastoilpro FROM field_stats WHERE oilgas_fields_lam.field_kid = field_stats.field_kid);

UPDATE oilgas_fields_lam SET lastgaspro = (SELECT lastgaspro FROM field_stats WHERE oilgas_fields_lam.field_kid = field_stats.field_kid);

UPDATE oilgas_fields_lam SET maxoilwell = (SELECT maxoilwell FROM field_stats WHERE oilgas_fields_lam.field_kid = field_stats.field_kid);

UPDATE oilgas_fields_lam SET maxgaswell = (SELECT maxgaswell FROM field_stats WHERE oilgas_fields_lam.field_kid = field_stats.field_kid);

UPDATE oilgas_fields_lam SET lastoilwel = (SELECT lastoilwel FROM field_stats WHERE oilgas_fields_lam.field_kid = field_stats.field_kid);

UPDATE oilgas_fields_lam SET lastgaswel = (SELECT lastgaswel FROM field_stats WHERE oilgas_fields_lam.field_kid = field_stats.field_kid);

UPDATE oilgas_fields_lam SET activeprod = 'OILGAS' WHERE prod_gas = 'Yes' AND prod_oil = 'Yes';

UPDATE oilgas_fields_lam SET activeprod = 'OIL' WHERE prod_gas = 'No' AND prod_oil = 'Yes';

UPDATE oilgas_fields_lam SET activeprod = 'GAS' WHERE prod_gas = 'Yes' AND prod_oil = 'No';

UPDATE oilgas_fields_lam SET field_type = (SELECT type_of_field FROM nomenclature.fields WHERE oilgas_fields_lam.field_kid = nomenclature.fields.kid);

UPDATE oilgas_fields_lam SET field_type = 'Oil and Gas' where field_type = 'O&G';

UPDATE oilgas_fields_lam SET field_type = 'Oil' where field_type = 'OIL';

UPDATE oilgas_fields_lam SET field_type = 'Gas' where field_type = 'GAS';