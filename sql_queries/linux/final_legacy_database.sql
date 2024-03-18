IF EXISTS (SELECT * FROM sys.databases WHERE name = 'PackageDelivery')
BEGIN
    ALTER DATABASE PackageDelivery SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE PackageDelivery;
END
GO

CREATE DATABASE PackageDelivery;
GO

USE PackageDelivery;
GO

create table ADDR_TBL
(
    ID_CLM int identity
        constraint PK_ADDR_TBL
            primary key,
    STR    char(300),
    CT_ST  char(200),
    ZP     char(5),
    DLVR   int
)
go

create trigger [dbo].[DeliverySync] on [dbo].[ADDR_TBL]
after update, insert
as
begin
    if (update(STR) or update(CT_ST) or update(ZP) or update(DLVR))
    begin
        update DLVR_TBL
        set is_sync_needed = 1
        where NMB_CLM in (select DLVR from inserted)

        update Sync
        set is_sync_required = 1
        where Name = 'Delivery'
    end
end
go

create table DLVR_TBL
(
    NMB_CLM        int identity
        constraint PK_DLVR_TBL
            primary key,
    CSTM           int,
    STS            char,
    ESTM_CLM       float,
    PRD_LN_1       int,
    PRD_LN_1_AMN   char(2),
    PRD_LN_2       int,
    PRD_LN_2_AMN   char(2),
    is_sync_needed bit default 0 not null
)
go

create table DLVR_TBL2
(
    NMB_CLM      int not null
        constraint PK_DLVR_TBL2
            primary key,
    PRD_LN_3     int,
    PRD_LN_3_AMN char(2),
    PRD_LN_4     int,
    PRD_LN_4_AMN char(2)
)
go

create table PRD_TBL
(
    NMB_CM         int identity,
    NM_CLM         char(100),
    DSC_CLM        char(500),
    WT             float,
    WT_KG          float,
    is_sync_needed bit default 0 not null
)
go

CREATE trigger [dbo].[ProductSync] on [dbo].[PRD_TBL]
after update, insert
as
begin
	set nocount on;

	if (update(NM_CLM) or update(WT) or update(WT_KG))
	begin
		update [dbo].[PRD_TBL]
		set	is_sync_needed = 1
		where NMB_CM in (select NMB_CM from inserted)

		update [dbo].[Sync]
		set	is_sync_required = 1
		where Name = 'Product'
	end
end
go

create table P_TBL
(
    NMB_CLM int identity
        constraint PK_P_TBL
            primary key,
    NM_CLM  char(100),
    ADDR1   int,
    ADDR2   int
)
go

create table outbox
(
    id      int identity
        primary key,
    content nvarchar(max) not null
        check (isjson([content]) = 1),
    type    nvarchar(100) not null
)
go

create table sync
(
    name             nvarchar(50)  not null
        primary key,
    is_sync_required bit default 0 not null,
    row_version      timestamp     not null
)
go

insert into sync (name) values ('Delivery'), ('Product')

SET IDENTITY_INSERT PackageDelivery.dbo.DLVR_TBL ON;

INSERT INTO PackageDelivery.dbo.DLVR_TBL (NMB_CLM, CSTM, STS, ESTM_CLM, PRD_LN_1, PRD_LN_1_AMN, PRD_LN_2, PRD_LN_2_AMN, is_sync_needed) VALUES (20, 1, N'R', 120.2, 3, N'2 ', null, null, 0);
INSERT INTO PackageDelivery.dbo.DLVR_TBL (NMB_CLM, CSTM, STS, ESTM_CLM, PRD_LN_1, PRD_LN_1_AMN, PRD_LN_2, PRD_LN_2_AMN, is_sync_needed) VALUES (24, 2, N'N', 60.8, 5, N'2 ', null, null, 0);
INSERT INTO PackageDelivery.dbo.DLVR_TBL (NMB_CLM, CSTM, STS, ESTM_CLM, PRD_LN_1, PRD_LN_1_AMN, PRD_LN_2, PRD_LN_2_AMN, is_sync_needed) VALUES (25, 3, N'N', 60.8, 5, N'2 ', null, null, 0);

SET IDENTITY_INSERT PackageDelivery.dbo.DLVR_TBL OFF;

SET IDENTITY_INSERT PackageDelivery.dbo.ADDR_TBL ON;

INSERT INTO PackageDelivery.dbo.ADDR_TBL (ID_CLM, STR, CT_ST, ZP, DLVR) VALUES (1, N'1234 Main St                                                                                                                                                                                                                                                                                                ', N'Washington DC                                                                                                                                                                                           ', N'22200', null);
INSERT INTO PackageDelivery.dbo.ADDR_TBL (ID_CLM, STR, CT_ST, ZP, DLVR) VALUES (2, N'2345 2nd St                                                                                                                                                                                                                                                                                                 ', N'Washington DC                                                                                                                                                                                           ', N'22201', null);
INSERT INTO PackageDelivery.dbo.ADDR_TBL (ID_CLM, STR, CT_ST, ZP, DLVR) VALUES (3, N'8338 3rd St                                                                                                                                                                                                                                                                                                 ', N'Arlington VA                                                                                                                                                                                            ', N'22202', null);
INSERT INTO PackageDelivery.dbo.ADDR_TBL (ID_CLM, STR, CT_ST, ZP, DLVR) VALUES (11, N'1234 Main St                                                                                                                                                                                                                                                                                                ', N'Washington DC                                                                                                                                                                                           ', N'22200', 8);
INSERT INTO PackageDelivery.dbo.ADDR_TBL (ID_CLM, STR, CT_ST, ZP, DLVR) VALUES (12, N'1321 S Eads St                                                                                                                                                                                                                                                                                              ', N'Arlingron VA                                                                                                                                                                                            ', N'22202', 9);
INSERT INTO PackageDelivery.dbo.ADDR_TBL (ID_CLM, STR, CT_ST, ZP, DLVR) VALUES (13, N'Hello Word                                                                                                                                                                                                                                                                                                  ', N'Mat ebal                                                                                                                                                                                                ', N'22200', 10);
INSERT INTO PackageDelivery.dbo.ADDR_TBL (ID_CLM, STR, CT_ST, ZP, DLVR) VALUES (14, N'Hello word                                                                                                                                                                                                                                                                                                  ', N'This is my city                                                                                                                                                                                         ', N'12312', 11);
INSERT INTO PackageDelivery.dbo.ADDR_TBL (ID_CLM, STR, CT_ST, ZP, DLVR) VALUES (15, N'Mini soft                                                                                                                                                                                                                                                                                                   ', N'LA CA                                                                                                                                                                                                   ', N'1234 ', 12);
INSERT INTO PackageDelivery.dbo.ADDR_TBL (ID_CLM, STR, CT_ST, ZP, DLVR) VALUES (16, N'Mini Soft 12345                                                                                                                                                                                                                                                                                             ', N'Tatarstan Astana                                                                                                                                                                                        ', N'12345', 13);
INSERT INTO PackageDelivery.dbo.ADDR_TBL (ID_CLM, STR, CT_ST, ZP, DLVR) VALUES (17, N'My Address                                                                                                                                                                                                                                                                                                  ', N'California love                                                                                                                                                                                         ', N'1234 ', 14);
INSERT INTO PackageDelivery.dbo.ADDR_TBL (ID_CLM, STR, CT_ST, ZP, DLVR) VALUES (18, N'Redmond, Somewhere in the US                                                                                                                                                                                                                                                                                ', N'City State                                                                                                                                                                                              ', N'82139', 15);
INSERT INTO PackageDelivery.dbo.ADDR_TBL (ID_CLM, STR, CT_ST, ZP, DLVR) VALUES (19, N'aarstarstarst                                                                                                                                                                                                                                                                                               ', N'a b                                                                                                                                                                                                     ', N'12341', 16);
INSERT INTO PackageDelivery.dbo.ADDR_TBL (ID_CLM, STR, CT_ST, ZP, DLVR) VALUES (20, N'Work it make it do it makes us                                                                                                                                                                                                                                                                              ', N'Harder better faster stronger                                                                                                                                                                           ', N'12345', 17);
INSERT INTO PackageDelivery.dbo.ADDR_TBL (ID_CLM, STR, CT_ST, ZP, DLVR) VALUES (21, N'Now now now now that don''t kill                                                                                                                                                                                                                                                                             ', N'Can only make me stronger                                                                                                                                                                               ', N'12345', 18);
INSERT INTO PackageDelivery.dbo.ADDR_TBL (ID_CLM, STR, CT_ST, ZP, DLVR) VALUES (22, N'Kwik e-wat???                                                                                                                                                                                                                                                                                               ', N'Dagestand Brotishka                                                                                                                                                                                     ', N'13245', 19);
INSERT INTO PackageDelivery.dbo.ADDR_TBL (ID_CLM, STR, CT_ST, ZP, DLVR) VALUES (23, N'Mini Sota                                                                                                                                                                                                                                                                                                   ', N'Makro sota                                                                                                                                                                                              ', N'12345', 20);
INSERT INTO PackageDelivery.dbo.ADDR_TBL (ID_CLM, STR, CT_ST, ZP, DLVR) VALUES (24, N'Kwik e-wattt??                                                                                                                                                                                                                                                                                              ', N'Urzik istan                                                                                                                                                                                             ', N'12345', 21);
INSERT INTO PackageDelivery.dbo.ADDR_TBL (ID_CLM, STR, CT_ST, ZP, DLVR) VALUES (25, N'NE macro soft but apple                                                                                                                                                                                                                                                                                     ', N'Where is apple                                                                                                                                                                                          ', N'12345', 22);
INSERT INTO PackageDelivery.dbo.ADDR_TBL (ID_CLM, STR, CT_ST, ZP, DLVR) VALUES (26, N'I pull up and say shit                                                                                                                                                                                                                                                                                      ', N'Gotabraclet onmynecklace                                                                                                                                                                                ', N'12345', 23);
INSERT INTO PackageDelivery.dbo.ADDR_TBL (ID_CLM, STR, CT_ST, ZP, DLVR) VALUES (27, N'No akazalus suck diknula                                                                                                                                                                                                                                                                                    ', N'zhosko ya saknula                                                                                                                                                                                       ', N'12345', 24);
INSERT INTO PackageDelivery.dbo.ADDR_TBL (ID_CLM, STR, CT_ST, ZP, DLVR) VALUES (28, N'Ya chorni                                                                                                                                                                                                                                                                                                   ', N'Dagestan Astana                                                                                                                                                                                         ', N'1345 ', 25);

SET IDENTITY_INSERT PackageDelivery.dbo.ADDR_TBL OFF;

insert into dbo.DLVR_TBL2 (NMB_CLM, PRD_LN_3, PRD_LN_3_AMN, PRD_LN_4, PRD_LN_4_AMN)
values  (20, null, null, null, null),
        (24, null, null, null, null),
        (25, null, null, null, null);

SET IDENTITY_INSERT PackageDelivery.dbo.P_TBL ON;

insert into dbo.P_TBL (NMB_CLM, NM_CLM, ADDR1, ADDR2)
values  (1, N'Macro Soft                                                                                          ', 1, null),
        (2, N'Devices for Everyone                                                                                ', 2, null),
        (3, N'Kwik-E-Mart                                                                                         ', 3, null);

SET IDENTITY_INSERT PackageDelivery.dbo.P_TBL OFF;

SET IDENTITY_INSERT PackageDelivery.dbo.PRD_TBL ON;

insert into dbo.PRD_TBL (NMB_CM, NM_CLM, DSC_CLM, WT, WT_KG, is_sync_needed)
values  (1, N'Best Pizza Ever                                                                                     ', N'Your favorite cheese pizza made with classic marinara sauce topped with mozzarella cheese.                                                                                                                                                                                                                                                                                                                                                                                                                          ', 2, null, 0),
        (2, N'myPhone                                                                                             ', null, null, 0.5, 0),
        (3, N'Couch                                                                                               ', N'Made with a sturdy wood frame and upholstered in touchable and classic linen, this fold-down futon provides a stylish seating solution along with an extra space for overnight guests.                                                                                                                                                                                                                                                                                                                              ', 83.5, null, 0),
        (4, N'TV Set                                                                                              ', null, null, 7, 0),
        (5, N'Fridge                                                                                              ', null, null, 34, 0);

SET IDENTITY_INSERT PackageDelivery.dbo.PRD_TBL OFF;