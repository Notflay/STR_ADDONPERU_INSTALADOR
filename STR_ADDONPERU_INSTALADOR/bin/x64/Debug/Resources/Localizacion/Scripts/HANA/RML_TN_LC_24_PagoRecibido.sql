CREATE FUNCTION RML_TN_LC_24_PagoRecibido
(
	IN id NVARCHAR(50),
	IN transaction_type NVARCHAR(1)
)
RETURNS error_message NVARCHAR(200)
AS
user VARCHAR(20);
R1 VARCHAR(30);
R2 VARCHAR(30);
R3 VARCHAR(30);
R4 VARCHAR(30);
R5 VARCHAR(30);
DOCTYPE NCHAR(1);

DATA INTEGER; 
R6 INTEGER; 
R7 INTEGER; 
R8 INTEGER; 
R9 INTEGER;
R10 INTEGER;
Campovalida INTEGER;
TpTr int;
DcOP int;


BEGIN
	IF :transaction_type = 'A' OR :transaction_type = 'U' THEN
		select (SELECT count(*) FROM ORCT T0 
	            WHERE T0."U_BPP_MPPG" ='000'  and t0."DataSource"<> 'O'
	             AND T0."DocEntry" = :id) into R1 from dummy;
	            IF :R1 > 0
	             then 
	             error_message := 'STR_A: Ingrese el Medio de Pago SUNAT'; 
	             END if;
	 END IF;
END