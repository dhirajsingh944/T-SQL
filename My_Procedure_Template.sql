USE [database_name]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
-- ================================================
-- Author:		dhiraj.s
-- Create date: 
-- Description:	
-- ================================================
/*

*/
-- ================================================
CREATE PROCEDURE [dbo].[procedure_name] 
	@admin_id			INT
AS
BEGIN

	SET NOCOUNT ON;	

    DECLARE @hDoc		INT;
	DECLARE @list_id	INT;


    IF Object_id('tempdb..#keyword') IS NOT NULL
    DROP TABLE #keyword;
	CREATE TABLE #keyword
	(
		i_keyword_list_id	INT,
		i_keyword_id		INT,
		i_percentage		INT
	);


	BEGIN TRY

		EXEC Sp_xml_preparedocument
		@hDoc OUTPUT,
		@keyword_data;

		INSERT INTO #keyword
		(
			i_keyword_list_id,
			i_keyword_id,
			i_percentage
		)
		SELECT	keyword_list_id, 
				keyword_id,
				percentage_value
		FROM	OPENXML(@hDoc, '/root/keyword_list/keyword_details')
				WITH ( 
						keyword_list_id		INT '../@keyword_list_id',
						keyword_id			INT,
						percentage_value	INT
				)
		;

		EXEC Sp_xml_removedocument @hDoc

		DROP TABLE IF EXISTS #keyword;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0  
			ROLLBACK TRANSACTION;
	
		DECLARE @ErrorMessage	NVARCHAR(4000);
		DECLARE @ErrorSeverity	INT;
		DECLARE @ErrorState		INT;
		
		SELECT
			@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE();

		SET @ErrorMessage = CONCAT('procedure_name-',@ErrorMessage)

		DROP TABLE IF EXISTS #keyword;

		-- Use RAISERROR inside the CATCH block to return error
		-- information about the original error that caused
		-- execution to jump to the CATCH block.
		RAISERROR(
			@ErrorMessage,	-- Message text.
			@ErrorSeverity, -- Severity.
			@ErrorState		-- State.
		);
	END CATCH

END 
GO


GRANT EXECUTE ON OBJECT::CAMPAIGN_MANAGEMENT.dbo.procedure_name
TO [mnetweb-dmadmin];
GO
