USE [Ranking] -- 9.1.0.1
GO
/****** Object:  StoredProcedure [dbo].[_SP_ENTER_CHECK_BC]    Script Date: 04/04/2014 22:03:19 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE	[dbo].[_SP_ENTER_CHECK_BC]

	@AccountID		varchar(10),
	@CharacterName	varchar(10),
	@Server		smallint
AS
BEGIN
	DECLARE	@iMaxEnterCheck	INT
	DECLARE	@iNowEnterCheck	INT

	SET		@iMaxEnterCheck	= 6
	
	BEGIN TRANSACTION
	
	SET NOCOUNT ON	

	IF EXISTS (SELECT AccountID FROM T_ENTER_CHECK_BC  WITH (READUNCOMMITTED) 
				WHERE  AccountID = @AccountID AND ServerCode = @Server AND CharName = @CharacterName)
	BEGIN
		SELECT @iNowEnterCheck = ToDayEnterCount 
		FROM T_ENTER_CHECK_BC  WITH (READUNCOMMITTED) 
		WHERE  AccountID = @AccountID AND ServerCode = @Server AND CharName = @CharacterName

		IF (@iNowEnterCheck >= @iMaxEnterCheck)
		BEGIN
			SELECT 0 AS EnterResult
		END
		ELSE
		BEGIN
			UPDATE T_ENTER_CHECK_BC 
			SET ToDayEnterCount = ToDayEnterCount + 1, LastEnterDate = GetDate()
			WHERE  AccountID = @AccountID AND ServerCode = @Server AND CharName = @CharacterName

			SELECT 1 AS EnterResult
		END
		
	END
	ELSE
	BEGIN
		INSERT INTO T_ENTER_CHECK_BC (AccountID, CharName, ServerCode, ToDayEnterCount, LastEnterDate) VALUES (
			@AccountID,
			@CharacterName,
			@Server,
			1,
			DEFAULT
		)
	
		SELECT 1 AS EnterResult
	END

	IF(@@Error <> 0 )
		ROLLBACK TRANSACTION
	ELSE	
		COMMIT TRANSACTION

	SET NOCOUNT OFF	
END



GO
/****** Object:  StoredProcedure [dbo].[_SP_POINT_ACCM_BC]    Script Date: 04/04/2014 22:03:19 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE	[dbo].[_SP_POINT_ACCM_BC]

	@Server		smallint,
	@Bridge		tinyint,
	@AccountID		varchar(10),
	@CharacterName	varchar(10),
	@Class			tinyint,
	@Point			int,
	@PCRoomGUID	int
AS
BEGIN	
	BEGIN TRANSACTION
	
	SET NOCOUNT ON	

	IF EXISTS (SELECT CharacterName FROM EVENT_INFO_BC  WITH (READUNCOMMITTED) 
				WHERE  Server = @Server AND AccountID = @AccountID AND CharacterName = @CharacterName)
		BEGIN		
			DECLARE @iiiPoint	int
			SELECT @iiiPoint = Point FROM EVENT_INFO_BC
			WHERE  Server = @Server  AND AccountID = @AccountID AND CharacterName = @CharacterName

			IF (@iiiPoint + @Point < 0)
			BEGIN
				UPDATE EVENT_INFO_BC
				SET Point = 0 , Bridge = @Bridge, PlayCount = PlayCount+1 										 										
				WHERE  Server = @Server  AND AccountID = @AccountID AND CharacterName = @CharacterName	
			END	
			ELSE
			BEGIN
				UPDATE EVENT_INFO_BC
				SET Point = Point + @Point , Bridge = @Bridge, PlayCount = PlayCount+1 										
				WHERE  Server = @Server  AND AccountID = @AccountID AND CharacterName = @CharacterName	
			END
		END
	ELSE
		BEGIN
			INSERT INTO EVENT_INFO_BC (Server,  Bridge, AccountID, CharacterName, Class, Point, PlayCount) VALUES (
				@Server,
				@Bridge,
				@AccountID,
				@CharacterName,
				@Class,
				@Point,
				default	
			)
		END

	IF (@PCRoomGUID <> 0)
	BEGIN
		IF EXISTS (SELECT AccountID FROM T_BC_PCROOM_PLAYCOUNT  WITH (READUNCOMMITTED) 
				WHERE  PCROOM_GUID = @PCRoomGUID AND AccountID = @AccountID)
		BEGIN
			UPDATE T_BC_PCROOM_PLAYCOUNT
			SET PlayCount = PlayCount + 1, Point = Point + @Point
			WHERE PCROOM_GUID = @PCRoomGUID AND AccountID = @AccountID		
		END
		ELSE
		BEGIN
			INSERT INTO T_BC_PCROOM_PLAYCOUNT
			VALUES (@PCRoomGUID, @AccountID, default, @Point)
		END
	END

	IF(@@Error <> 0 )
		ROLLBACK TRANSACTION
	ELSE	
		COMMIT TRANSACTION

	SET NOCOUNT OFF	
END



GO
/****** Object:  StoredProcedure [dbo].[SP_CHECK_BC]    Script Date: 04/04/2014 22:03:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE	[dbo].[SP_CHECK_BC]

	@AccountID		varchar(10),
	@CharacterName	varchar(10),
	@Server		smallint
AS
BEGIN
	DECLARE	@iMaxEnterCheck	INT
	DECLARE	@iNowEnterCheck	INT

	SET		@iMaxEnterCheck	= 6
	
	BEGIN TRANSACTION
	
	SET NOCOUNT ON	

	IF EXISTS (SELECT AccountID FROM T_ENTER_CHECK_BC  WITH (READUNCOMMITTED) 
				WHERE  AccountID = @AccountID AND ServerCode = @Server AND CharName = @CharacterName)
	BEGIN
		SELECT @iNowEnterCheck = ToDayEnterCount 
		FROM T_ENTER_CHECK_BC  WITH (READUNCOMMITTED) 
		WHERE  AccountID = @AccountID AND ServerCode = @Server AND CharName = @CharacterName

		IF (@iNowEnterCheck >= @iMaxEnterCheck)
		BEGIN
			SELECT 0 AS EnterResult
		END
		ELSE
		BEGIN
			SELECT 1 AS EnterResult
		END
		
	END
	ELSE
	BEGIN
		SELECT 1 AS EnterResult
	END

	IF(@@Error <> 0 )
		ROLLBACK TRANSACTION
	ELSE	
		COMMIT TRANSACTION

	SET NOCOUNT OFF	
END



GO
/****** Object:  StoredProcedure [dbo].[SP_CHECK_ILLUSION_TEMPLE]    Script Date: 04/04/2014 22:03:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE	[dbo].[SP_CHECK_ILLUSION_TEMPLE]

	@AccountID		varchar(10),
	@CharacterName	varchar(10),
	@Server		smallint
AS
BEGIN
	DECLARE	@iMaxEnterCheck	INT
	DECLARE	@iNowEnterCheck	INT

	SET		@iMaxEnterCheck	= 6
	
	BEGIN TRANSACTION
	
	SET NOCOUNT ON	

	IF EXISTS (SELECT AccountID FROM T_ENTER_CHECK_ILLUSION_TEMPLE  WITH (READUNCOMMITTED) 
				WHERE  AccountID = @AccountID AND ServerCode = @Server AND CharName = @CharacterName)
	BEGIN
		SELECT @iNowEnterCheck = TodayEnterCount 
		FROM T_ENTER_CHECK_ILLUSION_TEMPLE  WITH (READUNCOMMITTED) 
		WHERE  AccountID = @AccountID AND ServerCode = @Server AND CharName = @CharacterName

		IF (@iNowEnterCheck >= @iMaxEnterCheck)
		BEGIN
			SELECT 0 As EnterResult
		END
		ELSE
		BEGIN
			SELECT 1 As EnterResult
		END
		
	END
	ELSE
	BEGIN
		SELECT 1 As EnterResult
	END

	IF(@@Error <> 0 )
		ROLLBACK TRANSACTION
	ELSE	
		COMMIT TRANSACTION

	SET NOCOUNT OFF	
END



GO
/****** Object:  StoredProcedure [dbo].[SP_ENTER_BC]    Script Date: 04/04/2014 22:03:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE	[dbo].[SP_ENTER_BC]

	@AccountID		varchar(10),
	@CharacterName	varchar(10),
	@Server		smallint
AS
BEGIN
	BEGIN TRANSACTION
	
	SET NOCOUNT ON	

	IF EXISTS (SELECT AccountID FROM T_ENTER_CHECK_BC  WITH (READUNCOMMITTED) 
				WHERE  AccountID = @AccountID AND ServerCode = @Server AND CharName = @CharacterName)
	BEGIN
		UPDATE T_ENTER_CHECK_BC 
		SET ToDayEnterCount = ToDayEnterCount + 1, LastEnterDate = GetDate()
		WHERE  AccountID = @AccountID AND ServerCode = @Server AND CharName = @CharacterName
	END
	ELSE
	BEGIN
		INSERT INTO T_ENTER_CHECK_BC (AccountID, CharName, ServerCode, ToDayEnterCount, LastEnterDate) VALUES (
			@AccountID,
			@CharacterName,
			@Server,
			1,
			DEFAULT
		)
	END

	IF(@@Error <> 0 )
		ROLLBACK TRANSACTION
	ELSE	
		COMMIT TRANSACTION

	SET NOCOUNT OFF	
END



GO
/****** Object:  StoredProcedure [dbo].[SP_ENTER_ILLUSION_TEMPLE]    Script Date: 04/04/2014 22:03:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE	[dbo].[SP_ENTER_ILLUSION_TEMPLE]

	@AccountID		varchar(10),
	@CharacterName	varchar(10),
	@Server		smallint
AS
BEGIN
	BEGIN TRANSACTION
	
	SET NOCOUNT ON	

	IF EXISTS (SELECT AccountID FROM T_ENTER_CHECK_ILLUSION_TEMPLE  WITH (READUNCOMMITTED) 
				WHERE  AccountID = @AccountID AND ServerCode = @Server AND CharName = @CharacterName)
	BEGIN
		UPDATE T_ENTER_CHECK_ILLUSION_TEMPLE 
		SET TodayEnterCount = TodayEnterCount + 1, LastEnterDate = GetDate()
		WHERE  AccountID = @AccountID AND ServerCode = @Server AND CharName = @CharacterName
	END
	ELSE
	BEGIN
		INSERT INTO T_ENTER_CHECK_ILLUSION_TEMPLE (AccountID, CharName, ServerCode, TodayEnterCount, LastEnterDate) VALUES (
			@AccountID,
			@CharacterName,
			@Server,
			1,
			DEFAULT
		)
	END

	IF(@@Error <> 0 )
		ROLLBACK TRANSACTION
	ELSE	
		COMMIT TRANSACTION

	SET NOCOUNT OFF	
END



GO
/****** Object:  StoredProcedure [dbo].[SP_LEFT_ENTERCOUNT_BC]    Script Date: 04/04/2014 22:03:19 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE	[dbo].[SP_LEFT_ENTERCOUNT_BC]

	@AccountID		varchar(10),
	@CharacterName	varchar(10),
	@Server		smallint
AS
BEGIN
	DECLARE	@iMaxEnterCheck	INT
	DECLARE	@iNowEnterCheck	INT

	SET		@iMaxEnterCheck	= 6
	
	BEGIN TRANSACTION
	
	SET NOCOUNT ON	

	IF EXISTS (SELECT AccountID FROM T_ENTER_CHECK_BC  WITH (READUNCOMMITTED) 
				WHERE  AccountID = @AccountID AND ServerCode = @Server AND CharName = @CharacterName)
	BEGIN
		SELECT @iMaxEnterCheck - ToDayEnterCount As LeftEnterCount FROM T_ENTER_CHECK_BC  WITH (READUNCOMMITTED)
		WHERE  AccountID = @AccountID AND ServerCode = @Server AND CharName = @CharacterName
	END
	ELSE
	BEGIN
		INSERT INTO T_ENTER_CHECK_BC (AccountID, CharName, ServerCode, ToDayEnterCount, LastEnterDate) VALUES (
			@AccountID,
			@CharacterName,
			@Server,
			0,
			GetDate()
		)
	
		SELECT @iMaxEnterCheck As LeftEnterCount
	END

	IF(@@Error <> 0 )
		ROLLBACK TRANSACTION
	ELSE	
		COMMIT TRANSACTION

	SET NOCOUNT OFF	
END



GO
/****** Object:  StoredProcedure [dbo].[SP_LEFT_ENTERCOUNT_ILLUSIONTEMPLE]    Script Date: 04/04/2014 22:03:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE	[dbo].[SP_LEFT_ENTERCOUNT_ILLUSIONTEMPLE]

	@AccountID		varchar(10),
	@CharacterName	varchar(10),
	@Server		smallint
AS
BEGIN
	DECLARE	@iMaxEnterCheck	INT
	DECLARE	@iNowEnterCheck	INT

	SET		@iMaxEnterCheck	= 6
	
	BEGIN TRANSACTION
	
	SET NOCOUNT ON	

	IF EXISTS (SELECT AccountID FROM T_ENTER_CHECK_ILLUSION_TEMPLE  WITH (READUNCOMMITTED) 
				WHERE  AccountID = @AccountID AND ServerCode = @Server AND CharName = @CharacterName)
	BEGIN
		SELECT @iMaxEnterCheck - TodayEnterCount As LeftEnterCount FROM T_ENTER_CHECK_ILLUSION_TEMPLE  WITH (READUNCOMMITTED)
		WHERE  AccountID = @AccountID AND ServerCode = @Server AND CharName = @CharacterName
	END
	ELSE
	BEGIN
		INSERT INTO T_ENTER_CHECK_ILLUSION_TEMPLE (AccountID, CharName, ServerCode, TodayEnterCount, LastEnterDate) VALUES (
			@AccountID,
			@CharacterName,
			@Server,
			0,
			GetDate()
		)
	
		SELECT @iMaxEnterCheck As LeftEnterCount
	END

	IF(@@Error <> 0 )
		ROLLBACK TRANSACTION
	ELSE	
		COMMIT TRANSACTION

	SET NOCOUNT OFF	
END



GO
/****** Object:  StoredProcedure [dbo].[SP_POINT_ACCM_BC]    Script Date: 04/04/2014 22:03:19 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE	[dbo].[SP_POINT_ACCM_BC]

	@Server		smallint,
	@Bridge		tinyint,
	@AccountID		varchar(10),
	@CharacterName	varchar(10),
	@Class			tinyint,
	@Point			int,
	@PCRoomGUID	int
AS
BEGIN
	DECLARE	@TEMP	int
END



GO
/****** Object:  StoredProcedure [dbo].[SP_POINT_ACCM_BC_3RD]    Script Date: 04/04/2014 22:03:19 ******/
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
/****** Object:  StoredProcedure [dbo].[SP_POINT_ACCM_BC_4TH]    Script Date: 04/04/2014 22:03:19 ******/
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
/****** Object:  StoredProcedure [dbo].[SP_POINT_ACCM_BC_5TH]    Script Date: 04/04/2014 22:03:19 ******/
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
/****** Object:  StoredProcedure [dbo].[SP_POINT_ACCM_CC]    Script Date: 04/04/2014 22:03:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_POINT_ACCM_CC]
	@Server			tinyint,
	@Castle			tinyint,
	@AccountID		varchar(10),
	@Name			varchar(10),
	@Class			int,
	@PKillCount		smallint,
	@MKillCount		smallint,
	@Experience		bigint,
	@isWinner		tinyint
As
Begin
	
	BEGIN TRANSACTION
	
	SET NOCOUNT ON	

	IF EXISTS ( SELECT Name FROM EVENT_INFO_CC  WITH (READUNCOMMITTED) 
				WHERE  Server = @Server AND AccountID = @AccountID AND Name = @Name )
		Begin			
				UPDATE EVENT_INFO_CC
				SET Castle = @Castle, PKillCount = PKillCount + @PKillCount, MKillCount = MKillCount + @MKillCount, 
				Experience = @Experience, Wins = Wins + @isWinner
				WHERE  Server = @Server  AND AccountID = @AccountID AND Name = @Name
		End
	ELSE
		Begin
			INSERT INTO EVENT_INFO_CC ( Server,  Castle, AccountID, Name, Class, PKillCount, MKillCount, Experience, Wins) VALUES (
				@Server,
				@Castle,
				@AccountID,
				@Name,
				@Class,
				@PKillCount,
				@MKillCount,
				@Experience,
				@isWinner
			)
		End


	IF(@@Error <> 0 )
		ROLLBACK TRANSACTION
	ELSE	
		COMMIT TRANSACTION

	SET NOCOUNT OFF	
End


GO
/****** Object:  StoredProcedure [dbo].[SP_POINT_ACCM_IT]    Script Date: 04/04/2014 22:03:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE	[dbo].[SP_POINT_ACCM_IT]
	@Server		tinyint,
	@Temple		tinyint,
	@AccountID		varchar(10),
	@Name	varchar(10),
	@Class				int,
	@TotalScore			int,
	@KillCount			smallint,
	@RelicsGivenCount	smallint,
	@Experience		bigint,
	@isWinner		tinyint
As
Begin
	
	BEGIN TRANSACTION
	
	SET NOCOUNT ON	

	IF EXISTS ( SELECT Name FROM EVENT_INFO_IT  WITH (READUNCOMMITTED) 
				WHERE  Server = @Server AND AccountID = @AccountID AND Name = @Name )
		Begin			
				UPDATE EVENT_INFO_IT
				SET TotalScore = TotalScore + @TotalScore , Temple = @Temple, KillCount = KillCount + @KillCount, 
				PlayCount = PlayCount+1, RelicsGivenCount = RelicsGivenCount + @RelicsGivenCount, Experience = @Experience, isWinner = @isWinner
				WHERE  Server = @Server  AND AccountID = @AccountID AND Name = @Name
		End
	ELSE
		Begin
			INSERT INTO EVENT_INFO_IT ( Server,  Temple, AccountID, Name, Class, TotalScore, KillCount, RelicsGivenCount, Experience, isWinner, PlayCount ) VALUES (
				@Server,
				@Temple,
				@AccountID,
				@Name,
				@Class,
				@TotalScore,
				@KillCount,
				@RelicsGivenCount,
				@Experience,
				@isWinner,
				1
			)
		End


	IF(@@Error <> 0 )
		ROLLBACK TRANSACTION
	ELSE	
		COMMIT TRANSACTION

	SET NOCOUNT OFF	
End

GO
/****** Object:  StoredProcedure [dbo].[SP_POINT_ACCUMULATION]    Script Date: 04/04/2014 22:03:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE	[dbo].[SP_POINT_ACCUMULATION]

	@Server		smallint,
	@Square		tinyint,
	@AccountID		varchar(10),
	@CharacterName	varchar(10),
	@Class			tinyint,
	@Point			int
AS
BEGIN	
	BEGIN TRANSACTION
	
	SET NOCOUNT ON	

	IF EXISTS (SELECT CharacterName FROM EVENT_INFO  WITH (READUNCOMMITTED) 
				WHERE  Server = @Server AND AccountID = @AccountID AND CharacterName = @CharacterName)
		BEGIN	
			UPDATE EVENT_INFO
			SET Point = Point + @Point , Square = @Square 										
			WHERE  Server = @Server  AND AccountID = @AccountID AND CharacterName = @CharacterName		
		END
	ELSE
		BEGIN
			INSERT INTO EVENT_INFO (Server, Square, AccountID, CharacterName, Class, Point) VALUES (
				@Server,
				@Square,
				@AccountID,
				@CharacterName,
				@Class,
				@Point	
			)	
		END

	IF(@@Error <> 0 )
		ROLLBACK TRANSACTION
	ELSE	
		COMMIT TRANSACTION

	SET NOCOUNT OFF	
END



GO
/****** Object:  StoredProcedure [dbo].[USP_BloodCastle5_Ranking]    Script Date: 04/04/2014 22:03:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USP_BloodCastle5_Ranking]

	@BridgeSearch	tinyint
AS

SET NOCOUNT ON

	SELECT TOP 50  T1.CharacterName, T1.Server, 0 AS Point, MAX(T1.MinLeftTime) as MinLeftTime, T1.Bridge, 

	(SELECT TOP 1 T2.AlivePartyCount FROM EVENT_INFO_BC_5TH T2 WHERE T1.CharacterName = T2.CharacterName AND T1.Server = T2.Server 
	 AND T1.Bridge = T2.Bridge AND T1.AccountID = T2.AccountID AND T2.AlivePartyCount >= 5 ORDER BY T2.MinLeftTime DESC) AS AlivePartyCount,

	(SELECT TOP 1 Convert(char(8),T3.RegDate,112) FROM EVENT_INFO_BC_5TH T3 WHERE T1.CharacterName = T3.CharacterName AND T1.Server = T3.Server 
	 AND T1.Bridge = T3.Bridge AND T1.AccountID = T3.AccountID AND T3.AlivePartyCount >= 5 ORDER BY T3.MinLeftTime DESC, T3.RegDate) AS RegDate
	FROM EVENT_INFO_BC_5TH  T1 WHERE AlivePartyCount > 4 AND T1.Server <> 13 

	GROUP BY T1.CharacterName,T1.Server, T1.Bridge,T1.AccountID
	Having  T1.Bridge = @BridgeSearch

	ORDER BY AlivePartyCount DESC, MinLeftTime DESC, RegDate, T1.Server
			
SET NOCOUNT OFF



GO
/****** Object:  Table [dbo].[EVENT_INFO]    Script Date: 04/04/2014 22:03:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EVENT_INFO](
	[Server] [smallint] NOT NULL,
	[Square] [tinyint] NOT NULL,
	[AccountID] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CharacterName] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Class] [tinyint] NOT NULL,
	[Point] [int] NOT NULL,
 CONSTRAINT [PK_EVENT_INFO] PRIMARY KEY CLUSTERED 
(
	[Server] ASC,
	[Square] ASC,
	[AccountID] ASC,
	[CharacterName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[EVENT_INFO_BC]    Script Date: 04/04/2014 22:03:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EVENT_INFO_BC](
	[Server] [smallint] NOT NULL,
	[Bridge] [tinyint] NOT NULL,
	[AccountID] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CharacterName] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Class] [tinyint] NOT NULL,
	[Point] [int] NOT NULL,
	[PlayCount] [int] NOT NULL,
 CONSTRAINT [PK_EVENT_INFO_BC] PRIMARY KEY CLUSTERED 
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
/****** Object:  Table [dbo].[EVENT_INFO_BC_3RD]    Script Date: 04/04/2014 22:03:19 ******/
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
/****** Object:  Table [dbo].[EVENT_INFO_BC_4TH]    Script Date: 04/04/2014 22:03:19 ******/
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
/****** Object:  Table [dbo].[EVENT_INFO_BC_5TH]    Script Date: 04/04/2014 22:03:19 ******/
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
/****** Object:  Table [dbo].[EVENT_INFO_CC]    Script Date: 04/04/2014 22:03:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EVENT_INFO_CC](
	[Server] [tinyint] NOT NULL,
	[Castle] [tinyint] NOT NULL,
	[AccountID] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Name] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Class] [int] NULL,
	[PKillCount] [int] NULL,
	[MKillCount] [int] NULL,
	[Experience] [bigint] NULL,
	[Wins] [int] NULL,
 CONSTRAINT [PK_EVENT_INFO_CC] PRIMARY KEY CLUSTERED 
(
	[Server] ASC,
	[Castle] ASC,
	[AccountID] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[EVENT_INFO_IT]    Script Date: 04/04/2014 22:03:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EVENT_INFO_IT](
	[Server] [tinyint] NOT NULL,
	[Temple] [tinyint] NOT NULL,
	[AccountID] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Name] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TotalScore] [int] NULL,
	[KillCount] [int] NULL,
	[RelicsGivenCount] [int] NULL,
	[Experience] [bigint] NULL,
	[isWinner] [tinyint] NULL,
	[PlayCount] [smallint] NOT NULL,
	[Class] [int] NULL,
 CONSTRAINT [PK_EVENT_INFO_IT] PRIMARY KEY CLUSTERED 
(
	[Server] ASC,
	[Temple] ASC,
	[AccountID] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_BC_PCROOM_PLAYCOUNT]    Script Date: 04/04/2014 22:03:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_BC_PCROOM_PLAYCOUNT](
	[PCROOM_GUID] [int] NOT NULL,
	[AccountID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PlayCount] [int] NOT NULL,
	[Point] [int] NOT NULL,
 CONSTRAINT [PK_T_BC_PCROOM_PLAYCOUNT] PRIMARY KEY CLUSTERED 
(
	[PCROOM_GUID] ASC,
	[AccountID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_ENTER_CHECK_BC]    Script Date: 04/04/2014 22:03:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_ENTER_CHECK_BC](
	[AccountID] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CharName] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ServerCode] [smallint] NOT NULL,
	[ToDayEnterCount] [tinyint] NOT NULL,
	[LastEnterDate] [smalldatetime] NOT NULL,
 CONSTRAINT [PK_T_ENTER_CHECK_DS] PRIMARY KEY CLUSTERED 
(
	[AccountID] ASC,
	[CharName] ASC,
	[ServerCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_ENTER_CHECK_ILLUSION_TEMPLE]    Script Date: 04/04/2014 22:03:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_ENTER_CHECK_ILLUSION_TEMPLE](
	[AccountID] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CharName] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ServerCode] [tinyint] NOT NULL,
	[TodayEnterCount] [tinyint] NOT NULL,
	[LastEnterDate] [smalldatetime] NOT NULL,
 CONSTRAINT [PK_T_ENTER_CHECK_ILLUSION_TEMPLE] PRIMARY KEY CLUSTERED 
(
	[AccountID] ASC,
	[CharName] ASC,
	[ServerCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[EVENT_INFO_BC] ADD  CONSTRAINT [DF_EVENT_INFO_BC_PlayCount]  DEFAULT ((1)) FOR [PlayCount]
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
ALTER TABLE [dbo].[EVENT_INFO_IT] ADD  CONSTRAINT [DF_EVENT_INFO_IT_PlayCount]  DEFAULT ((0)) FOR [PlayCount]
GO
ALTER TABLE [dbo].[T_BC_PCROOM_PLAYCOUNT] ADD  CONSTRAINT [DF_T_BC_PCROOM_PLAYCOUNT_PlayCount]  DEFAULT ((1)) FOR [PlayCount]
GO
ALTER TABLE [dbo].[T_BC_PCROOM_PLAYCOUNT] ADD  CONSTRAINT [DF_T_BC_PCROOM_PLAYCOUNT_Point]  DEFAULT ((0)) FOR [Point]
GO
ALTER TABLE [dbo].[T_ENTER_CHECK_BC] ADD  CONSTRAINT [DF_T_ENTER_CHECK_DS_ToDayEnterCheck]  DEFAULT ((0)) FOR [ToDayEnterCount]
GO
ALTER TABLE [dbo].[T_ENTER_CHECK_BC] ADD  CONSTRAINT [DF_T_ENTER_CHECK_BC_LastEnterDate]  DEFAULT (getdate()) FOR [LastEnterDate]
GO
ALTER TABLE [dbo].[T_ENTER_CHECK_ILLUSION_TEMPLE] ADD  CONSTRAINT [DF_T_ENTER_CHECK_ILLUSION_TEMPLE_LastEnterDate]  DEFAULT (getdate()) FOR [LastEnterDate]
GO
