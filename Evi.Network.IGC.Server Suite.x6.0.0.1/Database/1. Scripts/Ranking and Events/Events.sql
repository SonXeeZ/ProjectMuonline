USE [Events] -- 9.1.0.1
GO
/****** Object:  StoredProcedure [dbo].[SP_POINT_ACCM_BC_3RD]    Script Date: 04/04/2014 21:57:21 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE	[dbo].[SP_POINT_ACCM_BC_3RD]

	@Server		smallint,
	@Bridge		tinyint,
	@AccountID		varchar(10),
	@CharacterName	varchar(10),
	@Class			tinyint,
	@Point			int,
	@PCRoomGUID	int,
	@LeftTime		int
AS
BEGIN
	
	BEGIN TRANSACTION
	
	SET NOCOUNT ON	

	IF(@@Error <> 0 )
		ROLLBACK TRANSACTION
	ELSE	
		COMMIT TRANSACTION

	SET NOCOUNT OFF	
END



GO
/****** Object:  StoredProcedure [dbo].[SP_POINT_ACCM_BC_4TH]    Script Date: 04/04/2014 21:57:21 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE	[dbo].[SP_POINT_ACCM_BC_4TH]

	@Server		smallint,
	@Bridge		tinyint,
	@AccountID		varchar(10),
	@CharacterName	varchar(10),
	@Class			tinyint,
	@Point			int,
	@PCRoomGUID	int,
	@LeftTime		int
AS
BEGIN	
	BEGIN TRANSACTION
	
	SET NOCOUNT ON	

	IF(@@Error <> 0 )
		ROLLBACK TRANSACTION
	ELSE	
		COMMIT TRANSACTION

	SET NOCOUNT OFF	
END



GO
/****** Object:  StoredProcedure [dbo].[SP_POINT_ACCM_BC_5TH]    Script Date: 04/04/2014 21:57:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE	[dbo].[SP_POINT_ACCM_BC_5TH]

	@Server		smallint,
	@Bridge		tinyint,
	@AccountID	 	varchar(10),
	@CharacterName	varchar(10),
	@Class			tinyint,
	@Point			int,
	@LeftTime		int,
	@AlivePartyCount	int
AS
BEGIN	
	BEGIN TRANSACTION
	
	SET NOCOUNT ON

	DECLARE @RegDate	SMALLDATETIME
	SET @RegDate = CAST(DATEPART(YY, GetDate()) AS VARCHAR(4)) + '-' + CAST(DATEPART(MM, GetDate()) AS VARCHAR(2)) + '-' + CAST(DATEPART(DD, GetDate()) AS VARCHAR(2)) + ' 00:00:00'

	IF EXISTS (SELECT CharacterName FROM EVENT_INFO_BC_5TH  WITH (READUNCOMMITTED) 
				WHERE RegDate = @RegDate AND Server = @Server AND AccountID = @AccountID AND CharacterName = @CharacterName)
		BEGIN			
			DECLARE @iiiPoint		int
			DECLARE @iMinLeftTime		int
			DECLARE @iAlivePartyCount	int
			DECLARE @iMaxPointLeftTime	int

			SELECT @iiiPoint = Point, @iMinLeftTime = MinLeftTime, @iAlivePartyCount = AlivePartyCount, @iMaxPointLeftTime = MaxPointLeftTime
			FROM EVENT_INFO_BC_5TH
			WHERE  RegDate = @RegDate AND Server = @Server  AND AccountID = @AccountID AND CharacterName = @CharacterName

			IF (@iiiPoint < @Point)
			BEGIN
				IF (@Point > 0)
				BEGIN
					SET @iiiPoint = @Point
					SET @iMaxPointLeftTime = @LeftTime
				END
			END

			IF (@iiiPoint = @Point)
			BEGIN
				IF (@Point > 0)
				BEGIN
					IF (@iMaxPointLeftTime < @LeftTime)
					BEGIN
						SET @iMaxPointLeftTime = @LeftTime
					END
				END
			END

			IF (@iAlivePartyCount <= @AlivePartyCount)
			BEGIN
				IF (@iMinLeftTime < @LeftTime)
				BEGIN
					IF (@Point > 0)
					BEGIN
						SET @iMinLeftTime = @LeftTime
					END
				END
				SET @iAlivePartyCount = @AlivePartyCount
			END

			IF (@iiiPoint < 0)
			BEGIN
				UPDATE EVENT_INFO_BC_5TH
				SET Point = 0 , Bridge = @Bridge, PlayCount = PlayCount+1, SumLeftTime = SumLeftTime + @LeftTime, MinLeftTime = @iMinLeftTime, AlivePartyCount = @iAlivePartyCount, MaxPointLeftTime = @iMaxPointLeftTime
				WHERE  RegDate = @RegDate AND Server = @Server  AND AccountID = @AccountID AND CharacterName = @CharacterName	
			END	
			ELSE
			BEGIN
				UPDATE EVENT_INFO_BC_5TH
				SET Point = @iiiPoint, Bridge = @Bridge, PlayCount = PlayCount+1, SumLeftTime = SumLeftTime + @LeftTime, MinLeftTime = @iMinLeftTime, AlivePartyCount = @iAlivePartyCount, MaxPointLeftTime = @iMaxPointLeftTime
				WHERE  RegDate = @RegDate AND Server = @Server  AND AccountID = @AccountID AND CharacterName = @CharacterName	
			END
		END
	ELSE
		BEGIN
			IF (@Point < 0)
			BEGIN
				INSERT INTO EVENT_INFO_BC_5TH (Server,  Bridge, AccountID, CharacterName, Class, Point, PlayCount, SumLeftTime, MinLeftTime, RegDate, AlivePartyCount, MaxPointLeftTime) VALUES (
					@Server,
					@Bridge,
					@AccountID,
					@CharacterName,
					@Class,
					0,
					1,
					0,
					0,
					@RegDate,
					0,
					0
				)
			END
			ELSE
			BEGIN
				INSERT INTO EVENT_INFO_BC_5TH (Server,  Bridge, AccountID, CharacterName, Class, Point, PlayCount, SumLeftTime, MinLeftTime, RegDate, AlivePartyCount, MaxPointLeftTime) VALUES (
					@Server,
					@Bridge,
					@AccountID,
					@CharacterName,
					@Class,
					@Point,
					1,
					@LeftTime,
					@LeftTime,
					@RegDate,
					@AlivePartyCount,
					@LeftTime
				)
			END

		END

	IF(@@Error <> 0 )
		ROLLBACK TRANSACTION
	ELSE	
		COMMIT TRANSACTION

	SET NOCOUNT OFF	
END



GO
/****** Object:  StoredProcedure [dbo].[SP_REG_CC_OFFLINE_GIFT]    Script Date: 04/04/2014 21:57:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE	[dbo].[SP_REG_CC_OFFLINE_GIFT]

	@AccountID		varchar(10),	
	@CharName		varchar(10),	
	@ServerCode		int
AS
BEGIN
	BEGIN TRANSACTION

	DECLARE @iGIFT_GUID	INT
	DECLARE @iGIFT_KIND	INT
	DECLARE @iGIFT_NAME	VARCHAR(50)
	
	SET NOCOUNT ON

		IF EXISTS (SELECT TOP 1 Guid FROM T_CC_OFFLINE_GIFT WHERE Date_Give < GetDate() and RegCheck = 0 ORDER BY Guid ASC)
		BEGIN
			SELECT TOP 1 @iGIFT_GUID = Guid, @iGIFT_KIND = GiftKind  FROM T_CC_OFFLINE_GIFT WHERE Date_Give < GetDate() and RegCheck = 0 ORDER BY Guid ASC
	
			UPDATE T_CC_OFFLINE_GIFT SET Server = @ServerCode, AccountID = @AccountID, CharName = @CharName, Date_Reg = GetDate(), RegCheck = 1 WHERE Guid = @iGIFT_GUID
	
			SELECT @iGIFT_NAME = GiftName FROM T_CC_OFFLINE_GIFTNAME WHERE GiftKind = @iGIFT_KIND
	
			SELECT 1 As ResultCode, @iGIFT_NAME As GiftName
		END
		ELSE
		BEGIN
			SELECT 0 As ResultCode, '' As GiftName
		END

	IF(@@Error <> 0 )
		ROLLBACK TRANSACTION
	ELSE	
		COMMIT TRANSACTION
	
	SET NOCOUNT OFF
END




GO
/****** Object:  StoredProcedure [dbo].[SP_REG_KANTURU_TIMEATTACK_EVENT]    Script Date: 04/04/2014 21:57:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[SP_REG_KANTURU_TIMEATTACK_EVENT]

	@AccountID	varchar(10),
	@Name		varchar(10),
	@ServerCode	smallint,
	@BattleID	varchar(13),
	@StageNum	tinyint,
	@ClearTime	smallint,
	@Level		int,
	@Experience	int
AS
BEGIN
	BEGIN TRANSACTION

	SET 		NOCOUNT ON
	SET		XACT_ABORT ON

	SET		 LOCK_TIMEOUT	1000

	BEGIN
	INSERT T_KanturuTimeAttackEvent2006 VALUES (@AccountID, @Name, @ServerCode, @BattleID, @StageNum, @ClearTime, @Level, @Experience, GetDate() )
	END

	IF( @@Error <>0 )
		ROLLBACK TRANSACTION		
	ELSE
		COMMIT TRANSACTION		

	SET NOCOUNT OFF
END




GO
/****** Object:  StoredProcedure [dbo].[SP_REG_SERIAL]    Script Date: 04/04/2014 21:57:21 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE	[dbo].[SP_REG_SERIAL]
	@AccountID		varchar(10),	@MembGUID		int,	@SERIAL1		varchar(4),	@SERIAL2		varchar(4),	@SERIAL3		varchar(4)AS
BEGIN	BEGIN TRANSACTION
	SET NOCOUNT ON	
	DECLARE @MAX_REGCOUNT	INT	DECLARE @iREG_COUNT	INT	DECLARE @iREG_ALREADY	BIT
	SET @MAX_REGCOUNT 	= 10	SET @iREG_ALREADY	= 0
	IF EXISTS ( SELECT * FROM T_RegCount_Check  WITH (READUNCOMMITTED) 
				WHERE AccountID = @AccountID)	BEGIN	
		SELECT @iREG_ALREADY = RegAlready FROM T_RegCount_Check WHERE AccountID = @AccountID
		IF (@iREG_ALREADY = 1 )
		BEGIN			SELECT 5 As RegResult, 0 As F_Register_Section		END		ELSE		BEGIN			SELECT @iREG_COUNT = RegCount 
			FROM T_RegCount_Check
			WHERE AccountID = @AccountID
			IF (@iREG_COUNT >= @MAX_REGCOUNT)
			BEGIN				SET @iREG_ALREADY = 1
				SELECT 1 As RegResult, 0 As F_Register_Section
			END			ELSE			BEGIN				UPDATE T_RegCount_Check
				SET RegCount = RegCount + 1
				WHERE AccountID = @AccountID
			END		END
	END	ELSE	BEGIN		INSERT INTO T_RegCount_Check
		VALUES (@AccountID, default, default)
	END
	IF (@iREG_ALREADY =1)
	BEGIN
		IF(@@Error <> 0 )
			ROLLBACK TRANSACTION		ELSE				COMMIT TRANSACTION
		SET NOCOUNT OFF	
		RETURN	END
	DECLARE @REG_CHECK	BIT
	IF EXISTS ( SELECT F_RegisterCheck FROM T_Serial_Bank  WITH (READUNCOMMITTED) 
		WHERE  P_Serial_1 = @SERIAL1 and P_Serial_2 = @SERIAL2 and P_Serial_3 = @SERIAL3)
	BEGIN	
		SELECT @REG_CHECK = F_RegisterCheck FROM T_Serial_Bank  WITH (READUNCOMMITTED) 
		WHERE  P_Serial_1 = @SERIAL1 and P_Serial_2 = @SERIAL2 and P_Serial_3 = @SERIAL3
		IF (@REG_CHECK = 0)
		BEGIN
			UPDATE T_Serial_Bank
			SET F_Member_Guid = @MembGUID, F_Member_Id = @AccountID, F_RegisterCheck = 1, F_Register_Date = GetDate()
			WHERE  P_Serial_1 = @SERIAL1 and P_Serial_2 = @SERIAL2 and P_Serial_3 = @SERIAL3
			UPDATE T_RegCount_Check
			SET RegAlready = 1
			WHERE AccountID = @AccountID
			SELECT 0 As RegResult, F_Register_Section
			FROM T_Serial_Bank
			WHERE  P_Serial_1 = @SERIAL1 and P_Serial_2 = @SERIAL2 and P_Serial_3 = @SERIAL3
		END		ELSE		BEGIN
			SELECT 1 As RegResult, 0 As F_Register_Section
		END	END	ELSE	BEGIN		SELECT 3 As RegResult, 0  As F_Register_Section	END
	IF(@@Error <> 0 )
		ROLLBACK TRANSACTION	ELSE			COMMIT TRANSACTION
	SET NOCOUNT OFF	
END




GO
/****** Object:  StoredProcedure [dbo].[SP_SANTA_CHECK]    Script Date: 04/04/2014 21:57:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Dudas, IGCN>
-- Create date: <12/18/2011>
-- Description:	<Santa Clause Checking Conditionals>
-- =============================================
CREATE PROCEDURE [dbo].[SP_SANTA_CHECK] 
	-- Add the parameters for the stored procedure here
	@AccountID varchar(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF NOT EXISTS(SELECT * FROM T_SantaEvent WHERE AccountID = @AccountID)
	BEGIN
		SELECT 0 AS Result, 0 AS VisitCount
	END
	ELSE
	BEGIN
		DECLARE @VisitCount int
	
		SELECT @VisitCount = VisitCount FROM T_SantaEvent WHERE AccountID = @AccountID
	
		IF(@VisitCount > 2) -- you can change this
		BEGIN
			SELECT 3 AS Result, 0 AS VisitCount
		END
		ELSE
		BEGIN
			SELECT 0 AS Result, @VisitCount AS VisitCount
		END
	END
END



GO
/****** Object:  StoredProcedure [dbo].[SP_SANTA_GIFT]    Script Date: 04/04/2014 21:57:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Dudas, IGCN>
-- Create date: <12/18/2011>
-- Description:	<Santa Clause Checking Conditionals>
-- =============================================
CREATE PROCEDURE [dbo].[SP_SANTA_GIFT]
	-- Add the parameters for the stored procedure here
	@AccountID varchar(10),
	@Server int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF NOT EXISTS(SELECT AccountID FROM T_SantaEvent WHERE AccountID = @AccountID)
	BEGIN
		SELECT 0 AS Result, 0 AS VisitCount
		INSERT INTO T_SantaEvent(AccountID, VisitCount, Server, LastVisitDate) VALUES (@AccountID, 1, @Server, GETDATE())
	END
	ELSE
	BEGIN
		DECLARE @VisitCount int
	
		SELECT @VisitCount = VisitCount FROM T_SantaEvent WHERE AccountID = @AccountID
	
		IF(@VisitCount > 2) -- you can change this
		BEGIN
			SELECT 3 AS Result, @VisitCount AS VisitCount
		END
		ELSE
		BEGIN
			SELECT 0 AS Result, @VisitCount AS VisitCount
			UPDATE T_SantaEvent SET VisitCount = @VisitCount+1, Server = @Server, LastVisitDate=GETDATE() WHERE AccountID = @AccountID
		END
	END
END



GO
/****** Object:  Table [dbo].[EVENT_INFO_BC_3RD]    Script Date: 04/04/2014 21:57:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EVENT_INFO_BC_3RD](
	[Server] [tinyint] NOT NULL,
	[Bridge] [tinyint] NOT NULL,
	[AccountID] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CharacterName] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Class] [tinyint] NOT NULL,
	[Point] [int] NOT NULL,
	[PlayCount] [int] NOT NULL,
	[SumLeftTime] [int] NOT NULL,
 CONSTRAINT [PK_EVENT_INFO_BC_3RD] PRIMARY KEY CLUSTERED 
(
	[Server] ASC,
	[Bridge] ASC,
	[AccountID] ASC,
	[CharacterName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[EVENT_INFO_BC_4TH]    Script Date: 04/04/2014 21:57:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EVENT_INFO_BC_4TH](
	[Server] [tinyint] NOT NULL,
	[Bridge] [tinyint] NOT NULL,
	[AccountID] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CharacterName] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Class] [tinyint] NOT NULL,
	[Point] [int] NOT NULL,
	[PlayCount] [int] NOT NULL,
	[SumLeftTime] [int] NOT NULL,
	[MinLeftTime] [int] NOT NULL,
 CONSTRAINT [PK_EVENT_INFO_BC_4TH] PRIMARY KEY CLUSTERED 
(
	[Server] ASC,
	[Bridge] ASC,
	[AccountID] ASC,
	[CharacterName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[EVENT_INFO_BC_5TH]    Script Date: 04/04/2014 21:57:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EVENT_INFO_BC_5TH](
	[Server] [tinyint] NOT NULL,
	[Bridge] [tinyint] NOT NULL,
	[AccountID] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CharacterName] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Class] [tinyint] NOT NULL,
	[Point] [int] NOT NULL,
	[PlayCount] [int] NOT NULL,
	[SumLeftTime] [int] NOT NULL,
	[MinLeftTime] [int] NOT NULL,
	[RegDate] [smalldatetime] NOT NULL,
	[AlivePartyCount] [int] NOT NULL,
	[MaxPointLeftTime] [int] NOT NULL,
 CONSTRAINT [PK_EVENT_INFO_BC_5TH] PRIMARY KEY CLUSTERED 
(
	[Server] ASC,
	[Bridge] ASC,
	[AccountID] ASC,
	[CharacterName] ASC,
	[RegDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_CC_OFFLINE_GIFT]    Script Date: 04/04/2014 21:57:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_CC_OFFLINE_GIFT](
	[Guid] [int] IDENTITY(1,1) NOT NULL,
	[Server] [int] NULL,
	[AccountID] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CharName] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[GiftKind] [int] NOT NULL,
	[Date_Give] [smalldatetime] NOT NULL,
	[Date_Reg] [smalldatetime] NULL,
	[RegCheck] [tinyint] NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_CC_OFFLINE_GIFTNAME]    Script Date: 04/04/2014 21:57:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_CC_OFFLINE_GIFTNAME](
	[GiftKind] [int] NOT NULL,
	[GiftName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
 CONSTRAINT [PK_T_CC_OFFLINE_GIFTNAME] PRIMARY KEY CLUSTERED 
(
	[GiftKind] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_KanturuTimeAttackEvent2006]    Script Date: 04/04/2014 21:57:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_KanturuTimeAttackEvent2006](
	[AccountID] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Name] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ServerCode] [smallint] NOT NULL,
	[BattleID] [varchar](13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[StageNum] [tinyint] NOT NULL,
	[ClearTime] [int] NOT NULL,
	[Level] [int] NOT NULL,
	[Experience] [int] NOT NULL,
	[RegDate] [smalldatetime] NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_LuckyCoin]    Script Date: 04/04/2014 21:57:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_LuckyCoin](
	[AccountID] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[LuckyCoin] [int] NOT NULL,
 CONSTRAINT [PK_T_LuckyCoin] PRIMARY KEY CLUSTERED 
(
	[AccountID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_RegCount_Check]    Script Date: 04/04/2014 21:57:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_RegCount_Check](
	[AccountID] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[RegCount] [int] NOT NULL,
	[RegAlready] [bit] NOT NULL,
 CONSTRAINT [PK_T_RegCount_Check] PRIMARY KEY CLUSTERED 
(
	[AccountID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_Register_Info]    Script Date: 04/04/2014 21:57:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_Register_Info](
	[F_Register_Section] [smallint] NOT NULL,
	[F_Register_Name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[F_Register_TotalCount] [int] NOT NULL,
 CONSTRAINT [PK_T_Register_Info] PRIMARY KEY CLUSTERED 
(
	[F_Register_Section] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_SantaEvent]    Script Date: 04/04/2014 21:57:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_SantaEvent](
	[AccountID] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[VisitCount] [int] NOT NULL,
	[LastVisitDate] [smalldatetime] NULL,
	[Server] [smallint] NULL,
 CONSTRAINT [PK_T_SantaEvent] PRIMARY KEY CLUSTERED 
(
	[AccountID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_Serial_Bank]    Script Date: 04/04/2014 21:57:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_Serial_Bank](
	[F_Serial_Guid] [int] IDENTITY(1,1) NOT NULL,
	[P_Serial_1] [char](4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[P_Serial_2] [char](4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[P_Serial_3] [char](4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[F_Serial_Section] [smallint] NOT NULL,
	[F_Member_Guid] [int] NULL,
	[F_Member_Id] [char](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[F_Register_Section] [smallint] NULL,
	[F_Register_Date] [smalldatetime] NULL,
	[F_Create_Date] [smalldatetime] NOT NULL,
	[F_RegisterCheck] [bit] NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [PK_T_CC_OFFLINE_GIFT]    Script Date: 04/04/2014 21:57:21 ******/
ALTER TABLE [dbo].[T_CC_OFFLINE_GIFT] ADD  CONSTRAINT [PK_T_CC_OFFLINE_GIFT] PRIMARY KEY NONCLUSTERED 
(
	[Guid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [PK_T_Serial_Bank]    Script Date: 04/04/2014 21:57:21 ******/
ALTER TABLE [dbo].[T_Serial_Bank] ADD  CONSTRAINT [PK_T_Serial_Bank] PRIMARY KEY NONCLUSTERED 
(
	[P_Serial_1] ASC,
	[P_Serial_2] ASC,
	[P_Serial_3] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EVENT_INFO_BC_3RD] ADD  CONSTRAINT [DF_EVENT_INFO_BC_3RD_SumLeftTime]  DEFAULT ((0)) FOR [SumLeftTime]
GO
ALTER TABLE [dbo].[EVENT_INFO_BC_4TH] ADD  CONSTRAINT [DF_EVENT_INFO_BC_4TH_SumLeftTime]  DEFAULT ((0)) FOR [SumLeftTime]
GO
ALTER TABLE [dbo].[EVENT_INFO_BC_4TH] ADD  CONSTRAINT [DF_EVENT_INFO_BC_4TH_MinLeftTime]  DEFAULT ((0)) FOR [MinLeftTime]
GO
ALTER TABLE [dbo].[EVENT_INFO_BC_5TH] ADD  CONSTRAINT [DF_EVENT_INFO_BC_5TH_SumLeftTime]  DEFAULT ((0)) FOR [SumLeftTime]
GO
ALTER TABLE [dbo].[EVENT_INFO_BC_5TH] ADD  CONSTRAINT [DF_EVENT_INFO_BC_5TH_MinLeftTime]  DEFAULT ((0)) FOR [MinLeftTime]
GO
ALTER TABLE [dbo].[EVENT_INFO_BC_5TH] ADD  CONSTRAINT [DF_EVENT_INFO_BC_5TH_MaxPointLeftTime]  DEFAULT ((0)) FOR [MaxPointLeftTime]
GO
ALTER TABLE [dbo].[T_CC_OFFLINE_GIFT] ADD  CONSTRAINT [DF_T_CC_OFFLINE_GIFT_Date_Reg]  DEFAULT (getdate()) FOR [Date_Reg]
GO
ALTER TABLE [dbo].[T_CC_OFFLINE_GIFT] ADD  CONSTRAINT [DF_T_CC_OFFLINE_GIFT_RegCheck]  DEFAULT ((0)) FOR [RegCheck]
GO
ALTER TABLE [dbo].[T_KanturuTimeAttackEvent2006] ADD  CONSTRAINT [DF__T_Kanturu__RegDa__6B24EA82]  DEFAULT (getdate()) FOR [RegDate]
GO
ALTER TABLE [dbo].[T_LuckyCoin] ADD  CONSTRAINT [DF_T_LuckyCoin_LuckyCoin]  DEFAULT ((0)) FOR [LuckyCoin]
GO
ALTER TABLE [dbo].[T_RegCount_Check] ADD  CONSTRAINT [DF_T_RegCount_Check_RegCount]  DEFAULT ((1)) FOR [RegCount]
GO
ALTER TABLE [dbo].[T_RegCount_Check] ADD  CONSTRAINT [DF_T_RegCount_Check_RegAlready]  DEFAULT ((0)) FOR [RegAlready]
GO
ALTER TABLE [dbo].[T_SantaEvent] ADD  CONSTRAINT [DF_T_SantaEvent_VisitCount]  DEFAULT ((0)) FOR [VisitCount]
GO
ALTER TABLE [dbo].[T_Serial_Bank] ADD  CONSTRAINT [DF_T_Serial_Bank_F_RegisterCheck]  DEFAULT ((0)) FOR [F_RegisterCheck]
GO
