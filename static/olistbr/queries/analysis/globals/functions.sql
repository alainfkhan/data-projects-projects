USE olist;
GO

-- ====================================================================================================
-- FORMATS

-- ==================================================
-- datetime to datekey function (avoid using)
CREATE OR ALTER FUNCTION utils.fn_datetime_to_datekey(
    @i_date DATETIME2
)
RETURNS INT
AS
BEGIN
    DECLARE @date_key INT = CONCAT(
        DATEPART(YEAR, @i_date),
        FORMAT(DATEPART(MONTH, @i_date), '00'),
        FORMAT(DATEPART(DAY, @i_date), '00')
    )
    RETURN @date_key
END;
GO

-- ==================================================
CREATE OR ALTER FUNCTION utils.fn_seconds_to_ddhhmmss(
    @total_seconds BIGINT
)
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @days SMALLINT
    DECLARE @hours TINYINT
    DECLARE @minutes TINYINT
    DECLARE @seconds TINYINT

    DECLARE @remaining_seconds BIGINT = ABS(@total_seconds)

    SET @days = @remaining_seconds / 86400
    SET @remaining_seconds = @remaining_seconds % 86400

    SET @hours = @remaining_seconds / 3600
    SET @remaining_seconds = @remaining_seconds % 3600

    SET @minutes = @remaining_seconds / 60
    SET @seconds = @remaining_seconds % 60

    DECLARE @duration VARCHAR(50) = ''
    IF @total_seconds < 0
        SET @duration += '-'

    IF @days > 0
        SET @duration = CONCAT(
            @duration,
            CAST(@days AS VARCHAR),
            CASE WHEN @days > 1
                THEN ' days '
                ELSE ' day '
            END
    )

    SET @duration = CONCAT(
        @duration,
        FORMAT(@hours, '00'), ':',
        FORMAT(@minutes, '00'), ':',
        FORMAT(@seconds, '00')
    )

    IF @total_seconds IS NULL
        SET @duration = NULL

    RETURN @duration
END;
GO

-- ==================================================
CREATE OR ALTER FUNCTION utils.fn_format_brl(
    @value REAL
)
RETURNS NVARCHAR(50)
AS
BEGIN
    RETURN FORMAT(@value, 'C', 'pt-BR')
END;
GO

-- ====================================================================================================
-- CALCULATIONS

-- ================================================== 
CREATE OR ALTER FUNCTION utils.fn_pcc(
    @old REAL,
    @new REAL
)
RETURNS REAL
AS
BEGIN
    RETURN 1.0 * (@new - @old) / NULLIF(@old, 0)
END;
GO
