USE [GES_Siderar]
GO
 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [dbo].[ges_bch_lg_calculo_overrolling]

@FechaIni DATETIME = NULL,
@FechaFin DATETIME = NULL

AS
BEGIN

	BEGIN TRY

		BEGIN TRANSACTION

			DECLARE
			@Errores VARCHAR(200),
			@ErrDesc VARCHAR(2000), 
			@Text_Err VARCHAR(200),
			@Log_Id bigint,
			@SQLQuery VARCHAR(4000),
			@orden_ejecucion int = 1, 
			@max_orden_ejecucion int


			EXEC st_siderar..Audit_IniLog_Industrial	@Dominio = 'PROCESO_CALCULO_OVERROLLING', 
														@Tipo_Proceso = 'BATCH', 
														@Origen = 'DWH', 
														@BTS_ID = '', 
														@LogId = @Log_id OUTPUT, 
														@extendido = 1

			IF @FechaIni is null SET @FechaIni = getdate()
			IF @FechaIni is not null SET @FechaIni = (select max(fecha_hora_ini) from ST_Siderar..log_auditoria_Industrial LA where LA.proceso = 'PROCESO_CALCULO_OVERROLLING')
			SET @FechaFin = GETDATE()


			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_Materiales') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_Materiales
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_tmp') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_tmp
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_EXPWEB') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_EXPWEB
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_EXPSNDWEBMTO') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_EXPSNDWEBMTO
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_TMPDEFAULT') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_TMPDEFAULT
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_SNDWEBX2WEBMTO') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_SNDWEBX2WEBMTO
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_NULLEXPX2') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_NULLEXPX2
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_RECUEBXCHT') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_RECUEBXCHT
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_RESULT_1') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_RESULT_1
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_ROLLCHANCE_ESP') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_ROLLCHANCE_ESP
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_COBBLES') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_COBBLES
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_TPO') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_TPO
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_CONFORMADOS') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_CONFORMADOS
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_FUERADEGRILLA') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_FUERADEGRILLA
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_TIRAENHEBRADO') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_TIRAENHEBRADO
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_BOBINATRAN') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_BOBINATRAN
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_ARRANQUEEST') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_ARRANQUEEST
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_ARRANQUELAC') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_ARRANQUELAC
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_DC') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_DC
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_EXCEDFAB') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_EXCEDFAB
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_DEVCLIENTES') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_DEVCLIENTES
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_EBX') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_EBX
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_PPROD') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_PPROD
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_default_ovr') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_default_ovr
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_padre_hijo') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_padre_hijo
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_posible_ovr') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_posible_ovr
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_padres_marca_ovr') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_padres_marca_ovr
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_COMERCIAL') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_COMERCIAL
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_SUPPLY') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_SUPPLY
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_AJUSTEINV') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_AJUSTEINV
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_IVANAR') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_IVANAR
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_TRAN_SUPPLY') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_TRAN_SUPPLY
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_CANC') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_CANC
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_NDES') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_NDES
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_PROY') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_PROY
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_DISC') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_DISC
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_RC_BLC') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_RC_BLC
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_RC_CHILE_ETP') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_RC_CHILE_ETP
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_RC_N05') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_RC_N05
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_RC_CHILE_COMERCIAL') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_RC_CHILE_COMERCIAL
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_RC_410') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_RC_410
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_RC_412') IS NOT NULL DROP TABLE ##fact_lg_calculo_overrolling_RC_412


			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_COBBLES') IS NULL CREATE TABLE ##fact_lg_calculo_overrolling_COBBLES (material_key int)
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_TPO') IS NULL CREATE TABLE ##fact_lg_calculo_overrolling_TPO (material_key int)
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_CONFORMADOS') IS NULL CREATE TABLE ##fact_lg_calculo_overrolling_CONFORMADOS (material_key int)
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_FUERADEGRILLA') IS NULL CREATE TABLE ##fact_lg_calculo_overrolling_FUERADEGRILLA (material_key int)
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_TIRAENHEBRADO') IS NULL CREATE TABLE ##fact_lg_calculo_overrolling_TIRAENHEBRADO (material_key int)
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_BOBINATRAN') IS NULL CREATE TABLE ##fact_lg_calculo_overrolling_BOBINATRAN (material_key int)
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_ARRANQUEEST') IS NULL CREATE TABLE ##fact_lg_calculo_overrolling_ARRANQUEEST (material_key int)
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_ARRANQUELAC') IS NULL CREATE TABLE ##fact_lg_calculo_overrolling_ARRANQUELAC (material_key int)
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_DC') IS NULL CREATE TABLE ##fact_lg_calculo_overrolling_DC (material_key int)
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_EXCEDFAB') IS NULL CREATE TABLE ##fact_lg_calculo_overrolling_EXCEDFAB (material_key int)
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_DEVCLIENTES') IS NULL CREATE TABLE ##fact_lg_calculo_overrolling_DEVCLIENTES (material_key int)
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_COMERCIAL') IS NULL CREATE TABLE ##fact_lg_calculo_overrolling_COMERCIAL (material_key int)
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_SUPPLY') IS NULL CREATE TABLE ##fact_lg_calculo_overrolling_SUPPLY (material_key int)
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_AJUSTEINV') IS NULL CREATE TABLE ##fact_lg_calculo_overrolling_AJUSTEINV (material_key int)
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_EBX') IS NULL CREATE TABLE ##fact_lg_calculo_overrolling_EBX (material_key int)
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_PPROD') IS NULL CREATE TABLE ##fact_lg_calculo_overrolling_PPROD (material_key int)
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_IVANAR') IS NULL CREATE TABLE ##fact_lg_calculo_overrolling_IVANAR (material_key int)
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_TRAN_SUPPLY') IS NULL CREATE TABLE ##fact_lg_calculo_overrolling_TRAN_SUPPLY (material_key int)
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_CANC') IS NULL CREATE TABLE ##fact_lg_calculo_overrolling_CANC (material_key int)
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_NDES') IS  NULL CREATE TABLE ##fact_lg_calculo_overrolling_NDES (material_key int)
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_PROY') IS NULL CREATE TABLE ##fact_lg_calculo_overrolling_PROY (material_key int)
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_DISC') IS NULL CREATE TABLE ##fact_lg_calculo_overrolling_DISC (material_key int)
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_RC_BLC') IS NULL CREATE TABLE ##fact_lg_calculo_overrolling_RC_BLC (material_key int)
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_RC_CHILE_ETP') IS NULL CREATE TABLE ##fact_lg_calculo_overrolling_RC_CHILE_ETP (material_key int)
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_RC_N05') IS NULL CREATE TABLE ##fact_lg_calculo_overrolling_RC_N05 (material_key int)
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_RC_CHILE_COMERCIAL') IS NULL CREATE TABLE ##fact_lg_calculo_overrolling_RC_CHILE_COMERCIAL (material_key int)
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_RC_410') IS NULL CREATE TABLE ##fact_lg_calculo_overrolling_RC_410 (material_key int)
			IF OBJECT_ID('tempdb..##fact_lg_calculo_overrolling_RC_412') IS NULL CREATE TABLE ##fact_lg_calculo_overrolling_RC_412 (material_key int)

			SELECT DISTINCT Material_key
			INTO ##fact_lg_calculo_overrolling_Materiales
			FROM GES_Siderar..fact_LG_movimientos_cab WITH(nolock) 
			WHERE fecha_movimiento BETWEEN @FechaIni AND @FechaFin

			select distinct INICIO.id_movimiento,INICIO.material_key, INICIO.Cod_Tipo_Movimiento, INICIO.Desc_Tipo_Movimiento, INICIO.Variable_Cod, INICIO.valor_anterior, INICIO.valor_posterior, INICIO.Fecha_Movimiento,
			row_number() over (
							   partition by INICIO.material_key
								   order by INICIO.Fecha_Movimiento asc) as O,
			INICIO.cod_cliente, INICIO.pro_norma_desc, INICIO.cod_clase_doc, INICIO.pro_grado_desc, INICIO.pro_subnorma_desc, INICIO.Clase_cod,
			INICIO.espesor_valor, INICIO.ancho_Valor, INICIO.largo_valor, INICIO.cod_grado_acero, INICIO.cod_tipo_calidad, INICIO.cod_tipo_ofa,
			INICIO.planta, INICIO.tipo, INICIO.ofa_documento, INICIO.ofa_posicion, INICIO.marca_logica_Calculo, INICIO.cod_linea, INICIO.ofa_necesidad,
			INICIO.desc_tipo_calidad, INICIO.pro_cod, INICIO.cod_motivo_pedido, INICIO.cod_linea_imputacion,
			INICIO.fact_lg_movimientos_cab_key, INICIO.peso_neto, INICIO.desc_defecto, INICIO.calidad_cod, INICIO.nro_bulto, INICIO.GALE,
			INICIO.desc_causa_defecto, INICIO.cod_calidad, INICIO.observaciones
			into ##fact_lg_calculo_overrolling_tmp from
			(
			(select distinct fmc.id_movimiento,fmc.material_key, DTM.Cod_Tipo_Movimiento, DTM.Desc_Tipo_Movimiento, DV.Variable_Cod, 
			FMD.valor_anterior, FMD.valor_posterior, FMC.Fecha_Movimiento, OFA.cod_cliente, C.pro_norma_desc, v.cod_clase_doc, 
			C.pro_grado_desc, C.pro_subnorma_desc, C.Clase_cod, MED.espesor_valor, MED.ancho_valor, MED.largo_valor, GRAC.cod_grado_acero, 
			OFACALIDAD.cod_tipo_calidad, TIPOOFA.cod_tipo_ofa, UBIC.Planta, DM.tipo, OFA.ofa_documento, OFA.ofa_posicion, DICT.marca_logica_calculo,
			DL.cod_linea, OFA.ofa_necesidad, OFACALIDAD.desc_tipo_calidad, C.pro_cod, V.cod_motivo_pedido, DL1.cod_linea cod_linea_imputacion
			,FMC.fact_lg_movimientos_cab_key, A.peso_neto, DEF1.desc_defecto, CALI.calidad_cod, DB.nro_bulto, OFRE.GALE, 
			DEF1.desc_causa_defecto, DLC.cod_calidad, FMC.observaciones
			FROM GES_Siderar..fact_LG_movimientos_cab FMC WITH(nolock)
			INNER JOIN GES_Siderar..fact_lg_movimientos_detalle FMD WITH(nolock) ON FMC.id_movimiento = FMD.Id_Movimiento
			inner join ##fact_lg_calculo_overrolling_Materiales m with(nolock) on fmc.material_key = m.material_key
			left join ges_siderar..fact_LG_bultos_Stk_hist A with(nolock) on A.material_key = fmc.material_key
			left join ges_siderar..dim_linea DL with(nolock) on DL.linea_key = A.linea_origen_key
			left join ges_siderar..dim_clientes B with(nolock) on A.Dim_APT_Cliente_key =B.cliente_key
			left join ges_siderar..dim_producto_pro C with(nolock) on A.dim_producto_key=C.dim_producto_pro_key
			left join ges_siderar..dim_documento_venta D with(nolock) on CAST(D.nro_documento as varchar) + '0000' + cast(D.nro_posicion as varchar) = cast(A.apt_clave as varchar)
			left join
			(select A.doc_venta_key, A.Reparto_key, A.tipo_venta_key, C.cod_clase_doc, D.cod_motivo_pedido from ges_siderar..fact_pedidos A with(nolock) 
			LEFT JOIN GES_Siderar..dim_motivo_pedido D with(nolock) ON A.dim_motivo_pedido_key = D.dim_motivo_pedido_key
			left join ges_siderar..dim_repartos B with(nolock) on A.reparto_key =B.reparto_key
			left join ges_siderar..dim_clases_documento C with(nolock) on A.clase_documento_key =c.clase_documento_key
			where B.nro_reparto =0) V on A.Dim_APT_Doc_Venta_key=V.doc_venta_key
			left join ges_siderar..dim_repartos REP with(nolock) on V.reparto_key = REP.reparto_key 
			left join ges_siderar..dim_calidad CALI with(nolock) on V.tipo_venta_key= CALI.calidad_key			left join ges_siderar..dim_lg_calidad DLC with(nolock) on DLC.calidad_key = A.dim_lg_calidad_key
			LEFT JOIN (select material_key, max(defecto_key) defecto_key from ges_siderar..fact_lg_bultos_prod with(nolock) group by material_key)
			as BP on BP.material_key = A.material_key 
			LEFT JOIN ges_siderar..fact_lg_bultos_prod P on P.defecto_key = BP.defecto_key and P.material_key = BP.material_key
			LEFT JOIN GES_SIDERAR..dim_ofa OFA with(nolock) on OFA.nro_ofa_key = P.nro_ofa_key
			LEFT JOIN  GES_SIDERAR..fact_ofa FOFA with(nolock) on fofa.nro_ofa_key = OFA.nro_ofa_key
			LEFT JOIN  GES_SIDERAR..dim_ofa_tipo TIPOOFA with(nolock) on TIPOOFA.tipo_ofa_key = FOFA.tipo_ofa_key 
			LEFT JOIN  GES_SIDERAR..dim_OFA_Tipo_Calidad OFACALIDAD  with(nolock) on OFACALIDAD.dim_OFA_Tipo_Calidad_key=FOFA.Tipo_calidad_key
			LEFT JOIN GES_Siderar..dim_lg_ubicacion UBIC with(nolock) on UBIC.ubicacion_key = A.ubicacion_key	
			LEFT JOIN GES_SIDERAR..dim_grado_acero GRAC with(nolock) on GRAC.grado_acero_key = A.grado_acero_key
			LEFT JOIN GES_SIDERAR..dim_medida_basica MED with(nolock) on MED.dim_medida_basica_key = A.dim_medida_basica_key
			left join (select material_key, max(fecha_caida_key) fecha_caida_key,  max(linea_imputacion_key) linea_imputacion_key from ges_siderar..fact_lg_dictamen_Caidas with(nolock) 
			group by material_key) as DICT1 on DICT1.material_key = FMC.material_key
			INNER JOIN GES_Siderar..dim_materiales DM with(nolock) ON FMC.material_key = DM.material_key
			INNER JOIN GES_Siderar..dim_lg_bultos DB with(nolock) ON DM.bulto_lg_key = DB.bulto_lg_key
			left join (select nro_bulto, max(lg_defecto_key) lg_defecto_key from ges_siderar..dim_lg_defectos with(nolock) group by nro_bulto) as DEF on DEF.nro_bulto = DB.nro_bulto
			left join ges_siderar..dim_lg_defectos DEF1 with(nolock) on DEF1.lg_defecto_key = DEF.lg_defecto_key and DEF1.nro_bulto = DEF.nro_bulto
			LEFT JOIN ges_siderar..dim_linea DL1 with(nolock) on DL1.linea_key = DICT1.linea_imputacion_key
			left join GES_Siderar..fact_lg_dictamen_caidas DICT with (nolock) on DICT.fecha_caida_key = DICT1.fecha_caida_key and DICT.material_key = DICT1.material_key 
			INNER JOIN GES_Siderar..dim_lg_tipo_movimiento DTM with(nolock) ON FMC.tipo_movimiento_key = DTM.tipo_movimiento_key
			LEFT JOIN GES_Siderar..dim_lg_variables_stk DV with(nolock) ON FMD.dim_lg_variables_stk_key = DV.dim_lg_variables_stk_key
			left join ges_siderar.dbo.dim_ofrecimiento ofre (nolock) ON FOFA.ofrecimiento_key = ofre.dim_ofrecimiento_key
			where 1=1
			and DV.variable_cod = 'id_tipo_estrategia'
			AND DTM.Cod_tipo_movimiento IN ('33', '148', '154', '235', '338')
			and (FMD.valor_posterior IN ('OVR', 'OVE', 'EXP', 'WEB', 'EOV') or FMD.valor_anterior IN ('OVR', 'OVE', 'EXP', 'WEB', 'EOV'))
			--Roll Chance Slabs sobrantes
			or (V.cod_motivo_pedido = 'N05')
			-- Roll Chance Chile
			or ((V.cod_clase_doc = 'ZNPE' and calidad_cod = 'RC')
			and (FMD.valor_posterior NOT IN ('OVR', 'OVE', 'EXP', 'WEB', 'EOV') or FMD.valor_anterior NOT IN ('OVR', 'OVE', 'EXP', 'WEB', 'EOV')))
			-- Roll Chance STC, STN
			or (FMD.valor_posterior IN ('STC', 'STN') and DTM.cod_tipo_movimiento = '33' and OFA.cod_cliente in ('0000000410', '0000000412'))			
			-- Vuelta de CHT, EBX, o I&D Pruebas de producto
			or (FMD.valor_posterior IN ('OVR', 'OVE', 'WEB', 'EOV') and FMD.valor_anterior IN ('EBX')) 
			
			)

			union

			(SELECT distinct fmc.id_movimiento,fmc.material_key, DTM.Cod_Tipo_Movimiento, DTM.Desc_Tipo_Movimiento, DV.Variable_Cod, 
			FMD.valor_anterior, FMD.valor_posterior, FMC.Fecha_Movimiento,	OFA.cod_cliente, C.pro_norma_desc, v.cod_clase_doc, 
			C.pro_grado_desc, C.pro_subnorma_desc, C.Clase_cod, MED.espesor_valor, MED.ancho_valor, MED.largo_valor, GRAC.cod_grado_acero, 
			OFACALIDAD.cod_tipo_calidad, TIPOOFA.cod_tipo_ofa, UBIC.Planta, DM.tipo, OFA.ofa_documento, OFA.ofa_posicion, DICT.marca_logica_calculo,
			DL.cod_linea, OFA.ofa_necesidad, OFACALIDAD.desc_tipo_calidad, C.pro_cod, V.cod_motivo_pedido, DL1.cod_linea cod_linea_imputacion
			,FMC.fact_lg_movimientos_cab_key, A.peso_neto, DEF1.desc_defecto, CALI.calidad_cod, DB.nro_bulto, OFRE.GALE, 
			DEF1.desc_causa_defecto, DLC.cod_calidad, FMC.observaciones
			FROM hiGES_Siderar..fact_LG_movimientos_cab FMC WITH(nolock)
			LEFT JOIN hiGES_Siderar..fact_lg_movimientos_detalle FMD WITH(nolock) ON FMC.id_movimiento = FMD.Id_Movimiento
			inner join ##fact_lg_calculo_overrolling_Materiales m with(nolock) on fmc.material_key = m.material_key
			left join ges_siderar..fact_LG_bultos_Stk_hist A with(nolock) on A.material_key = fmc.material_key
			left join ges_siderar..dim_linea DL with(nolock) on DL.linea_key = A.linea_origen_key
			left join ges_siderar..dim_clientes B with(nolock) on A.Dim_APT_Cliente_key =B.cliente_key
			left join ges_siderar..dim_producto_pro C with(nolock) on A.dim_producto_key=C.dim_producto_pro_key
			left join ges_siderar..dim_documento_venta D with(nolock) on CAST(D.nro_documento as varchar) + '0000' + cast(D.nro_posicion as varchar) = cast(A.apt_clave as varchar)
			left join
			(select A.doc_venta_key, A.Reparto_key, A.tipo_venta_key, C.cod_clase_doc, D.cod_motivo_pedido from ges_siderar..fact_pedidos A with(nolock) 
			LEFT JOIN GES_Siderar..dim_motivo_pedido D with(nolock) ON A.dim_motivo_pedido_key = D.dim_motivo_pedido_key
			left join ges_siderar..dim_repartos B with(nolock) on A.reparto_key =B.reparto_key
			left join ges_siderar..dim_clases_documento C with(nolock) on A.clase_documento_key =c.clase_documento_key
			where B.nro_reparto =0) V on A.Dim_APT_Doc_Venta_key=V.doc_venta_key
			left join ges_siderar..dim_repartos REP with(nolock) on V.reparto_key = REP.reparto_key 
			left join ges_siderar..dim_calidad CALI with(nolock) on V.tipo_venta_key= CALI.calidad_key
			left join ges_siderar..dim_lg_calidad DLC with(nolock) on DLC.calidad_key = A.dim_lg_calidad_key
			INNER JOIN GES_Siderar..dim_lg_tipo_movimiento DTM with(nolock) ON FMC.tipo_movimiento_key = DTM.tipo_movimiento_key
			LEFT JOIN GES_Siderar..dim_lg_variables_stk DV with(nolock) ON FMD.dim_lg_variables_stk_key = DV.dim_lg_variables_stk_key
			INNER JOIN GES_Siderar..dim_materiales DM with(nolock) ON FMC.material_key = DM.material_key
			INNER JOIN GES_Siderar..dim_lg_bultos DB with(nolock) ON DM.bulto_lg_key = DB.bulto_lg_key
			LEFT JOIN (select material_key, max(defecto_key) defecto_key from ges_siderar..fact_lg_bultos_prod with(nolock) group by material_key)
			as BP on BP.material_key = A.material_key 
			LEFT JOIN ges_siderar..fact_lg_bultos_prod P on P.defecto_key = BP.defecto_key and P.material_key = BP.material_key
			LEFT JOIN GES_SIDERAR..dim_ofa OFA with(nolock) on OFA.nro_ofa_key = P.nro_ofa_key
			LEFT JOIN  GES_SIDERAR..fact_ofa FOFA with(nolock) on fofa.nro_ofa_key = OFA.nro_ofa_key
			LEFT JOIN  GES_SIDERAR..dim_ofa_tipo TIPOOFA with(nolock) on TIPOOFA.tipo_ofa_key = FOFA.tipo_ofa_key 
			LEFT JOIN  GES_SIDERAR..dim_OFA_Tipo_Calidad OFACALIDAD  with(nolock) on OFACALIDAD.dim_OFA_Tipo_Calidad_key=FOFA.Tipo_calidad_key
			LEFT JOIN GES_Siderar..dim_lg_ubicacion UBIC with(nolock) on UBIC.ubicacion_key = A.ubicacion_key	
			LEFT JOIN GES_SIDERAR..dim_grado_acero GRAC with(nolock) on GRAC.grado_acero_key = A.grado_acero_key
			LEFT JOIN GES_SIDERAR..dim_medida_basica MED with(nolock) on MED.dim_medida_basica_key = A.dim_medida_basica_key
			left join (select material_key, max(fecha_caida_key) fecha_caida_key,  max(linea_imputacion_key) linea_imputacion_key from ges_siderar..fact_lg_dictamen_Caidas
			group by material_key) as DICT1 on DICT1.material_key = FMC.material_key
			left join (select nro_bulto, max(lg_defecto_key) lg_defecto_key from ges_siderar..dim_lg_defectos with(nolock) group by nro_bulto) as DEF on DEF.nro_bulto = DB.nro_bulto
			left join ges_siderar..dim_lg_defectos DEF1 with(nolock) on DEF1.lg_defecto_key = DEF.lg_defecto_key and DEF1.nro_bulto = DEF.nro_bulto
			LEFT JOIN ges_siderar..dim_linea DL1 with(nolock) on DL1.linea_key = DICT1.linea_imputacion_key
			left join GES_Siderar..fact_lg_dictamen_caidas DICT with (nolock) on DICT.fecha_caida_key = DICT1.fecha_caida_key and DICT.material_key = DICT1.material_key
			left join ges_siderar.dbo.dim_ofrecimiento ofre (nolock) ON FOFA.ofrecimiento_key = ofre.dim_ofrecimiento_key
			where 1=1
			and DV.variable_cod = 'id_tipo_estrategia'
			AND DTM.Cod_tipo_movimiento IN ('33', '148', '154', '235', '338')
			and (FMD.valor_posterior IN ('OVR', 'OVE', 'EXP', 'WEB', 'EOV') or FMD.valor_anterior IN ('OVR', 'OVE', 'EXP', 'WEB', 'EOV'))
			--Roll Chance Slabs sobrantes
			or (V.cod_motivo_pedido = 'N05')
			-- Roll Chance Chile
			or ((V.cod_clase_doc = 'ZNPE' and calidad_cod = 'RC')
			and (FMD.valor_posterior NOT IN ('OVR', 'OVE', 'EXP', 'WEB', 'EOV') or FMD.valor_anterior NOT IN ('OVR', 'OVE', 'EXP', 'WEB', 'EOV')))
			-- Roll Chance STC, STN
			or (FMD.valor_posterior IN ('STC', 'STN') and DTM.cod_tipo_movimiento = '33' and OFA.cod_cliente in ('0000000410', '0000000412'))
			-- Vuelta de CHT, EBX, o I&D Pruebas de producto
			or (FMD.valor_posterior IN ('OVR', 'OVE', 'WEB', 'EOV') and FMD.valor_anterior IN ('EBX')) 

			)
			) as INICIO

			--OVR si ''-EXP --> EXP-WEB (se debe tomar el último movimiento EXP-WEB)
			select max(id_movimiento) id_movimiento, material_key,max(cod_tipo_movimiento) cod_tipo_movimiento,max(desc_tipo_movimiento) desc_tipo_movimiento,
			max(variable_cod) variable_cod,max(valor_anterior) valor_anterior,max(valor_posterior) valor_posterior,max(fecha_movimiento) fecha_movimiento,
			max(o) o, max(cod_cliente) cod_cliente, max(pro_norma_desc) pro_norma_desc, max(cod_clase_doc) cod_clase_doc, max(pro_grado_desc) pro_grado_desc, 
			max(pro_subnorma_desc) pro_subnorma_desc, max(clase_cod) clase_cod, max(espesor_valor) espesor_Valor, max(ancho_valor) ancho_valor,
			max(largo_valor) largo_valor, max(cod_grado_acero) cod_grado_acero, max(cod_tipo_Calidad) cod_tipo_calidad, max(cod_tipo_ofa) cod_tipo_ofa,
			max(planta) planta, max(tipo) tipo, max(ofa_documento) ofa_documento, max(ofa_posicion) ofa_posicion, max(marca_logica_Calculo) marca_logica_calculo,
			max(cod_linea) cod_linea, max(ofa_necesidad) ofa_necesidad, max(desc_tipo_calidad) desc_tipo_calidad,
			max(pro_cod) pro_cod, max(cod_motivo_pedido) cod_motivo_pedido, max(cod_linea_imputacion) cod_linea_imputacion, max(fact_lg_movimientos_cab_key) fact_lg_movimientos_cab_key,
			max(peso_neto) peso_neto, max(desc_defecto) desc_defecto, max(calidad_cod) calidad_cod, 
			max(nro_bulto) nro_bulto, max(gale) gale, max(desc_causa_defecto) desc_causa_defecto, max(cod_calidad) cod_calidad,
			max(observaciones) observaciones
			

			into ##fact_lg_calculo_overrolling_EXPWEB
			from ##fact_lg_calculo_overrolling_tmp t1 with(nolock) 
			where (valor_anterior = '' and valor_posterior = 'EXP' or valor_anterior = 'EXP' and valor_posterior = 'WEB')
			and o > 1
			group by material_key

			--Casos en los que son ''-EXP --> SND-WEB --> WEB-MTO --> Se debe tomar el SND_WEB
			select t2.*
			into ##fact_lg_calculo_overrolling_EXPSNDWEBMTO
			from ##fact_lg_calculo_overrolling_tmp t1 with(nolock)
			inner join ##fact_lg_calculo_overrolling_tmp t2 on t1.material_key = t2.material_key and 
									t1.valor_anterior = '' and t1.valor_posterior = 'EXP' and t1.o = 1 and
									t2.o = 2 and
									t2.valor_anterior = 'SND' and t2.valor_posterior = 'WEB'
			inner join ##fact_lg_calculo_overrolling_tmp t3 on t2.material_key = t3.material_key and 
									t2.valor_anterior = 'SND' and t2.valor_posterior = 'WEB' and
									t2.valor_posterior = t3.valor_anterior and 
									t3.valor_anterior = 'WEB' and t3.valor_posterior = 'MTO'

			--Casos en los que son ''-EXP --> ''-EXP --> Se debe tomar el primer movimiento 
			select t1.* 
			into ##fact_lg_calculo_overrolling_NULLEXPX2
			from ##fact_lg_calculo_overrolling_tmp t1 with(nolock)
			inner join ##fact_lg_calculo_overrolling_tmp t2 on t1.material_key = t2.material_key and 
									t1.valor_anterior = '' and t1.valor_posterior = 'EXP' and t1.o = 1 and
									t2.valor_anterior = '' and t2.valor_posterior = 'EXP' and t2.o = 2

			--Si encuentro el mismo material_key de la ##fact_lg_calculo_overrolling_NULLEXPX2 en la ##fact_lg_calculo_overrolling_result_1 debo eliminar de la ##fact_lg_calculo_overrolling_EXPWEB para no duplicar
			delete from ##fact_lg_calculo_overrolling_EXPWEB where material_key in (select material_key from ##fact_lg_calculo_overrolling_NULLEXPX2)

			--Creación de ROLLCHANCE_ESP, para que los especiales no pisen a los genuinos
			select t2.*
			into ##fact_lg_calculo_overrolling_ROLLCHANCE_ESP
			from ##fact_lg_calculo_overrolling_tmp t1 with(nolock)
			inner join ##fact_lg_calculo_overrolling_tmp t2 on t1.material_key = t2.material_key and
									t1.cod_clase_doc = 'ZNPE' and t1.calidad_cod = 'RC' and t1.o = 1
									and t2.variable_cod = 'id_tipo_estrategia'
									AND t2.Cod_tipo_movimiento IN ('33', '148', '154', '235', '338')
									and (t2.valor_posterior IN ('OVR', 'OVE', 'EXP', 'WEB', 'EOV') or t2.valor_anterior IN ('OVR', 'OVE', 'EXP', 'WEB', 'EOV'))

			-- Selecciono casos ESTRATEGIA OVR - EBX O CHT, ya que no son OVR
			select t1.*
			into [GES_Siderar].DBO.[fact_lg_calculo_overrolling_recupero]
			from ##fact_lg_calculo_overrolling_tmp t1
			inner join ##fact_lg_calculo_overrolling_tmp t2 on t1.material_key = t2.material_key and
									t1.valor_posterior IN ('OVR', 'OVE', 'EXP', 'WEB', 'EOV') and t1.o = 1 and
									t2.valor_anterior IN ('OVR', 'OVE', 'EXP', 'WEB', 'EOV') and (t2.valor_posterior = 'EBX' or t2.valor_posterior = 'CHT') 
									and t2.o > 1
									and t2.fecha_movimiento BETWEEN @FechaIni AND @FechaFin

			insert into [GES_siderar].DBO.[fact_lg_calculo_overrolling_recupero]
			select * from ##fact_lg_calculo_overrolling_RECUEBXCHT recu

			-- Elimino casos OVE - EBX de tmp
			delete t from ##fact_lg_calculo_overrolling_tmp t
			inner join ##fact_lg_calculo_overrolling_RECUEBXCHT r on r.material_key = t.material_key

			--Elimino de la ##fact_lg_calculo_overrolling_tmp aquellos que vengan de ''-EXP --> SND-WEB --> WEB-MTO
			delete t
			from ##fact_lg_calculo_overrolling_tmp t 
			inner join ##fact_lg_calculo_overrolling_EXPSNDWEBMTO r with(nolock) on t.material_key = r.material_key

			--Elimino de la ##fact_lg_calculo_overrolling_tmp a quellos que vengan de ''-EXP --> EXP-WEB
			delete t
			from ##fact_lg_calculo_overrolling_tmp t
			inner join ##fact_lg_calculo_overrolling_EXPWEB r with(nolock) on t.material_key = r.material_key
			where t.valor_anterior = '' and t.valor_posterior = 'EXP' or t.o != 1

			--Elimino de la ##fact_lg_calculo_overrolling_tmp a aquellos que vengan de ''-EXP --> ''-EXP 
			delete t
			from ##fact_lg_calculo_overrolling_tmp t
			inner join ##fact_lg_calculo_overrolling_NULLEXPX2 r with(nolock) on t.material_key = r.material_key

			--inserto lo que tiene ##fact_lg_calculo_overrolling_EXPSNDWEBMTO
			insert into ##fact_lg_calculo_overrolling_tmp 
			select * from ##fact_lg_calculo_overrolling_EXPSNDWEBMTO with(nolock)

			--inserto lo que tiene ##fact_lg_calculo_overrolling_EXPWEB
			insert into ##fact_lg_calculo_overrolling_tmp
			select * from ##fact_lg_calculo_overrolling_EXPWEB with(nolock)

			--Después de hacer los insert, agrupo por material_key y me quedo con el primero (esa sería la marca por default de OVR la primera ocurrencia)
			select material_key
			into ##fact_lg_calculo_overrolling_default_ovr
			from ##fact_lg_calculo_overrolling_tmp with(nolock)
			group by material_key
			having count(1) > 1	

			-- Inserto en result_4 lo que hay en tmp que coincide con default ovr y tiene o = 1
			select * 
			into ##fact_lg_calculo_overrolling_TMPDEFAULT
			from ##fact_lg_calculo_overrolling_tmp with(nolock) where material_key in (select material_key from ##fact_lg_calculo_overrolling_default_ovr) and o = 1

			--Elimino de la ##fact_lg_calculo_overrolling_tmp los que sean default_ovr
			delete t
			from ##fact_lg_calculo_overrolling_tmp t 
			inner join ##fact_lg_calculo_overrolling_TMPDEFAULT r with(nolock) on t.material_key = r.material_key

			--inserto lo que tiene ##fact_lg_calculo_overrolling_TMPDEFAULT
			insert into ##fact_lg_calculo_overrolling_tmp 
			select * from ##fact_lg_calculo_overrolling_TMPDEFAULT with(nolock)

			--inserto lo que tiene ##fact_lg_calculo_overrolling_NULLEXPX2
			insert into ##fact_lg_calculo_overrolling_tmp
			select * from ##fact_lg_calculo_overrolling_NULLEXPX2 with(nolock)

			-- INSERT ##fact_lg_calculo_overrolling_posible_ovr
			select distinct fmc.id_movimiento,fmc.material_key, DTM.Cod_Tipo_Movimiento, DTM.Desc_Tipo_Movimiento, DV.Variable_Cod, 
			FMD.valor_anterior, FMD.valor_posterior, FMC.Fecha_Movimiento, 1 o, OFA.cod_cliente, c.pro_norma_desc, v.cod_clase_doc, 
			C.pro_grado_desc, C.pro_subnorma_desc, C.Clase_cod, MED.espesor_valor, MED.ancho_valor, MED.largo_valor, GRAC.cod_grado_acero, 
			OFACALIDAD.cod_tipo_calidad, TIPOOFA.cod_tipo_ofa, UBIC.Planta, DM.tipo, OFA.ofa_documento, OFA.ofa_posicion, DICT.marca_logica_calculo,
			DL.cod_linea, OFA.ofa_necesidad, OFACALIDAD.desc_tipo_calidad, C.pro_cod, V.cod_motivo_pedido, DL1.cod_linea cod_linea_imputacion
			,FMC.fact_lg_movimientos_cab_key, A.peso_neto, DEF1.desc_defecto, CALI.calidad_cod, DB.nro_bulto, OFRE.GALE, 
			DEF1.desc_causa_defecto, DLC.cod_calidad, FMC.observaciones
			into ##fact_lg_calculo_overrolling_posible_ovr
			FROM ##fact_lg_calculo_overrolling_default_ovr r with(nolock)
			inner join GES_Siderar..fact_LG_movimientos_cab FMC WITH(nolock) on r.material_key = FMC.material_key
			INNER JOIN GES_Siderar..fact_lg_movimientos_detalle FMD WITH(nolock) ON FMC.id_movimiento = FMD.Id_Movimiento
			inner join ##fact_lg_calculo_overrolling_Materiales m with(nolock) on fmc.material_key = m.material_key
			left join ges_siderar..fact_LG_bultos_Stk_hist A with(nolock) on A.material_key = fmc.material_key
			left join ges_siderar..dim_linea DL with(nolock) on DL.linea_key = A.linea_origen_key
			left join ges_siderar..dim_clientes B with(nolock) on A.Dim_APT_Cliente_key =B.cliente_key
			left join ges_siderar..dim_producto_pro C with(nolock) on A.dim_producto_key=C.dim_producto_pro_key
			left join ges_siderar..dim_documento_venta D with(nolock) on CAST(D.nro_documento as varchar) + '0000' + cast(D.nro_posicion as varchar) = cast(A.apt_clave as varchar)
			left join
			(select A.doc_venta_key, A.Reparto_key, A.tipo_venta_key, C.cod_clase_doc, D.cod_motivo_pedido from ges_siderar..fact_pedidos A with(nolock) 
			LEFT JOIN GES_Siderar..dim_motivo_pedido D with(nolock) ON A.dim_motivo_pedido_key = D.dim_motivo_pedido_key
			left join ges_siderar..dim_repartos B with(nolock) on A.reparto_key =B.reparto_key
			left join ges_siderar..dim_clases_documento C with(nolock) on A.clase_documento_key =c.clase_documento_key
			where B.nro_reparto =0) V on A.Dim_APT_Doc_Venta_key=V.doc_venta_key
			left join ges_siderar..dim_repartos REP with(nolock) on V.reparto_key = REP.reparto_key 
			left join ges_siderar..dim_calidad CALI with(nolock) on V.tipo_venta_key= CALI.calidad_key
			left join ges_siderar..dim_lg_calidad DLC with(nolock) on DLC.calidad_key = A.dim_lg_calidad_key
			LEFT JOIN (select material_key, max(defecto_key) defecto_key from ges_siderar..fact_lg_bultos_prod with(nolock) group by material_key)
			as BP on BP.material_key = A.material_key 
			LEFT JOIN ges_siderar..fact_lg_bultos_prod P on P.defecto_key = BP.defecto_key and P.material_key = BP.material_key
			LEFT JOIN GES_SIDERAR..dim_ofa OFA with(nolock) on OFA.nro_ofa_key = P.nro_ofa_key
			LEFT JOIN  GES_SIDERAR..fact_ofa FOFA with(nolock) on fofa.nro_ofa_key = OFA.nro_ofa_key
			LEFT JOIN  GES_SIDERAR..dim_ofa_tipo TIPOOFA with(nolock) on TIPOOFA.tipo_ofa_key = FOFA.tipo_ofa_key 
			LEFT JOIN  GES_SIDERAR..dim_OFA_Tipo_Calidad OFACALIDAD  with(nolock) on OFACALIDAD.dim_OFA_Tipo_Calidad_key=FOFA.Tipo_calidad_key
			LEFT JOIN GES_Siderar..dim_lg_ubicacion UBIC with(nolock) on UBIC.ubicacion_key = A.ubicacion_key	
			LEFT JOIN GES_SIDERAR..dim_grado_acero GRAC with(nolock) on GRAC.grado_acero_key = A.grado_acero_key
			LEFT JOIN GES_SIDERAR..dim_medida_basica MED with(nolock) on MED.dim_medida_basica_key = A.dim_medida_basica_key
			left join (select material_key, max(fecha_caida_key) fecha_caida_key,  max(linea_imputacion_key) linea_imputacion_key from ges_siderar..fact_lg_dictamen_Caidas with(nolock) 
			group by material_key) as DICT1 on DICT1.material_key = FMC.material_key
			INNER JOIN GES_Siderar..dim_materiales DM with(nolock) ON FMC.material_key = DM.material_key
			INNER JOIN GES_Siderar..dim_lg_bultos DB with(nolock) ON DM.bulto_lg_key = DB.bulto_lg_key
			left join (select nro_bulto, max(lg_defecto_key) lg_defecto_key from ges_siderar..dim_lg_defectos with(nolock) group by nro_bulto) as DEF on DEF.nro_bulto = DB.nro_bulto
			left join ges_siderar..dim_lg_defectos DEF1 with (nolock) on DEF1.lg_defecto_key = DEF.lg_defecto_key and DEF1.nro_bulto = DEF.nro_bulto
			LEFT JOIN ges_siderar..dim_linea DL1 with(nolock) on DL1.linea_key = DICT1.linea_imputacion_key
			left join GES_Siderar..fact_lg_dictamen_caidas DICT with (nolock) on DICT.fecha_caida_key = DICT1.fecha_caida_key and DICT.material_key = DICT1.material_key 
			INNER JOIN GES_Siderar..dim_lg_tipo_movimiento DTM with(nolock) ON FMC.tipo_movimiento_key = DTM.tipo_movimiento_key
			LEFT JOIN GES_Siderar..dim_lg_variables_stk DV with(nolock) ON FMD.dim_lg_variables_stk_key = DV.dim_lg_variables_stk_key
			left join ges_siderar.dbo.dim_ofrecimiento ofre (nolock) ON FOFA.ofrecimiento_key = ofre.dim_ofrecimiento_key
			where 1=1 and DTM.cod_tipo_movimiento = '151' 

			union

			select distinct fmc.id_movimiento,fmc.material_key, DTM.Cod_Tipo_Movimiento, DTM.Desc_Tipo_Movimiento, DV.Variable_Cod, 
			FMD.valor_anterior, FMD.valor_posterior, FMC.Fecha_Movimiento, 1 o, OFA.cod_cliente, c.pro_norma_desc, v.cod_clase_doc, 
			C.pro_grado_desc, C.pro_subnorma_desc, C.Clase_cod, MED.espesor_valor, MED.ancho_valor, MED.largo_valor, GRAC.cod_grado_acero, 
			OFACALIDAD.cod_tipo_calidad, TIPOOFA.cod_tipo_ofa, UBIC.Planta, DM.tipo, OFA.ofa_documento, OFA.ofa_posicion, DICT.marca_logica_calculo,
			DL.cod_linea, OFA.ofa_necesidad, OFACALIDAD.desc_tipo_calidad, C.pro_cod, V.cod_motivo_pedido, DL1.cod_linea cod_linea_imputacion
			,FMC.fact_lg_movimientos_cab_key, A.peso_neto, DEF1.desc_defecto, CALI.calidad_cod, DB.nro_bulto, OFRE.GALE, 
			DEF1.desc_causa_defecto, DLC.cod_calidad, FMC.observaciones
			FROM ##fact_lg_calculo_overrolling_default_ovr r with(nolock)
			inner join hiGES_Siderar..fact_LG_movimientos_cab FMC WITH(nolock) on r.material_key = FMC.material_key
			LEFT JOIN hiGES_Siderar..fact_lg_movimientos_detalle FMD WITH(nolock) ON FMC.id_movimiento = FMD.Id_Movimiento
			inner join ##fact_lg_calculo_overrolling_Materiales m with(nolock) on fmc.material_key = m.material_key
			left join ges_siderar..fact_LG_bultos_Stk_hist A with(nolock) on A.material_key = fmc.material_key
			left join ges_siderar..dim_linea DL with(nolock) on DL.linea_key = A.linea_origen_key
			left join ges_siderar..dim_clientes B with(nolock) on A.Dim_APT_Cliente_key =B.cliente_key
			left join ges_siderar..dim_producto_pro C with(nolock) on A.dim_producto_key=C.dim_producto_pro_key
			left join ges_siderar..dim_documento_venta D with(nolock) on CAST(D.nro_documento as varchar) + '0000' + cast(D.nro_posicion as varchar) = cast(A.apt_clave as varchar)
			left join
			(select A.doc_venta_key, A.Reparto_key, A.tipo_venta_key, C.cod_clase_doc, D.cod_motivo_pedido from ges_siderar..fact_pedidos A with(nolock) 
			LEFT JOIN GES_Siderar..dim_motivo_pedido D with(nolock) ON A.dim_motivo_pedido_key = D.dim_motivo_pedido_key
			left join ges_siderar..dim_repartos B with(nolock) on A.reparto_key =B.reparto_key
			left join ges_siderar..dim_clases_documento C with(nolock) on A.clase_documento_key =c.clase_documento_key
			where B.nro_reparto =0) V on A.Dim_APT_Doc_Venta_key=V.doc_venta_key
			left join ges_siderar..dim_repartos REP with(nolock) on V.reparto_key = REP.reparto_key 
			left join ges_siderar..dim_calidad CALI with(nolock) on V.tipo_venta_key= CALI.calidad_key
			left join ges_siderar..dim_lg_calidad DLC with(nolock) on DLC.calidad_key = A.dim_lg_calidad_key
			INNER JOIN GES_Siderar..dim_lg_tipo_movimiento DTM with(nolock) ON FMC.tipo_movimiento_key = DTM.tipo_movimiento_key
			LEFT JOIN GES_Siderar..dim_lg_variables_stk DV with(nolock) ON FMD.dim_lg_variables_stk_key = DV.dim_lg_variables_stk_key
			INNER JOIN GES_Siderar..dim_materiales DM with(nolock) ON FMC.material_key = DM.material_key
			INNER JOIN GES_Siderar..dim_lg_bultos DB with(nolock) ON DM.bulto_lg_key = DB.bulto_lg_key
			LEFT JOIN (select material_key, max(defecto_key) defecto_key from ges_siderar..fact_lg_bultos_prod with(nolock) group by material_key)
			as BP on BP.material_key = A.material_key 
			LEFT JOIN ges_siderar..fact_lg_bultos_prod P on P.defecto_key = BP.defecto_key and P.material_key = BP.material_key
			LEFT JOIN GES_SIDERAR..dim_ofa OFA with(nolock) on OFA.nro_ofa_key = P.nro_ofa_key
			LEFT JOIN  GES_SIDERAR..fact_ofa FOFA with(nolock) on fofa.nro_ofa_key = OFA.nro_ofa_key
			LEFT JOIN  GES_SIDERAR..dim_ofa_tipo TIPOOFA with(nolock) on TIPOOFA.tipo_ofa_key = FOFA.tipo_ofa_key 
			LEFT JOIN  GES_SIDERAR..dim_OFA_Tipo_Calidad OFACALIDAD  with(nolock) on OFACALIDAD.dim_OFA_Tipo_Calidad_key=FOFA.Tipo_calidad_key
			LEFT JOIN GES_Siderar..dim_lg_ubicacion UBIC with(nolock) on UBIC.ubicacion_key = A.ubicacion_key	
			LEFT JOIN GES_SIDERAR..dim_grado_acero GRAC with(nolock) on GRAC.grado_acero_key = A.grado_acero_key
			LEFT JOIN GES_SIDERAR..dim_medida_basica MED with(nolock) on MED.dim_medida_basica_key = A.dim_medida_basica_key
			left join (select material_key, max(fecha_caida_key) fecha_caida_key,  max(linea_imputacion_key) linea_imputacion_key from ges_siderar..fact_lg_dictamen_Caidas
			group by material_key) as DICT1 on DICT1.material_key = FMC.material_key
			left join (select nro_bulto, max(lg_defecto_key) lg_defecto_key from ges_siderar..dim_lg_defectos with(nolock) group by nro_bulto) as DEF on DEF.nro_bulto = DB.nro_bulto
			left join ges_siderar..dim_lg_defectos DEF1 with (nolock) on DEF1.lg_defecto_key = DEF.lg_defecto_key and DEF1.nro_bulto = DEF.nro_bulto
			LEFT JOIN ges_siderar..dim_linea DL1 with(nolock) on DL1.linea_key = DICT1.linea_imputacion_key
			left join GES_Siderar..fact_lg_dictamen_caidas DICT with (nolock) on DICT.fecha_caida_key = DICT1.fecha_caida_key and DICT.material_key = DICT1.material_key
			left join ges_siderar.dbo.dim_ofrecimiento ofre (nolock) ON FOFA.ofrecimiento_key = ofre.dim_ofrecimiento_key
			where 1=1 and DTM.cod_tipo_movimiento = '151'

			--borro los de tmp para que no se repitan
			delete povr from ##fact_lg_calculo_overrolling_posible_ovr povr
			inner join ##fact_lg_calculo_overrolling_tmp on ##fact_lg_calculo_overrolling_tmp.material_key = povr.material_key

			--inserto los que hayan quedado en la ##fact_lg_calculo_overrolling_tmp
			insert into ##fact_lg_calculo_overrolling_posible_ovr 
			(id_movimiento,	material_key, Cod_Tipo_Movimiento, Desc_Tipo_Movimiento, Variable_Cod, valor_anterior, valor_posterior,	Fecha_Movimiento,
			o, cod_cliente, pro_norma_desc, cod_clase_doc, pro_grado_desc, pro_subnorma_desc, clase_cod, espesor_valor, ancho_valor, largo_valor, 
			cod_grado_acero, cod_tipo_calidad, cod_tipo_ofa, planta, tipo, ofa_documento, ofa_posicion, marca_logica_calculo, cod_linea, ofa_necesidad,
			desc_tipo_calidad, pro_cod, cod_motivo_pedido, cod_linea_imputacion, fact_lg_movimientos_cab_key, peso_neto, 
			desc_defecto, calidad_cod, nro_bulto, gale, desc_causa_defecto, cod_calidad, observaciones)
			select * from ##fact_lg_calculo_overrolling_tmp with(nolock)

			-- CONSULTA PADRES INICIO

			-- Consulta padres de materiales seleccionados

			SELECT bt.materialmadre_key padre_material_key, bt.materialproducido_key hijo_material_key
			into ##fact_lg_calculo_overrolling_padre_hijo
			FROM GES_Siderar..fact_lg_bultos_trazabilidad BT with(nolock)
			inner join ##fact_lg_calculo_overrolling_posible_ovr ovr with(nolock) on ovr.material_key = bt.materialproducido_key
			WHERE 1=1

			-- Consulta padres con marca OVR en toda su historia

			select distinct PADRESOVR.id_movimiento, PADRESOVR.material_key, PADRESOVR.Cod_Tipo_Movimiento, PADRESOVR.Desc_Tipo_Movimiento, PADRESOVR.Variable_Cod, PADRESOVR.valor_anterior, PADRESOVR.valor_posterior, PADRESOVR.Fecha_Movimiento,

			row_number() over (
							   partition by PADRESOVR.material_key--,FMD.valor_posterior,FMC.Fecha_Movimiento
								   order by PADRESOVR.Fecha_Movimiento asc) as O,
			PADRESOVR.cod_cliente, PADRESOVR.pro_norma_desc, PADRESOVR.cod_clase_doc, PADRESOVR.pro_grado_desc, PADRESOVR.pro_subnorma_desc,
			PADRESOVR.clase_cod, PADRESOVR.espesor_valor, PADRESOVR.ancho_valor, PADRESOVR.largo_valor, PADRESOVR.cod_grado_acero,
			PADRESOVR.cod_tipo_calidad, PADRESOVR.cod_tipo_ofa, PADRESOVR.planta, PADRESOVR.tipo, PADRESOVR.ofa_documento,
			PADRESOVR.ofa_posicion, PADRESOVR.Marca_logica_calculo, PADRESOVR.cod_linea, PADRESOVR.ofa_necesidad, PADRESOVR.desc_tipo_calidad,
			PADRESOVR.pro_cod, PADRESOVR.cod_motivo_pedido, PADRESOVR.cod_linea_imputacion,
			PADRESOVR.fact_lg_movimientos_cab_key, PADRESOVR.peso_neto, PADRESOVR.desc_defecto, PADRESOVR.calidad_cod, PADRESOVR.nro_bulto,
			PADRESOVR.gale, PADRESOVR.desc_causa_defecto, PADRESOVR.cod_calidad, PADRESOVR.observaciones
			into ##fact_lg_calculo_overrolling_padres_marca_ovr from
			(
			(select distinct fmc.id_movimiento,fmc.material_key, DTM.Cod_Tipo_Movimiento, DTM.Desc_Tipo_Movimiento, DV.Variable_Cod, 
			FMD.valor_anterior, FMD.valor_posterior, FMC.Fecha_Movimiento, OFA.cod_cliente, c.pro_norma_desc, v.cod_clase_doc, 
			C.pro_grado_desc, C.pro_subnorma_desc, C.Clase_cod, MED.espesor_valor, MED.ancho_valor, MED.largo_valor, GRAC.cod_grado_acero, 
			OFACALIDAD.cod_tipo_calidad, TIPOOFA.cod_tipo_ofa, UBIC.Planta, DM.tipo, OFA.ofa_documento, OFA.ofa_posicion, DICT.marca_logica_calculo,
			DL.cod_linea, OFA.ofa_necesidad, OFACALIDAD.desc_tipo_calidad, C.pro_cod, V.cod_motivo_pedido, DL1.cod_linea cod_linea_imputacion
			,FMC.fact_lg_movimientos_cab_key, A.peso_neto, DEF1.desc_defecto, CALI.calidad_cod, DB.nro_bulto, OFRE.GALE, 
			DEF1.desc_causa_defecto, DLC.cod_calidad, FMC.observaciones
			FROM GES_Siderar..fact_LG_movimientos_cab FMC WITH(nolock)
			INNER JOIN GES_Siderar..fact_lg_movimientos_detalle FMD WITH(nolock) ON FMC.id_movimiento = FMD.Id_Movimiento
			inner join ##fact_lg_calculo_overrolling_Materiales m with(nolock) on fmc.material_key = m.material_key
			left join ges_siderar..fact_LG_bultos_Stk_hist A with(nolock) on A.material_key = fmc.material_key
			left join ges_siderar..dim_linea DL with(nolock) on DL.linea_key = A.linea_origen_key
			left join ges_siderar..dim_clientes B with(nolock) on A.Dim_APT_Cliente_key =B.cliente_key
			left join ges_siderar..dim_producto_pro C with(nolock) on A.dim_producto_key=C.dim_producto_pro_key
			left join ges_siderar..dim_documento_venta D with(nolock) on CAST(D.nro_documento as varchar) + '0000' + cast(D.nro_posicion as varchar) = cast(A.apt_clave as varchar)
			left join
			(select A.doc_venta_key, A.Reparto_key, A.tipo_venta_key, C.cod_clase_doc, D.cod_motivo_pedido from ges_siderar..fact_pedidos A with(nolock) 
			LEFT JOIN GES_Siderar..dim_motivo_pedido D with(nolock) ON A.dim_motivo_pedido_key = D.dim_motivo_pedido_key
			left join ges_siderar..dim_repartos B with(nolock) on A.reparto_key =B.reparto_key
			left join ges_siderar..dim_clases_documento C with(nolock) on A.clase_documento_key =c.clase_documento_key
			where B.nro_reparto =0) V on A.Dim_APT_Doc_Venta_key=V.doc_venta_key
			left join ges_siderar..dim_repartos REP with(nolock) on V.reparto_key = REP.reparto_key 
			left join ges_siderar..dim_calidad CALI with(nolock) on V.tipo_venta_key= CALI.calidad_key
			left join ges_siderar..dim_lg_calidad DLC with(nolock) on DLC.calidad_key = A.dim_lg_calidad_key
			LEFT JOIN (select material_key, max(defecto_key) defecto_key from ges_siderar..fact_lg_bultos_prod with(nolock) group by material_key)
			as BP on BP.material_key = A.material_key 
			LEFT JOIN ges_siderar..fact_lg_bultos_prod P on P.defecto_key = BP.defecto_key and P.material_key = BP.material_key
			LEFT JOIN GES_SIDERAR..dim_ofa OFA with(nolock) on OFA.nro_ofa_key = P.nro_ofa_key
			LEFT JOIN  GES_SIDERAR..fact_ofa FOFA with(nolock) on fofa.nro_ofa_key = OFA.nro_ofa_key
			LEFT JOIN  GES_SIDERAR..dim_ofa_tipo TIPOOFA with(nolock) on TIPOOFA.tipo_ofa_key = FOFA.tipo_ofa_key 
			LEFT JOIN  GES_SIDERAR..dim_OFA_Tipo_Calidad OFACALIDAD  with(nolock) on OFACALIDAD.dim_OFA_Tipo_Calidad_key=FOFA.Tipo_calidad_key
			LEFT JOIN GES_Siderar..dim_lg_ubicacion UBIC with(nolock) on UBIC.ubicacion_key = A.ubicacion_key	
			LEFT JOIN GES_SIDERAR..dim_grado_acero GRAC with(nolock) on GRAC.grado_acero_key = A.grado_acero_key
			LEFT JOIN GES_SIDERAR..dim_medida_basica MED with(nolock) on MED.dim_medida_basica_key = A.dim_medida_basica_key
			left join (select material_key, max(fecha_caida_key) fecha_caida_key,  max(linea_imputacion_key) linea_imputacion_key from ges_siderar..fact_lg_dictamen_Caidas with(nolock) 
			group by material_key) as DICT1 on DICT1.material_key = FMC.material_key
			INNER JOIN GES_Siderar..dim_materiales DM with(nolock) ON FMC.material_key = DM.material_key
			INNER JOIN GES_Siderar..dim_lg_bultos DB with(nolock) ON DM.bulto_lg_key = DB.bulto_lg_key
			left join (select nro_bulto, max(lg_defecto_key) lg_defecto_key from ges_siderar..dim_lg_defectos with(nolock) group by nro_bulto) as DEF on DEF.nro_bulto = DB.nro_bulto
			left join ges_siderar..dim_lg_defectos DEF1 with (nolock) on DEF1.lg_defecto_key = DEF.lg_defecto_key and DEF1.nro_bulto = DEF.nro_bulto
			LEFT JOIN ges_siderar..dim_linea DL1 with(nolock) on DL1.linea_key = DICT1.linea_imputacion_key
			left join GES_Siderar..fact_lg_dictamen_caidas DICT with (nolock) on DICT.fecha_caida_key = DICT1.fecha_caida_key and DICT.material_key = DICT1.material_key 
			INNER JOIN GES_Siderar..dim_lg_tipo_movimiento DTM with(nolock) ON FMC.tipo_movimiento_key = DTM.tipo_movimiento_key
			LEFT JOIN GES_Siderar..dim_lg_variables_stk DV with(nolock) ON FMD.dim_lg_variables_stk_key = DV.dim_lg_variables_stk_key
			left join ges_siderar.dbo.dim_ofrecimiento ofre (nolock) ON FOFA.ofrecimiento_key = ofre.dim_ofrecimiento_key
			where 1=1
			and (DV.variable_cod = 'id_tipo_estrategia'
			AND DTM.Cod_tipo_movimiento IN ('33', '148', '154', '235', '338')
			and (FMD.valor_posterior IN ('OVR', 'OVE', 'EXP', 'WEB', 'EOV') or FMD.valor_anterior IN ('OVR', 'OVE', 'EXP', 'WEB', 'EOV'))
			--Roll Chance Slabs sobrantes
			or (V.cod_motivo_pedido = 'N05')
			-- Roll Chance STC, STN
			or (FMD.valor_posterior IN ('STC', 'STN') and DTM.cod_tipo_movimiento = '33' and OFA.cod_cliente in ('0000000410', '0000000412'))
			-- Vuelta de CHT, EBX, o I&D Pruebas de producto
			or (FMD.valor_posterior IN ('OVR', 'OVE', 'WEB', 'EOV') and FMD.valor_anterior IN ('EBX'))) 
			and FMC.material_key in (select padre_material_key from ##fact_lg_calculo_overrolling_padre_hijo with(nolock))
			)

			union

			(SELECT distinct fmc.id_movimiento,fmc.material_key, DTM.Cod_Tipo_Movimiento, DTM.Desc_Tipo_Movimiento, DV.Variable_Cod, 
			FMD.valor_anterior, FMD.valor_posterior, FMC.Fecha_Movimiento, OFA.cod_cliente, c.pro_norma_desc, v.cod_clase_doc, 
			C.pro_grado_desc, C.pro_subnorma_desc, C.Clase_cod, MED.espesor_valor, MED.ancho_valor, MED.largo_valor, GRAC.cod_grado_acero, 
			OFACALIDAD.cod_tipo_calidad, TIPOOFA.cod_tipo_ofa, UBIC.Planta, DM.tipo, OFA.ofa_documento, OFA.ofa_posicion, DICT.marca_logica_calculo,
			DL.cod_linea, OFA.ofa_necesidad, OFACALIDAD.desc_tipo_calidad, C.pro_cod, V.cod_motivo_pedido, DL1.cod_linea cod_linea_imputacion
			,FMC.fact_lg_movimientos_cab_key, A.peso_neto, DEF1.desc_defecto, CALI.calidad_cod, DB.nro_bulto, OFRE.GALE, 
			DEF1.desc_causa_defecto, DLC.cod_calidad, FMC.observaciones
			FROM hiGES_Siderar..fact_LG_movimientos_cab FMC WITH(nolock)
			LEFT JOIN hiGES_Siderar..fact_lg_movimientos_detalle FMD WITH(nolock) ON FMC.id_movimiento = FMD.Id_Movimiento
			inner join ##fact_lg_calculo_overrolling_Materiales m with(nolock) on fmc.material_key = m.material_key
			left join ges_siderar..fact_LG_bultos_Stk_hist A with(nolock) on A.material_key = fmc.material_key
			left join ges_siderar..dim_linea DL with(nolock) on DL.linea_key = A.linea_origen_key
			left join ges_siderar..dim_clientes B with(nolock) on A.Dim_APT_Cliente_key =B.cliente_key
			left join ges_siderar..dim_producto_pro C with(nolock) on A.dim_producto_key=C.dim_producto_pro_key
			left join ges_siderar..dim_documento_venta D with(nolock) on CAST(D.nro_documento as varchar) + '0000' + cast(D.nro_posicion as varchar) = cast(A.apt_clave as varchar)
			left join
			(select A.doc_venta_key, A.Reparto_key, A.tipo_venta_key, C.cod_clase_doc, D.cod_motivo_pedido from ges_siderar..fact_pedidos A with(nolock) 
			LEFT JOIN GES_Siderar..dim_motivo_pedido D with(nolock) ON A.dim_motivo_pedido_key = D.dim_motivo_pedido_key
			left join ges_siderar..dim_repartos B with(nolock) on A.reparto_key =B.reparto_key
			left join ges_siderar..dim_clases_documento C with(nolock) on A.clase_documento_key =c.clase_documento_key
			where B.nro_reparto =0) V on A.Dim_APT_Doc_Venta_key=V.doc_venta_key
			left join ges_siderar..dim_repartos REP with(nolock) on V.reparto_key = REP.reparto_key 
			left join ges_siderar..dim_calidad CALI with(nolock) on V.tipo_venta_key= CALI.calidad_key
			left join ges_siderar..dim_lg_calidad DLC with(nolock) on DLC.calidad_key = A.dim_lg_calidad_key
			INNER JOIN GES_Siderar..dim_lg_tipo_movimiento DTM with(nolock) ON FMC.tipo_movimiento_key = DTM.tipo_movimiento_key
			LEFT JOIN GES_Siderar..dim_lg_variables_stk DV with(nolock) ON FMD.dim_lg_variables_stk_key = DV.dim_lg_variables_stk_key
			INNER JOIN GES_Siderar..dim_materiales DM with(nolock) ON FMC.material_key = DM.material_key
			INNER JOIN GES_Siderar..dim_lg_bultos DB with(nolock) ON DM.bulto_lg_key = DB.bulto_lg_key
			LEFT JOIN (select material_key, max(defecto_key) defecto_key from ges_siderar..fact_lg_bultos_prod with(nolock) group by material_key)
			as BP on BP.material_key = A.material_key 
			LEFT JOIN ges_siderar..fact_lg_bultos_prod P on P.defecto_key = BP.defecto_key and P.material_key = BP.material_key
			LEFT JOIN GES_SIDERAR..dim_ofa OFA with(nolock) on OFA.nro_ofa_key = P.nro_ofa_key
			LEFT JOIN  GES_SIDERAR..fact_ofa FOFA with(nolock) on fofa.nro_ofa_key = OFA.nro_ofa_key
			LEFT JOIN  GES_SIDERAR..dim_ofa_tipo TIPOOFA with(nolock) on TIPOOFA.tipo_ofa_key = FOFA.tipo_ofa_key 
			LEFT JOIN  GES_SIDERAR..dim_OFA_Tipo_Calidad OFACALIDAD  with(nolock) on OFACALIDAD.dim_OFA_Tipo_Calidad_key=FOFA.Tipo_calidad_key
			LEFT JOIN GES_Siderar..dim_lg_ubicacion UBIC with(nolock) on UBIC.ubicacion_key = A.ubicacion_key	
			LEFT JOIN GES_SIDERAR..dim_grado_acero GRAC with(nolock) on GRAC.grado_acero_key = A.grado_acero_key
			LEFT JOIN GES_SIDERAR..dim_medida_basica MED with(nolock) on MED.dim_medida_basica_key = A.dim_medida_basica_key
			left join (select material_key, max(fecha_caida_key) fecha_caida_key,  max(linea_imputacion_key) linea_imputacion_key from ges_siderar..fact_lg_dictamen_Caidas
			group by material_key) as DICT1 on DICT1.material_key = FMC.material_key
			left join (select nro_bulto, max(lg_defecto_key) lg_defecto_key from ges_siderar..dim_lg_defectos with(nolock) group by nro_bulto) as DEF on DEF.nro_bulto = DB.nro_bulto
			left join ges_siderar..dim_lg_defectos DEF1 with(nolock) on DEF1.lg_defecto_key = DEF.lg_defecto_key and DEF1.nro_bulto = DEF.nro_bulto
			LEFT JOIN ges_siderar..dim_linea DL1 with(nolock) on DL1.linea_key = DICT1.linea_imputacion_key
			left join GES_Siderar..fact_lg_dictamen_caidas DICT with (nolock) on DICT.fecha_caida_key = DICT1.fecha_caida_key and DICT.material_key = DICT1.material_key
			left join ges_siderar.dbo.dim_ofrecimiento ofre (nolock) ON FOFA.ofrecimiento_key = ofre.dim_ofrecimiento_key			where 1=1
			and (DV.variable_cod = 'id_tipo_estrategia'
			AND DTM.Cod_tipo_movimiento IN ('33', '148', '154', '235', '338')
			and (FMD.valor_posterior IN ('OVR', 'OVE', 'EXP', 'WEB', 'EOV') or FMD.valor_anterior IN ('OVR', 'OVE', 'EXP', 'WEB', 'EOV'))
			--Roll Chance Slabs sobrantes
			or (V.cod_motivo_pedido = 'N05')
			-- Roll Chance STC, STN
			or (FMD.valor_posterior IN ('STC', 'STN') and DTM.cod_tipo_movimiento = '33' and OFA.cod_cliente in ('0000000410', '0000000412'))
			-- Vuelta de CHT, EBX, o I&D Pruebas de producto
			or (FMD.valor_posterior IN ('OVR', 'OVE', 'WEB', 'EOV') and FMD.valor_anterior IN ('EBX')))
			and FMC.material_key in (select padre_material_key from ##fact_lg_calculo_overrolling_padre_hijo with(nolock))
			) 
			) as PADRESOVR

			-- INSERT DE PADRES

			-- Guardo el resultado en ##fact_lg_calculo_overrolling_RESULT_1
			select distinct padresovr.* into ##fact_lg_calculo_overrolling_RESULT_1 from ##fact_lg_calculo_overrolling_padres_marca_ovr padresovr with(nolock)
			inner join ##fact_lg_calculo_overrolling_padre_hijo ph with(nolock) on ph.padre_material_key = padresovr.material_key
			inner join ##fact_lg_calculo_overrolling_posible_ovr ovr with(nolock) on ovr.material_key = ph.hijo_material_key
			where padresovr.o = 1
			and ph.padre_material_key != ph.hijo_material_key

			-- Elimino hijos con material_key = padres con ese material_key
			delete ovr from ##fact_lg_calculo_overrolling_posible_ovr ovr
			inner join ##fact_lg_calculo_overrolling_padre_hijo ph with(nolock) on ph.hijo_material_key = ovr.material_key
			inner join ##fact_lg_calculo_overrolling_padres_marca_ovr padresovr with(nolock) on padresovr.material_key = ph.padre_material_key
			where ph.padre_material_key in (select material_key from ##fact_lg_calculo_overrolling_RESULT_1 with(nolock))
			and ph.padre_material_key != ph.hijo_material_key

			-- Inserto los padres con OVR en la tabla ##fact_lg_calculo_overrolling_posible_ovr
			insert into ##fact_lg_calculo_overrolling_posible_ovr 
			(id_movimiento,	material_key, Cod_Tipo_Movimiento, Desc_Tipo_Movimiento, Variable_Cod, valor_anterior, valor_posterior,	Fecha_Movimiento,
			o, cod_cliente, pro_norma_desc, cod_clase_doc, pro_grado_desc, pro_subnorma_desc, clase_cod, espesor_valor, ancho_valor, largo_valor, 
			cod_grado_acero, cod_tipo_calidad, cod_tipo_ofa, planta, tipo, ofa_documento, ofa_posicion, marca_logica_calculo, cod_linea, ofa_necesidad,
			desc_tipo_calidad, pro_cod, cod_motivo_pedido, cod_linea_imputacion, fact_lg_movimientos_cab_key, peso_neto, 
			desc_defecto, calidad_cod, nro_bulto, gale, desc_causa_defecto, cod_calidad, observaciones)
			select id_movimiento,	material_key, Cod_Tipo_Movimiento, Desc_Tipo_Movimiento, Variable_Cod, valor_anterior, valor_posterior,	Fecha_Movimiento,
			o, cod_cliente, pro_norma_desc, cod_clase_doc, pro_grado_desc, pro_subnorma_desc, clase_cod, espesor_valor, ancho_valor, largo_valor, 
			cod_grado_acero, cod_tipo_calidad, cod_tipo_ofa, planta, tipo, ofa_documento, ofa_posicion, marca_logica_calculo, cod_linea, ofa_necesidad,
			desc_tipo_calidad, pro_cod, cod_motivo_pedido, cod_linea_imputacion, fact_lg_movimientos_cab_key, peso_neto, 
			desc_defecto, calidad_cod, nro_bulto, gale, desc_causa_defecto, cod_calidad, observaciones 
			from ##fact_lg_calculo_overrolling_RESULT_1 R1 with(nolock)
			where R1.material_key not in (select material_key from ##fact_lg_calculo_overrolling_posible_ovr)

			

			-- CONSULTA PADRES FIN

			-- Elimino Roll chance especiales que pisaron a los genuinos
			delete ovr from ##fact_lg_calculo_overrolling_posible_ovr ovr
			where material_key in (select material_key from ##fact_lg_calculo_overrolling_ROLLCHANCE_ESP with(nolock))

			-- Inserto los Roll chance genuinos que fueron pisados
			insert into ##fact_lg_calculo_overrolling_posible_ovr
			(id_movimiento,	material_key, Cod_Tipo_Movimiento, Desc_Tipo_Movimiento, Variable_Cod, valor_anterior, valor_posterior,	Fecha_Movimiento,
			o, cod_cliente, pro_norma_desc, cod_clase_doc, pro_grado_desc, pro_subnorma_desc, clase_cod, espesor_valor, ancho_valor, largo_valor, 
			cod_grado_acero, cod_tipo_calidad, cod_tipo_ofa, planta, tipo, ofa_documento, ofa_posicion, marca_logica_calculo, cod_linea, ofa_necesidad,
			desc_tipo_calidad, pro_cod, cod_motivo_pedido, cod_linea_imputacion, fact_lg_movimientos_cab_key, peso_neto, 
			desc_defecto, calidad_cod, nro_bulto, gale, desc_causa_defecto, cod_calidad, observaciones)
			select * from ##fact_lg_calculo_overrolling_ROLLCHANCE_ESP with(nolock)

			-- Agrego Voces en ##fact_lg_calculo_overrolling_posible_ovr y ##fact_lg_calculo_overrolling_padres_marca_ovr
			alter table ##fact_lg_calculo_overrolling_posible_ovr
			add voz varchar(50), subvoz varchar(50)

			alter table ##fact_lg_calculo_overrolling_padres_marca_ovr
			add voz varchar(50), subvoz varchar(50)

			-- Update desc_defecto en DESVÍO CUALITATIVO, para que sea el principal

			UPDATE ##fact_lg_calculo_overrolling_posible_ovr
			SET desc_defecto = dimdef.desc_defecto, desc_causa_defecto = dimdef.desc_causa_defecto
			from GES_Siderar..fact_lg_dictamen_caidas A 
			inner join ##fact_lg_calculo_overrolling_posible_ovr ovr with(nolock) on ovr.material_key = a.material_key
			left join ges_siderar..fact_lg_defectos fd with(nolock) on fd.material_key = ovr.material_key
			left join ges_siderar..dim_lg_defectos dimdef with(nolock) on dimdef.lg_defecto_key = fd.defecto_key
			where a.marca_logica_calculo like 'B%'
			and a.fecha_caida_key = fd.fecha_key
			and a.hhmm_caida_key = fd.hora_minuto_key

			UPDATE ##fact_lg_calculo_overrolling_posible_ovr
			SET desc_defecto = dimdef.desc_defecto, desc_causa_defecto = dimdef.desc_causa_defecto
			from GES_Siderar..fact_lg_dictamen_caidas a
			left join ##fact_lg_calculo_overrolling_padre_hijo ph with(nolock) on ph.padre_material_key = A.material_key
			left join ##fact_lg_calculo_overrolling_posible_ovr ovr with(nolock) on ovr.material_key = ph.hijo_material_key
			left join ges_siderar..fact_lg_defectos fd with(nolock) on fd.material_key = ph.padre_material_key
			left join ges_siderar..dim_lg_defectos dimdef with(nolock) on dimdef.lg_defecto_key = fd.defecto_key
			where a.marca_logica_calculo like 'B%'
			and ovr.marca_logica_calculo not like 'B%'
			and a.fecha_caida_key = fd.fecha_key
			and a.hhmm_caida_key = fd.hora_minuto_key

			-- INICIO VOCES

			-- PROCESO DE INSERT DE MATERIAL_KEY EN LAS TABLAS SEGÚN REGLAS

				set @max_orden_ejecucion = (select max(orden) from [GES_siderar].DBO.[fact_lg_calculo_overrolling_cfg])

				WHILE @orden_ejecucion <= @max_orden_ejecucion
		
					BEGIN

								SET @SQLQuery =		(select top 1 replace(cond_insert, '@tabla_voces', tabla_voces) + char(13) + cond_select + char(13) + cond_from from [GES_siderar].DBO.[fact_lg_calculo_overrolling_cfg] where orden = @orden_ejecucion) + ' with(nolock)' + char(13)
								SET @SQLQuery +=	(select top 1 isnull(cond_join, '') from [GES_siderar].DBO.[fact_lg_calculo_overrolling_cfg] where orden = @orden_ejecucion) + char(13) 
								SET @SQLQuery +=	(select top 1 replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(cond_where, '@pro_norma_desc', isnull(pro_norma_desc, '')), '@observaciones', isnull(observaciones, '')), '@gale', isnull(gale, '')), '@desc_causa_defecto', isnull(desc_causa_defecto, '')), '@cod_linea_origen', isnull(cod_linea, '')), '@desc_defecto', isnull(desc_defecto, '')), '@cod_clase_doc', isnull(cod_clase_doc, '')), '@calidad_cod', isnull(calidad_cod, '')), '@cod_tipo_movimiento', isnull(cod_tipo_movimiento, '')), '@pro_norma_desc', isnull(pro_norma_desc, '')), '@cod_cliente', isnull(cod_cliente, '')), '@valor_posterior', isnull(valor_posterior, '')), '@pro_subnorma_desc', isnull(pro_subnorma_desc, '')), '@tipo', isnull(tipo, '')), '@clase_cod', isnull(clase_cod, '')), '@pro_cod', isnull(pro_cod, '')), '@cod_motivo_pedido', isnull(cod_motivo_pedido, '')), '@cod_tipo_ofa', isnull(cod_tipo_ofa, '')), '@espesor_valor', isnull(espesor_valor, '')), '@ancho_valor', isnull(ancho_valor, '')), '@cod_grado_acero', isnull(cod_grado_acero, '')), '@marca_logica_calculo', isnull(marca_logica_calculo, '')), '@planta', isnull(planta, '')), '@largo_valor', isnull(largo_valor, '')), '@cod_tipo_calidad', isnull(cod_tipo_calidad, '')), '@cod_linea_imputacion', isnull(cod_linea_imputacion, '')), '@ofa_necesidad', isnull(ofa_necesidad, '')), '@ofadoc_ofapos', isnull(ofadoc_ofapos, '')), '@valor_anterior', isnull(valor_anterior, '')), '@pro_grado_desc', isnull(pro_grado_desc, '')) from [GES_siderar].DBO.[fact_lg_calculo_overrolling_cfg] where orden = @orden_ejecucion) + char(13)
								SET @SQLQuery +=	(select top 1 replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(cond_and_or, ''), '@pro_norma_desc', isnull(pro_norma_desc, '')), '@observaciones', isnull(observaciones, '')), '@gale', isnull(gale, '')), '@desc_causa_defecto', isnull(desc_causa_defecto, '')), '@cod_linea_origen', isnull(cod_linea, '')), '@desc_defecto', isnull(desc_defecto, '')), '@cod_clase_doc', isnull(cod_clase_doc, '')), '@calidad_cod', isnull(calidad_cod, '')), '@cod_tipo_movimiento', isnull(cod_tipo_movimiento, '')), '@pro_norma_desc', isnull(pro_norma_desc, '')), '@cod_cliente', isnull(cod_cliente, '')), '@valor_posterior', isnull(valor_posterior, '')), '@pro_subnorma_desc', isnull(pro_subnorma_desc, '')), '@tipo', isnull(tipo, '')), '@clase_cod', isnull(clase_cod, '')), '@pro_cod', isnull(pro_cod, '')), '@cod_motivo_pedido', isnull(cod_motivo_pedido, '')), '@cod_tipo_ofa', isnull(cod_tipo_ofa, '')), '@espesor_valor', isnull(espesor_valor, '')), '@ancho_valor', isnull(ancho_valor, '')), '@cod_grado_acero', isnull(cod_grado_acero, '')), '@marca_logica_calculo', isnull(marca_logica_calculo, '')), '@planta', isnull(planta, '')), '@largo_valor', isnull(largo_valor, '')), '@cod_tipo_calidad', isnull(cod_tipo_calidad, '')), '@cod_linea_imputacion', isnull(cod_linea_imputacion, '')), '@ofa_necesidad', isnull(ofa_necesidad, '')), '@ofadoc_ofapos', isnull(ofadoc_ofapos, '')), '@valor_anterior', isnull(valor_anterior, '')), '@pro_grado_desc', isnull(pro_grado_desc, '')) from [GES_siderar].DBO.[fact_lg_calculo_overrolling_cfg] where orden = @orden_ejecucion) + char(13)


								EXEC (@SQLQuery)
					
								SET @orden_ejecucion += 1
		
					END

			-- FIN PROCESO DE INSERTS

			-- PROCESO DE UPDATE EN LA TABLA #POSIBLE_OVR SEGUN MATERIAL_KEY INSERTADO ARRIBA

				SET @orden_ejecucion = 1
				SET @max_orden_ejecucion = (select max(prioridad_voces) from [GES_siderar].DBO.[fact_lg_calculo_overrolling_cfg])

				WHILE @orden_ejecucion <= @max_orden_ejecucion

					BEGIN

								SET @SQLQuery =		'UPDATE ovr set voz = '
								SET @SQLQuery +=	'''' + (select top 1 voces from [GES_siderar].DBO.[fact_lg_calculo_overrolling_cfg] where prioridad_voces = @orden_ejecucion) + '''' 
								SET @SQLQuery +=	', subvoz = ' + '''' + (select top 1 isnull(subvoces, '') from [GES_siderar].DBO.[fact_lg_calculo_overrolling_cfg] where prioridad_voces = @orden_ejecucion) + '''' + char(13)
								SET @SQLQuery +=	'from ##fact_lg_calculo_overrolling_posible_ovr ovr' + char(13) + 'where ovr.material_key in (select material_key from '
								SET @SQLQuery +=	(select top 1 tabla_voces from [GES_siderar].DBO.[fact_lg_calculo_overrolling_cfg] where prioridad_voces = @orden_ejecucion) + ')' + char(13)

								EXEC (@SQLQuery)

								SET @orden_ejecucion += 1

					END

			-- FIN VOCES

			-- Borro de Posible OVR los Vacío > EXP y Vacío > MTO que no tengan el tipo de movimiento en cuestión, 
			-- dejando los movimientos con alguna voz encontrados

			delete ovr from ##fact_lg_calculo_overrolling_posible_ovr ovr 
			where ((ovr.valor_posterior = 'EXP' and not isnull(ovr.cod_clase_doc, '') in ('ZBVA', 'ZPOV', 'ZPNF'))
			or (ovr.valor_posterior = 'MTO' and not isnull(ovr.cod_clase_doc, '') in ('ZWEB')))
			and 
			(
			ovr.material_key not in (select material_key from ##fact_lg_calculo_overrolling_RC_CHILE_COMERCIAL with(nolock))
			and ovr.material_key not in (select material_key from ##fact_lg_calculo_overrolling_RC_CHILE_ETP with(nolock))
			and ovr.material_key not in (select material_key from ##fact_lg_calculo_overrolling_RC_N05 with(nolock))
			and ovr.material_key not in (select material_key from ##fact_lg_calculo_overrolling_RC_BLC with(nolock))
			and ovr.material_key not in (select material_key from ##fact_lg_calculo_overrolling_RC_412 with(nolock))
			and ovr.material_key not in (select material_key from ##fact_lg_calculo_overrolling_RC_410 with(nolock))
			)

			-- Borro los materiales con calidad SCRAP

			delete ovr from ##fact_lg_calculo_overrolling_posible_ovr ovr
			where ovr.cod_calidad = 'Scrap' and ovr.voz not in ('COBBLES')

			-- Elimino los recuperos

			delete from ##fact_lg_calculo_overrolling_posible_ovr where 
			material_key in (select material_key from ##fact_lg_calculo_overrolling_RECUEBXCHT)

			-- Inserto en las tablas finales los resultados del SP

			set identity_insert [Ges_siderar].DBO.[fact_lg_calculo_overrolling] ON

				insert into [GES_Siderar].DBO.[fact_lg_calculo_overrolling]
				(cod_clase_doc, id_movimiento, fact_lg_movimientos_cab_key, material_key, nro_bulto, Cod_Tipo_Movimiento, Desc_Tipo_Movimiento,
				Variable_Cod, valor_anterior, valor_posterior, Fecha_Movimiento, cod_cliente, 
				pro_norma_desc, pro_grado_desc, pro_subnorma_desc, Clase_cod, espesor_valor, ancho_valor, largo_valor, peso_neto,
				cod_grado_acero, desc_tipo_calidad, cod_tipo_ofa, desc_tipo_calidad, Planta, tipo, ofa_documento, ofa_posicion, 
				ofa_necesidad, marca_logica_calculo, cod_linea, cod_linea_imputacion, desc_defecto, desc_causa_defecto,
				pro_cod, cod_motivo_pedido, calidad_cod, cod_calidad, gale, observaciones, voz, subvoz)

				select * from #posible_ovr
				where #posible_ovr.material_key not in (select material_key from [GES_Siderar].DBO.[fact_lg_calculo_overrolling])
				 
				insert into [GES_Siderar].DBO.[fact_lg_calculo_overrolling] (fecha_marca_ovr)
				select @FechaIni

			set identity_insert [Ges_siderar].DBO.[fact_lg_calculo_overrolling] OFF

			EXEC ST_Siderar..Audit_FinLog_Industrial	@Log_id
	
		COMMIT TRAN

		END TRY

		BEGIN CATCH
		
			SET @Errores = ERROR_NUMBER()
			SET @ErrDesc = ERROR_MESSAGE()
			SET @Text_Err = 'Falla en el llamado al store ges_bch_lg_calculo_overrolling con log_id '+  convert(varchar(20), @log_id)


			EXEC ST_Siderar..Audit_ErrLog_Industrial	@Dominio ='PROCESO_CALCULO_OVERROLLING', 
												@Tipo_Proceso ='BATCH',  
												@Origen = 'DWH', 
												@Paso = 'ges_bch_lg_calculo_overrolling', 
												@Cod_Err = @Errores, 
												@Desc_Err = @ErrDesc, 
												@Text_Err = @Text_Err, 
												@Data_err = '', 
												@tipo_err = '', 
												@LogId = @Log_ID
				
			ROLLBACK TRAN
		
		END CATCH

END
