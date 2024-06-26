﻿using System.Data.SqlClient;
using ACL.Synchronizers.Product.Models;
using Dapper;

namespace ACL.Synchronizers.Product.Repositories;

internal class LegacyProductRepository
{
    private const string TempTable = "#products_to_sync";
    private readonly SqlConnection _connection;
    private readonly SqlTransaction _transaction;

    public LegacyProductRepository(SqlConnection connection, SqlTransaction transaction)
    {
        _connection = connection;
        _transaction = transaction;
    }

    public List<ProductInLegacy> GetAllThatNeedSync()
    {
        string query =
            @$"
            select NMB_CM, NM_CLM, WT, WT_KG 
            into {TempTable}
            from [dbo].[PRD_TBL]
            where IsSyncNeeded = 1
            
            select *
            from {TempTable}";

        return _connection.Query<ProductInLegacy>(query, transaction: _transaction).ToList();
    }

    public void SetSyncFlagFalseForQueriedProducts()
    {
        string query =
            @$"
            update p
            set p.IsSyncNeeded = 0
            from [dbo].[PRD_TBL] p
            inner join {TempTable} t 
            on p.NMB_CM = t.NMB_CM";

        _connection.Execute(query, new { TempTable }, transaction: _transaction);
    }
}
