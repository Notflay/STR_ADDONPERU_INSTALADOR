CREATE PROCEDURE STR_SP_LT_MaestroLetra
(
@codLet nvarchar(20)
, @EstAct int
,@EstAnt int
,@fecha DateTime
,@serie varchar(10)
,@TipoRen int
, @TipoLet int)
--  exec SP_LT_MaestroLetra -1,1,0,'2009-01-16 10:48:21.310'

as
begin
	DECLARE @Name			 nVarchar(60)
			,@Code			 nVarchar(16)
			,@codStrLet		 nVarchar(20)
			-- 12082013 - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
			,@nCodLet		 numeric			
						
			if isnull(CHARINDEX('-', @codLet, 1), 0)<>0
			begin
				if(@CodLet <> '-1')				
				begin
					set @nCodLet = SUBSTRING(@codLet, 1, CHARINDEX('-', @codLet, 1)- 1)
				end
				else
				begin
					set @nCodLet = @codLet
				end					
			end
			else
			begin
				set @nCodLet = @codLet
			end	
				
					
			-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	set @Code = (Select isnull(max(convert(int,Code)),0)+1 from "@ST_LT_mstlet" )	
	set @Name = 'Letra '+@Code
	if(@TipoRen = 0) --Se genera una nueva letra
	begin
		if(@nCodLet = -1)
		begin
			set @nCodLet = (Select isnull(max(U_codLet),0)+1 from "@ST_LT_mstlet"  where U_cdStLet like 'LET%' and u_serie =  @serie And u_tipo = case when @TipoLet = 1 then '001' else '002' end)
		end	
		set @codStrLet = 'LET'+right('0000000000'+cast(@nCodLet as varchar),10)
	end	
	else --Se renueva una letra
	begin
		set @codStrLet = 'LET'+right('0000000000'+cast(@nCodLet as varchar),10) +'-'+ right('00'+cast(@TipoRen as varchar),2)
	end
	
	--if @EstAct <> 2	--Si no es cartera entonces se busca la serie de cartera para obtener la serie
--		set @Serie = (select top 1 u_serie from [@ST_LT_mstlet] where u_cdstlet =@codStrLet And u_estAct = '002' order by cast(code as int) desc)	
	
	insert into "@ST_LT_mstlet" values (@Code,@Name,@fecha,@nCodLet,@codStrLet,right('000'+cast(@EstAct as varchar),3),right('000'+cast(@EstAnt as varchar),3),@serie,case when @TipoLet = 1 then '001' else '002' end)
end