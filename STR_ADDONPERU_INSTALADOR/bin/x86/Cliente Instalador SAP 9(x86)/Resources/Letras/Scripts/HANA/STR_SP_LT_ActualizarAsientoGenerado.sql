CREATE PROCEDURE STR_SP_LT_ActualizarAsientoGenerado
(
	docent int,
	lineid int,
	trnsid int
)
as
begin
	update "@ST_LT_ELLETRAS" set "U_NumAsi" = :trnsid where "DocEntry" = :docent AND "LineId" = :lineid;
end;

