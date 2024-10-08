CREATE FUNCTION REPLICATE
(
string nvarchar(10),
repeat_count int
)
RETURNS replicated nvarchar(4000)
LANGUAGE SQLSCRIPT AS
BEGIN

SELECT LPAD('', LENGTH(:string) * :repeat_count, :string) INTO "REPLICATED" FROM dummy;

END;
