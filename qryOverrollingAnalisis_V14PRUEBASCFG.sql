/*select * from ##fact_lg_calculo_overrolling_posible_ovr
select * from ##fact_lg_calculo_overrolling_recuperos_ovr
select * from ##fact_lg_calculo_overrolling_definicion*/


			--------------------------------------------------------------------- CFG

DECLARE @orden_ejecucion int = 1, @max_orden_ejecucion int, @SQLQuery varchar(max)

set nocount on
IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_cfgvocesovr') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_cfgvocesovr
IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_definicion') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_definicion

create table ##fact_lg_calculo_overrolling_cfgvocesovr (id int identity(1,1), prioridad_voces int, codigo varchar(200), 
voces varchar(200), subvoces varchar(200), tabla_voces varchar(200), cod_tipo_movimiento varchar(200), pro_norma_desc varchar(200), cod_cliente varchar(200), valor_posterior varchar(200),
pro_grado_desc varchar(200), pro_subnorma_desc varchar(200), tipo varchar(200), clase_cod varchar(200), pro_cod varchar(200), cod_motivo_pedido varchar(200), cod_tipo_ofa varchar(200),
espesor_valor varchar(200), ancho_valor varchar(200), cod_grado_acero varchar(200), marca_logica_calculo varchar(200), planta varchar(200), largo_valor varchar(200),
cod_tipo_calidad varchar(200), cod_linea_imputacion varchar(2000), ofa_necesidad varchar(200), ofadoc_ofapos varchar(200), valor_anterior varchar(200),
desc_defecto varchar(200), cod_linea varchar(2000), desc_causa_defecto varchar(200),cod_clase_doc varchar(10), calidad_cod varchar(50),
gale varchar(200),observaciones varchar(1000),
cond_update varchar(2000), cond_insert varchar(2000), cond_select varchar(2000), cond_from varchar(MAX), cond_join varchar(2000)
, cond_where varchar(2000), cond_and_or varchar(2000), cond_groupby varchar(200) )

/*==============================================================================================================================================================================================================================
1) TRANSFERENCIAS DESDE SUPPLY
- Materiales con estrategia anterior STF, STS, STC, XTS y cliente distinto de 410 o 412.
==============================================================================================================================================================================================================================*/

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, tabla_voces, valor_anterior, cod_cliente, cond_insert, cond_select, cond_from, cond_where, cond_and_or)
select 'tran_supply', 1, 'TRANSFERENCIA SUPPLY CHAIN', '##fact_lg_calculo_overrolling_tran_supply', '''STS'',''STF'',''STC'',''XTS''', '''0000000410'',''0000000412''', 'insert into @tabla_voces', 'select material_key', 'from ##fact_lg_calculo_overrolling_posible_ovr', 'where valor_anterior in (@valor_anterior)', 'and cod_cliente not in (@cod_cliente)'

/*==============================================================================================================================================================================================================================
2) AJUSTE DE INVENTARIO
- Materiales con movimiento 141, 23 o 162 en toda su historia.
==============================================================================================================================================================================================================================*/

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, tabla_voces, cod_tipo_movimiento, cond_insert, cond_select, cond_from, cond_join, cond_where, cond_and_or)
select 'ajuste_inv', 2, 'AJUSTE DE INVENTARIO', '##fact_lg_calculo_overrolling_AJUSTEINV', '''141'',''23'',''162''', 'insert into @tabla_voces', 'select material_key', 'from ges_siderar..fact_lg_movimientos_cab FMC', 'left join GES_siderar..dim_lg_tipo_movimiento DTM on FMC.tipo_movimiento_key = DTM.tipo_movimiento_key', 'where cod_tipo_movimiento in (@cod_tipo_movimiento)', 'and material_key in (select material_key from ##fact_lg_calculo_overrolling_posible_ovr)'

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, tabla_voces, cod_tipo_movimiento, cond_insert, cond_select, cond_from, cond_join, cond_where, cond_and_or)
select 'ajuste_inv_padres', 2, 'AJUSTE DE INVENTARIO', '##fact_lg_calculo_overrolling_AJUSTEINV', '''141'',''23'',''162''', 'insert into @tabla_voces', 'select hijo_material_key', 'from ##fact_lg_calculo_overrolling_padre_hijo PH', 'left join ges_siderar..fact_lg_movimientos_cab FMC on FMC.material_key = PH.padre_material_key left join GES_siderar..dim_lg_tipo_movimiento DTM on FMC.tipo_movimiento_key = DTM.tipo_movimiento_key', 'where cod_tipo_movimiento in (@cod_tipo_movimiento)', 'and material_key in (select padre_material_key from ##fact_lg_calculo_overrolling_padre_hijo)'

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, tabla_voces, cod_tipo_movimiento, cond_insert, cond_select, cond_from, cond_join, cond_where, cond_and_or)
select 'ajuste_inv_hist', 2, 'AJUSTE DE INVENTARIO', '##fact_lg_calculo_overrolling_AJUSTEINV', '''141'',''23'',''162''', 'insert into @tabla_voces', 'select material_key', 'from higes_siderar..fact_lg_movimientos_cab FMC', 'left join GES_siderar..dim_lg_tipo_movimiento DTM on FMC.tipo_movimiento_key = DTM.tipo_movimiento_key', 'where cod_tipo_movimiento in (@cod_tipo_movimiento)', 'and material_key in (select material_key from ##fact_lg_calculo_overrolling_posible_ovr)'

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, tabla_voces, cod_tipo_movimiento, cond_insert, cond_select, cond_from, cond_join, cond_where, cond_and_or)
select 'ajuste_inv_padres_hist', 2, 'AJUSTE DE INVENTARIO', '##fact_lg_calculo_overrolling_AJUSTEINV', '''141'',''23'',''162''', 'insert into @tabla_voces', 'select hijo_material_key', 'from ##fact_lg_calculo_overrolling_padre_hijo PH', 'left join higes_siderar..fact_lg_movimientos_cab FMC on FMC.material_key = PH.padre_material_key left join GES_siderar..dim_lg_tipo_movimiento DTM on FMC.tipo_movimiento_key = DTM.tipo_movimiento_key', 'where cod_tipo_movimiento in (@cod_tipo_movimiento)', 'and material_key in (select padre_material_key from ##fact_lg_calculo_overrolling_padre_hijo)'


/*==============================================================================================================================================================================================================================
3) TECNOLÓGICO-PROGRAMACIÓN-OPERACIÓN - INDUSTRIAL
-----------------------------------------------
- Materiales con mov 33 (Ingreso a APT) tomando el movimiento mas viejo con estrategia SND,OVR,OVE,EOV ó WEB que no sean VaC sin importar el responsable 
- y con al menos una Caida Rechazada (marca A* de caida rechazada sin haberse aceptado en ningun momento)
- O Si clase_cod='M-P-FRIO-BOB-CRU' y espesor_real in (0.25,0.28,0.30)
- Si cod_cliente <>'0000000999' (Siderar Ordenes de Prueba) y clave_anterior <> 'SNADCA' y:
* Si cod_tipo_ofa='EVACUACION' y  clase_cod='M-P-FRIO-BOB-REC' y espesor_real <=0.30 y ancho_real <1000 y cod_grado_acero in ('7010','0010')
* Si tipo='BOBINA' y ancho_real <1000 y espesor_real < 2.0     y	clase_cod='M-P-DECAPADO-BOB-_'         y cod_grado_acero='7026'
* Si tipo='PAQUETE' y planta in ('HA','CA')                       y cod_tipo_ofa='EVACUACION'              y largo_real in (3048.0,3658.0,3962.0,4267.0)
* Si cod_tipo_calidad in ('SACRIFICIO_TIRAS','BOBINA_TRANSICION','SACRIFICIO_CINTA_NOC','SACRIFICIO_FAJAS')
==============================================================================================================================================================================================================================*/

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, tabla_voces, cod_cliente, valor_anterior, cod_tipo_ofa, clase_cod, espesor_valor, ancho_valor, cod_grado_acero, cond_insert, cond_select, cond_from, cond_where, cond_and_or)
select 'tpo', 3, 'TECNOLÓGICO/PROGRAMACIÓN/OPERACIÓN', '##fact_lg_calculo_overrolling_TPO', '''0000000999''', '''SNADCA''', '''EVACUACION''', '''M-P-FRIO-BOB-REC''', '0.30', '1000', '''7010'',''0010''', 'insert into @tabla_voces', 'select material_key', 'from ##fact_lg_calculo_overrolling_posible_ovr ovr', 'WHERE  cod_cliente <> @cod_cliente AND valor_anterior <> @valor_anterior', 'AND (cod_tipo_ofa in (@cod_tipo_ofa) AND clase_cod in (@clase_cod) AND espesor_valor <= @espesor_valor AND ancho_valor < @ancho_valor AND cod_grado_acero in (@cod_grado_acero))'

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, tabla_voces, cod_cliente, valor_anterior, marca_logica_Calculo, clase_cod, espesor_valor, cond_insert, cond_select, cond_from, cond_where, cond_and_or)
select 'tpo', 3, 'TECNOLÓGICO/PROGRAMACIÓN/OPERACIÓN', '##fact_lg_calculo_overrolling_TPO', '''0000000999''', '''SNADCA''', '''A%''', '''M-P-FRIO-BOB-CRU''', '''0.25'', ''0.28'', ''0.30'', ''0.305''', 'insert into @tabla_voces', 'select material_key', 'from ##fact_lg_calculo_overrolling_posible_ovr ovr', 'WHERE  cod_cliente <> @cod_cliente AND valor_anterior <> @valor_anterior', 'AND (marca_logica_calculo not like @marca_logica_calculo and clase_cod in (@clase_cod) and espesor_valor in (@espesor_valor))'

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, subvoces, tabla_voces, cod_cliente, valor_anterior, tipo, planta, clase_cod, cod_tipo_ofa, largo_valor, cond_insert, cond_select, cond_from, cond_where, cond_and_or)
select 'tpo_conformados', 4, 'TECNOLÓGICO/PROGRAMACIÓN/OPERACIÓN', 'CONFORMADOS', '##fact_lg_calculo_overrolling_CONFORMADOS', '''0000000999''', '''SNADCA''', '''PAQUETE''', '''HA''', '''M-P-GALVANIZAD-HOJ-_'',''M-P-CINCALUM-HOJ-_'',''M-P-PREPINTADO-HOJ-_'',''M-C-GALVANIZAD-SIN-_''', '''EVACUACION''', '2440.0, 2000.0', 'insert into @tabla_voces', 'select material_key', 'from ##fact_lg_calculo_overrolling_posible_ovr ovr', 'WHERE  cod_cliente <> @cod_cliente AND valor_anterior <> @valor_anterior', 'AND tipo in(@tipo) AND planta in (@planta) AND clase_cod in (@clase_cod) AND cod_tipo_ofa in(@cod_tipo_ofa) AND largo_valor in (@largo_valor)'

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, subvoces, tabla_voces, cod_cliente, valor_anterior, planta, clase_cod, cod_tipo_ofa, largo_valor, cond_insert, cond_select, cond_from, cond_where, cond_and_or)
select 'tpo_conformados', 4, 'TECNOLÓGICO/PROGRAMACIÓN/OPERACIÓN', 'CONFORMADOS', '##fact_lg_calculo_overrolling_CONFORMADOS', '''0000000999''', '''SNADCA''', '''HA'',''CA''', '''M-C%''', '''EVACUACION''', '3500.0, 4000.0', 'insert into @tabla_voces', 'select material_key', 'from ##fact_lg_calculo_overrolling_posible_ovr ovr', 'WHERE  cod_cliente <> @cod_cliente AND valor_anterior <> @valor_anterior', 'AND ( planta in (@planta) AND clase_cod LIKE @clase_cod AND cod_tipo_ofa in(@cod_tipo_ofa) AND largo_valor in (@largo_valor))'

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, subvoces, tabla_voces, cod_cliente, valor_anterior, planta, clase_cod, cod_tipo_ofa, largo_valor, cond_insert, cond_select, cond_from, cond_where, cond_and_or)
select 'tpo_conformados', 4, 'TECNOLÓGICO/PROGRAMACIÓN/OPERACIÓN', 'CONFORMADOS', '##fact_lg_calculo_overrolling_CONFORMADOS', '''0000000999''', '''SNADCA''', '''HA'',''IVAN''', '''M-R%''', '''EVACUACION''', '6000.0', 'insert into @tabla_voces', 'select material_key', 'from ##fact_lg_calculo_overrolling_posible_ovr ovr', 'WHERE  cod_cliente <> @cod_cliente AND valor_anterior <> @valor_anterior', 'AND ( planta in (@planta) AND clase_cod LIKE @clase_cod AND cod_tipo_ofa in(@cod_tipo_ofa) AND largo_valor in (@largo_valor))' 

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, subvoces, tabla_voces, cod_cliente, valor_anterior, clase_cod, espesor_valor, cond_insert, cond_select, cond_from, cond_where, cond_and_or)
select 'tpo_fuera_de_grilla', 5, 'TECNOLÓGICO/PROGRAMACIÓN/OPERACIÓN', 'FUERA DE GRILLA', '##fact_lg_calculo_overrolling_FUERADEGRILLA', '''0000000999''', '''SNADCA''',  '''M-P-FRIO-BOB-CRU''', 'espesor_valor >= 0.2 and espesor_valor<=0.36', 'insert into @tabla_voces', 'select material_key', 'from ##fact_lg_calculo_overrolling_posible_ovr ovr', 'WHERE  cod_cliente <> @cod_cliente AND valor_anterior <> @valor_anterior', 'AND (clase_cod in(@clase_cod) and @espesor_valor)'

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, subvoces, tabla_voces, cod_cliente, valor_anterior, clase_cod, espesor_valor, ancho_valor, cod_grado_acero, ofadoc_ofapos, cond_insert, cond_select, cond_from, cond_where, cond_and_or)
select 'tpo_fuera_de_grilla', 5, 'TECNOLÓGICO/PROGRAMACIÓN/OPERACIÓN', 'FUERA DE GRILLA', '##fact_lg_calculo_overrolling_FUERADEGRILLA', '''0000000999''', '''SNADCA''',  '''M-P-FRIO-BOB-REC''', 'espesor_Valor<=0.30', 'ancho_valor < 999.9', '''7010'',''0010''', 'ofa_documento+ofa_posicion like ''7%'' or ofa_documento+ofa_posicion like ''07%''', 'insert into @tabla_voces', 'select material_key', 'from ##fact_lg_calculo_overrolling_posible_ovr ovr', 'WHERE  cod_cliente <> @cod_cliente AND valor_anterior <> @valor_anterior', 'AND (clase_cod in (@clase_cod) and @espesor_valor and @ancho_valor and cod_grado_acero in (@cod_grado_acero) and (@ofadoc_ofapos))'

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, subvoces, tabla_voces, cod_cliente, valor_anterior, tipo, ancho_valor, espesor_valor, clase_cod, cod_grado_acero, marca_logica_Calculo, cond_insert, cond_select, cond_from, cond_where, cond_and_or)
select 'tpo_tira_de_enhebrado', 6, 'TECNOLÓGICO/PROGRAMACIÓN/OPERACIÓN', 'TIRA DE ENHEBRADO', '##fact_lg_calculo_overrolling_TPO', '''0000000999''', '''SNADCA''', '''BOBINA''', '1000.0', '2.0', '''M-P-DECAPADO-BOB-_'',''M-P-DECAPADO-BOB-PLA''', '''7026'',''6026''', '''A8%''', 'insert into @tabla_voces', 'select material_key', 'from ##fact_lg_calculo_overrolling_posible_ovr ovr', 'WHERE  cod_cliente <> @cod_cliente AND valor_anterior <> @valor_anterior', 'AND ((tipo in(@tipo) AND ancho_valor <@ancho_valor AND espesor_valor < @espesor_valor AND clase_cod in (@clase_cod) AND cod_grado_acero in(@cod_grado_acero)) OR (ovr.marca_logica_calculo like @marca_logica_calculo))'

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, subvoces, tabla_voces, cod_cliente, valor_anterior, cod_tipo_calidad, cond_insert, cond_select, cond_from, cond_where, cond_and_or)
select 'tpo_bobina_tran', 7, 'TECNOLÓGICO/PROGRAMACIÓN/OPERACIÓN', 'BOBINA DE TRANSICION', '##fact_lg_calculo_overrolling_TPO', '''0000000999''', '''SNADCA''', '''SACRIFICIO_TIRAS'',''BOBINA_TRANSICION'',''SACRIFICIO_CINTA_NOC'',''SACRIFICIO_FAJAS''', 'insert into @tabla_voces', 'select material_key', 'from ##fact_lg_calculo_overrolling_posible_ovr ovr', 'WHERE  cod_cliente <> @cod_cliente AND valor_anterior <> @valor_anterior', 'AND cod_tipo_calidad in (@cod_tipo_calidad)'

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, subvoces, tabla_voces, cod_cliente, valor_anterior, cod_tipo_ofa, marca_logica_calculo, cod_linea_imputacion, cond_insert, cond_select, cond_from, cond_where, cond_and_or)
select 'tpo_arranque_estañado', 8, 'TECNOLÓGICO/PROGRAMACIÓN/OPERACIÓN', 'ARRANQUE ESTAÑADO', '##fact_lg_calculo_overrolling_ARRANQUEEST', '''0000000999''', '''SNADCA''', '''EVACUACION''', '''A6%''', '''EEB''', 'insert into @tabla_voces', 'select material_key', 'from ##fact_lg_calculo_overrolling_posible_ovr ovr', 'WHERE  cod_cliente <> @cod_cliente AND valor_anterior <> @valor_anterior', 'AND (cod_tipo_ofa in (@cod_tipo_ofa) and marca_logica_Calculo like @marca_logica_calculo and cod_linea_imputacion in (@cod_linea_imputacion))'

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, subvoces, tabla_voces, cod_cliente, valor_anterior, cod_tipo_ofa, ofa_necesidad, cod_tipo_calidad, cond_insert, cond_select, cond_from, cond_where, cond_and_or)
select 'tpo_arranque_lac', 9, 'TECNOLÓGICO/PROGRAMACIÓN/OPERACIÓN', 'ARRANQUE LAC', '##fact_lg_calculo_overrolling_ARRANQUELAC', '''0000000999''', '''SNADCA''', '''EVACUACION''', '''001000460991'',''003000033879''', '''1''', 'insert into @tabla_voces', 'select material_key', 'from ##fact_lg_calculo_overrolling_posible_ovr ovr', 'WHERE  cod_cliente <> @cod_cliente AND valor_anterior <> @valor_anterior', 'AND (cod_tipo_ofa in (@cod_tipo_ofa) and ofa_necesidad in (@ofa_necesidad) and cod_tipo_calidad in (@cod_tipo_calidad))'

/*==============================================================================================================================================================================================================================
4) DEVOLUCION DE CLIENTES
- Materiales con movimiento 165, 179 o 182 en toda su historia.
==============================================================================================================================================================================================================================*/

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, tabla_voces, cod_tipo_movimiento, cond_insert, cond_select, cond_from, cond_join, cond_where, cond_and_or)
select 'dev_clientes', 10, 'DEVOLUCION DE CLIENTES', '##fact_lg_calculo_overrolling_DEVCLIENTES', '''165'',''179'',''182''', 'insert into @tabla_voces', 'select material_key', 'from ges_siderar..fact_lg_movimientos_cab FMC', 'left join GES_siderar..dim_lg_tipo_movimiento DTM on FMC.tipo_movimiento_key = DTM.tipo_movimiento_key', 'where cod_tipo_movimiento in (@cod_tipo_movimiento)', 'and material_key in (select material_key from ##fact_lg_calculo_overrolling_posible_ovr)'

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, tabla_voces, cod_tipo_movimiento, cond_insert, cond_select, cond_from, cond_join, cond_where, cond_and_or)
select 'dev_clientes_padres', 10, 'DEVOLUCION DE CLIENTES', '##fact_lg_calculo_overrolling_DEVCLIENTES', '''165'',''179'',''182''', 'insert into @tabla_voces', 'select hijo_material_key', 'from ##fact_lg_calculo_overrolling_padre_hijo PH', 'left join ges_siderar..fact_lg_movimientos_cab FMC on FMC.material_key = PH.padre_material_key left join GES_siderar..dim_lg_tipo_movimiento DTM on FMC.tipo_movimiento_key = DTM.tipo_movimiento_key', 'where cod_tipo_movimiento in (@cod_tipo_movimiento)', 'and material_key in (select padre_material_key from ##fact_lg_calculo_overrolling_padre_hijo)'

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, tabla_voces, cod_tipo_movimiento, cond_insert, cond_select, cond_from, cond_join, cond_where, cond_and_or)
select 'dev_clientes_hist', 10, 'DEVOLUCION DE CLIENTES', '##fact_lg_calculo_overrolling_DEVCLIENTES', '''165'',''179'',''182''', 'insert into @tabla_voces', 'select material_key', 'from higes_siderar..fact_lg_movimientos_cab FMC', 'left join GES_siderar..dim_lg_tipo_movimiento DTM on FMC.tipo_movimiento_key = DTM.tipo_movimiento_key', 'where cod_tipo_movimiento in (@cod_tipo_movimiento)', 'and material_key in (select material_key from ##fact_lg_calculo_overrolling_posible_ovr)'

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, tabla_voces, cod_tipo_movimiento, cond_insert, cond_select, cond_from, cond_join, cond_where, cond_and_or)
select 'dev_clientes_padres_hist', 10, 'DEVOLUCION DE CLIENTES', '##fact_lg_calculo_overrolling_DEVCLIENTES', '''165'',''179'',''182''', 'insert into @tabla_voces', 'select hijo_material_key', 'from ##fact_lg_calculo_overrolling_padre_hijo PH', 'left join higes_siderar..fact_lg_movimientos_cab FMC on FMC.material_key = PH.padre_material_key left join GES_siderar..dim_lg_tipo_movimiento DTM on FMC.tipo_movimiento_key = DTM.tipo_movimiento_key', 'where cod_tipo_movimiento in (@cod_tipo_movimiento)', 'and material_key in (select padre_material_key from ##fact_lg_calculo_overrolling_padre_hijo)'


/*==============================================================================================================================================================================================================================
5) EXCEDENTE DE FABRICACIÓN
- Materiales con movimiento 733 o 33 y estrategia anterior SNADSC (En cualquier momento de su historia)
==============================================================================================================================================================================================================================*/

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, subvoces, tabla_voces, valor_anterior, valor_posterior, planta, cond_insert, cond_select, cond_from, cond_where, cond_and_or)
select 'exced_fab_ivanar', 11, 'EXCEDENTE DE FABRICACION', 'IVANAR', '##fact_lg_calculo_overrolling_IVANAR', '''MTS''', '''WEB''', '''IVAN'',''LAM'',''LAMR''', 'insert into @tabla_voces', 'select material_key', 'from ##fact_lg_calculo_overrolling_posible_ovr', 'where valor_anterior in (@valor_anterior)', 'and valor_posterior in (@valor_posterior) and planta in (@planta)'

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, tabla_voces, valor_anterior, cond_insert, cond_select, cond_from, cond_where, cond_and_or)
select 'exced_fab', 12, 'EXCEDENTE DE FABRICACION', '##fact_lg_calculo_overrolling_EXCEDFAB', '''SNADSC''', 'insert into @tabla_voces', 'select material_key', 'from ges_siderar..fact_lg_movimientos_detalle FMD', 'where valor_anterior in (@valor_anterior)', 'and FMD.material_key in (select material_key from ##fact_lg_calculo_overrolling_posible_ovr)'

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, tabla_voces, valor_anterior, cond_insert, cond_select, cond_from, cond_where, cond_and_or)
select 'exced_fab_hist', 12, 'EXCEDENTE DE FABRICACION', '##fact_lg_calculo_overrolling_EXCEDFAB', '''SNADSC''', 'insert into @tabla_voces', 'select material_key', 'from higes_siderar..fact_lg_movimientos_detalle FMD', 'where valor_anterior in (@valor_anterior)', 'and FMD.material_key in (select material_key from ##fact_lg_calculo_overrolling_posible_ovr)'

/*==============================================================================================================================================================================================================================
6) COBBLES
------------------------
Materiales cuyo tipo de movimiento es 33 y su Clase es M-P-CALIENTE-HOJ-GRU
==============================================================================================================================================================================================================================*/

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, tabla_voces, tipo, clase_cod, cond_insert, cond_select, cond_from, cond_where, cond_and_or)
select 'cobbles', 13, 'COBBLES', '##fact_lg_calculo_overrolling_COBBLES', '''COBBLE''' , '''M-P-CALIENTE-HOJ-GRU''' , 'insert into @tabla_voces', 'select material_key', 'from ##fact_lg_calculo_overrolling_posible_ovr ovr', 'where tipo in (@tipo)',  'and clase_cod in (@clase_cod)'

/*==============================================================================================================================================================================================================================
7) DESVÍO CUALITATIVO
Todos los bultos con cod_tipo_ofa = 'EVACUACION' que:
- Alguna vez hayan sido marcados ellos o sus padres como B* y no vengan de vuelta a ciclo
- Su marca actual sea A1* y no vengan de vuelta a ciclo
==============================================================================================================================================================================================================================*/

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, subvoces, tabla_voces, marca_logica_calculo, cond_insert, cond_select, cond_from, cond_join, cond_where)
select 'dc', 14, 'DESVIO CUALITATIVO', 'INDUSTRIAL', '##fact_lg_calculo_overrolling_DC', '''B%''', 'insert into @tabla_voces', 'select distinct ovr.material_key', 'from ##fact_lg_calculo_overrolling_posible_ovr ovr', 'left join ges_siderar..fact_lg_dictamen_caidas fdc on fdc.material_key = ovr.material_key', 'where fdc.marca_logica_calculo like @marca_logica_calculo'

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, subvoces, tabla_voces, marca_logica_calculo, cond_insert, cond_select, cond_from, cond_join, cond_where)
select 'dc', 15, 'DESVIO CUALITATIVO', 'INDUSTRIAL', '##fact_lg_calculo_overrolling_DC', '''B%''', 'insert into @tabla_voces', 'select distinct ph.hijo_material_key', 'from ##fact_lg_calculo_overrolling_padre_hijo ph', 'inner join ges_siderar..fact_lg_dictamen_caidas fdc on fdc.material_key = ph.padre_material_key ', 'where fdc.marca_logica_calculo like @marca_logica_calculo'

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, subvoces, tabla_voces, marca_logica_calculo, planta, cond_insert, cond_select, cond_from, cond_where, cond_and_or)
select 'dc', 16, 'DESVIO CUALITATIVO', 'INDUSTRIAL', '##fact_lg_calculo_overrolling_DC', '''A6%''', '''SIII''', 'insert into @tabla_voces', 'select distinct material_key', 'from ##fact_lg_calculo_overrolling_posible_ovr', 'where marca_logica_calculo like @marca_logica_calculo', 'and planta in (@planta)'

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, subvoces, tabla_voces, desc_causa_defecto, cod_linea_imputacion, desc_defecto, cond_insert, cond_select, cond_from, cond_where, cond_and_or)
select 'dc', 17, 'DESVIO CUALITATIVO', 'COMERCIAL', '##fact_lg_calculo_overrolling_COMERCIAL', '''Fuera de Permanencia''', '''APT'',''TAL'',''TCE'',''TCF'',''TCH'',''TCS'',''TCS1CS2'',''TCS1SA1'',''TCS1SR'',''TCS2CS1'',''TCS2SA1'',''TCS2SR'',''TEC'',''TEF'',''TEH'',''TES'',''TFB'',''TFC'',''TFE'',''TFH'',''TFL'',''TFS'',''THC'',''THE'',''THF'',''THS'',''TIL'',''TLA'',''TLAHDO'',''TLI'',''TRAPROSIII'',''TRASIIIPRO'',''TRBSASFV'',''TSA1CS1'',''TSA1CS2'',''TSA1SR'',''TSC'',''TSE'',''TSE'',''TSF'',''TSH'',''TSRCS1'',''TSRCS2'',''TSRSA1''', '''Herrumbre''', 'insert into @tabla_voces', 'select material_key', 'from ##fact_lg_calculo_overrolling_posible_ovr', 'where material_key in (select material_key from ##fact_lg_calculo_overrolling_DC)', 'and desc_defecto in (@desc_defecto) and cod_linea_imputacion in (@cod_linea_imputacion) and desc_causa_defecto in (@desc_causa_defecto)'

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, subvoces, tabla_voces, cod_linea, cond_insert, cond_select, cond_from, cond_where, cond_and_or)
select 'dc', 18, 'DESVIO CUALITATIVO', 'SUPPLY', '##fact_lg_calculo_overrolling_SUPPLY', '''APT'',''TAL'',''TCE'',''TCF'',''TCH'',''TCS'',''TCS1CS2'',''TCS1SA1'',''TCS1SR'',''TCS2CS1'',''TCS2SA1'',''TCS2SR'',''TEC'',''TEF'',''TEH'',''TES'',''TFB'',''TFC'',''TFE'',''TFH'',''TFL'',''TFS'',''THC'',''THE'',''THF'',''THS'',''TIL'',''TLA'',''TLAHDO'',''TLI'',''TRAPROSIII'',''TRASIIIPRO'',''TRBSASFV'',''TSA1CS1'',''TSA1CS2'',''TSA1SR'',''TSC'',''TSE'',''TSE'',''TSF'',''TSH'',''TSRCS1'',''TSRCS2'',''TSRSA1''', 'insert into @tabla_voces', 'select material_key', 'from ##fact_lg_calculo_overrolling_posible_ovr', 'where material_key in (select material_key from ##fact_lg_calculo_overrolling_DC)', 'and cod_linea in (@cod_linea_origen) and cod_linea_imputacion in (@cod_linea_origen)'


/*==============================================================================================================================================================================================================================
8) ROLL CHANCE - INDUSTRIAL
------------------------
Materiales con movimiento 33 (Ingreso a APT) identificados con una norma especifica ETP-3BLC.003 (RC) sin importar si son ordenes genuinas o SNAD.
Tambien se consideran los materiales que ingresan al stock balo los clientes 410 (Disponible Tubos y Caños de Produccion) y 412 (Abastecimiento DECS), con estrategia STC/STN. 
==============================================================================================================================================================================================================================*/

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, subvoces, tabla_voces, gale, cod_clase_doc, calidad_cod, cond_insert, cond_select, cond_from, cond_where)
select 'roll_chance_chile', 19, 'ROLL CHANCE', 'CHILE COMERCIAL', '##fact_lg_calculo_overrolling_RC_CHILE_COMERCIAL', '''NA''', '''ZNPE''' , '''RC''', 'insert into @tabla_voces', 'select material_key', 'from ##fact_lg_calculo_overrolling_posible_ovr ovr', 'where (ovr.cod_clase_doc in (@cod_clase_doc) and ovr.calidad_cod in (@calidad_cod) and gale not in (@gale)) '

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, subvoces, tabla_voces, cod_tipo_movimiento, pro_norma_desc, pro_grado_desc, cond_insert, cond_select, cond_from, cond_where, cond_and_or)
select 'roll_chance_no_genuino', 20, 'ROLL CHANCE', 'CHILE ETP-3ESP.003', '##fact_lg_calculo_overrolling_RC_CHILE_ETP', '''33''', '''ETP-3ESP.003''', '''NCH3518 (V 2019 REV 0)''', 'insert into @tabla_voces', 'select material_key', 'from ##fact_lg_calculo_overrolling_posible_ovr ovr', 'where ovr.cod_tipo_movimiento in (@cod_tipo_movimiento)', 'and (ovr.pro_norma_desc in (@pro_norma_desc) AND ovr.pro_grado_desc in (@pro_grado_desc))'

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, subvoces, tabla_voces, cod_tipo_movimiento, pro_norma_desc, pro_grado_desc, pro_subnorma_desc, cond_insert, cond_select, cond_from, cond_where, cond_and_or)
select 'roll_chance_no_genuino', 20, 'ROLL CHANCE', 'CHILE ETP-3ESP.003', '##fact_lg_calculo_overrolling_RC_CHILE_ETP', '''33''', '''ETP-3ESP.003''', '''15B30M''', '''TER (V 2018 REV 0)''', 'insert into @tabla_voces', 'select material_key', 'from ##fact_lg_calculo_overrolling_posible_ovr ovr', 'where ovr.cod_tipo_movimiento in (@cod_tipo_movimiento)', 'and (ovr.pro_norma_desc in (@pro_norma_desc) and ovr.pro_grado_desc in (@pro_grado_desc) AND ovr.pro_subnorma_desc in (@pro_subnorma_desc))'

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, subvoces, tabla_voces, cod_motivo_pedido, cond_insert, cond_select, cond_from, cond_where)
select 'roll_chance_slabs_sobrantes', 21, 'ROLL CHANCE', 'SLABS SOBRANTES N05', '##fact_lg_calculo_overrolling_RC_N05', '''N05''' , 'insert into @tabla_voces', 'select material_key', 'from ##fact_lg_calculo_overrolling_posible_ovr ovr', 'where (ovr.cod_motivo_pedido in (@cod_motivo_pedido)) '

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, subvoces, tabla_voces, cod_tipo_movimiento, pro_norma_desc, cond_insert, cond_select, cond_from, cond_where, cond_and_or)
select 'roll_chance_slabs_sobrantes', 22, 'ROLL CHANCE', 'ETP-3BLC.003', '##fact_lg_calculo_overrolling_RC_BLC', '''33''', '''ETP-3BLC.003''' , 'insert into @tabla_voces', 'select material_key', 'from ##fact_lg_calculo_overrolling_posible_ovr ovr', 'where ovr.cod_tipo_movimiento in (@cod_tipo_movimiento)', 'and (ovr.pro_norma_desc in (@pro_norma_desc))'

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, subvoces, tabla_voces, cod_tipo_movimiento, cod_cliente, valor_posterior, cond_insert, cond_select, cond_from, cond_where, cond_and_or)
select 'roll_chance', 23, 'ROLL CHANCE', 'CLIENTE 412', '##fact_lg_calculo_overrolling_RC_412', '''33''', '''0000000412''', '''STC'',''STN''', 'insert into @tabla_voces', 'select distinct material_key', 'from ##fact_lg_calculo_overrolling_posible_ovr ovr', 'where ovr.cod_tipo_movimiento in (@cod_tipo_movimiento)', 'and (ovr.cod_cliente in (@cod_cliente) and ovr.valor_posterior in (@valor_posterior))'

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, subvoces, tabla_voces, cod_tipo_movimiento, cod_cliente, valor_posterior, cond_insert, cond_select, cond_from, cond_where, cond_and_or)
select 'roll_chance', 24, 'ROLL CHANCE', 'CLIENTE 410', '##fact_lg_calculo_overrolling_RC_410', '''33''', '''0000000410''', '''STC'',''STN''', 'insert into @tabla_voces', 'select distinct material_key', 'from ##fact_lg_calculo_overrolling_posible_ovr ovr', 'where ovr.cod_tipo_movimiento in (@cod_tipo_movimiento)', 'and (ovr.cod_cliente in (@cod_cliente) and ovr.valor_posterior in (@valor_posterior))'

/*==============================================================================================================================================================================================================================
9) TRANSFERENCIAS DESDE EBX 
Materiales que tienen como estrategia anterior EBX
==============================================================================================================================================================================================================================*/

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, tabla_voces, valor_anterior, cond_insert, cond_select, cond_from, cond_where, cond_and_or)
select 'ebx', 25, 'TRANSFERENCIA DESDE EBX', '##fact_lg_calculo_overrolling_EBX', '''EBX''', 'insert into @tabla_voces', 'select material_key', 'from ges_siderar..fact_lg_movimientos_detalle FMD', 'where valor_anterior in (@valor_anterior)', 'and material_key in (select material_key from ##fact_lg_calculo_overrolling_posible_ovr)'

/*==============================================================================================================================================================================================================================
10) PRUEBAS DE PRODUCTO 
Materiales que tuvieron clave anterior SNADCA en algún momento de su historia
==============================================================================================================================================================================================================================*/

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, tabla_voces, valor_anterior, cond_insert, cond_select, cond_from, cond_where, cond_and_or)
select 'pprod', 26, 'I&D - PRUEBAS DE PRODUCTO', '##fact_lg_calculo_overrolling_PPROD', '''SNADCA''', 'insert into @tabla_voces', 'select material_key', 'from ges_siderar..fact_lg_movimientos_detalle FMD', 'where valor_anterior in (@valor_anterior)', 'and material_key in (select material_key from ##fact_lg_calculo_overrolling_posible_ovr)'

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, tabla_voces, valor_anterior, cond_insert, cond_select, cond_from, cond_where, cond_and_or)
select 'pprod', 27, 'I&D - PRUEBAS DE PRODUCTO', '##fact_lg_calculo_overrolling_PPROD', '''SNADCA''', 'insert into @tabla_voces', 'select material_key', 'from higes_siderar..fact_lg_movimientos_detalle FMD', 'where valor_anterior in (@valor_anterior)', 'and material_key in (select material_key from ##fact_lg_calculo_overrolling_posible_ovr)'

/*==============================================================================================================================================================================================================================
11) Cancelaciones Comerciales: CANC
	Material No Despachado: NDES
	Proyectos: PROY
	Discontinuados: DISC
	(Códigos agregados en campo OBSERVACIONES)
==============================================================================================================================================================================================================================*/

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, tabla_voces, observaciones, cond_insert, cond_select, cond_from, cond_where, cond_and_or)
select 'canc', 28, 'CANCELACIONES COMERCIALES', '##fact_lg_calculo_overrolling_CANC', '''CANC%''', 'insert into @tabla_voces', 'select material_key', 'from ges_siderar..fact_lg_movimientos_cab FMC', 'where observaciones like @observaciones', 'and material_key in (select material_key from ##fact_lg_calculo_overrolling_posible_ovr)'

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, tabla_voces, observaciones, cond_insert, cond_select, cond_from, cond_where, cond_and_or)
select 'ndes', 29, 'MATERIAL NO DESPACHADO', '##fact_lg_calculo_overrolling_NDES', '''NDES%''', 'insert into @tabla_voces', 'select material_key', 'from ges_siderar..fact_lg_movimientos_cab FMC', 'where observaciones like @observaciones', 'and material_key in (select material_key from ##fact_lg_calculo_overrolling_posible_ovr)'

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, tabla_voces, observaciones, cond_insert, cond_select, cond_from, cond_where, cond_and_or)
select 'proy', 30, 'PROYECTOS', '##fact_lg_calculo_overrolling_PROY', '''PROY%''', 'insert into @tabla_voces', 'select material_key', 'from ges_siderar..fact_lg_movimientos_cab FMC', 'where observaciones like  @observaciones', 'and material_key in (select material_key from ##fact_lg_calculo_overrolling_posible_ovr)'

insert into ##fact_lg_calculo_overrolling_cfgvocesovr
(codigo, prioridad_voces, voces, tabla_voces, observaciones, cond_insert, cond_select, cond_from, cond_where, cond_and_or)
select 'disc', 31, 'DISCONTINUADOS', '##fact_lg_calculo_overrolling_DISC', '''DISC%''', 'insert into @tabla_voces', 'select material_key', 'from ges_siderar..fact_lg_movimientos_cab FMC', 'where observaciones like  @observaciones', 'and material_key in (select material_key from ##fact_lg_calculo_overrolling_posible_ovr)'


-- FIN VOCES

-- CREACION DE TABLA ORDEN PRIORIDADES

select *, row_number() over(order by prioridad_voces) orden into ##fact_lg_calculo_overrolling_definicion from ##fact_lg_calculo_overrolling_cfgvocesovr order by prioridad_voces

-- FIN TABLA ORDEN PRIORIDADES

select * from ##fact_lg_Calculo_overrolling_definicion

			-- INICIO VOCES

			-- PROCESO DE INSERT DE MATERIAL_KEY EN LAS TABLAS SEGÚN REGLAS

				set @max_orden_ejecucion = (select max(orden) from ##fact_lg_calculo_overrolling_definicion)

				WHILE @orden_ejecucion <= @max_orden_ejecucion
		
					BEGIN

								SET @SQLQuery =		(select top 1 replace(cond_insert, '@tabla_voces', tabla_voces) + char(13) + cond_select + char(13) + cond_from from ##fact_lg_calculo_overrolling_definicion where orden = @orden_ejecucion) + ' with(nolock)' + char(13)
								SET @SQLQuery +=	(select top 1 isnull(cond_join, '') from ##fact_lg_calculo_overrolling_definicion where orden = @orden_ejecucion) + char(13) 
								SET @SQLQuery +=	(select top 1 replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(cond_where, '@pro_norma_desc', isnull(pro_norma_desc, '')), '@observaciones', isnull(observaciones, '')), '@gale', isnull(gale, '')), '@desc_causa_defecto', isnull(desc_causa_defecto, '')), '@cod_linea_origen', isnull(cod_linea, '')), '@desc_defecto', isnull(desc_defecto, '')), '@cod_clase_doc', isnull(cod_clase_doc, '')), '@calidad_cod', isnull(calidad_cod, '')), '@cod_tipo_movimiento', isnull(cod_tipo_movimiento, '')), '@pro_norma_desc', isnull(pro_norma_desc, '')), '@cod_cliente', isnull(cod_cliente, '')), '@valor_posterior', isnull(valor_posterior, '')), '@pro_subnorma_desc', isnull(pro_subnorma_desc, '')), '@tipo', isnull(tipo, '')), '@clase_cod', isnull(clase_cod, '')), '@pro_cod', isnull(pro_cod, '')), '@cod_motivo_pedido', isnull(cod_motivo_pedido, '')), '@cod_tipo_ofa', isnull(cod_tipo_ofa, '')), '@espesor_valor', isnull(espesor_valor, '')), '@ancho_valor', isnull(ancho_valor, '')), '@cod_grado_acero', isnull(cod_grado_acero, '')), '@marca_logica_calculo', isnull(marca_logica_calculo, '')), '@planta', isnull(planta, '')), '@largo_valor', isnull(largo_valor, '')), '@cod_tipo_calidad', isnull(cod_tipo_calidad, '')), '@cod_linea_imputacion', isnull(cod_linea_imputacion, '')), '@ofa_necesidad', isnull(ofa_necesidad, '')), '@ofadoc_ofapos', isnull(ofadoc_ofapos, '')), '@valor_anterior', isnull(valor_anterior, '')), '@pro_grado_desc', isnull(pro_grado_desc, '')) from ##fact_lg_calculo_overrolling_definicion where orden = @orden_ejecucion) + char(13)
								SET @SQLQuery +=	(select top 1 replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(cond_and_or, ''), '@pro_norma_desc', isnull(pro_norma_desc, '')), '@observaciones', isnull(observaciones, '')), '@gale', isnull(gale, '')), '@desc_causa_defecto', isnull(desc_causa_defecto, '')), '@cod_linea_origen', isnull(cod_linea, '')), '@desc_defecto', isnull(desc_defecto, '')), '@cod_clase_doc', isnull(cod_clase_doc, '')), '@calidad_cod', isnull(calidad_cod, '')), '@cod_tipo_movimiento', isnull(cod_tipo_movimiento, '')), '@pro_norma_desc', isnull(pro_norma_desc, '')), '@cod_cliente', isnull(cod_cliente, '')), '@valor_posterior', isnull(valor_posterior, '')), '@pro_subnorma_desc', isnull(pro_subnorma_desc, '')), '@tipo', isnull(tipo, '')), '@clase_cod', isnull(clase_cod, '')), '@pro_cod', isnull(pro_cod, '')), '@cod_motivo_pedido', isnull(cod_motivo_pedido, '')), '@cod_tipo_ofa', isnull(cod_tipo_ofa, '')), '@espesor_valor', isnull(espesor_valor, '')), '@ancho_valor', isnull(ancho_valor, '')), '@cod_grado_acero', isnull(cod_grado_acero, '')), '@marca_logica_calculo', isnull(marca_logica_calculo, '')), '@planta', isnull(planta, '')), '@largo_valor', isnull(largo_valor, '')), '@cod_tipo_calidad', isnull(cod_tipo_calidad, '')), '@cod_linea_imputacion', isnull(cod_linea_imputacion, '')), '@ofa_necesidad', isnull(ofa_necesidad, '')), '@ofadoc_ofapos', isnull(ofadoc_ofapos, '')), '@valor_anterior', isnull(valor_anterior, '')), '@pro_grado_desc', isnull(pro_grado_desc, '')) from ##fact_lg_calculo_overrolling_definicion where orden = @orden_ejecucion) + char(13)


								PRINT (@SQLQuery)
					
								SET @orden_ejecucion += 1
		
					END

			-- FIN PROCESO DE INSERTS

			-- PROCESO DE UPDATE EN LA TABLA #POSIBLE_OVR SEGUN MATERIAL_KEY INSERTADO ARRIBA

				SET @orden_ejecucion = 1
				SET @max_orden_ejecucion = (select max(prioridad_voces) from ##fact_lg_calculo_overrolling_cfgvocesovr)

				WHILE @orden_ejecucion <= @max_orden_ejecucion

					BEGIN

								SET @SQLQuery =		'UPDATE ovr set voz = '
								SET @SQLQuery +=	'''' + (select top 1 voces from ##fact_lg_calculo_overrolling_definicion where prioridad_voces = @orden_ejecucion) + '''' 
								SET @SQLQuery +=	', subvoz = ' + '''' + (select top 1 isnull(subvoces, '') from ##fact_lg_calculo_overrolling_definicion where prioridad_voces = @orden_ejecucion) + '''' + char(13)
								SET @SQLQuery +=	'from ##fact_lg_calculo_overrolling_posible_ovr ovr' + char(13) + 'where ovr.material_key in (select material_key from '
								SET @SQLQuery +=	(select top 1 tabla_voces from ##fact_lg_calculo_overrolling_cfgvocesovr where prioridad_voces = @orden_ejecucion) + ')' + char(13)

								PRINT (@SQLQuery)

							/*	SET @SQLQuery =		'UPDATE padresovr set voz = '
								SET @SQLQuery +=	'''' + (select top 1 voces from ##fact_lg_calculo_overrolling_cfgvocesovr where prioridad_voces = @orden_ejecucion) + '''' 
								SET @SQLQuery +=	', subvoz = ' + '''' + (select top 1 isnull(subvoces, '') from ##fact_lg_calculo_overrolling_definicion where prioridad_voces = @orden_ejecucion) + '''' + char(13)
								SET @SQLQuery +=	'from ##fact_lg_calculo_overrolling_padres_marca_ovr padresovr' + char(13) + 'where padresovr.material_key in (select material_key from '
								SET @SQLQuery +=	(select top 1 tabla_voces from ##fact_lg_calculo_overrolling_definicion where prioridad_voces = @orden_ejecucion) + ')' + char(13)

								PRINT (@SQLQuery)*/

								SET @orden_ejecucion += 1

					END
/*
-------------------------------------------------------------------------------------------------------------------------------------------------------
create table ##fact_lg_calculo_overrolling_posible_ovr (id_movimiento int, material_key int, cod_tipo_movimiento varchar(5), desc_tipo_movimiento varchar(50), variable_cod varchar(100),
valor_anterior varchar(100), valor_posterior varchar(100), Fecha_Movimiento DATETIME, o int, cod_cliente varchar(10), pro_norma_desc varchar(50),
cod_clase_doc varchar(4), pro_grado_desc varchar(50), pro_subnorma_desc varchar(50), clase_cod varchar(22), espesor_valor decimal,
ancho_valor numeric, largo_valor decimal, cod_grado_acero varchar(16), cod_tipo_calidad varchar(20), cod_tipo_ofa varchar(10),
Planta varchar(20), tipo varchar(20), ofa_documento varchar(10), ofa_posicion varchar(6), marca_logica_calculo varchar(20), cod_linea varchar(10),
ofa_necesidad varchar(12), desc_tipo_calidad varchar(80), Estado_Caida_Codigo varchar(2), pro_cod varchar(9), cod_motivo_pedido varchar(3),
cod_linea_imputacion varchar(10), fact_lg_movimientos_cab_key int, peso_neto float, desc_defecto varchar(50), calidad_cod varchar(50), nro_bulto varchar(50),
gale varchar(200), desc_causa_defecto varchar(200), cod_calidad varchar(100), observaciones varchar(1000), voz varchar(50), subvoz varchar(50), fecha_marca_ovr DATETIME)

create table ##fact_lg_calculo_overrolling_recuperos_ovr (id_movimiento int, material_key int, cod_tipo_movimiento varchar(5), desc_tipo_movimiento varchar(50), variable_cod varchar(100),
valor_anterior varchar(100), valor_posterior varchar(100), Fecha_Movimiento DATETIME, o bigint, cod_cliente varchar(10), pro_norma_desc varchar(50),
cod_clase_doc varchar(4), pro_grado_desc varchar(50), pro_subnorma_desc varchar(50), clase_cod varchar(22), espesor_valor decimal,
ancho_valor numeric, largo_valor decimal, cod_grado_acero varchar(16), cod_tipo_calidad varchar(20), cod_tipo_ofa varchar(10),
Planta varchar(20), tipo varchar(20), ofa_documento varchar(10), ofa_posicion varchar(6), marca_logica_calculo varchar(20), cod_linea varchar(10),
ofa_necesidad varchar(12), desc_tipo_calidad varchar(80), pro_cod varchar(9), cod_motivo_pedido varchar(3),
cod_linea_imputacion varchar(10), fact_lg_movimientos_cab_key int, peso_neto float, desc_defecto varchar(50), calidad_cod varchar(50), nro_bulto varchar(50),
gale varchar(200), desc_causa_defecto varchar(200), cod_calidad varchar(100), observaciones varchar(1000))
*/